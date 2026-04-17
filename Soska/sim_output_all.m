function q_arr_sim=sim_output_all(params, in_data, model_obj)
%Simulate model response (with specified parameter values) to a given input signal and return all joint
%outputs.
%Used in optimisation

els=[7,22];

model_obj.params.k1=params(1); model_obj.params.k2=params(2); model_obj.params.k3=params(3);
A_params=params(4:15);
model_obj.m.irc.a2=params(16:21);
model_obj.m.irc.a3=params(22:27);
model_obj.tend.ei.r1=params(28);
model_obj.tend.ei.r2=params(29);

num_muscles=length(model_obj.gen.arr_map_obj.musc_arr);
count=1;
for i=1:length(els)
    [a,b]=return_arr_index(els(i),4);
    for m=1:num_muscles
        model_obj.gen.arr_map_obj.musc_arr{m}(a,b)=A_params(count);
        count=count+1;
    end
end

if(size(in_data,2)~=2)
    in_data=in_data';
end


[~,~,q]=sim_dynamic_response_Soska(0.025*size(in_data,1),in_data, model_obj);


q_arr_sim=rad2deg(q(1:end-1,1:3)); %Full output
end