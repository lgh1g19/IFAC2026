% Code used to fit parameters and generate accuracy staticstics for full
% data set (vertical/horizontal combined) on Hammmerstein model

clearvars -except mypi mypi_ros tarObj myspidevice
close all


%%%%% Original 2 input data set %%%%%%
cross_corr=1;
data_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper original\Experimental data\Processed data\";
fileNames=["04042025_3718rast_2input_data", "03042025_2412rast_2input_data", "03042025_1611rast_2input_data", "02042025_0517rast_2input_data", "01042025_1015rast_2input_data", "01042025_4012rast_2input_data", "27032025_5011rast_2input_data", "27032025_3508rast_2input_data"];%"27032025_5011rast_2input_data"; %["27032025_3508rast_2input_data"];

data_dir_save="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper updated\Hammerstein\Fitted models\";
num_inputs=2;
%%


joints=[1,16,18];
num_outputs=length(joints);


Ts=0.025;

num_muscles=2; %Number of muscles used in the model

step_len=5; %Length of each step in the rastering input signal
N_step=step_len/Ts; %Number of timesteps in each step

in_data_cell_full=cell(1, length(fileNames));
time_data_cell_full=cell(1, length(fileNames));
out_data_cell_full=cell(num_outputs, length(fileNames));
mean_CI_arr=zeros(num_outputs, length(fileNames));
max_comb_arr=zeros(1, length(fileNames));

%% Load and format arrays, then compute confidence intervals to illustrate variability

