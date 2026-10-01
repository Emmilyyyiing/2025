import cv2
import numpy as np
import matplotlib.pyplot as plt

K = np.array([[718.8560, 0, 607.1928],
              [0, 718.8560, 185.2157],
              [0, 0, 1]])

K_inv = np.linalg.inv(K)


def feature_detection(img):
    """Detect good features to track using Shi-Tomasi."""
    return cv2.goodFeaturesToTrack(
        img,
        maxCorners=2000,
        qualityLevel=0.01,
        minDistance=7,
        blockSize=7
    )

def feature_tracking(old_img, new_img, old_points):
    """Track points using Lucas–Kanade optical flow."""
    new_points, status, _ = cv2.calcOpticalFlowPyrLK(
        old_img, new_img, old_points, None
    )
    

    good_old = old_points[status == 1]
    good_new = new_points[status == 1]
    
    return good_old.reshape(-1,1,2), good_new.reshape(-1,1,2)

video_path = "video (1).mp4"
cap = cv2.VideoCapture(video_path)

ret, old_frame = cap.read()
if not ret:
    print("Could not read video.")
    exit()

old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
p0 = feature_detection(old_gray)

R_total = np.eye(3)
t_total = np.zeros((3,1))
trajectory = []
frame_idx = 0

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    

    p0, p1 = feature_tracking(old_gray, frame_gray, p0)


    E, mask = cv2.findEssentialMat(
        p1, p0, K, method=cv2.RANSAC, prob=0.999, threshold=1.0
    )


    _, R, t, mask_pose = cv2.recoverPose(E, p1, p0, K)


    t_total += R_total.dot(t)
    R_total = R.dot(R_total)

 
    trajectory.append((t_total[0][0], t_total[2][0]))


    old_gray = frame_gray.copy()
    p0 = p1.reshape(-1,1,2)


    if len(p0) < 1000:
        p0 = feature_detection(old_gray)

    frame_idx += 1
    print(f"Processed frame {frame_idx}", end="\r")


cap.release()


traj = np.array(trajectory)

plt.figure(figsize=(8,8))
plt.plot(traj[:,0], traj[:,1], '-b')
plt.scatter(traj[-1,0], traj[-1,1], c='red', label="Final Position")
plt.title("2D Visual Odometry Map")
plt.xlabel("X position")
plt.ylabel("Z position")
plt.legend()
plt.grid(True)
plt.show()
