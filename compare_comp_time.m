% Compare computation time for Hammerstein and Soska models
% Timing results were generated using an Intel Core i7-11700K processor running at 3.6GHz
clear all

data_dir_H="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper original\Hammerstein\Fitted models\";
data_dir_S="C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Year 3 code\IFAC paper original\Soska\Fitted models\";
fileNames=["04042025_3718rast_2input_data", "04042025_2416rast_2input_data","03042025_2412rast_2input_data", "03042025_1611rast_2input_data","02042025_0517rast_2input_data", "01042025_1015rast_2input_data", "01042025_4012rast_2input_data", "27032025_5011rast_2input_data", "27032025_3508rast_2input_data"];

time_arr_full=zeros(length(fileNames),2);
time_arr_std=zeros(length(fileNames),2);

for f=1:length(fileNames)
    date_str=extract_date(fileNames(f));
    files_H=dir(data_dir_H);
    files_S=dir(data_dir_S);

    time_log=[];
        for file=1:length(files_H)
        if(~files_H(file).isdir)
            name=char(files_H(file).name);
            if(strcmp(date_str, name(1:13)))
                load(strcat(data_dir_H, name), 'run_time_arr')
                for i=1:size(run_time_arr,1)
                    time_log=[time_log; run_time_arr{i,1}];
                end
            end
        end

        end
        time_arr_full(f,2)=mean(time_log);
        time_arr_std(f,2)=std(time_log);

         time_log=[];
        for file=1:length(files_S)
        if(~files_S(file).isdir)
            name=char(files_S(file).name);
            if(strcmp(date_str, name(1:13)))
                load(strcat(data_dir_S, name), 'opt_time')
                time_log=[time_log; opt_time];

            end
        end

        end

        time_arr_full(f,1)=mean(time_log);
        time_arr_std(f,1)=std(time_log);

end

time_arr_forReport=round([time_arr_full;mean(time_arr_full,1)],3, 'significant');

time_std_forReport=round(time_arr_std,3, 'significant');

