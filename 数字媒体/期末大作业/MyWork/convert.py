import cv2
import numpy as np
import scipy.spatial as spatial
import logging

## Grid coordination of specific points
# Param     points: specific points array
# Return    gird: the grid behind the points
def grid_coordination(points): 
    x_min, x_max = np.min(points[:, 0]), np.max(points[:, 0]) + 1
    y_min, y_max = np.min(points[:, 1]), np.max(points[:, 1]) + 1
   
    gird = np.asarray([(x, y) for y in range(y_min, y_max) for x in range(x_min, x_max)], np.uint32)
    return gird

## Bilinear interpolate to image
# Param     image: image open by cv2.imread
#           coords: 2-tuple of keypoints coordinates 
# Return    pixel_in: image after interpolation
def bilinear_interpolation(image, coords):
    coords_floor = np.int32(coords)
    x, y = coords_floor
    dx, dy = coords - coords_floor
    
    pixel_lt, pixel_lb = image[y, x], image[y, x + 1]
    pixel_rt, pixel_rb = image[y + 1, x], image[y + 1, x + 1]
    
    pixel_t = pixel_lt.T * (1 - dx) + pixel_rt.T * dx
    pixel_b = pixel_lb.T * (1 - dx) + pixel_rb.T * dx
    
    pixel_in = (pixel_t * (1 - dy) + pixel_b * dy).T
    return pixel_in

## Calculate the affine transformation matrix for each triangle (x,y) vertex from dst_points to src_points
# Param     vertices: array of triplet indices to corners of triangle
#           src_points: array of [x, y] points to landmarks for source image
#           dst_points: array of [x, y] points to landmarks for destination image
# Return    2 x 3 affine matrix transformation for a triangle
def triangular_affine_matrices(vertices, src_points, dst_points):
    ones = [1, 1, 1]
    for tri_indices in vertices:
        src_tri = np.vstack((src_points[tri_indices, :].T, ones))
        dst_tri = np.vstack((dst_points[tri_indices, :].T, ones))
        mat = np.dot(src_tri, np.linalg.inv(dst_tri))[:2, :]
        yield mat


## Calculate affine transformation matrix of points1 and points2
# Param     points1: src_points
#           points2: dst_points
# Return    M: affine transformation matrix
def points_transformation(points1, points2):
    p1 = points1.astype(np.float64)
    p2 = points2.astype(np.float64)

    c1 = np.mean(p1, axis=0)
    c2 = np.mean(p2, axis=0)
    p1 = p1 - c1
    p2 = p2 - c2

    s1 = np.std(p1)
    s2 = np.std(p2)
    p1 = p1/s1
    p2 = p2/s2

    U, S, Vt = np.linalg.svd(np.dot(p1.T, p2))
    R = (np.dot(U, Vt)).T

    a1 = s2 / s1 * R
    a2 = (c2.T - np.dot(a1, c1.T))[:, np.newaxis]
    a3 = np.array([[0., 0., 1.]])
    a4 = np.hstack([a1, a2])
    M = np.vstack([a4, a3])
    return M

## Warping Face to Src-Image 2D
# Param     src_img: source image
#           M: affine transformation matrix
#           dst_shape:  (x, y ,width, height) of face in destination image
#           dtype: data type of result image
# Return    res_img: image after warping
def image_warping_2d(src_img, M, dst_shape, dtype = np.uint8):
    res_img = np.zeros(dst_shape, dtype = dtype)
    dsize = (dst_shape[1], dst_shape[0])
    cv2.warpAffine(src_img, M[:2], dsize, res_img, borderMode = cv2.BORDER_TRANSPARENT, flags = cv2.WARP_INVERSE_MAP)
    return res_img

## Warping Face to Src-Image
# Param     src_img: source image
#           src_points: array of [x, y] points to landmarks for source image
#           dst_points: array of [x, y] points to landmarks for destination image
#           dst_shape:  (x, y ,width, height) of face in destination image
#           dtype: data type of result image
# Return    res_img: image after warping
def image_warping_3d(src_img, src_points, dst_points, dst_shape, dtype = np.uint8):
    rows, cols = dst_shape[:2]
    res_img = np.zeros((rows, cols, 3), dtype = dtype)

    delaunay = spatial.Delaunay(dst_points)
    
    tri_affine_matrices = triangular_affine_matrices(delaunay.simplices, src_points, dst_points)
    tri_affines = np.asarray(list(tri_affine_matrices))

    dst_gird = grid_coordination(dst_points)
    dst_simplex = delaunay.find_simplex(dst_gird)

    for simplex in range(len(delaunay.simplices)):
        coords = dst_gird[dst_simplex == simplex]
        x, y = coords.T

        all_1_vec = np.ones(len(coords))
        dim_2_arr = np.vstack((coords.T, all_1_vec))
        affine_arr = tri_affines[simplex]
        out_coords = np.dot(affine_arr, dim_2_arr)

        res_img[y, x] = bilinear_interpolation(src_img, out_coords)

    return res_img

