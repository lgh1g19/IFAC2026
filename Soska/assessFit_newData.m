function [fit_q1, fit_q2, fit_q3, q1_sim_arr, q2_sim_arr, q3_sim_arr] = assessFit_newData(model_obj, q1,q2,q3,v1,v2)
%ASSESSFIT Returns the % fit of the data given a particular model object.
%Data given in radians
to_plot=1;

els=[7,22];

data_arr=[];
q1_sim_arr=zeros(size(q1));
q2_sim_arr=zeros(size(q2));
q3_sim_arr=zeros(size(q3));


[~,~,q]=sim_dynamic_response_Soska(0.025*length(v1),[v1,v2], model_obj,els,24,0);
q=rad2deg(q);

q1_full=q1;
q2_full=q2;
q3_full=q3;
q1_s_full=q(1:length(q1_full),1);
q2_s_full=q(1:length(q2_full),2);
q3_s_full=q(1:length(q3_full),3);




q1_off=find_offset(q1_full,[v1,v2]);
q2_off=find_offset(q2_full,[v1,v2]);
q3_off=find_offset(q3_full,[v1,v2]);

fit_q1=(1-norm(q1_full-q1_s_full)/norm(q1_full-q1_off))*100; %Assumes initial output corresponds to zero input
fit_q2=(1-norm(q2_full-q2_s_full)/norm(q2_full-q2_off))*100;
fit_q3=(1-norm(q3_full-q3_s_full)/norm(q3_full-q3_off))*100;

if(to_plot)
figure;
    subplot(3,1,1)
    plot(q1_s_full,'k');
    hold on
    plot(q1_full);
   xlabel('Step number');
    ylabel('Wrist angle');


    subplot(3,1,2)
    plot(q2_s_full,'k');
    hold on
    plot(q2_full);
    xlabel('Step number');
    ylabel('MCP angle');

    subplot(3,1,3)
    plot(q3_s_full,'k');
    hold on
    plot(q3_full);
    xlabel('Step number');
    ylabel('PIP angle');
%%
    % figure;
    % subplot(2,1,1)
    % scatter3(v1_full, v2_full, q1_full);
    % hold on
    % scatter3(v1_full, v2_full, q1_s_full);
    % %legend('data', 'model');
    %  xlabel('v1');
    % ylabel('v2');
    % zlabel('q1');
    % 
    % subplot(2,1,2)
    % scatter3(v1_full, v2_full, q2_full);
    % hold on
    % scatter3(v1_full, v2_full, q2_s_full);
    % xlabel('v1');
    % ylabel('v2');
    % zlabel('q2');
    
end
end

