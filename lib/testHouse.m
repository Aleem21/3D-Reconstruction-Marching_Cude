function [] = testHouse(n1, n2)
addpath('./matching_cube/')
leftI = imread(['../data/lego/Lego Data D90/DSC_0' num2str(n1) '.JPG']);
rightI = imread(['../data/lego/Lego Data D90/DSC_0' num2str(n2) '.JPG']);
%% resize
leftI = imresize(leftI,0.25);
rightI = imresize(rightI, 0.25);
size_org = size(leftI);
%% load p1, p2
load(['../data/lego_proj/p_' num2str(n1) '_' num2str(n2) '.mat'])

%% resize P matrix
rs = [0.5, 0, 0;
    0, 0.5, 0
    0, 0, 1];
P_1 = rs*rs*P_1;
P_2 = rs*rs*P_2;
%% rectify
leftI_org = leftI;
rightI_org = rightI;
[T1,T2,Pn1,Pn2] = rectify(P_1,P_2);
[ leftI, rightI, start ] = warp( T1, leftI, T2, rightI );
%subplot(1,2,1); imshow(leftI); subplot(1,2,2);imshow(rightI);
%% convolve to get edge
temp1 = leftI;
temp2 = rightI;
[ ~, ~, leftE_org, rightE_org, ~, ~ ] = ...
    getEdgeGrad( im2double(leftI_org), im2double(rightI_org) );
[ leftE, rightE, start ] = warp( T1, leftE_org, T2, rightE_org );
[ ~, ~, ~, ~, left_angle_matrix, right_angle_matrix ] = ...
    getEdgeGrad( leftI, rightI );
leftI = im2double(leftI);
rightI = im2double(rightI);
%subplot(1,2,1);imshow(leftE);subplot(1,2,2);imshow(rightE);
%% get disparity
half_window_size = 40;
angle_thresh = 15;
thresh = 400;
edge_thresh = 0.00;
quite = true;
%disparity_map = sparseMatchByNCC(leftI, rightI, [20 20], 200, angle_thresh, edge_thresh, left_angle_matrix, right_angle_matrix, leftE, rightE);
%disparity_map = denseMatchByNCC(leftI, rightI, [40 40], 500);
[ disparity_map ] = sparseMatchByNCC(leftI, rightI, ...
    leftE, rightE, left_angle_matrix, right_angle_matrix,...
    edge_thresh, thresh, angle_thresh, half_window_size, quite, start, size(leftI));
%delete noisy
%disparity_map(disparity_map < 125 | disparity_map > 225) = 0;
% show
% figure
% imshow(disparity_map)
% caxis('auto')
% colorbar
% colormap default
%%
[ txt_matrix ] = getOutputMatrix( leftI, disparity_map, inf , Pn1, Pn2, start);
dlmwrite(['../output/house_pc_' num2str(n1) '_' num2str(n2) '.txt'],txt_matrix,'delimiter',' ','roffset',0);
end