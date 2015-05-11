function [ grid ] = getGridCube( M_N, thresh, res, resz)
%   M_N is the Nx10 matrix with computed norm returned from meshlab
res_x = res;
res_y = res;
res_z = resz;
grid = zeros(res_x, res_y, res_z, 4);

mdl = createns(M_N(:, 1:3),'nsmethod','kdtree');
parfor x = 1:res_x
    for y = 1:res_y
        for z = 1:res_z
            point = zeros(1, 3);
            point(1) = min(M_N(:, 1)) + (max(M_N(:, 1))-min(M_N(:, 1))) * x / res_x;
            point(2) = min(M_N(:, 2)) + (max(M_N(:, 2))-min(M_N(:, 2))) * y / res_y;
            point(3) = min(M_N(:, 3)) + (max(M_N(:, 3))-min(M_N(:, 3))) * z / res_z;
            %             idxNN = knnsearch(mdl, point, 'K', 20); % search 20 nearest points
            %             % add thresh & compute common normal & compute centroid
            %             ave_normal = mean(M_N(idxNN,4:6));
            %             centroid = mean(M_N(idxNN,1:3));
            %             grid(x, y, z) = dot(ave_normal, point-centroid);
            [idxNN, D] = knnsearch(mdl, point,'K',1); % search 20 nearest points
            if(D(1) > thresh)
                grid(x, y, z, :) = [-inf, 0, 0, 0];
            else
                % add thresh
                grid(x, y, z, :) = [dot(M_N(idxNN(1), 4:6), point-M_N(idxNN(1), 1:3)),M_N(idxNN(1),7:9)];
            end
        end
    end
    disp(['computing grid ' num2str(x/res_x*100) '%'])
end



end

