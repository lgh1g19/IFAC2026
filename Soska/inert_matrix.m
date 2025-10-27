function [M] = inert_matrix(q, params)
%Inertia matrix M(q) based on joint angles

%Extract parameters
m1=params.m1; m2=params.m2; m3=params.m3;
J1=params.J1; J2=params.J2; J3=params.J3;
c1=params.c1; c2=params.c2; c3=params.c3;
l1=params.l1; l2=params.l2; l3=params.l3;
theta2=q(2); theta3=q(3);


% m11=m1*c1^2+m2*l1^2+m2*c2^2+2*m2*l1*c2*cos(theta2)+m3*l1^2+m3*l2^2+2*m3*l1*l2*cos(theta2)+ ...
%     2*m3*l1*c3*cos(theta2+theta3)+2*m3*l2*c3*cos(theta3)+m3*c3^2+J1+J2+J3;
% m12=m2*(c2^2+l1*c2*cos(theta2))+m3*l2^2+m3*c3^2+m3*l1*l2*cos(theta2)+m3*l1*c3*cos(theta2+theta3)+ ...
%     2*m3*l2*c3*cos(theta3)+J2+J3;
% m13=m3*c3^2+m3*l1*c3*cos(theta2+theta3)+m3*l2*c3*cos(theta3)+J3;
% m22=m2*c2^2+m3*l2^2+m3*c3^2+m3*l2*c3*cos(theta3)+J3;
% m23=m3*c3^2+m3*l2*c3*cos(theta3)+J3;
% m33=m3*c3^2+J3;

m11=J1 + J2 + J3 + c1^2*m1 + c2^2*m2 + l1^2*m2 + l1^2*m3 + l2^2*m3 + l3^2*m3 + 2*l1*l3*m3*cos(theta2 + theta3) + 2*c2*l1*m2*cos(theta2) + 2*l1*l2*m3*cos(theta2) + 2*l2*l3*m3*cos(theta3);
m12=m2*c2^2 + l1*m2*cos(theta2)*c2 + m3*l2^2 + 2*m3*cos(theta3)*l2*l3 + l1*m3*cos(theta2)*l2 + m3*l3^2 + l1*m3*cos(theta2 + theta3)*l3 + J2 + J3;
m13=J3 + l3^2*m3 + l1*l3*m3*cos(theta2 + theta3) + l2*l3*m3*cos(theta3);
m22=m2*c2^2 + m3*l2^2 + 2*m3*cos(theta3)*l2*l3 + m3*l3^2 + J2 + J3;
m23=m3*l3^2 + l2*m3*cos(theta3)*l3 + J3;
m33=m3*l3^2 + J3;



M=[m11, m12, m13;
    m12, m22, m23;
    m13, m23, m33];

end
