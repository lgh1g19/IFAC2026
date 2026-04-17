function [db_params,sat_params] = separate_ds_params(db_params, sat_params, min_diff)
%Takes in db/sat parameters and returns new values that are all > min_diff
%apart
num_inputs=length(db_params);

if(all(round(sat_params-db_params,1)>=min_diff))
    condition=1;
else
    condition=0;
end


while ~condition
    disp('Separating db and sat');
    %Iterate through each input to check if db/sat are too close together
    for in=1:num_inputs
        if(sat_params(in)-db_params(in)<min_diff)
            sat_params(in)=db_params(in)+min_diff; %Separate db and sat
            idx=1:num_inputs; idx(in)=[]; %Re-scale al other saturation parameters
            sat_params(idx)=[compute_sat_u_n([db_params(in),db_params(idx),sat_params(in)])];
        end
        if(all(round(sat_params-db_params,1)>=min_diff))
            condition=1;
            break
        end
    end

end
end