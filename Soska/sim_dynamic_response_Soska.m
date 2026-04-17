function [timeSeries,x_full, qout_sampled]=sim_dynamic_response_Soska(T, full_input, model_obj)
%Simulates the model response to an arbitrary input

els=[7,22];  %Elements of the array being stimulated. Selected to give maximum activation of musscles within the model
total_els=24; %Number of array elements
Ts=0.025; %Sampling time

init_q=[model_obj.params.t_01,model_obj.params.t_02,model_obj.params.t_03]; %Initially at the resting position 
num_joints=model_obj.gen.num_joints;
num_muscles=model_obj.gen.num_muscles;
init_state=zeros(2*num_muscles+2*num_joints, 1);
init_state(1:num_joints)=init_q;


%Construct array mapping matrix
obj=model_obj.gen.arr_map_obj;
R=zeros(obj.num_muscles, obj.height*obj.width);
for i=1:size(R,1)
    for j=1:size(R,2)
        R(i,j)=obj.musc_arr{i}(ceil(j/obj.width),mod(j-1, obj.width)+1);
    end
end


v=zeros(total_els, 1);
u=zeros(size(full_input,1), 6);

%convert to muscle input (i.e. carry out array mapping)
for row=1:size(full_input,1)
    v_in=full_input(row, :);
    for count=1:length(els)
        if(length(v_in)==length(v))
            v(els(count))=v_in(els(count));
        else
            v(els(count))=v_in(count);
        end
    end

    z=R*v;



 for i=1:length(z)
    u(row, :)=z';
 end

end

%Simulate differential equation representing muscle dynamics
[timeSeries, x_full]=ode15s(@(t,x_full)state_func_mlb(t, x_full, u, model_obj, Ts), [0,T-Ts], init_state);


%Interpolate to get constant sampling time
qout_sampled=interp1(timeSeries, x_full, 0:Ts:T);
end