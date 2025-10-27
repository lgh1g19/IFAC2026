function [timeSeries,x_full, qout_sampled]=sim_dynamic_response_Soska(T, full_input, model_obj, els, total_els, noise)


Ts=0.025;

init_q=[model_obj.params.t_01,model_obj.params.t_02,model_obj.params.t_03];
num_joints=model_obj.gen.num_joints;
num_muscles=model_obj.gen.num_muscles;
init_state=zeros(2*num_muscles+2*num_joints, 1);
init_state(1:num_joints)=init_q;

obj=model_obj.gen.arr_map_obj;
R=zeros(obj.num_muscles, obj.height*obj.width);

for i=1:size(R,1)
    for j=1:size(R,2)
        R(i,j)=obj.musc_arr{i}(ceil(j/obj.width),mod(j-1, obj.width)+1);
    end
end


%%%Needs more general setup code from sim_inc_ramp_Tsang
v=zeros(total_els, 1);
u=zeros(size(full_input,1), 6);

%convert to muscle input
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
 %Convert element stimulation to muscle stimulation
 for i=1:length(z)
    u(row, :)=z';
 end

end

[timeSeries, x_full]=ode15s(@(t,x_full)state_func_mlb(t, x_full, u, model_obj, Ts), [0,T-Ts], init_state);


if noise==1
    x_full=awgn(x_full,30);
end


qout_sampled=interp1(timeSeries, x_full, 0:Ts:T);
end