function [model_obj, q1_val_norm, q2_val_norm, q3_val_norm, model_obj_log, opt_time] = empirical_fitting_Aparams(q1_fit,q2_fit,q3_fit, q1_val, q2_val,q3_val, v1, v2, alg, init_estimate)
%EMPIRICAL_FITTING Aims to fit model to data using global/ local
%optimisation
%Designed to work on rast data given in terms of input-output vectors

%Similar to empirical_fitting_newData but designed to fit A matrix
%parameters as well (though due to over-parameterisation it just increases the flexibility on the max force parameters instead)


to_plot=1;

model_obj_log=cell(1,9);
counter=1;

q1=q1_fit; q2=q2_fit; q3=q3_fit;
num_inputs=2;


%options = optimoptions('lsqcurvefit','Algorithm','interior-point');
%options.StepTolerance=1e-13;

base_dir='C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\rpi simulink program\ID model_fitting GUI\Parameter investigation app\';

addpath(strcat(base_dir,'empirical_fit_funcs'));
[model_obj.params, model_obj.tend, model_obj.m, model_obj.gen]=param_return(); %Begin with default object
model_obj.m.max_force=ones(1,6);
model_obj.m.irc.a1=ones(1,6);

els=[7,22]; %choice is somewhat arbitrary
num_muscles=length(model_obj.gen.arr_map_obj.musc_arr);



save(strcat(base_dir,'model_obj mat log\model_obj.mat'), 'model_obj');

%% Extract values of v/q1/q2 for different regions of the input space
% v_cell=cell(3); %cell containing values of v for each of the 9 regions of the input space

 model_obj_log{1,counter}=model_obj;
 counter=counter+1;
%% Alter q_01 and q_02 to fit angle at [0,0] (Note that these angles must both be in radians)


%Assume initial input is zero
model_obj.params.t_01=deg2rad(find_offset(q1,[v1,v2]));
model_obj.params.t_02=deg2rad(find_offset(q2,[v1,v2]));
model_obj.params.t_03=deg2rad(find_offset(q3,[v1,v2]));

%%%%
figure; subplot(3,1,1); plot(q1); subplot(3,1,2); plot(q2); subplot(3,1,3); plot(q3);
subplot(3,1,1); hold on; yline(rad2deg(model_obj.params.t_01)); subplot(3,1,2); hold on; yline(rad2deg(model_obj.params.t_02)); subplot(3,1,3); hold on; yline(rad2deg(model_obj.params.t_03));
%%%%

model_obj_log{1,counter}=model_obj;
counter=counter+1;

if(size(q1,1)==1)
    q1=q1';
end

if(size(q2,1)==1)
    q2=q2';
end

if(size(q3,1)==1)
    q3=q3';
end

if(size(v1,1)==1)
    v1=v1';
end

if(size(v2,1)==1)
    v2=v2';
end

%% Use global optimisation to fit all other model parameters

%max_c=max([abs(range(deg2rad(q1))), abs(range(deg2rad(q2))),abs(range(deg2rad(q3)))]);


%%%%%%%%%%% All params (including tendon params) %%%%%%%%%%%%%%



%%%