## Mask generation
# Param     size: the size of the target mask
#           points: 64 facial keypoints
#           erode: erode the mask or not
#           radius: radius of element used for erosion
# Return    mask: the mask of facial keypoints
def mask_generation(points, size, erode = True, radius = 10):
    mask = np.zeros(size, np.uint8)
    convex_hull = cv2.convexHull(points)
    cv2.fillConvexPoly(mask, convex_hull, 255)
    if erode:
        kernel = np.ones((radius, radius), np.uint8)
        mask = cv2.erode(mask, kernel, iterations = 1)
    
    return mask



## Color correction
# Param     src_img: source image
#           des_img: destination image
#           landmarks: landmarks of source image
#           blur_factor: blur factor range from [0,1]
# Return    res_img: destination image after color correction
def color_correction(src_img, dst_img, landmarks, blur_factor = 0.75):
    left_eye = list(range(42, 48))
    right_eye = list(range(36, 42))
    le_mean = np.mean(landmarks[left_eye], axis=0)
    re_mean = np.mean(landmarks[right_eye], axis=0)
    mean = le_mean - re_mean
    norm = np.linalg.norm(mean)

    blur_amount = blur_factor * norm
    blur_amount = int(blur_amount)
    blur_amount += (blur_amount % 2 == 0)
    ksize = (blur_amount, blur_amount)

    src_blur = cv2.GaussianBlur(src_img, (blur_amount, blur_amount), 0)
    dst_blur = cv2.GaussianBlur(dst_img, (blur_amount, blur_amount), 0)

    dst_blur = dst_blur.astype(int)
    dst_blur += 128 * (dst_blur <= 1)
    
    rate = src_blur.astype(np.float64) / dst_blur.astype(np.float64)
    res_img = rate * dst_img.astype(np.float64)
    res_img = np.clip(res_img, 0, 255).astype(np.uint8)
    return res_img


## Face swap: We swap the face destination image into the source face
# Param     src_face: sub-image of face in source image
#           dst_face: sub-image of face in destination image
#           src_points: relative coordinates 68 keypoints of source image
#           dst_points: relative coordinates 68 keypoints of destination image
#           dst_shape: (x, y ,width, height) of face in image
#           dst_img: whole destination image
#           args: correct_color to call color_correction
#           end: we set end to 48 which means we don't change the mouth
# Return    res_img: the image after face swapping
def face_swap(src_face, dst_face, src_points, dst_points, dst_shape, dst_img, warp_3d, correct_color, end = 48):
    if src_face is None or dst_face is None:
        return None

    src_h, src_w = src_face[:2]
    dst_h, dst_w = dst_face.shape[:2]

    if warp_3d:
        warped_src_face = image_warping_3d(src_face, src_points[:end], dst_points[:end], (dst_h, dst_w))
    else:
        M = points_transformation(dst_points, src_points)
        warped_src_face = image_warping_2d(src_face, M, (dst_h, dst_w, 3))

    mask = mask_generation(dst_points, (dst_h, dst_w))
    mask = np.asarray(mask, dtype = np.uint8)

    if correct_color:
        masked_src_face = cv2.bitwise_and(warped_src_face, warped_src_face, mask = mask)
        masked_dst_face = cv2.bitwise_and(dst_face, dst_face, mask = mask)
        warped_src_face = color_correction(masked_dst_face, masked_src_face, dst_points)
        
    kernel = np.ones((10, 10), np.uint8)
    mask = cv2.erode(mask, kernel, iterations = 1)

    mask_frame = cv2.boundingRect(mask)
    center_x = mask_frame[0] + int(mask_frame[2] / 2)
    center_y = mask_frame[1] + int(mask_frame[3] / 2)
    center = ((center_x, center_y))
    mix_face = cv2.seamlessClone(warped_src_face, dst_face, mask, center, cv2.NORMAL_CLONE)

    x, y, w, h = dst_shape
    res_img = dst_img.copy()
    res_img[y:y + h, x:x + w] = mix_face

    return res_img