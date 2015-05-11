function [ disparity_map ] = sparseMatchBySSDPar( leftI, rightI,...
    leftE, rightE, left_angle_matrix, right_angle_matrix, edge_thresh, thresh, angle_thresh, half_window_size, quite, start, size_org)

if(~quite)
    close all;
    figure;
end
if(start(1) == 0)
    start(1) = start(1) + 1;
end

x_dim = start(1):size_org(1);
y_dim = size_org(2) + start(2):-1:1;
m = length(x_dim);
n = length(y_dim);
disparity_map_cell = cell(m, 1);

parfor a = 1:m
    disparity_map_sub_cell = zeros(size(leftI, 1)*size(leftI, 2), 1);
    for b = 1:n
        i = x_dim(a);
        j = y_dim(b);
        if(leftE(i,j) > edge_thresh)
            count = 1;
            SSD_list = [];
            idx_list = [];
            for k = j:-1:max(1, j-thresh+1)
                if(rightE(i, k) > edge_thresh && abs(right_angle_matrix(i, k) - left_angle_matrix(i, j)) < angle_thresh)
                    if(i-half_window_size > 1 && i+half_window_size < size(leftI, 1) && k-half_window_size > 1 ...
                            && k+half_window_size < size(leftI, 2) && j-half_window_size > 1 && j+half_window_size < size(leftI, 2))
                        SSD_list(count) = sum(sum((leftI(i-half_window_size:i+half_window_size,...
                            j-half_window_size:j+half_window_size)-rightI(i-half_window_size:i+half_window_size,...
                            k-half_window_size:k+half_window_size)).^2));
                        idx_list(count) = k;
                        count = count + 1;
                    end
                end
            end
            if(~isempty(SSD_list))
                [v, min_idx] = min(SSD_list);
                idx = sub2ind(size(leftI),i, j );
                disparity_map_sub_cell(idx) = j - idx_list(min_idx);
            end
            SSD_list = [];
            idx_list = [];
        end
    end
    disparity_map_cell{a} = disparity_map_sub_cell;
    disp(['SSD sparse matching, ' num2str(i/size(leftI, 1)*100) '%'])
    
end

disparity_map = zeros(size(leftI,1),size(leftI,2));
for a = 1:m
    cur = disparity_map_cell{a};
    for i = 1:length(cur)
       if(cur(i) ~= 0)
           [x, y] = ind2sub(size(leftI), cur(i, 1));
           disparity_map(x, y) = cur(i);
       end
    end
end

end



