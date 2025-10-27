function sat_u_n=compute_sat_u_n(db_sat_params)
%Returns the value of sat_u2,sat_u3, etc. params given db_u1,sat_u1, and
%db_u2,db_u3, ect.
num_inputs=length(db_sat_params)-1;
db_u1=db_sat_params(1); sat_u1=db_sat_params(end); db_u_n=db_sat_params(2:end-1);

sat_u_n=zeros(1,num_inputs-1);
for in=1:num_inputs-1
sat_u_n(in)=(sat_u1*db_u_n(in))/db_u1;
end
end