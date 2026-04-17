%Need to finish off annotating

%Code to fit parameters to full dynamic response
%Loads in data and automatically fits models to compute the cross-correlation fitting accuracy

%PLOT USING globalish_fitting_results.m
clear all


data_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper original\Experimental data\Processed data\";
fileName_arr=["04042025_3718rast_2input_data", "03042025_2412rast_2input_data", "03042025_1611rast_2input_data","02042025_0517rast_2input_data", "01042025_1015rast_2input_data", "01042025_4012rast_2input_data", "27032025_5011rast_2input_data", "27032025_3508rast_2input_data"];

param_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper original\Soska\Fitted models\";


joints=[1,16,18]; num_outputs=length(joints);


min_params=[0.02,0.02,0.02,0.005*ones(1,12), 0.01*ones(1,6), 50*ones(1,6), 5,5];
max_params=[8,8,8,0.1*ones(1,12), 0.75*ones(1,6), 50000*ones(1,6), 20,20];


smoothing=1;
fitted_params=cell(1,length(fileName_arr));
q1_fit_arr=[];
q2_fit_arr=[];
q3_fit_arr=[];

plotting=1;

max_tests=100;
num_inputs=2;


for test=1:max_tests %Generate a bunch of data for each participant, then run fitting_results.m to find the best fitting accuracy based on this
for file=1:length(fileName_arr)
    


    date_str=extract_date(fileName_arr(file));
    load(strcat(data_dir, date_str,"_rast_processed_data_", string(num_inputs)),'in_data_full', 'q_noOut', 'time_data_full', 'num_inputs');
    %load(strcat(data_dir, date_str,"_rast_processed_data"), 'in_data_full', 'q_noOut', 'time_data_full', 'num_inputs');
    data_q1=q_noOut{joints(1)}; data_q2=q_noOut{joints(2)}; data_q3=q_noOut{joints(3)}; %Data for all trials
    data_v1=in_data_full(:,1); data_v2=in_data_full(:,2);
    num_tests=size(data_q1,2);

    param_file_name=fileName_arr(file);

    %Randomly select initial parameters for optimisation
    init_params=zeros(size(max_params));
    for i=1:length(max_params)
        init_params(i)=rand(1)*(max_params(i)-min_params(i))+min_params(i);
        init_params(i)=round(init_params(i),3,"significant");
    end
    param_file_name=strcat(param_file_name, "_",string(datetime('now', 'Format', 'ss_ddMMyyyy_mmHH')),".mat");


        model_obj_autofit_all=repmat(struct('params', [], 'tend', [],'gen',[], 'm',[]), [1,size(data_q1,2)]);
        fit_q1_arr=zeros(size(data_q1,2),1); fit_q2_arr=zeros(size(data_q1,2),1); fit_q3_arr=zeros(size(data_q1,2),1);
        opt_time=zeros(size(data_q1,2),1);
        for t=1:size(data_q1,2) %Fit model for each combination of data (cross-validation)
            idx=1:size(data_q1,2); idx(t)=[];
            [model_obj_autofit_all(t), fit_q1_arr(t), fit_q2_arr(t), fit_q3_arr(t), model_obj_log, opt_time(t)]=empirical_fitting_Aparams(mean(data_q1(:,idx),2),mean(data_q2(:,idx),2),mean(data_q3(:,idx),2),data_q1(:,t), data_q2(:,t),data_q3(:,t), data_v1, data_v2, init_params);

        end

        save(strcat(param_dir, param_file_name), 'model_obj_log', 'model_obj_autofit_all', 'fit_q3_arr', 'fit_q2_arr', "fit_q1_arr", "init_params", 'opt_time');


end
end


