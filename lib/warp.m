function [ output_args_L, output_args_R, start ] = warp( H_L, input_L, H_R, input_R )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

input_L = im2double(input_L);
input_R = im2double(input_R);
H_L_inv = inv(H_L);
H_R_inv = inv(H_R);


output_args_L = zeros(size(input_L,1), size(input_L,2),3);

%%rectify image_L
for row = 1: size(output_args_L,1)
    for col = 1:size(output_args_L,2)
        position_ = H_L_inv*[col ,row,1]';
        position = position_/(position_(3));
            output_args_L(row , col, : ) = interpolation(input_L,position);
    end
end

output_args_R = zeros(size(input_R,1),size(input_R,2),3);

%%rectify image_R
for row = 1: size(output_args_R,1)
    for col = 1:size(output_args_R,2)
        position_ = H_R_inv*[col ,row, 1]';
        position = position_/(position_(3));
            output_args_R(row, col, : ) = interpolation(input_R,position);
    end
end
start = [1;1];

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
