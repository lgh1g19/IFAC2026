function [lin_params, norm_err, run_time] = fit_lin_params_generalised(IRC_ss_params, q_cell, q_test_cell, in_data)
%Fits linear (\Theta) parameter values using continuous-time data
%in_mean is array and out_fit/ out_val are cell arrays

%This implements eqn (45) in IFAC paper


num_inputs=size(in_data,2);
num_outputs=length(q_cell);

%%% Ensuring column vectors in cell
for out=1:length(q_cell)
    if(size(q_cell{out},1)==1)
        q_cell{out}=q_cell{out}';
    end
    if(size(q_test_cell{out},1)==1)
        q_test_cell{out}=q_test_cell{out}';
    end
end
%%%

q_arr=cell_2_arr_cat(q_cell);
q_arr_test=cell_2_arr_cat(q_test_cell);


in_data_fit=in_data;
in_data_val=in_data;

% Remove resting angle offset (ensure zero output for zero input)
q_off=zeros(1, num_outputs); q_off_test=zeros(1, num_outputs);
for out=1:num_outputs
q_off(out)=find_offset(q_arr(:,out), in_data_fit);
q_off_test(out)=find_offset(q_arr_test(:,out), in_data_fit);
end

q_arr2=q_off-q_arr;
q_arr_test2=q_off_test-q_arr_test;


% Generate activation data - eqn (44) in IFAC paper
w_arr=IRC_ss_combined_2input(IRC_ss_params, in_data_fit, num_inputs, num_outputs);


% Function simulating dynamic system response
func=@(params, input)sim_system_w_b_k_generalised(params, input);


%Construct initial parameter value from default values given in https://ieeexplore.ieee.org/document/6398278
init_params=[2.7,repmat([0.7], [1,num_outputs])]; %Should this be chosen randomly or is a fixed value fine?


max_omega=10;
tic
lin_params=lsqcurvefit(func, init_params, w_arr,q_arr2, zeros(1, num_outputs+1), [max_omega, inf(1,num_outputs)]);
run_time=toc;

%Simulate output
w_arr_val=IRC_ss_combined_2input(IRC_ss_params, in_data_val, num_inputs, num_outputs);
fitted_response=sim_system_w_b_k_generalised(lin_params, w_arr_val);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fitted_response is model output, q_arr_test2 is experimental data (with offset accounted for)
% NB: offset is already accounted for in fitted_response

%Compute fitting error accuracy

norm_err=zeros(1, num_outputs);
for out=1:num_outputs
    err=fitted_response(:,out)-q_arr_test2(:,out);
    norm_err(out)=(1-norm(err)/norm(q_arr_test2(:,out)))*100;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end