const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

/**
 * Triggered whenever a new borewell entry is created.
 * Updates the zone aggregate and generates alerts if threshold crossed.
 */
exports.onBorewellCreated = functions.firestore
  .document("borewells/{borewellId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const zoneId = data.zoneId;
    const depthFt = data.depthFt;
    const yieldVal = data.yield;

    const zoneRef = db.collection("zones").doc(zoneId);

    await db.runTransaction(async (tx) => {
      const zoneSnap = await tx.get(zoneRef);

      if (!zoneSnap.exists) {
        tx.set(zoneRef, {
          zoneName: zoneId,
          center: data.anonymisedLocation,
          avgDepthFt: depthFt,
          totalBorewells: 1,
          criticalCount: depthFt >= 250 ? 1 : 0,
          stressScore: Math.min(depthFt / 500, 1.0),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        const z = zoneSnap.data();
        const total = z.totalBorewells + 1;
        const newAvg = (z.avgDepthFt * (total - 1) + depthFt) / total;
        const critCount =
          z.criticalCount + (depthFt >= 250 ? 1 : 0);

        tx.update(zoneRef, {
          avgDepthFt: newAvg,
          totalBorewells: total,
          criticalCount: critCount,
          stressScore: Math.min(newAvg / 500, 1.0),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    // Check if this zone should trigger an alert
    const updatedZone = (await zoneRef.get()).data();
    await _checkAndCreateAlert(zoneId, updatedZone);
  });

async function _checkAndCreateAlert(zoneId, zone) {
  const score = zone.stressScore;
  const avgDepth = zone.avgDepthFt;

  let severity = null;
  let title = null;
  let message = null;

  if (avgDepth >= 250 && zone.criticalCount >= 3) {
    severity = "critical";
    title = `Critical: ${zone.zoneName}`;
    message = `Water table in ${zone.zoneName} has reached ${Math.round(avgDepth)} ft average depth. ` +
      `${zone.criticalCount} borewells are now in the critical range. Immediate recharge action needed.`;
  } else if (avgDepth >= 150) {
    severity = "warning";
    title = `Water stress: ${zone.zoneName}`;
    message = `Average borewell depth in ${zone.zoneName} is now ${Math.round(avgDepth)} ft. ` +
      `Consider starting recharge activities before the dry season.`;
  }

  if (severity) {
    // Avoid duplicate alerts within 24h for same zone + severity
    const recent = await db.collection("alerts")
      .where("zoneId", "==", zoneId)
      .where("severity", "==", severity)
      .where("createdAt", ">=", new Date(Date.now() - 86400000))
      .limit(1)
      .get();

    if (recent.empty) {
      await db.collection("alerts").add({
        zoneId,
        zoneName: zone.zoneName,
        severity,
        title,
        message,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      });

      // Send FCM topic notification
      await admin.messaging().send({
        topic: `zone_${zoneId}`,
        notification: { title, body: message },
        data: { zoneId, severity },
      });
    }
  }
}

/**
 * Scheduled: runs every Monday 8am IST to generate weekly summaries.
 */
exports.weeklyWaterReport = functions.pubsub
  .schedule("0 8 * * 1")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const zonesSnap = await db.collection("zones").get();
    const critical = zonesSnap.docs.filter(
      (d) => d.data().stressScore > 0.6
    );

    if (critical.length > 0) {
      await admin.messaging().send({
        topic: "all_users",
        notification: {
          title: "Weekly water report",
          body: `${critical.length} zones are under water stress this week. Check the map for details.`,
        },
      });
    }
  });
