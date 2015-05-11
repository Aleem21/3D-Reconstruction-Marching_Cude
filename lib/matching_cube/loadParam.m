M_N = dlmread('../../output/house_pc_merge_denoised.txt');
global minX;
global maxX;
global minY;
global maxY;
global minZ;
global maxZ;
global thresh;

minX = min(M_N(:, 1));
maxX = max(M_N(:, 1));
minY = min(M_N(:, 2));
maxY = max(M_N(:, 2));
minZ = min(M_N(:, 3));
maxZ = max(M_N(:, 3));
thresh = 1.5*max([maxX-minX maxY-minY maxZ-minZ]) / res;




