addpath('/lib/')
addpath('/lib/matching_cube/')
% get point cloud from each pair of images
parfor i = 751:754
    testHouse(i, i+1);
end
% merge PCD
out = [];
for i = 751:754
   M = dlmread(['output/house_pc_' num2str(i) '_' num2str(i+1) '.txt']);
   out = vertcat(out, M);
end
dlmwrite(['./output/house_pc_merge_raw.txt'],out,'delimiter',' ','roffset',0);
% denoise
[ out ] = denoiseByDensity( out, 50, 0.7);
dlmwrite(['./output/house_pc_merge_denoised.txt'],out,'delimiter',' ','roffset',0);
% surface Reconstruction
surf_recon(256, 64);