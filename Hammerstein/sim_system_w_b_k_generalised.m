function [y]=sim_system_w_b_k_generalised(lin_params, z)
%Simulates the transfer function from z to y

Ts=0.025;

omega=lin_params(1);
b_k=lin_params(2:end); % \mu parameter

num_outputs=length(b_k);
N=size(z,1);
y=zeros(N,num_outputs);

for out=1:num_outputs
    % eqn (19) in IFAC paper
    sys_den=[b_k(out)/(omega^2), (2*b_k(out)/(omega)+1/omega^2), (b_k(out)+2/omega), 1];
    sys_num=1;
    sys=tf(sys_num, sys_den);

    %Simulate response
    y(:,out)=lsim(sys, z(:,out), (1:length(z(:,out)))*Ts);


end
