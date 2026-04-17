function [X, F, C, Ry, R, y_vec] = X_matrix(q, q_dot, x, t_params, j_params, m_params)
%X matrix defined in (33) of %Slight modification of (21) in https://ieeexplore.ieee.org/document/6398278. x represents the state of each muscle



w_n=m_params.omega_n;
[~, ~, M_C, ~]=tf2ss(w_n^2, [1, 2*w_n, w_n^2]); %State space form of (6)

y_vec=zeros(length(x)/2, 1); %Muscle force output vector
for i=1:length(y_vec)
    y_vec(i)=M_C*x(2*i-1:2*i);
end

R=R_matrix(q, t_params); %Tendon mapping matrix
Ry=R*y_vec; %Torque about each joint
C=cor_matrix(q, q_dot, j_params); %Coriolis

F=F_matrix(q, q_dot, j_params); %Friction

    X=Ry-C-F; %eqn (33) in https://ieeexplore.ieee.org/document/6398278



end
