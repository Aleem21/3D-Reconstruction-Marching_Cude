function [T1,T2,Pn1,Pn2] = rectify(Po1,Po2)

% factorise old PPM 
[A1,R1,t1] = art(Po1);
[A2,R2,t2] = art(Po2);

% TODO: Compute  rectification matrices in homogeneous coordinate
% compute camera center
c1 = - inv(Po1(:,1:3))*Po1(:,4);
c2 = - inv(Po2(:,1:3))*Po2(:,4);
% follow paper to make R
r1 = (c2-c1)/norm(c2-c1);
r2 = cross(R1(3,:)',r1);
r3 = cross(r1,r2);
R = [r1'; r2'; r3'];
% take average
A = (A1 + A2)./2;
A(1,2)=0;
Pn1 = A * [R -R*c1 ];   
Pn2 = A * [R -R*c2 ];%get T1 T2
T1 = Pn1(1:3,1:3)* inv(Po1(1:3,1:3));
T2 = Pn2(1:3,1:3)* inv(Po2(1:3,1:3));
end
