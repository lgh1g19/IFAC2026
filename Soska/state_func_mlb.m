function [d_x_full] = state_func_mlb(t, x_full,u_full,param_obj, Ts)
%Function given in (32) used to transition to the next state

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Modified version of state_func(u) used to run integration directly in matlab script using ode functions
%
% Elements of state are [q;q_dot;x], where x represents muscles states (each muscle has 2 states associated with it)
%
% fit_0 gives the muscle fitness at the start of stimulation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% General setup
param_obj_new=param_obj;

num_joints=3; 
if(size(u_full,1)>1 && size(u_full,2)>1)
timeStep=round((t+Ts)/Ts);
u=u_full(timeStep, :); %Extract input corresponding to current timestep
else
    u=u_full;
end

[q, q_dot, x]=extract_vals(x_full, num_joints); %Extract angle and angular velocity from full state
j_params=param_obj_new.params;
t_params=param_obj_new.tend;
m_params=param_obj_new.m;



%h_LAD parameters
w_n=m_params.omega_n;
[M_A, M_B, ~, ~]=tf2ss(w_n^2, [1, 2*w_n, w_n^2]); %eqn (6)

%% Calculate f(u,x)

%Lower rows f eqn (32) in https://ieeexplore.ieee.org/document/6398278
dx=zeros(size(x));
for i = 1:(length(x)/2)
        dx(2*(i-1)+1:2*(i-1)+2,1)=M_A*x(2*i-1:2*i)+M_B*h_IRC(u(i), i, m_params);
end


M=inert_matrix(q, j_params);


X=X_matrix(q, q_dot, x, t_params, j_params, m_params);




 q_ddot= M\X;   

d_x_full=[q_dot; q_ddot; dx];

end