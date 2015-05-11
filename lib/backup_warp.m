function [ output_args_L, output_args_R, start ] = warp( H_L, input_L, H_R, input_R )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

input_L = im2double(input_L);
input_R = im2double(input_R);
H_L_inv = inv(H_L);
H_R_inv = inv(H_R);

shift_L = zeros(4,3);
shift_L(1,:) = H_L*[1,1,1]';
shift_L(2,:) = H_L*[size(input_L,2),1,1]';
shift_L(3,:) = H_L*[1,size(input_L,1),1]';
shift_L(4,:) = H_L*[size(input_L,2),size(input_L,1),1]';

shift_R = zeros(4,3);
shift_R(1,:) = H_R*[1,1,1]';
shift_R(2,:) = H_R*[size(input_R,2),1,1]';
shift_R(3,:) = H_R*[1,size(input_R,1),1]';
shift_R(4,:) = H_R*[size(input_R,2),size(input_R,1),1]';

shift_L = round(shift_L./repmat(shift_L(:,3), [1 3]));
shift_R = round(shift_R./repmat(shift_R(:,3), [1 3]));

new_size = [0,0];
% new_size(1) = max(abs([min(shift_L(:,1)), min(shift_R(:,1))]));
% new_size(2) = max(abs([min(shift_L(:,2)), min(shift_R(:,2))]));

if min(shift_L(:,1)) < min(shift_R(:,1))
    new_size(1) = min(shift_L(:,1));
else
    new_size(1) = min(shift_R(:,1));
end

if min(shift_L(:,2)) < min(shift_R(:,2))
    new_size(2) = min(shift_L(:,2));
else
    new_size(2) = min(shift_R(:,2));
end


new_width = max([max(shift_L(:,1)), max(shift_R(:,1))]) - min([min(shift_L(:,1)), min(shift_R(:,1))]);
new_high = max([max(shift_L(:,2)), max(shift_R(:,2))]) - min([min(shift_L(:,2)), min(shift_R(:,2))]);

x_ = -new_size(1);
y_ = -new_size(2);

output_args_L = zeros(abs(new_high), abs(new_width),3);

%%rectify image_L
for row = 1: size(output_args_L,1)
    for col = 1:size(output_args_L,2)
        position_ = H_L_inv*[col - x_ ,row - y_ ,1]';
        position = position_/(position_(3));
%         if row < size(output_args_L,1) && row  > 1 && col > 1 && col< size(output_args_L,2)
            output_args_L(row , col, : ) = interpolation(input_L,position);
%         end
    end
end

output_args_R = zeros(abs(new_high), abs(new_width),3);

%%rectify image_R
for row = 1: size(output_args_R,1)
    for col = 1:size(output_args_R,2)
        position_ = H_R_inv*[col - x_ ,row - y_ ,1]';
        position = position_/(position_(3));
%         if row < size(output_args_R,1) && row  > 1 && col  > 1 && col  < size(output_args_R,2)
            output_args_R(row, col, : ) = interpolation(input_R,position);
%         end
    end
end
start = [1;1];
% start(1) = abs(new_size(2));
% start(2) = abs(new_size(1));
% end

end

function [pixel] = interpolation(input, position)
x = floor(position(1));
y = floor(position(2));
x_ = position(1);
y_ = position(2);
pixel = [0;0;0];
if y_ < size(input,1) && y_ > 1 && x_ > 1 && x_ < size(input,2)
    pixel = input(y,x,:)*( x+1 - x_)*(y+1 -y_) + input(y+1,x,:)*( y_ - y)*(x+1 -x_) + input(y,x+1,:)*( y+1 - y_)*(x_ - x) + input(y+1,x+1,:)*(x_ - x)*( y_ - y);
end
end
