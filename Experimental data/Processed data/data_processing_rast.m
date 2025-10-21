%% Load in input/ output data, reformulate this, and save as file

clear all
close all


%%%%% Original 2 input data set %%%%%%
cross_corr=1;
data_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Data\Year 2\March\Experimental trials\";
fileNames=["04042025_3718rast_2input_data", "04042025_2416rast_2input_data","03042025_2412rast_2input_data", "03042025_1611rast_2input_data", "02042025_0517rast_2input_data", "01042025_1015rast_2input_data", "01042025_4012rast_2input_data", "27032025_5011rast_2input_data", "27032025_3508rast_2input_data"];%"27032025_5011rast_2input_data"; %["27032025_3508rast_2input_data"];


data_dir_save="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Data\Year 2\July\Hammerstein model fitting\";



Ts=0.025;
joints=1:22; %1: Wrist, 12: Middle MCP, 16: Index MCP, 18: Index PIP, 19:Thumb add/abd, 20: Thumb joint 2
num_outputs=length(joints);


in_data_cell_full=cell(1, length(fileNames));
time_data_cell_full=cell(1, length(fileNames));
out_data_cell_full=cell(num_outputs, length(fileNames));
mean_CI_arr=zeros(num_outputs, length(fileNames));
max_comb_arr=zeros(1, length(fileNames));

%% Load and format arrays, then compute confidence intervals to illustrate variability

for f=1:length(fileNames)
    interrim_cell_q=cell(1,num_outputs);
    interrim_cell_in={};
    interrim_cell_q_v=cell(1,num_outputs);
    interrim_cell_q_h=cell(1,num_outputs);
    interrim_cell_in_v={};
    interrim_cell_in_h={};
    interrim_cell_time={};

    load(strcat(data_dir, fileNames(f)))
    date_str=extract_date(fileNames(f));
    max_comb_arr(f)=max(sum(in_data_cell{1,1},2));

    num_inputs=size(in_data_cell{1,1},2);

    [out_data_cell] = remove_camera_issues_interp(out_data_cell); %Get rid of issues caused by camera faults

    for j=1:size(out_data_cell,2)

        N_step=step_len/Ts; %Currently assume this is the same for each repeat (will be true unless I change how I'm approaching the code)

        in_data_v=in_data_cell{1,j}(:,1:num_inputs);
        in_data_h=in_data_cell{2,j}(:,1:num_inputs);

        len_v=floor(length(in_data_v)/N_step)*N_step; in_data_v=in_data_v(1:len_v, :);
        len_h=floor(length(in_data_h)/N_step)*N_step; in_data_h=in_data_h(1:len_h, :);

        time_data=(1:length(in_data_v(:,1))+length(in_data_h(:,1)))'*Ts;


        out_data=cell(1,num_outputs);
        for out=1:num_outputs
            q_arr_v{out}=out_data_cell{1,j}(1:len_v,joints(out));
            q_arr_h{out}=out_data_cell{2,j}(1:len_h,joints(out)); 
        end

        out_data=cell(1,num_outputs);

            interrim_cell_time=[interrim_cell_time, {time_data}];
            interrim_cell_in=[interrim_cell_in, {[in_data_v;in_data_h]}];
        

        for out=1:num_outputs
            interrim_cell_q{out}=[interrim_cell_q{out}, {[q_arr_v{out};q_arr_h{out}]}];
        end


    end

    in_data_full=cell_2_arr_cat(interrim_cell_in);
    in_data_full_v=cell_2_arr_cat(interrim_cell_in_v);
    in_data_full_h=cell_2_arr_cat(interrim_cell_in_h);

    time_data_full=cell_2_arr_cat(interrim_cell_time);


    [q_noOut, out_idx]=clean_cell_data(interrim_cell_q); %Returns cell array with each element being an array corresponding to one joint

    in_data_full(:, [2*out_idx, 2*out_idx-1])=[];


    % %Plot 95% confidence intervals
    figure;
    for out=1:num_outputs
        subplot(num_outputs,1,out)
        CI=plot_conf_and_data(time_data_full(:,1)', q_noOut{out},1);
        mean_CI_arr(out,f)=mean(CI)/2;
    end

    for out=1:num_outputs
        out_data_cell_full{out,f}=q_noOut{out};
    end

    in_data_cell_full{f}=in_data_full;

    time_data_cell_full{f}=time_data_full;

    save(strcat(data_dir, date_str,"_rast_processed_data"),'in_data_full', 'q_noOut', 'time_data_full');%What data directory do I want to save this in?
end


%% Functions

function [q_noOut, els_removed]=clean_cell_data(interrim_cell_q)
% Remove outliers and artifacts from camera
num_outputs=length(interrim_cell_q);
q_arr=cell(size(interrim_cell_q));
q_clean=cell(size(interrim_cell_q));

for out=1:num_outputs
q_arr{out}=cell_2_arr_cat(interrim_cell_q{out});
q_clean{out}=remove_response_jumps(q_arr{out});
end

    [q_noOut, ~, ~, els_removed]=remove_response_outliers_general(q_clean);


end
