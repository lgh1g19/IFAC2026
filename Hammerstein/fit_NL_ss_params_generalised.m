function [params_IRC_ss, norm_err, data_for_plotting, successful_reps, err_over_time, run_time_arr] = fit_NL_ss_params_generalised(q_cell, q_test_cell, in_data, to_plot, num_muscles)
%Non-linear fitting code to solve optimisation (43) in IFAC paper


if(~isscalar(num_muscles))
    warning('Invalid value entered for number of muscles. Using default of l=2')
    num_muscles=2;
end

%%% Ensuring column vectors in cell
for out=1:length(q_cell)
    if((size(q_cell{out},1))==1)
        q_cell{out}=q_cell{out}';
    end
    if((size(q_test_cell{out},1))==1)
        q_test_cell{out}=q_test_cell{out}';
    end
end
%%%

q_arr=cell_2_arr_cat(q_cell);
q_test_arr=cell_2_arr_cat(q_test_cell);

for out=1:length(q_cell) %Flagging if output arrays aren't the same length
    if(length(q_cell{out})~=size(q_arr,1))
        warning("Dimensions of output arrays don't match")
    end
end


for in=1:length(in_data)
    if(isscalar(size(in_data{in},1)))
        in_data{in}=in_data{in}';
    end
end

in_data_fit=cell_2_arr_cat(in_data);
in_data_val=cell_2_arr_cat(in_data);


num_inputs=size(in_data,2);
num_outputs=size(q_arr,2);



successful_reps=0; %Keep track of whether any of the optimisations fail

num_reps=50; %How many initial start points are tested for each algorithm
err_over_time=nan(num_reps,num_outputs);

num_params=(num_inputs+num_outputs+1)*num_muscles;

%Generates optimally fitted non-linear and steady-state parameters (i.e.
%all static parameters) using global optimisation
% Designed to fit discrete points of rastering data, rather than continuous
% response (also the first element of the arrays should correspond to zero input)


lookup_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Data\Year 2\July\Hammerstein EMMILC\";
load(strcat(lookup_dir, "gamma_lookup_table.mat"),'lookup_obj');

%Acceptable range of deadband and saturation parameter values
db_range=[20,280];
sat_range=[42,600];

db_sat_min=repmat([repmat(db_range(1), [1,num_inputs]),sat_range(1)],[1,num_muscles]);
db_sat_max=repmat([repmat(db_range(2), [1,num_inputs]),sat_range(2)],[1,num_muscles]);


Ts=0.025;


%Remove resting angle offset from experimental data
q_off=zeros(1,num_outputs); q_off_test=zeros(1,num_outputs);
q=zeros(size(q_arr)); q_test=zeros(size(q_arr));
for out=1:num_outputs
    q_off(out)=find_offset(q_arr(:,out),in_data_fit);
    q_off_test(out)=find_offset(q_test_arr(:,out),in_data_fit);
    q(:,out)=q_off(out)-q_arr(:,out);
    q_test(:,out)=q_off_test(out)-q_test_arr(:,out);
end




%%%%%%%
%Non-linear constraints corresponding to eqn (41) in IFAC paper
nl_constr=@(params)nonlcon_sat2(params, sat_range, num_inputs, num_outputs); %Is this constraint actually consistent with the paper?
max_c=150;


%************
%Linear inequality constraints (though these are already implemented in the non-linear constraint function)
if(num_inputs==1)
    buffer_mat=zeros([(2*(num_inputs+1))*num_muscles,(num_inputs+1)*num_muscles]);
else
    buffer_mat=zeros([(2*(num_inputs+1)+1)*num_muscles,(num_inputs+1)*num_muscles]);
end

for p=1:((num_inputs+1)*num_muscles)
    buffer_mat(2*p-1:2*p,p)=[1;-1];
end
if(num_inputs>1)
    for p=1:num_muscles
        buffer_mat(2*(num_inputs+1)*num_muscles+p,3*p-2:3*p-1)=[1,-1]; %%%% I think the 3's here need replacing, but need to think carefully about how to do that %%%%%%%
    end
end

if(num_inputs==1)
    A_constr=[zeros(2*(num_inputs+1)*num_muscles,num_outputs*num_muscles), buffer_mat];
else
    A_constr=[zeros((2*(num_inputs+1)+1)*num_muscles,num_outputs*num_muscles), buffer_mat];
end

if(num_inputs==1)
    B_constr=[repmat([repmat([db_range(2);-db_range(1)],[num_inputs,1]);sat_range(2); -sat_range(1)],[num_muscles,1])];
else
    B_constr=[repmat([repmat([db_range(2);-db_range(1)],[num_inputs,1]);sat_range(2); -sat_range(1)],[num_muscles,1]);zeros([num_muscles,1])];
end

norm_err=zeros(1,num_outputs); params_IRC_ss=zeros(1,num_params);


%for debugging
params_log=[]; err_log=[];
run_time_arr=[];



