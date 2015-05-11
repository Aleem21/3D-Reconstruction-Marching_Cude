function[cloud] = createSurface(leafNode, index3D, iso_level,minX,maxX,minY,maxY,minZ,maxZ, res, resz)
% loadParam;
cloud = [];
[edgeTable, triTable] = getMCLookUpTable();
cubeindex = 0;
vertex_list = zeros(12, 1);
if(leafNode(1,1) < iso_level)
    cubeindex = bitor(cubeindex, 1);
end
if(leafNode(2,1) < iso_level)
    cubeindex = bitor(cubeindex, 2);
end
if(leafNode(3,1) < iso_level)
    cubeindex = bitor(cubeindex, 4);
end
if(leafNode(4,1) < iso_level)
    cubeindex = bitor(cubeindex, 8);
end
if(leafNode(5,1) < iso_level)
    cubeindex = bitor(cubeindex, 16);
end
if(leafNode(6,1) < iso_level)
    cubeindex = bitor(cubeindex, 32);
end
if(leafNode(7,1) < iso_level)
    cubeindex = bitor(cubeindex, 64);
end
if(leafNode(8,1) < iso_level)
    cubeindex = bitor(cubeindex, 128);
end
cubeindex = cubeindex + 1;
% Cube is entirely in/out of the surface
if (edgeTable(cubeindex) == 0)
    return;
end
center = zeros(1, 3);
center(1) = minX + (maxX - minX) * index3D(1) / res;
center(2) = minY + (maxY - minY) * index3D(2) / res;
center(3) = minZ + (maxZ - minZ) * index3D(3) / resz;

p = cell(1, 8);
for i = 0:7
    point = center;
    if(bitand(i, hex2dec('4')))
        point(2) = center(2) + (maxY - minY) / res;
    end
    if(bitand(i, hex2dec('2')))
        point(3) = center(3) + (maxZ - minZ) / resz;
    end
    if bitxor(bitand(i, hex2dec('1')), bitand(bitshift(i, -1), hex2dec('1')))
        point(1) = center(1) + (maxX - minX) / res;
    end
    p{i+1} = point;
end

vertex_list = zeros(12, 3);
% Find the vertices where the surface intersects the cube
if (bitand(edgeTable(cubeindex),  1))
    vertex_list(1, :) = interpolateEdge(p{1}, p{2}, leafNode(1,1), leafNode(2,1));
end
if (bitand(edgeTable(cubeindex),  2))
    vertex_list(2, :) = interpolateEdge(p{2}, p{3}, leafNode(2,1), leafNode(3,1));
end
if (bitand(edgeTable(cubeindex),  4))
    vertex_list(3, :) = interpolateEdge(p{3}, p{4}, leafNode(3,1), leafNode(4,1));
end
if (bitand(edgeTable(cubeindex),  8))
    vertex_list(4, :) = interpolateEdge(p{4}, p{1}, leafNode(4,1), leafNode(1,1));
end
if (bitand(edgeTable(cubeindex), 16))
    vertex_list(5, :) = interpolateEdge(p{5}, p{6}, leafNode(5,1), leafNode(6,1));
end
if (bitand(edgeTable(cubeindex), 32))
    vertex_list(6, :) = interpolateEdge(p{6}, p{7}, leafNode(6,1), leafNode(7,1));
end
if (bitand(edgeTable(cubeindex), 64))
    vertex_list(7, :) = interpolateEdge(p{7}, p{8}, leafNode(7,1), leafNode(8,1));
end
if (bitand(edgeTable(cubeindex), 128))
    vertex_list(8, :) = interpolateEdge(p{8}, p{5}, leafNode(8,1), leafNode(5,1));
end
if (bitand(edgeTable(cubeindex), 256))
    vertex_list(9, :) = interpolateEdge(p{1}, p{5}, leafNode(1,1), leafNode(5,1));
end
if (bitand(edgeTable(cubeindex), 512))
    vertex_list(10, :) = interpolateEdge(p{2}, p{6}, leafNode(2,1), leafNode(6,1));
end
if (bitand(edgeTable(cubeindex), 1024))
    vertex_list(11, :) = interpolateEdge(p{3}, p{7}, leafNode(3,1), leafNode(7,1));
end
if (bitand(edgeTable(cubeindex), 2048))
    vertex_list(12, :) = interpolateEdge(p{4}, p{8}, leafNode(4,1), leafNode(8,1));
end

if isnan(vertex_list(1,1))
    disp('haah')
end

i = 1; 
while(triTable(cubeindex, i) ~= -1)
    p1 = cell(3, 1);
    p1{1} = vertex_list(triTable(cubeindex, i)+1, 1);
    p1{2} = vertex_list(triTable(cubeindex, i)+1, 2);
    p1{3} = vertex_list(triTable(cubeindex, i)+1, 3);
    p2 = cell(3, 1);
    p2{1} = vertex_list(triTable(cubeindex, i+1)+1, 1);
    p2{2} = vertex_list(triTable(cubeindex, i+1)+1, 2);
    p2{3} = vertex_list(triTable(cubeindex, i+1)+1, 3);
    p3 = cell(3, 1);
    p3{1} = vertex_list(triTable(cubeindex, i+2)+1, 1);
    p3{2} = vertex_list(triTable(cubeindex, i+2)+1, 2);
    p3{3} = vertex_list(triTable(cubeindex, i+2)+1, 3);
    
    cloud(i,:) =  [[p1{1} p1{2} p1{3}], (leafNode(1,2:4)+leafNode(3,2:4))/2] ;
    cloud(i+1,:) = [[p2{1} p2{2} p2{3}], (leafNode(4,2:4)+leafNode(6,2:4))/2];
    cloud(i+2,:) = [[p3{1} p3{2} p3{3}], (leafNode(7,2:4)+leafNode(8,2:4))/2];
    i = i + 3;
end

end



function [out] = interpolateEdge(p1, p2, valP1, valP2)
iso_level = 0;
mu = (iso_level - valP1) / (valP2-valP1);
out = p1 + mu * (p2 - p1);
end