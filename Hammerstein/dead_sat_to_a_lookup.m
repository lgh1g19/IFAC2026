function [delta, gamma] = dead_sat_to_a_lookup(dead,sat, lookup_obj)%#codegen
%Modified version of dead_sat_to_a_year2 that speeds up computation by
%using a pre-computed lookup table

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
gamma=lookup_tab(d_idx,s_idx); %Each element of this lookup table gives the value of gamma corresponding to a particular deadband/ saturation value
delta=log(19*gamma+20)/sat;
end
end


end