%elseif (strcmp(alg, "IP")) %Since problem is non-convex is interior point a sensible approach?

        opt=optimoptions('lsqcurvefit', 'StepTolerance',1e-12, 'DiffMinChange', 0.01, 'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, 'Algorithm', 'interior-point');




%%% Local optimisation
min_params=[0.02,0.02,0.02,0.005*ones(1,12), 0.01*ones(1,6), 50*ones(1,6), 5,5];
max_params=[8,8,8,0.1*ones(1,12), 0.75*ones(1,6), 50000*ones(1,6), 20,20];
%init_estimate=params_of_interest(model_obj);

%obj=@(params)obj_func(params, [v1,v2],[q1,q2,q3], model_obj, els);
obj=@(params, input)sim_output_all(params, input, model_obj, els);

tic
%params=lsqnonlin(obj, init_estimate, min_params, max_params,[],[],[],[],[],opt);
params=lsqcurvefit(obj, init_estimate, [v1,v2],[q1,q2,q3], min_params, max_params,[],[],[],[],[],opt);
opt_time=toc;

%%%%%%%%%%
model_obj.params.k1=params(1);
model_obj.params.k2=params(2);
model_obj.params.k3=params(3);
A_params=params(4:15);
model_obj.m.irc.a2=params(16:21);
model_obj.m.irc.a3=params(22:27);
model_obj.tend.ei.r1=params(28);
model_obj.tend.ei.r2=params(29);


num_muscles=length(model_obj.gen.arr_map_obj.musc_arr);
count=1;
for i=1:length(els)
    [a,b]=return_arr_index(els(i),4);
    for m=1:num_muscles
        model_obj.gen.arr_map_obj.musc_arr{m}(a,b)=A_params(count);
        count=count+1;
    end
end


tic
[q1_val_norm, q2_val_norm, q3_val_norm, ~]=assessFit_newData(model_obj, q1_val, q2_val, q3_val,v1, v2); %This function needs updating(???)
toc




end



%% Functions
function param_vec=params_of_interest(model_obj)
params=model_obj.params; m=model_obj.m; tend=model_obj.tend;
param_vec=[params.k1, params.k2, params.k3, m.max_force, m.irc.a2, m.irc.a3, tend.ei.r1, tend.ei.r1];
end

function total_norm=obj_func(params, in_data, out_data, model_obj, els)
q_arr_sim=sim_output_all(params, in_data, model_obj, els);

err_vec=[rad2deg(q_arr_sim(:,1))-out_data(:,1);rad2deg(q_arr_sim(:,2))-out_data(:,2);rad2deg(q_arr_sim(:,3))-out_data(:,3)];

total_norm=norm(err_vec);
end





function q_arr_sim=sim_output_all_ms(params, in_data, model_obj, els)
model_obj.params.k1=params(1); model_obj.params.k2=params(2); model_obj.params.k3=params(3);
A_params=params(4:15);
model_obj.m.irc.a2=params(16:21);
model_obj.m.irc.a3=params(22:27);
model_obj.tend.ei.r1=params(28);
model_obj.tend.ei.r2=params(29);

num_muscles=length(model_obj.gen.arr_map_obj.musc_arr);
count=1;
for i=1:length(els)
    [a,b]=return_arr_index(els(i),4);
    for m=1:num_muscles
        model_obj.gen.arr_map_obj.musc_arr{m}(a,b)=A_params(count);
        count=count+1;
    end
end

if(size(in_data,2)~=2)
    in_data=in_data';
end

% q1=zeros(size(in_data,1),1); q2=zeros(size(in_data,1),1); q3=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1(i), q2(i), q3(i)]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, els);
% end

tic
[~,~,q]=sim_dynamic_response_Soska(0.025*size(in_data,1),in_data, model_obj,els,24,0);
toc

window=0.5/0.025;

q_arr_sim=rad2deg(q(1:end-1,1:3)); %Full output
%q_arr_sim=rad2deg(mean(q(1:end-window,1:3),1)); %steady-state output
end

