import cv2
import dlib
import numpy as np

## Face detection by dlib detector
# Param     image: image open by cv2.imread
#           times: times of upsample 
# Returns   faces: rectangle coordinates of faces
def face_detection(image, times = 1):
    if image is None:
        return None
    detector = dlib.get_frontal_face_detector()
    faces = detector(image, times)
    return faces

## Face-keypoints(68) detection by dlib predictor
# Param     image: image open by cv2.imread
#           face: rectangle coordinates of face
# Returns   coords: 2-tuple of keypoints coordinates 
def keypoints_detection(image, face:dlib.rectangle):
    PREDICTOR_PATH = './model/shape_predictor_68_face_landmarks.dat'
    predictor = dlib.shape_predictor(PREDICTOR_PATH)
    keypoints = predictor(image, face)
    coords = np.asarray(list([p.x, p.y] for p in keypoints.parts()), dtype = np.int)
    return coords

## Face Selection
# Param     image: image open by cv2.imread
#           mode: 'MAX' means choose max face only
#                 'ONE' means choose one manually
#           r: a integer to adjust the size of selected face  
# Returns   relative_coords: relative coordinates of 68 keypoints
#           image_shape: (x, y ,width, height) of face in image
#           face_image: sub-image of face
def face_selection(image, mode = 'MAX', r = 10):
    faces = face_detection(image)
    if faces is None:
        return None, None, None
    if len(faces) == 0:
        return None, None, None
    elif len(faces) == 1 or mode == 'MAX':
        face_rectangle = faces[np.argmax([(face.bottom() - face.top())*(face.right() - face.left()) for face in faces])]
    elif mode == 'ONE':
        face_rectangle = []
        image_replica = image.copy()

        def click_on_face(event, x, y, flags, params):
            if event != cv2.EVENT_LBUTTONDOWN:
                return

            for face in faces:
                if face.left() < x < face.right() and face.top() < y < face.bottom():
                    face_rectangle.append(face)
                    break

        for face in faces:
            cv2.rectangle(image_replica, (face.left(), face.top()), (face.right(), face.bottom()), (255, 0, 0), 2)

        cv2.imshow('Click the Face:', image_replica)
        cv2.setMouseCallback('Click the Face:', click_on_face)
        while len(face_rectangle) == 0:
            cv2.waitKey(1)
        cv2.destroyAllWindows()
        face_rectangle = face_rectangle[0]

    coords = keypoints_detection(image, face_rectangle)
    coords = np.asarray(coords)
    left, top = np.min(coords, 0)
    right, bottom = np.max(coords, 0)
    x, y = max(0, left - r), max(0, top - r)
    w = min(right + r, image.shape[1]) - x
    h = min(bottom + r, image.shape[0]) - y
 
    relative_coords = coords - np.asarray([[x, y]]) 
    image_shape = (x, y, w, h)
    face_image = image[y:y + h, x:x + w]
    return relative_coords, image_shape, face_image