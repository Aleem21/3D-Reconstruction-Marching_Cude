function [disparity] = denseMatchByNCC(imgL, imgR, kSize, maxDisparity)
imgL = double(rgb2gray(imgL));
imgR = double(rgb2gray(imgR));
[h, w] = size(imgL);
disparity = zeros(h,w);
halfH = floor(kSize(1)/2);
halfW = floor(kSize(2)/2);
%initialize score array with minimum values
%note that corr score cannot be less than -1
score = -5*ones(1,w);
%for each scanline of left image
for i=1+halfH:h-halfH
    for j=1+halfW:w-halfW
        template = imgL(i-halfH:i+halfH, j-halfW:j+halfW);
        %normalize the template
        template_norm = normalize(template);
        %search the best match in the corresponding
        %scanline of the right image
        for k=j:-1:max(1+halfW,j-maxDisparity)
            patch = imgR(i-halfH:i+halfH, k-halfW:k+halfW);
            patch_norm = normalize(patch);
            score(k) = sum(sum(template_norm .* patch_norm));
        end
        [~, idx] = max(score);
        disparity(i,j) = abs(j - idx);
        %re-initialize score array
        score = -5*ones(1,w);
    end
    disp(['NCC dense matching ' num2str(i/(h-halfH-1-halfW)*100) '%'])
end
end


function y = normalize(x)
d = x - mean2(x);
v = d.^2;
y = d./sqrt(sum(v(:)));
end