% %%%%%%%% Without IRC params
% function param_vec=params_of_interest2(model_obj)
% params=model_obj.params; m=model_obj.m;
% param_vec=[params.k1, params.k2, m.max_force];
% end
% 
% function total_norm=obj_func2(params, in_data, out_data, model_obj)
% els=[7,22];
% model_obj.params.k1=params(1);
% model_obj.params.k2=params(2);
% model_obj.m.max_force=params(3:8);
% model_obj.m.irc.a1=params(3:8);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% if(size(out_data,2)~=2)
%     out_data=out_data';
% end
% 
% q1_arr_sim=zeros(size(in_data,1),1); q2_arr_sim=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1_arr_sim(i),q2_arr_sim(i), ~]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, els);
% end
% 
% err_vec=[rad2deg(q1_arr_sim)-out_data(:,1);rad2deg(q2_arr_sim)-out_data(:,2)];
% 
% total_norm=norm(err_vec);
% end
% 
% 
% function q_arr_sim=sim_output_k_mf(params, in_data, model_obj)
% model_obj.params.k1=params(1); model_obj.params.k2=params(2);
% model_obj.m.max_force=params(3:8);
% model_obj.m.irc.a1=params(3:8);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% q1=zeros(size(in_data,1),1); q2=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1(i), q2(i)]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, [7,22]);
% end
% %[q1,~, ~]=simulate_response_time(model_obj, in_data(:,1), in_data(:,2));
% q_arr_sim=[rad2deg(q1), rad2deg(q2)];
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%% Only stiffness params
% 
% function q_arr_sim=sim_output_k1_k2(params, in_data, model_obj)
% model_obj.params.k1=params(1); model_obj.params.k2=params(2);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% q1=zeros(size(in_data,1),1); q2=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1(i), q2(i)]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, [7,22]);
% end
% %[q1,~, ~]=simulate_response_time(model_obj, in_data(:,1), in_data(:,2));
% q_arr_sim=[rad2deg(q1), rad2deg(q2)];
% end
% 
% 
% function q1_arr_sim=sim_output_k1(params, in_data, model_obj)
% model_obj.params.k1=params(1);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% q1=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1(i)]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, [7,22]);
% end
% %[q1,~, ~]=simulate_response_time(model_obj, in_data(:,1), in_data(:,2));
% q1_arr_sim=rad2deg(q1);
% end
% 
% 
% function q2_arr_sim=sim_output_k2(params, in_data, model_obj)
% model_obj.params.k2=params(1);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% q2=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [~,q2(i)]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, [7,22]);
% end
% 
% %[~,q2, ~]=simulate_response_time(model_obj, in_data(:,1), in_data(:,2));
% q2_arr_sim=rad2deg(q2);
% end
% 
% %%%
% 
% function total_norm=obj_func3(params, in_data, out_data, model_obj)
% els=[7,22];
% model_obj.params.k1=params(1);
% model_obj.params.k2=params(2);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% if(size(out_data,2)~=2)
%     out_data=out_data';
% end
% 
% q1_arr_sim=zeros(size(in_data,1),1); q2_arr_sim=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1_arr_sim(i),q2_arr_sim(i), ~]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, els);
% end
% 
% err_vec=[rad2deg(q1_arr_sim)-out_data(:,1);rad2deg(q2_arr_sim)-out_data(:,2)];
% 
% total_norm=norm(err_vec);
% end
% 
% 
% 
% 
% function total_norm=obj_func_k1(params, in_data, out_data, model_obj)
% els=[7,22];
% model_obj.params.k1=params(1);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% if(size(out_data,2)~=2)
%     out_data=out_data';
% end
% 
% q1_arr_sim=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [q1_arr_sim(i),~, ~]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, els);
% end
% 
% err_vec=[rad2deg(q1_arr_sim)-out_data(:,1)];
% 
% total_norm=norm(err_vec);
% end
% 
% 
% function total_norm=obj_func_k2(params, in_data, out_data, model_obj)
% els=[7,22];
% model_obj.params.k2=params(1);
% 
% if(size(in_data,2)~=2)
%     in_data=in_data';
% end
% 
% if(size(out_data,2)~=2)
%     out_data=out_data';
% end
% 
% q2_arr_sim=zeros(size(in_data,1),1);
% for i=1:size(in_data,1)
%     [~,q2_arr_sim(i),~,]=simulate_response_els(model_obj, in_data(i,1), in_data(i,2), 0, NaN, els);
% end
% 
% err_vec=[rad2deg(q2_arr_sim)-out_data(:,1)];
% 
% total_norm=norm(err_vec);
% end
% %%%%%%%%%%% Bisection approach %%%%%%%
% function e_norm_grad=find_grad_k2(k2, q2_in, v_data, model_obj)
% %Finds the gradient of the function at a particular point using values
% %either side
% delta_k=0.02;
% 
% e_norm1=return_enorm_k2(k2+delta_k, q2_in, v_data, model_obj);
% e_norm2=return_enorm_k2(max([0.005,k2-delta_k]), q2_in, v_data, model_obj);
% 
% e_norm_grad=(e_norm1-e_norm2)/(2*delta_k);
% 
% end
% 
% 
% function e_norm = return_enorm_k2(k2, q2_in, v_data, model_obj)
% %Returns the error norm between the simulated and experimental data
% 
% model_obj.params.k2=k2;
% q2_out=[];
% 
% for i=1:size(v_data,1)
% [~,q2_sim, ~]=simulate_response_els(model_obj, v_data(i,1), v_data(i,2), 0, NaN, [7,22]);
% q2_out=[q2_out; rad2deg(q2_sim)];
% end
% 
% e_norm=norm(q2_in-q2_out);
% 
% end
% %%%
% function e_norm_grad=find_grad_k1(k1, q2_in, v_data, model_obj)
% %Finds the gradient of the function at a particular point using values
% %either side
% delta_k=0.02;
% 
% e_norm1=return_enorm_k1(k1+delta_k, q2_in, v_data, model_obj);
% e_norm2=return_enorm_k1(max([0.005,k1-delta_k]), q2_in, v_data, model_obj);
% 
% e_norm_grad=(e_norm1-e_norm2)/(2*delta_k);
% 
% end
% 
% 
% function e_norm = return_enorm_k1(k1, q1_in, v_data, model_obj)
% %Returns the error norm between the simulated and experimental data
% 
% model_obj.params.k1=k1;
% q1_out=[];
% 
% for i=1:size(v_data,1)
% [q1_sim,~, ~]=simulate_response_els(model_obj, v_data(i,1), v_data(i,2), 0, NaN, [7,22]);
% q1_out=[q1_out; rad2deg(q1_sim)];
% end
% 
% e_norm=norm(q1_in-q1_out);
% 
% end
