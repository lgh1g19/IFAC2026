%Loads in data and finds the overall best fitting accuracy

data_dir_original="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\Model ID IFAC paper\Experimental data\Raw data\";
fileName_arr=["04042025_3718rast_2input_data", "04042025_2416rast_2input_data","03042025_2412rast_2input_data", "03042025_1611rast_2input_data","02042025_0517rast_2input_data", "01042025_1015rast_2input_data", "01042025_4012rast_2input_data", "27032025_5011rast_2input_data", "27032025_3508rast_2input_data"];


%data_dir="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Data\Year 2\May\Soska fitted parameters\";
param_dir_full="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\Model ID IFAC paper\Soska\Fitted models\";


%Participant file name
p_fileName_arr=["04042025_3718Soska_data", "04042025_2416Soska_data","03042025_2412Soska_data", "03042025_1611Soska_data","02042025_0517Soska_data", "01042025_1015Soska_data", "01042025_4012Soska_data", "27032025_5011Soska_data", "27032025_3508Soska_data"];


joints=[1,16,18];

%alg= 'TRR'; %'TRR', 'IP', 'LM'


opt_fitting_mean=-inf(1,length(p_fileName_arr));
best_fit_vals_mean=-inf(3,length(p_fileName_arr));
best_fit_vals_max=-inf(3,length(p_fileName_arr));
best_model_obj=repmat(struct('params', [], 'tend', [],'gen',[], 'm',[]), [1,length(p_fileName_arr)]);
best_model_idx_log=zeros(1, length(p_fileName_arr));

debug_plot=0;


files=dir(param_dir_full);

file_idx=[];

for p=1:length(p_fileName_arr)
    fileName=char(p_fileName_arr(p));
    dateStr=fileName(1:13);
all_fit=[];
    for f=1:length(files)
        
        if(~files(f).isdir)
            fileName2=char(files(f).name);
            if(strcmp(dateStr, fileName2(1:13)))
                %try
                load(strcat(param_dir_full, fileName2), 'fit_q3_arr','fit_q2_arr', 'fit_q1_arr', 'model_obj_autofit_all')
                fit_q1=mean(fit_q1_arr); fit_q2=mean(fit_q2_arr); fit_q3=mean(fit_q3_arr);
                fit_q1_best=max(fit_q1_arr); fit_q2_best=max(fit_q2_arr); fit_q3_best=max(fit_q3_arr);
                mean_fit=mean([fit_q1, fit_q2,fit_q3]);
                mean_fit_arr=mean([fit_q1_arr, fit_q2_arr,fit_q3_arr],2);
                [~,opt_idx]=max(mean_fit_arr);
                
                if(mean_fit>opt_fitting_mean(p))
                    opt_fitting_mean(p)=mean_fit;
                    best_fit_vals_mean(1,p)=fit_q1; best_fit_vals_mean(2,p)=fit_q2; best_fit_vals_mean(3,p)=fit_q3;
                    best_model_obj(p)=model_obj_autofit_all(opt_idx);
                    best_model_idx_log(p)=opt_idx;
                end

                if(fit_q1_best>best_fit_vals_max(1,p))
                    best_fit_vals_max(1,p)=fit_q1_best;
                end

                if(fit_q2_best>best_fit_vals_max(2,p))
                    best_fit_vals_max(2,p)=fit_q2_best;
                end

                if(fit_q3_best>best_fit_vals_max(3,p))
                    best_fit_vals_max(3,p)=fit_q3_best;
                end

                all_fit=[all_fit;[fit_q1,fit_q2,fit_q3]];

                if(debug_plot)
                    load(strcat(data_dir_original, fileName_arr(p)), 'in_data_cell', 'out_data_cell')
                    data_v1=[in_data_cell{1,1}(:,1);in_data_cell{2,1}(:,1)]; data_v2=[in_data_cell{1,1}(:,2);in_data_cell{2,1}(:,2)];
                    num_tests=size(out_data_cell,2);
                    data_q1=[]; data_q2=[]; data_q3=[];
                    for t=1:num_tests
                        data_q1=[data_q1,[out_data_cell{1,t}(:,joints(1));out_data_cell{2,t}(:,joints(1))]];
                        data_q2=[data_q2,[out_data_cell{1,t}(:,joints(2));out_data_cell{2,t}(:,joints(2))]];
                        data_q3=[data_q3,[out_data_cell{1,t}(:,joints(3));out_data_cell{2,t}(:,joints(3))]];
                    end

                    [f_q1,f_q2,f_q3]=assessFit_newData(model_obj_autofit_all(1), data_q1,data_q2,data_q3,data_v1,data_v2);
                end

                % if(fit_q1_arr>best_fit_vals(1,p))
                %     best_fit_vals(1,p)=fit_q1_arr;
                % end
                % 
                % if(fit_q2_arr>best_fit_vals(2,p))
                %     best_fit_vals(2,p)=fit_q2_arr;
                % end
                % catch
                % end
            end
        end
        
    end
figure;
        for i=1:3
            subplot(3,1,i)
            plot(all_fit(:,i));
            xlabel('Test'); ylabel('% fitting accuracy');
        end
end


optimal_fit=opt_fitting_mean;

%save('Best_Soska_models.mat', 'best_model_obj', 'best_model_idx_log');