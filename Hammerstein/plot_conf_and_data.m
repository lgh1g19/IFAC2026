function [CI_size] = plot_conf_and_data(in_data, out_data, to_plot)
%PLOT_CONF_AND_DATA Plots 95% confidence intervals of the inputted data,
%with the actual data itself then plotted on top of this (Can also use to just find the confidence interval size)
x=in_data;
y1=out_data';

N = size(y1,1);                                      % Number of ‘Experiments’ In Data Set
    yMean1 = mean(y1);
    ySEM = std(y1)/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
    CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
    yCI951 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

    if(to_plot)
    confplot(x, yMean1', (yCI951(2,:))', (yCI951(2,:))');
    hold on
    for i=1:size(y1,1)
        plot(x, y1(i,:), 'Color',[0.5 0.5 0.5]);
    end
    end
    CI_size=2*yCI951(2,:);
end

