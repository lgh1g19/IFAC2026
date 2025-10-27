function [q, q_dot, x]=extract_vals(x_full, num_joints)
%Extctracts joint angle/ velocity and muscle states from the full state
%vector
q=x_full(1:num_joints);
q_dot=x_full(num_joints+1:2*num_joints);
x=x_full(2*num_joints+1:length(x_full));
end