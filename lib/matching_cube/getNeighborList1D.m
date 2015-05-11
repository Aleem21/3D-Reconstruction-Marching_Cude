function [leafNode] = getNeighborList1D(index3d, grid, res, resz)
leafNode = zeros(8, 4);
leafNode(1,:) = getGridValue (index3d, grid, res, resz);
leafNode(2,:) = getGridValue (index3d+[1 0 0], grid, res, resz);
leafNode(3,:) = getGridValue (index3d+[1 0 1], grid, res, resz);
leafNode(4,:) = getGridValue (index3d+[0 0 1], grid, res, resz);
leafNode(5,:) = getGridValue (index3d+[0 1 0], grid, res, resz);
leafNode(6,:) = getGridValue (index3d+[1 1 0], grid, res, resz);
leafNode(7,:) = getGridValue (index3d+[1 1 1], grid, res, resz);
leafNode(8,:) = getGridValue (index3d+[0 1 1], grid, res, resz);

if(min(leafNode(:)) == -inf)
    leafNode(:,:) = zeros(8, 4);
end
end


function [ret] = getGridValue(pos, grid, res, resz)
if(pos(1) < 1 || pos(1) > res)
    ret =  -1;
    return;
end
if(pos(2) < 1 || pos(2) > res)
    ret = -1;
    return;
end
if(pos(3) < 1 || pos(3) > resz)
    ret = -1;
    return;
end
ret = grid(pos(1), pos(2), pos(3),:);
end