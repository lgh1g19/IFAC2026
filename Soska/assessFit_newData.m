function [fit_q1, fit_q2, fit_q3, q1_s_full, q2_s_full, q3_s_full] = assessFit_newData(model_obj, q1,q2,q3,v1,v2)
%ASSESSFIT Returns the % fit of the data given a particular model object.
%Data given in radians
to_plot=1;


%Simulate model response
[~,~,q]=sim_dynamic_response_Soska(0.025*length(v1),[v1,v2], model_obj);
q=rad2deg(q);


q1_s_full=q(1:length(q1),1);
q2_s_full=q(1:length(q2),2);
q3_s_full=q(1:length(q3),3);




q1_off=find_offset(q1,[v1,v2]); %Find offset (resting angle) fom recorded output data (denoted by r in IFAC paper)
q2_off=find_offset(q2,[v1,v2]);
q3_off=find_offset(q3,[v1,v2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qi_full is experimental data, qi_s_full is model output, qi_off is
%offset

fit_q1=(1-norm(q1-q1_s_full)/norm(q1-q1_off))*100; %Assumes initial output corresponds to zero input
fit_q2=(1-norm(q2-q2_s_full)/norm(q2-q2_off))*100;
fit_q3=(1-norm(q3-q3_s_full)/norm(q3-q3_off))*100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if(to_plot) %Plot data and model if desired
figure;
    subplot(3,1,1)
    plot(q1_s_full,'k');
    hold on
    plot(q1);
   xlabel('Step number');
    ylabel('Wrist angle');


    subplot(3,1,2)
    plot(q2_s_full,'k');
    hold on
    plot(q2);
    xlabel('Step number');
    ylabel('MCP angle');

    subplot(3,1,3)
    plot(q3_s_full,'k');
    hold on
    plot(q3);
    xlabel('Step number');
    ylabel('PIP angle');
%%

    
end
end

