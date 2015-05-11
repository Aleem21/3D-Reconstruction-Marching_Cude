function [ disparity_map ] = sparseMatchByNCC( leftI, rightI,...
    leftE, rightE, left_angle_matrix, right_angle_matrix, edge_thresh, thresh, angle_thresh, half_window_size, quite, start, size_org)

if(~quite)
   close all;
   figure;
end
disparity_map = zeros(size(leftI,1),size(leftI,2));
if(start(1) == 0)
   start(1) = start(1) + 1; 
end
for i = start(1):size_org(1)
    for j = min(size_org(2) + start(2), size(leftI, 2)):-1:1
        if(leftE(i,j) > edge_thresh)
            count = 1;
            NCC_list = [];
            idx_list = [];
            for k = min(j,size(leftI, 2)):-1:max(1, j-thresh+1)
                if(rightE(i, k) > edge_thresh && abs(right_angle_matrix(i, k) - left_angle_matrix(i, j)) < angle_thresh)
                    if(i-half_window_size > 1 && i+half_window_size < size(leftI, 1) && k-half_window_size > 1 ...
                            && k+half_window_size < size(leftI, 2) && j-half_window_size > 1 && j+half_window_size < size(leftI, 2))
                        left_patch = leftI(i-half_window_size:i+half_window_size,j-half_window_size:j+half_window_size);
                        right_patch = rightI(i-half_window_size:i+half_window_size, k-half_window_size:k+half_window_size);
                        left_mean = mean(left_patch(:));
                        right_mean = mean(right_patch(:));
                        left_shift = left_patch - left_mean;
                        right_shift = right_patch - right_mean;
                        NCC_list(count) = sum(sum((left_shift.*right_shift))) / (norm(left_shift, 'fro')*norm(right_shift, 'fro'));
                        idx_list(count) = k;
                        count = count + 1;
                    end
                end
            end
            if(~isempty(NCC_list))
                [~, max_idx] = max(NCC_list);
                disparity_map(i, j) = j - idx_list(max_idx);
            end
        end
        
    end
    if(~quite)
        imshow(disparity_map);caxis('auto'); pause(0.03);
        disp(['done ' num2str(i/size(leftI, 1)*100) '%'])
       % imshow(disparity_map + rightE + leftE)
        caxis('auto')
       % colorbar
        colormap default
        pause(0.0005);
    end
    disp(['NCC sparse matching, ' num2str(i/size(leftI, 1)*100) '%'])
    
end

end


