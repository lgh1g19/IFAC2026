function [in_mean, out_mean, in_data_arr, out_data_arr] = format_step_data_general(in_data, q_data, N_step)
%FORMAT_STEP_DATA Takes in input and output data from step ramp response,
%and returns mean steady-state values at each step, plus arrays where each
%column corresponds to the response to a single step
%Currently assumes q1_data and q2_data are vectors rather than arrays



out_data=q_data;
num_outputs=length(q_data);
total_steps=floor(length(in_data)/N_step);

num_inputs=size(in_data,2);
%split up data
in_data_arr=cell(1, num_inputs);
out_data_arr=cell(1,num_outputs);
for jnt=1:num_outputs
    out_data_arr{jnt}=zeros(N_step, total_steps);
    for s=1:total_steps
        out_data_arr{jnt}(:,s)=out_data{jnt}(N_step*(s-1)+1:N_step*s); %each column represents response to a different step input
    end
end

for jnt=1:num_inputs
in_data_arr{jnt}=zeros(N_step, total_steps);
for s=1:total_steps
in_data_arr{jnt}(:,s)=in_data(N_step*(s-1)+1:N_step*s, jnt); %each column represents response to a different step input
end
end


%Average over last second
out_mean=cell(1,num_outputs);
in_mean=cell(1,num_inputs);
for jnt=1:num_outputs
out_mean{jnt}=mean(out_data_arr{jnt}(end-40:end, :));
end
for jnt=1:num_inputs
in_mean{jnt}=mean(in_data_arr{jnt}(end-40:end, :));
end

if(num_inputs==1)
in_data_arr=in_data_arr{1};
in_mean=in_mean{1};
end
end

