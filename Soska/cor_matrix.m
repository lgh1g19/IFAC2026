function [C] = cor_matrix(q, q_dot, params)
%Returns the coriolis/ centifugal force matric C(q, q_dot)

%Extract parameters
m1=params.m1; m2=params.m2; m3=params.m3;
J1=params.J1; J2=params.J2; J3=params.J3;
c1=params.c1; c2=params.c2; c3=params.c3;
l1=params.l1; l2=params.l2; l3=params.l3;
theta1=q(1); theta2=q(2); theta3=q(3);
t_dot1=q_dot(1); t_dot2=q_dot(2); t_dot3=q_dot(3); 


c11=-(m3*c3*l1*sin(theta2+theta3)+m3*c3*l2*sin(theta3))*(2*t_dot1*t_dot3+2*t_dot2*t_dot3+t_dot3^2)...
    -((m2*l1*c2+m3*l1*l2)*sin(theta2)+m3*l1*c3*sin(theta1+theta2))*(2*t_dot1*t_dot2+t_dot2^2);
c21=((m2*c2*l1+m3*l1*l2)*sin(theta2)+m3*c3*l2*sin(theta2+theta3))*t_dot1^2 ...
    -m3*c3*l2*sin(theta3)*(2*t_dot1*t_dot3+2*t_dot2*t_dot3+t_dot3^2);
c31=(m3*c3*l2*sin(theta3)+m3*c3*l1*sin(theta2+theta3))*t_dot1^2 ...
    +m3*c3*l2*sin(2*t_dot1*t_dot2+t_dot2^2);

C=[c11;c21;c31];

end