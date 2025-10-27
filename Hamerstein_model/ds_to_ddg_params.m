function [ddg_params, ds_params_updated] = ds_to_ddg_params(ds_params, varargin)
%DS_TO_DDG_PARAMS  Converts deadband/sat params to delta1,delta2,...delta_n,gamma
%ds params in order [db1,...,dbn, sat1,...,satn] (though sat params 2-n can be automatically calculated)

%Assumes ratios of deadband and saturation parameters are consistent, but
%if only one saturation value is inputted will automatically scale the
%other sat values

%First varargin element is lookup object, then no. of inputs. Alternatively
%if lookup object not known you can just enter the number of inputs


if(isempty(varargin))
lookup_obj=[];
num_inputs=2;
warning('Number of inputs not specified - defaulting to 2');
elseif(length(varargin)>=2) %Need to check if any of these elements are our lookup table object
    if(isstruct(varargin{1}))
        lookup_obj=varargin{1};
        num_inputs=varargin{2};
    else
        lookup_obj=[];
        num_inputs=varargin{1};
    end

elseif(isscalar(varargin))
    if(isstruct(varargin{1}))
    lookup_obj=varargin{1};
    num_inputs=2;
    else
lookup_obj=[];
num_inputs=varargin{1};
    end
end

%In order of db1_u1,sat1_u1,db2_u2,sat2_u2

%Check consistency of entered parameters (Need to generalise this)
if(length(ds_params)==num_inputs+1)
    sat_params=[ds_params(end),compute_sat_u_n(ds_params)];
    db_params=ds_params([1:end-1]);

%ds_params=[ds_params, compute_sat_u_n(ds_params)]; %Slightly chaos order of [db_u1,sat_u1,db_u2:n, sat_u2:n]
else
    db_params=ds_params(1:end/2);
    sat_params=ds_params(end/2:end);
end
if(round(db_params(1)/sat_params(1),3)~=round(db_params./sat_params,3)) %Ideally want to generalise this check
    warning("Deadband and saturation ratios are different");
end

%% Fixing issues if parameters are too close together
[db_params, sat_params]=separate_ds_params(db_params, sat_params, 5);

%%
delta_arr=zeros(1,num_inputs);
if(isempty(lookup_obj))
[delta_arr(1),gamma]=dead_sat_to_a_year2(db_params(1),sat_params(1));
for in=2:num_inputs
delta_arr(in)=dead_sat_to_a_year2(db_params(in),sat_params(in));
end
else %Using lookup table to hopefully speed things up
[delta_arr(1),gamma]=dead_sat_to_a_lookup(db_params(1),sat_params(1), lookup_obj);
for in=2:num_inputs
delta_arr(in)=dead_sat_to_a_lookup(db_params(in),sat_params(in), lookup_obj);
end
end

ddg_params=[delta_arr,gamma];
ds_params_updated=ds_params;
end