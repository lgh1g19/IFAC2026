function [delta, gamma, fval] = dead_sat_to_a_lookup(dead,sat, lookup_obj)%#codegen
%DEAD_SAT_TO_A_YEAR2 Using analytic approach to find values of gamma and
%delta from dead/sat values (notes on p.43 of notebook F)
%max_gamma=500000;
%sum_inputs=sat+dead;
%diff_inputs=sat-dead;
%in_ratio=sum_inputs/diff_inputs; %????

%Varargin gives initial guess of gamma value to hopefully speed up
%computation


lookup_tab=lookup_obj.table;
d_arr=lookup_obj.d_arr;
s_arr=lookup_obj.s_arr;

if(dead>sat)
    error('Cannot have deadband>saturation');
end
if(sat-dead<20)
    %warning('deadband-saturation difference too small');
end

if(dead<=0); dead=1e-5; end

if(round(sat-dead,1)<5)
    warning('deadband-saturation difference too small'); %This will mess up other calculations so we really want to avoid this!!!
    [delta,gamma]=dead_sat_to_a_year2(dead,dead+5);
else
if(round(dead)>d_arr(end)||round(dead)<d_arr(1))
    warning('Deadband outside of limit');   
    [delta,gamma]=dead_sat_to_a_year2(dead,sat);
elseif(round(sat)>s_arr(end)||round(sat)<s_arr(1))
    warning('Saturation outside of limit');
    [delta,gamma]=dead_sat_to_a_year2(dead,sat);

else
%%% Lookup-table %%%
[~,d_idx]=find_closest(dead, d_arr);
[~,s_idx]=find_closest(sat, s_arr);
gamma=lookup_tab(d_idx,s_idx);
delta=log(19*gamma+20)/sat;
end
end


end



%% Functions
function val=obj_func(gamma, input_ratio)%Function relating gamma to sum_inputs/diff_inputs (want this to be zero)
val=abs(log(gamma^2+(2*19/20)*gamma+1)/log((19*gamma+20)/(gamma/19+1/20))-input_ratio);
%val=abs((log(19*gamma+20)/log(gamma/19+1/20))-input_ratio);
end