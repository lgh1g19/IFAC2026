function [c,ceq]=nonlcon_sat2(params_db_sat, sat_range, num_inputs, num_outputs) %Impose conditions on sat1_u1
% Updated version designed to be consistent with IFAC paper
num_muscles=length(params_db_sat)/(num_inputs+num_outputs+1);
c=[];

%Need to generalise this

for m=1:num_muscles
    db1=params_db_sat(num_outputs*num_muscles+(num_inputs+1)*(m-1)+1);
    db=params_db_sat(num_outputs*num_muscles+(num_inputs+1)*(m-1)+1:num_outputs*num_muscles+(num_inputs+1)*m-1)';
    sat1=params_db_sat(num_outputs*num_muscles+(num_inputs+1)*m);
    sat=[sat1;sat1/db1.*db(2:end)];
    c=[c;sat(2:end)-sat_range(2)*ones(num_inputs-1,1); sat_range(1)*ones(num_inputs-1,1)-sat(2:end); db-sat; sat-58.404*db];
end


ceq=[];
end