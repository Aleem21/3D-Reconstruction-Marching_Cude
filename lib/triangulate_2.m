function [tri_points] = triangulate_2(P_1, P_2, pixels_1, pixels_2)
A = vec_to_matrix([pixels_1 ; 1])*P_1;
B = vec_to_matrix([pixels_2; 1])*P_2;
T = [A;B];
null_space = null(T, 'r');
X = null_space(1);
Y = null_space(2);
Z = null_space(3);

tri_points = zeros(3,1);
tri_points(1) = X;
tri_points(2) = Y;
tri_points(3) = Z;



    function [matrix] = vec_to_matrix(v)
        a = v(1);
        b = v(2);
        c = v(3);
        matrix = [0 -c b; c 0 -a; -b a 0];
    end
end