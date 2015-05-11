function [ txt_matrix ] = getOutputMatrix( inputI, disparity_map, z_thresh, Pn1, Pn2, start )
txt_matrix = size(size(inputI, 1)*size(inputI, 2), 6);
linear_idx = 1;
for row = 1:size(inputI, 1)
    for col = 1:size(inputI, 2)
        if(disparity_map(row, col) == col || disparity_map(row, col) == 0)
            continue;
        end
        pixels_1 = [col - start(2);row - start(1)]; pixels_2 = [col - start(2) - disparity_map(row, col);row - start(1)];
        cord = triangulate_1(Pn1, Pn2, pixels_1, pixels_2);
        txt_matrix(linear_idx, 1) = cord(1);
        txt_matrix(linear_idx, 2) = cord(2);
        txt_matrix(linear_idx, 3) = cord(3);
        if abs(cord(3)) > z_thresh
            continue
        end
        txt_matrix(linear_idx, 4) = inputI(row, col, 1)*255;
        txt_matrix(linear_idx, 5) = inputI(row, col, 2)*255;
        txt_matrix(linear_idx, 6) = inputI(row, col, 3)*255;
        linear_idx = linear_idx + 1;
    end
    disp(['Writing to output matrix, ' num2str(row/size(inputI, 1)*100) '%'])
end


end

