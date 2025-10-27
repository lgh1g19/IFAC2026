function [lin_params, norm_err, run_time] = fit_lin_params_generalised(IRC_ss_params, q_cell, q_test_cell, in_data)
%Fits linear parameter values using continuous-time data
%in_mean is array and out_fit/ out_val are cell arrays


num_inputs=size(in_data,2);
num_outputs=length(q_cell);

%%% Ensuring column vectors in cell (Why is this not working???)
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

q_off=zeros(1, num_outputs); q_off_test=zeros(1, num_outputs);
for out=1:num_outputs
q_off(out)=find_offset(q_arr(:,out), in_data_fit);
q_off_test(out)=find_offset(q_arr_test(:,out), in_data_fit);
end

%% Ensure zero output for zero inputs
q_arr2=q_off-q_arr;
q_arr_test2=q_off_test-q_arr_test;
% Generate activation data

w_arr=IRC_ss_combined_2input(IRC_ss_params, in_data_fit, num_inputs, num_outputs);

%init_output=q_off;

func=@(params, input)sim_system_w_b_k_generalised(params, input, []); %What should the final 'initial output' input be to this function?

%Construct initial parameter value
init_params=[2.7,repmat([0.7], [1,num_outputs])]; %Should this be chosen randomly or is a fixed value fine?

%NB: Is this really the most sensible approach to use?
max_omega=10;
tic
lin_params=lsqcurvefit(func, init_params, w_arr,q_arr2, zeros(1, num_outputs+1), [max_omega, inf(1,num_outputs)]);
run_time=toc;

%Simulate output with linear params
w_arr_val=IRC_ss_combined_2input(IRC_ss_params, in_data_val, num_inputs, num_outputs);
fitted_response=sim_system_w_b_k_generalised(lin_params, w_arr_val, []);

norm_err=zeros(1, num_outputs);

for out=1:num_outputs
    err=fitted_response(:,out)-q_arr_test2(:,out);
    norm_err(out)=(1-norm(err)^2/norm(q_arr_test2(:,out))^2)*100;
end


end