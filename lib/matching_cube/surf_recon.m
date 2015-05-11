function [] = surf_recon(resXY, resZ)
global res;
res = resXY;
global resz;
resz = resZ;
loadParam;
global iso_level
iso_level = 0;
% poolobj = gcp;
% addAttachedFiles(poolobj,'loadParam.m');
[ grid ] = getGridCube( M_N, thresh, res, resz);
save(['../../output/grid_' num2str(resXY) '.mat'], 'grid');

p_cloud_list = cell(res-2, res-2, resz-2);
parfor x = 1:res-2
    for y = 1:res-2
        for z = 1:resz-2
            index3D = [x+1 y+1 z+1];% 1 based
            %             disp('start nn')
            leafNode = getNeighborList1D(index3D, grid, res, resz);
            %             disp('start cc')
            temp =  createSurface(leafNode, index3D, iso_level,minX,maxX,minY,maxY,minZ,maxZ, res, resz);
            p_cloud_list{x, y, z} = temp;
        end
    end
    disp(['creating surface ' num2str(x/res*100) '%'])
end
p_cloud = zeros(size(M_N,1),6); counter = 1;
for x = 1:res-2
    for y = 1:res-2
        for z = 1:resz-2
            temp = p_cloud_list{x, y, z};
            if size(temp,1) ~= 0
                p_cloud(counter:counter + size(temp, 1)-1,:) = temp;
                counter = counter + size(temp, 1);
            end
        end
    end
    
end

endindex = find(p_cloud(:, 1) ~= 0);
endindex = endindex(end);
p_cloud = p_cloud(1:endindex,:);
p_cloud(:, 4:6) = round(p_cloud(:, 4:6));

polygons = zeros(floor(size(p_cloud, 1)/3), 3);
for i = 0:size(polygons, 1)-1
    for j = 0:2
        polygons(i+1, j+1) = i*3+j;
    end
end
p_cloud = [p_cloud 255*ones(size(p_cloud,1),1)];
temp = [repmat(3, [size(polygons, 1) 1]) polygons];
dlmwrite(['../../output/dart_nodes_res' num2str(resXY) '.txt'],p_cloud,'delimiter',' ','roffset',0, 'precision', 10);
dlmwrite(['../../output/dart_elements_res' num2str(resXY) '.txt'],temp,'delimiter',' ','roffset',0, 'precision', 10);

polygons = polygons + 1;
dlmwrite('../../output/dart_nodes.txt',p_cloud,'delimiter',' ','roffset',0);
dlmwrite('../../output/dart_elements.txt',polygons,'delimiter',' ','roffset',0);
tri_surface_to_ply ( '/./../output/dart' )
end
