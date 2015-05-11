function [ leftI, rightI, leftE, rightE, left_angle_matrix, right_angle_matrix ] = getEdgeGrad( leftI, rightI )
Ix = conv2(rgb2gray(leftI), [-1 0 1; -2 0 2; -1 0 1]);
Ix = Ix(3:size(Ix,1)-2,3:size(Ix,2)-2);
Ix = padarray(Ix,[1 1]);
Iy = conv2(rgb2gray(leftI), [1 2 1; 0 0 0; -1 -2 -1]);
Iy = Iy(3:size(Iy,1)-2,3:size(Iy,2)-2);
Iy = padarray(Iy,[1 1]);

leftE = sqrt(Ix.^2 + Iy.^2);

Ix = conv2(rgb2gray(rightI), [-1 0 1; -2 0 2; -1 0 1]);
Ix = Ix(3:size(Ix,1)-2,3:size(Ix,2)-2);
Ix = padarray(Ix,[1 1]);
Iy = conv2(rgb2gray(rightI), [1 2 1; 0 0 0; -1 -2 -1]);
Iy = Iy(3:size(Iy,1)-2,3:size(Iy,2)-2);
Iy = padarray(Iy,[1 1]);
rightE = sqrt(Ix.^2 + Iy.^2);

Ix = conv2(rgb2gray(leftI), [-1 0 1; -2 0 2; -1 0 1]);
Ix = Ix(3:size(Ix,1)-2,3:size(Ix,2)-2);
Ix = padarray(Ix,[1 1]);
Iy = conv2(rgb2gray(leftI), [1 2 1; 0 0 0; -1 -2 -1]);
Iy = Iy(3:size(Iy,1)-2,3:size(Iy,2)-2);
Iy = padarray(Iy,[1 1]);

left_angle_matrix = atan2d(Iy, Ix);

Ix = conv2(rgb2gray(rightI), [-1 0 1; -2 0 2; -1 0 1]);
Ix = Ix(3:size(Ix,1)-2,3:size(Ix,2)-2);
Ix = padarray(Ix,[1 1]);

Iy = conv2(rgb2gray(rightI), [1 2 1; 0 0 0; -1 -2 -1]);
Iy = Iy(3:size(Iy,1)-2,3:size(Iy,2)-2);
Iy = padarray(Iy,[1 1]);

right_angle_matrix = atan2d(Iy, Ix);


end

