function [delta, gamma, fval] = dead_sat_to_a_year2(dead,sat, varargin)%#codegen
%DEAD_SAT_TO_A_YEAR2 Using analytic approach to find values of gamma and
%delta from dead/sat values (notes on p.43 of notebook F)
%max_gamma=500000;
%sum_inputs=sat+dead;
%diff_inputs=sat-dead;
%in_ratio=sum_inputs/diff_inputs;

%Varargin gives initial guess of gamma value to hopefully speed up
%computation

%%%
%warning('Slow code being used - for much faster run-time use dead_sat_to_a_lookup');
%%%

%%% Using Matlab eqn solver %%%
if(coder.target('Matlab'))
in_ratio=sat/dead;
syms gmma
eqn=log(19*gmma+20)/log(gmma/19+20/19)-in_ratio;

if(isempty(varargin))
    gamma=double(vpasolve(eqn,gmma));
elseif(isempty(varargin{1}))
    gamma=double(vpasolve(eqn,gmma));
else
    gamma=double(vpasolve(eqn,gmma, varargin{1}));
end

fval=log(19*gamma+20)/log(gamma/19+20/19)-in_ratio;
delta=log(19*gamma+20)/sat;
else
[delta,gamma]=dead_sat_to_a(dead,sat);
end
%%%





%%
% gamma_arr=5:max_gamma*1000;
% val_arr=zeros(size(gamma_arr));
% for i=1:length(val_arr)
% val_arr(i)=obj_func(gamma_arr(i), in_ratio);
% end
% figure;
% plot(gamma_arr, val_arr)
%%
end



%% Functions
function val=obj_func(gamma, input_ratio)%Function relating gamma to sum_inputs/diff_inputs (want this to be zero)
val=abs(log(gamma^2+(2*19/20)*gamma+1)/log((19*gamma+20)/(gamma/19+1/20))-input_ratio);
%val=abs((log(19*gamma+20)/log(gamma/19+1/20))-input_ratio);
end