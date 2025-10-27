function [y]=sim_system_w_b_k_generalised(lin_params, w, init_output)
%Simulates the transfer function from w to y

Ts=0.025;

omega=lin_params(1);
b_k=lin_params(2:end); %b/k
%k=lin_params(3:2:end);
num_outputs=length(b_k);
N=size(w,1);
y=zeros(N,num_outputs);

for out=1:num_outputs
sys_den=[b_k(out)/(omega^2), (2*b_k(out)/(omega)+1/omega^2), (b_k(out)+2/omega), 1];
sys_num=1;
sys=tf(sys_num, sys_den);


y(:,out)=lsim(sys, w(:,out), (1:length(w(:,out)))*Ts);

%end


end
