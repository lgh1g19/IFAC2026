function [F] = F_matrix(q, q_dot, params)
%Frictional force matrix F(q, q_dot)


%Extract parameters
k1=params.k1; k2=params.k2; k3=params.k3;

%Params used to define how stiffness varies with angle
q_thres1=params.q_thres1;
q_thres2=params.q_thres2;
q_thres3=params.q_thres3;
a3=1/(0.1*k3*q_thres3);
q_cutoff1=params.q_cutoff1;
q_cutoff2=params.q_cutoff2;

    a1=1/(0.1*k1*(q_thres1-q_cutoff1));  
    a2=1/(0.1*k2*(q_thres2-q_cutoff2));


t_01=params.t_01; t_02=params.t_02; t_03=params.t_03;
b1=params.b1; b2=params.b2; b3=params.b3;
theta1=q(1); theta2=q(2); theta3=q(3);
t_dot1=q_dot(1); t_dot2=q_dot(2); t_dot3=q_dot(3);


    k1=1/(a1*(theta1-q_cutoff1))+k1; %This might go weird if
    k2=1/(a2*(theta2-q_cutoff2))+k2;
    k3=1/(a3*theta3)+k3;

F=[-k1*(t_01-theta1)+b1*t_dot1;
    -k2*(t_02-theta2)+b2*t_dot2;
    -k3*(t_03-theta3)+b3*t_dot3];

end