%%%%%%%%%%%%%% Optimisation %%%%%%%%%%%%%%%
for rep=1:num_reps
    %%% Local optimisation
        obj_local=@(params, in_data)obj_func_local(params, in_data, lookup_obj, num_outputs);
        options = optimoptions('lsqcurvefit', 'Algorithm', 'interior-point');



    %%% Generate random initial parameter values
        c_params=rand([1,num_outputs*num_muscles])*(2*max_c)-max_c;
        init_estimate=c_params;
        for m=1:num_muscles
            db_vals=rand([1,num_inputs])*(db_range(2)-db_range(1))+db_range(1);
            sat1=rand(1)*(sat_range(2)-db_vals(1))+db_vals(1);
            if(num_inputs==1)
                    init_estimate=[init_estimate,db_vals(1),sat1];
            else

                    init_estimate=[init_estimate,db_vals, sat1];

            end
        end
    %%%


        tic
            %Use local optimisation from randomly generated start-point to
            %find an estimate of optimal parameter values
            params_db_sat=lsqcurvefit(obj_local, init_estimate, in_data_fit, q, [repmat(-max_c,[1,num_outputs*num_muscles]),  db_sat_min], [repmat(max_c,[1,num_outputs*num_muscles]), db_sat_max], A_constr,B_constr,[],[],nl_constr,options);
            params_local=zeros(1,num_params); params_local(1:num_outputs*num_muscles)=params_db_sat(1:num_outputs*num_muscles);
            
            %Transforms deadband/ saturation parameters to delta/gamma
            for m=1:num_muscles
                params_local(num_outputs*num_muscles+((num_inputs+1)*(m-1)+1):num_outputs*num_muscles+((num_inputs+1)*m))=ds_to_ddg_params(params_db_sat(num_outputs*num_muscles+((num_inputs+1)*(m-1)+1):num_outputs*num_muscles+((num_inputs+1)*m)), lookup_obj, num_inputs, num_outputs);
            end
        run_time=toc; run_time_arr=[run_time_arr;run_time];



    %%%
    %Simulate model output
    y_pred=IRC_ss_combined_2input(params_local, in_data_val, num_inputs, num_outputs);
    fitted_response=y_pred;


    % Compute fitting error as a percentage (transformed version of that presented in IFAC paper)
    err_arr=zeros(length(q_test(:,1)),num_outputs); norm_local=zeros(1,num_outputs);

    for out=1:num_outputs
        err_arr(:,out)=fitted_response(:,out)-q_test(:,out);
        norm_local(out)=(1-norm(err_arr(:,out))/norm(q_test(:,out)))*100;

    end

    successful_reps=successful_reps+1;

    %Log optimised parameters and fitting error over each local
    %optimisation
    params_log=[params_log; params_local];
    err_log=[err_log; norm_local];

    if(mean(norm_local)>mean(norm_err))
        norm_err=norm_local;
        params_IRC_ss=params_local;
    end
    err_over_time(rep,:)=norm_err; %Log model fitting error on each repetition

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%% plot
if(to_plot)
    figure;
    for out=1:num_outputs
        subplot(2,1,out)
        plot(-q_test(:,out)+q_off(:,out));
        hold on
        plot(-fitted_response(:,out)+q_off(:,out));
        xlabel('Step number');
        ylabel('Joint response');
        legend('Joint output', 'Fitted model')
        %title('IRC fitting');

    end

    %%%%%%%%%%%%%%%%%
    %This plots the input-output map for the generated model against the
    %steady-state raw data values

    [v_arr,q_cell]=map_gen_Hammerstein_general(10,params_IRC_ss,num_inputs, num_outputs);

    figure;
    for out=1:num_outputs
        subplot(num_outputs,1,out)
        scatter3(in_data_fit(:,1), in_data_fit(:,2), q(:,out))
        hold on
        surf(v_arr(:,1),v_arr(:,2),q_cell{out}', 'FaceAlpha',0.5);

        xlabel('u_1 (\mu s)'); ylabel('u_2 (\mu s)');
        zlabel('Joint response');
    end

end

%Can use this to plot easily plot data and model response
data_for_plotting=cell(1,num_outputs);
for out=1:num_outputs
    data_for_plotting{out}=[(1:length(q_test(:,out)))'*Ts, -q_test(:,out)+q_off(:,out), -fitted_response(:,out)+q_off(:,out)];
end

end

%%


%%%%%%%%%%%%%%%%%%%%%
function y_pred=obj_func_local(params_db_sat, in_data, lookup_obj, num_outputs)
%Parameters entered in order [c1,c2,c3,c4,db1_u1,db1_u2,sat1_u1,db2_u1,db2_u2,sat2_u1]
num_inputs=size(in_data,2);

num_muscles=length(params_db_sat)/(num_inputs+num_outputs+1);
params=zeros(size(params_db_sat)); params(1:num_outputs*num_muscles)=params_db_sat(1:num_outputs*num_muscles);

%Mapping saturation to db values
for m=1:num_muscles
    [params(num_outputs*num_muscles+((num_inputs+1)*(m-1)+1):num_outputs*num_muscles+((num_inputs+1)*m)), ~] = ds_to_ddg_params(params_db_sat(num_outputs*num_muscles+((num_inputs+1)*(m-1)+1):num_outputs*num_muscles+((num_inputs+1)*m)), lookup_obj, num_inputs);
end


y_pred=IRC_ss_combined_2input(params, in_data, num_inputs, num_outputs);

end
%%%%%%%%%%%%



