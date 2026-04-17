function [R] = R_matrix(q, tend)
%R matrix representing moment arm vector corresponding to each muscle (i.e. tendon mapping)
%tend holds relevant parameter values relating to tendon structure



theta1=q(1); theta2=q(2); theta3=q(3);


%Slight modification of (22)-(29) in https://ieeexplore.ieee.org/document/6398278
R_FDP=[0; tend.fdp.d1+tend.fdp.y1*((sin(theta2)-theta2)/(2*sin(theta2)^2)); 
    tend.fdp.d2+tend.fdp.y2*((sin(theta3)-theta3)/(2*sin(theta3)^2))];%

R_UB=[0;0;-(tend.ub.b+2*tend.ub.h+theta3)];
R_RB=[0;0;-(tend.rb.b+2*tend.rb.h+theta3)];
R_EC=[-tend.ec.r1; -tend.ec.r2; -tend.w1*tend.es.r+tend.w2*R_UB(3)+tend.w3*R_RB(3)];
R_ECR=[(tend.ecr.b+2*tend.ecr.h); 0; 0];
R_ECU=[(tend.ecu.b+2*tend.ecu.h); 0; 0];

R_EI=[-tend.ei.r1; -tend.ei.r2; -tend.w1*tend.es.r-tend.w2*R_UB(3)-tend.w3*R_RB(3)]; %First part of this shouldn't be zero but will need to think about what this would actually be
R_FDS=[0; tend.fds.d1+tend.fds.y1*((sin(theta2)-theta2)/(2*sin(theta2)^2)); tend.fds.d2+tend.fds.y2*((sin(theta3)-theta3)/(2*sin(theta3)^2))];



R=[R_FDP, R_FDS, R_EI, R_EC, R_ECR, R_ECU]; %Slight modification of (21) in https://ieeexplore.ieee.org/document/6398278
end