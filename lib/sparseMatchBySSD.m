function [P1, P2, disparity_map ] = sparseMatchBySSD( leftI, rightI,...
    leftE, rightE, left_angle_matrix, right_angle_matrix, edge_thresh, thresh, angle_thresh, half_window_size, quite, start, size_org)
imgL = rgb2gray(leftI);
imgR = rgb2gray(rightI);
leftE = rgb2gray(leftE);
rightE = rgb2gray(rightE);
P1 = []; P2 = [];cnt = 1;
%%%%%
% imgL = imresize(imgL,0.5);
% imgR = imresize(imgR,0.5);

h = fspecial('gaussian', [5 5], 6);
imgL = conv2(imgL,h,'same');
imgR = conv2(imgR,h,'same');

% leftE = imresize(leftE,0.5);
% rightE = imresize(rightE,0.5);
%
% left_angle_matrix = imresize(left_angle_matrix,0.5);
% right_angle_matrix = imresize(right_angle_matrix,0.5);


if(~quite)
    close all;
    figure;
end

halfW = half_window_size;
max_range = thresh;
edge_decider = mean2(leftE(leftE~=0));

disparity_map = zeros(size(imgL,1),size(imgR,2),1);
disp('start sparse matching!');
for i=1+halfW:size(disparity_map,1)-halfW
    for j=1+halfW:size(disparity_map,2)-halfW
        
        if leftE(i,j) < edge_decider
            continue;
        end
        
        template = imgL(i-halfW:i+halfW, j-halfW:j+halfW);
        templateE = leftE(i-halfW:i+halfW, j-halfW:j+halfW);
        
        ROW = imgR(i-halfW:i+halfW, max(j - max_range,1):j);
        ROW_E = leftE(i-halfW:i+halfW, max(j - max_range,1):j);
        
        
        left_angle = left_angle_matrix(i,j);
        right_angle_ROW = right_angle_matrix(i, max(j - max_range,1):j);
        
        [match,tmp] = disparity_match(template, ROW, j, halfW, templateE, ROW_E, left_angle, right_angle_ROW, 0, edge_decider);
        if tmp ~= 0
            P1(cnt,:) = [i,j]; P2(cnt,:) = [i,match]; disparity_map(i,j) = tmp; cnt = cnt+1;
        end
        
    end
    %     disparity_map(i,:) = conv(disparity_map(i,:),fspecial('gaussian',[1, 5],3), 'same');
    if(~quite)
        imshow(disparity_map);caxis('auto'); pause(0.03); colormap default;
        disp(['done ' num2str((i- halfW)/(size(imgL, 1)- 2*halfW)*100) '%'])
        % imshow(disparity_map + rightE + leftE)
        caxis('auto')
        % colorbar
        colormap default
        pause(0.0005);
    end
    disp(['NC Sparse matching, ' num2str((i - halfW)/(size(imgL, 1) - 2*halfW)*100) '%'])
    
end
%%dense matching
disp('start dense matching!');
for i=1+halfW:size(disparity_map,1)-halfW
    for j=1+halfW:size(disparity_map,2)-halfW
        
        
        range_canadite = disparity_map(i-10:i+10 ,:);
        pool = range_canadite(:);
        z_score = (pool-mean(pool))/(std(pool));
        z_score(abs(z_score) > 0.95) = nan;
        [~, umn] = max(z_score);
        max_range = pool(umn) + 40;
        [~, cmu] = min(z_score);
        min_range = pool(cmu);
        
        
        template = imgL(i-halfW:i+halfW, j-halfW:j+halfW);
        templateE = leftE(i-halfW:i+halfW, j-halfW:j+halfW);
        
        
        
        ROW = imgR(i-halfW:i+halfW, max(j - max_range,1):j - min_range);
        ROW_E = leftE(i-halfW:i+halfW, max(j - max_range,1):j);
        
        
        left_angle = left_angle_matrix(i,j);
        right_angle_ROW = right_angle_matrix(i, max(j - max_range,1):j);
        
        [match,tmp] = disparity_match(template, ROW, j, halfW, templateE, ROW_E, left_angle, right_angle_ROW, min_range, -1);
        if tmp ~= 0
            P1(cnt,:) = [i,j]; P2(cnt,:) = [i,match]; disparity_map(i,j) = tmp; cnt = cnt+1;
        end
        
    end
    %     disparity_map(i,:) = conv(disparity_map(i,:),fspecial('gaussian',[1, 5],3), 'same');
    if(~quite)
        imshow(disparity_map);caxis('auto'); pause(0.03);
        disp(['done ' num2str((i- halfW)/(size(imgL, 1)- 2*halfW)*100) '%'])
        % imshow(disparity_map + rightE + leftE)
        caxis('auto')
        % colorbar
        colormap default
        pause(0.0005);
    end
    disp(['NC Dense matching, ' num2str((i - halfW)/(size(imgL, 1) - 2*halfW)*100) '%'])
    
end
% temp = disparity_map(:);
% zc = zscore(temp);
% zc(abs(zc) > 0.98) = nan;
% [~, umn] = max(zc);
% max_disp = temp(umn);
% [~, cmu] = min(zc);
% min_disp = temp(cmu);
% disparity_map(disparity_map < min_disp | disparity_map > max_disp) = 0;

end


function [index,diff] = disparity_match(w, row, right_index, halfW, templateE, ROW_E, left_angle, right_angle_ROW, min_range, Edge_threshold)
c_rgb = 0; c_Edge = 0; c_angle = 0; match = []; COST = [];

for k = size(row,2) - halfW : -1: halfW + 1
    %check gradient
    if ROW_E(1+halfW,k) < Edge_threshold
        continue;
    end
    %cost of RGB
    wp = row(:, k-halfW:k+halfW);
    w_ave = mean2(w);
    wp_ave = mean2(wp);
    term1 = (w - w_ave).*(wp - wp_ave);
    term1 = sum(sum(term1));
    term2 = norm((w - w_ave),'fro');
    term3 = norm((wp-wp_ave),'fro');
    c_rgb = term1/(term2*term3);
    match(k) = right_index - min_range - (size(row,2) - halfW - k);
    
    %cost of gradient
    %     wp = ROW_E(:, k-halfW:k+halfW);
    %     w_ave = mean2(templateE);
    %     wp_ave = mean2(wp);
    %     term1 = (w - w_ave).*(wp - wp_ave);
    %     term1 = sum(sum(term1));
    %     term2 = norm((w - w_ave),2);
    %     term3 = norm((wp-wp_ave),2);
    %     c_Edge = term1/(term2*term3);
    %cost of angel
    %     angle_R = right_angle_ROW(:,k);
    %     c_angle = abs(left_angle - angle_R);
    %%
    COST(k) = c_rgb; % + c_Edge;
end
if isempty(COST)
    index = 0;
    diff = 0;
    return
end
[test,ind] = max(COST(:,halfW+1:size(COST,2)));
if test <= 0
    index = 0;
    diff = 0;
    return
end
ind = ind + halfW;
index = match(ind);
diff = right_index - index;

end

function [max] = find_max_cretical(data)
data = data(data>0);

end

