function [d_map] = get_disparity_map(leftI, rightI, windowSize, maxDisparity, method)
if(length(windowSize) ~= 1)
   error('window size is a scalar') 
end
leftI = im2double(leftI);
rightI = im2double(rightI);
if(strcmp(method, 'NCC'))
    d_map = zeros(size(leftI));
    halfWindow = windowSize / 2;
    for x = 1+halfWindow:size(leftI, 1)-halfWindow
        for y = 1+halfWindow:size(leftI, 2)-halfWindow
            argdx = 0;
            lpatch = imcrop(leftI,[x-halfWindow y-halfWindow windowSize windowSize]);
            rpatch = -lpatch;
            max = rpatch .* lpatch / (norm(lpatch)*norm(rpatch));
            lm = lpatch - sum(lpatch(:))/(size(lpatch, 1)*size(lpatch, 2));
            for dx = -maxDisparity:maxDisparity
                rpatch = imcrop(rightI,[x-halfWindow+dx y-halfWindow windowSize windowSize]);
                rm = rpatch - sum(rpatch(:))/(size(rpatch, 1)*size(rpatch, 2));
                corr = lm.*rm/(norm(lm)*norm(rm));
                if(corr > max)
                    max = corr;
                    argdx = dx;
                end
            end
            d_map(x, y) = argdx;
        end
        disp(['Done ' num2str(x/size(leftI, 1)*100) '%'])
    end
elseif(strcmp(method, 'SSD'))
    
    
else
    error('NCC or SSD')
end


end