for f=1:length(fileNames)
    date_str=extract_date(fileNames(f)); %Extracts file identifier from the file name

    %Load in experimental data
    load(strcat(data_dir, date_str,"_rast_processed_data_", string(num_inputs)),'in_data_full', 'q_noOut', 'time_data_full', 'num_inputs');

    % %Plot 95% confidence intervals
    figure;
    for out=1:num_outputs
        subplot(num_outputs,1,out)
        CI=plot_conf_and_data(time_data_full(:,1)', q_noOut{joints(out)},1);
        mean_CI_arr(out,f)=mean(CI)/2;
    end


    %Populate cell arrays with input/output data
    for out=1:num_outputs
        out_data_cell_full{out,f}=q_noOut{joints(out)};
    end
    in_data_cell_full{f}=in_data_full(:,1:num_inputs);
    time_data_cell_full{f}=time_data_full;

end


mean_CI_arr=round(mean_CI_arr', 3, 'significant');



params_arr=zeros(length(fileNames), num_muscles*(num_inputs+num_outputs+1));
params_arr_lin=zeros(length(fileNames), num_outputs+1);
err_norm_cell=cell(num_outputs, length(fileNames));
err_norm_mean=zeros(num_outputs, length(fileNames));
succ_reps=zeros(length(fileNames),4); %Number of successful repetitions of local optimisation


for f=1:length(fileNames)

    q_full=cell(1,num_outputs); q_mean=cell(1,num_outputs);
    for out=1:num_outputs
        q_full{out}=out_data_cell_full{out,f};
        q_mean{out}=mean(q_full{out},2);
    end

    in_data=in_data_cell_full{1,f};

    %Construct file name
    date_str=extract_date(fileNames(f));
    save_fileName=strcat(data_dir_save, date_str, "_fitted_allParams_joints_");
    for out=1:length(joints)
    save_fileName=strcat(save_fileName,string(joints(out)),"_");
    end

    save_fileName=strcat(save_fileName,"numMusc_",string(num_muscles),"_numIn_",string(num_inputs),".mat");

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(~exist(save_fileName, 'file'))
        [in_mean_step, out_mean_step] = format_step_data_general(in_data, q_mean, N_step); %Extract steady-state input-output data from step responses

        %remove repeats in input data
        in_data=in_data(:,1:num_inputs);

       
        
        num_tests=size(q_full{1},2);
        IRC_params_arr_local=zeros(num_tests,(num_inputs+num_outputs+1)*num_muscles);
        lin_params_arr_local=zeros(num_tests,num_outputs+1);
        norm_arr=zeros(num_tests, num_outputs);
        norm_arr_lin=zeros(num_tests, num_outputs);
        run_time_lin=zeros(num_tests, 1);
        run_time_arr=cell(num_tests);

         %Fit model parameters and calculate cross-correlation fitting accuracy
        for test=1:num_tests
            q_data_fit=cell(1, num_outputs); q_data_val=cell(1, num_outputs);
            idx=1:size(q_full{1},2); idx(test)=[];
            for out=1:num_outputs
                q_data_fit{out}=mean(q_full{out}(:,idx),2); %Compute the mean of all experiments except one
                q_data_val{out}=q_full{out}(:,test); %Final experiment is used for validation
            end
            [~, out_fit_step] = format_step_data_general(in_data, q_data_fit, N_step); %Extract steady-state input-output data from step responses
            [~, out_val_step] = format_step_data_general(in_data, q_data_val, N_step);

            %Non-linear parameter fitting (eqn (43) in IFAC paper)
            [IRC_params_arr_local(test,:), norm_arr(test,:), data_for_plotting, succ_reps(f,test),~,run_time_arr{test}]=fit_NL_ss_params_generalised(out_fit_step, out_val_step, in_mean_step, 0, num_muscles); %Might need to check data types being inputted
        
            %Fit linear params (eqn (45) in IFAC paper)
            [lin_params_arr_local(test,:), norm_arr_lin(test,:), run_time_lin(test)]=fit_lin_params_generalised(IRC_params_arr_local(test,:), q_data_fit, q_data_val, in_data);
        end
        IRC_ss_params_full=IRC_params_arr_local;


        lin_params_mean=mean(lin_params_arr_local,1);
        err_norm_IRC=mean(norm_arr,1);
        err_norm_lin=mean(norm_arr_lin,1);
        save(save_fileName, 'IRC_ss_params_full','lin_params_mean','lin_params_arr_local', 'in_data', 'q_full', 'err_norm_IRC', 'err_norm_lin','data_for_plotting', 'joints', 'num_muscles','run_time_arr', 'run_time_lin');
    %%
    else
        load(save_fileName, 'IRC_ss_params', 'IRC_ss_params_full','lin_params_mean','lin_params_arr_local', 'in_data', 'q_full', 'err_norm_IRC', 'err_norm_lin','data_for_plotting', 'joints', 'num_muscles');
        lin_params_mean=mean(lin_params_arr_local,1);
    end

    err_norm_mean(1:num_outputs,f)=err_norm_lin';

    %%%%% Plot fitting results %%%%%%%%
    in_data_all=[];
    for i=1:size(in_data,2)/num_inputs
        in_data_all=[in_data_all;in_data(:,(i-1)*num_inputs+1:i*num_inputs)];
    end

    q_data_all=cell(1, length(q_full));

    for out=1:num_outputs
        q_data_all{out}=q_full{out}(:); %Stack columns of matrix
    end

    [in_step, out_step]=format_step_data_general(in_data_all, q_data_all, N_step);

    q_off=zeros(1, num_outputs);

    for out=1:num_outputs
        q_off(out)=find_offset(mean(q_full{out},2), in_data);
    end


    figure;
    for out=1:num_outputs
        subplot(num_outputs,1,out)
        for test=1:size(IRC_ss_params_full,1)
            w_arr=IRC_ss_combined_2input(IRC_ss_params_full(test,:), in_data, num_inputs, num_outputs);
            q_sim=sim_system_w_b_k_generalised(lin_params_arr_local(test,:), w_arr);
            q_sim(:,out)=q_off(out)-q_sim(:,out);
            plot(q_sim(:,out),'k')
            hold on
        end
        plot(q_full{out});
        xlabel('Step number');
        ylabel('Joint output');

    end
    %%%%%%%%%%%%


end


%%


NMSE=zeros(length(fileNames),num_outputs);
for f=1:length(fileNames)
for out=1:num_outputs
    x=err_norm_mean(out,f);
    NMSE(f,out)=(1-x/100);
end
end

NMSE(1,3)=NaN; NMSE(2,1)=NaN; NMSE(6,3)=NaN; %Ignore data with high response variability

mean_NMSE=mean_w_NaN(NMSE); %Compute mean of all other results

%%

%Compute mean and std of run time
run_time_mean_std=zeros(length(fileNames),2);

for f=1:length(fileNames)
    run_times=[];
    for test=1:size(run_time_arr,2)
        run_times=[run_times;run_time_arr{f}];
    end
    run_time_mean_std(f,1)=round(mean(run_times),3);
    run_time_mean_std(f,2)=round(std(run_times),3);
end

%% Functions

function mean_params=mean_over_ds(param_arr, num_inputs, num_outputs)
%Takes the mean of db/sat equivalent parameter definitions, then converts
%back to delta/gamma params
nz=find(sum(param_arr,2));
param_arr=param_arr(nz,:);

num_muscles=length(param_arr)/(num_inputs+num_outputs+1);
mean_params=zeros(1,size(param_arr,2)); mean_params(1:num_outputs*num_muscles)=mean(param_arr(:,1:num_outputs*num_muscles),1);

for m=1:num_muscles
ds_arr=zeros(size(param_arr,1),num_inputs+1);
for i=1:size(param_arr,1)
[ds_arr(i,1),ds_arr(i,end)]=a_to_dead_sat_year2(param_arr(i,num_outputs*num_muscles+(num_inputs+1)*m-num_inputs), param_arr(i,num_outputs*num_muscles+(num_inputs+1)*m));

for j=1:num_inputs-1
ds_arr(i,j+1)=a_to_dead_sat_year2(param_arr(i,num_outputs*num_muscles+(num_inputs+1)*m-num_inputs+j), param_arr(i,num_outputs*num_muscles+(num_inputs+1)*m));
end
end

mean_params(num_outputs*num_muscles+(num_inputs+1)*m-num_inputs:num_outputs*num_muscles+(num_inputs+1)*m)=ds_to_ddg_params(mean(ds_arr,1), num_inputs, num_outputs);
end

end

