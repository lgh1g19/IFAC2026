function [X, F, C, Ry, R, y_vec] = X_matrix(q, q_dot, x, t_params, j_params, m_params)
%X matrix defined in (33) of Soska_2012_ISIC. x represents the state of each muscle

%sp=stim_par();

w_n=m_params.omega_n;
[~, ~, M_C, ~]=tf2ss(w_n^2, [1, 2*w_n, w_n^2]);

y_vec=zeros(length(x)/2, 1); %Muscle force output vector
for i=1:length(y_vec)
    y_vec(i)=M_C*x(2*i-1:2*i); %*F_lenVel(q, q_dot);
end

R=R_matrix(q, t_params);
Ry=R*y_vec; %Torque
C=cor_matrix(q, q_dot, j_params);

F=F_matrix(q, q_dot, j_params);

    X=Ry-C-F;



end
