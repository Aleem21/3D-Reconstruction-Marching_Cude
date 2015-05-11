function [tri_points] = triangulate_1(P_1, P_2, pixels_1, pixels_2)
[C1, V1] = cam_center_vector(P_1, pixels_1);
[C2, V2] = cam_center_vector(P_2, pixels_2);
V3 = cross(V1, V2);
A = [V1 V3 V2];
T = C2 - C1;
coffs = inv(A)*T;
alpha = coffs(1);
beta =  coffs(2);
gama = coffs(3);
temp = C1 + alpha*V1;
tri_points = temp + 0.5*beta*V3;
end