function [params, tend, m, gen] = param_return()


%Returns each of the parameters required by the model, as given in Soska_2012_ISIC
%varargin should be pairs of values in the form 'variable name',
%scaling_factor

%addpath('C:\Users\lgh1g19\OneDrive - University of Southampton\PhD\Matlab\Multiple-model ILC\Param_variation\')


%Default params
%Alter to be closer to real values (out of order due to changes in muscle choice)

%%
%R_FDP, R_FDS, R_EI, R_EC, R_ECR, R_ECU
%gen.max_force=[0.15, 1.2, 0.3, 0.3, 0.3, 0.3];%[0.15, 0.5, 0.3, 0.3, 0.3, 0.3]; %Maximum force output from each muscle (first 4 taken from Theodorou, last 2 made up (try to find sources for these))
%gen.max_force=gen.max_force/10;
%gen.musc_names=["FDP", "FDS", "EI", "EC", "ECR", "ECU"];

m.max_force=[0.015, 0.12, 0.05, 0.05, 0.05, 0.05];

%Initialise values (needed for slx implementation)
m.irc.a1=zeros(1,6);
m.irc.a2=zeros(1,6);
m.irc.a3=zeros(1,6);
m.fat.T_rec=0;

gen.max_stim=300;

musc=6;
gen.num_muscles=musc;%7;
gen.num_joints=3;


%% Array mapping
 h=6; w=4;

obj.height=h;
obj.width=w;

obj.musc_arr=cell(1,musc);
obj.musc_arr_ext=cell(1,musc);

obj.shift_v=0;
obj.shift_h=0;
obj.rot=0;

if coder.target('MATLAB')
    obj.musc_target{1}=[2,3]; %Specifies which joint angles are targeted by each muscle (Is this actually used?)
    obj.musc_target{2}=[2,3];
    obj.musc_target{3}=[1,2,3];
    obj.musc_target{4}=[1,2,3];
    obj.musc_target{5}=[1];
    obj.musc_target{6}=[1];
    
    for i=1:musc
    obj.musc_shift{i}=[0,0,0];%Rotation, vertical and horizontal shift of each muscle
    end
end

obj.num_muscles=musc;


%FDP
obj.musc_arr{1}=[zeros(4,4); 0,0,0,0.25;0,0,0,0.25];
%FDS
obj.musc_arr{2}=[zeros(3,4); 0,0,0,0.25;0,0,0,0.5;0,0,0,0.5];
%EI
obj.musc_arr{3}=[zeros(3,4); 0, 0.5,0,0; 0.25, 1,0,0; 0,0.75,0,0];
%EC
obj.musc_arr{4}=[0,0,0.75,0;0,0,1,0;0,0,0.8,0.25;0,0,0.7,0.25;0,0,0.25,0;0,0,0,0];
%ECR
obj.musc_arr{5}=[0,0.25,0.9,0.5;0,1,1,0;0,0.7,0.7,0;0,0.5,0.5,0;0,0,0.25,0;0,0,0,0];
%ECU
obj.musc_arr{6}=[0,0.5,0.25,0;0,0.8,0.25,0;0.25,0.9,0,0;0.25,0.7,0,0;0,0,0,0;0,0,0,0];

%%% Add muscle extension (pad with zeros)
for i=1:6
obj.musc_arr_ext{i}=zeros(10); obj.musc_arr_ext{i}(3:8, 4:7)=obj.musc_arr{i}; 
end



gen.arr_map_obj=obj;

%% Constant definitions of bone and joint structure
len_scale=1;

params.J1=1e-4; params.J2=1e-4; params.J3=1e-4; %Values from thesis
params.b1=0.4; params.b2=0.4; params.b3=0.4; %Values from thesis
params.t_01=2*pi/3; params.t_03=pi/3; params.t_02=deg2rad(80);%pi/2;
%params.k1=6.5; params.k2=0.9; params.k3=0.8; %Values from paper
params.k1=0.8; params.k2=0.8; params.k3=0.8; %Values from thesis


%Tendon constant definitions
tend.fdp.d1=8.32; tend.fdp.d2=5.67; tend.fdp.y1=8.32; tend.fdp.y2=7.5;
tend.fds.d1=9.56; tend.fds.d2=4.13; tend.fds.y1=8.14; tend.fds.y2=6.73;
tend.ecr.h=-11.72; tend.ecr.b=1.14;
tend.ecu.h=-8.51; tend.ecu.b=1.55;

tend.ec.r1=14.12; tend.ec.r2=15;%8.3; %Second parameter picked to give good response (different from other param_return functions)
tend.es.r=2.92;
tend.ei.r1=15; tend.ei.r2=15;%8.82; %Second parameter picked to give good response (and first picked to approximately match EC r1 param)
tend.rb.h=-0.47; tend.rb.b=2.54;
tend.ub.h=0.57; tend.ub.b=1.7;

%Not varying this parameter as it needs to add up to 1 and is just an
%method of linearising the model
tend.w1= 0.3; tend.w2= 0.3; tend.w3= 0.4; %Find values for these

m.omega_n=2.7;




%%

%Values computed from previous parameters 

%Need to initialise here for rpi deployment
params.l1=0; params.l2=0; params.l3=0;
params.c1=0; params.c2=0; params.c3=0;
params.m1=0; params.m2=0; params.m3=0;

params.q_thres1=0; params.q_thres2=0; params.q_thres3=0;
params.q_cutoff1=0; params.q_cutoff2=0;
params.d_thres1=0; params.d_thres2=0;
%Threshold values for joint stiffness to start to increase


params.q_thres3=deg2rad(15);

params.q_thres1=deg2rad(53);
    params.q_cutoff1=deg2rad(48);
    params.q_thres2=deg2rad(-18);
    params.q_cutoff2=deg2rad(-28);


params.d_thres1=params.q_thres1-params.q_cutoff1;
params.d_thres2=params.q_thres2-params.q_cutoff2;

params.l1=0.1*len_scale; params.l2=0.05*len_scale; params.l3=0.06*len_scale; %Values from thesis
params.c1=0.5*params.l1*len_scale; params.c2=0.5*params.l2*len_scale; params.c3=0.5*params.l3*len_scale;

%Using len_scale^2 to be halfway between linear and volume scaling - Don't
%think this would be exactly either but maybe this isn't a valid assumption
params.m1=0.4*len_scale^2; params.m2=0.25*len_scale^2; params.m3=0.2*len_scale^2; %Values from thesis



%%%%%%%% Default values%%%%%%%%%%%%%
d=40; s=260;
[a2,a3]=dead_sat_to_a_year2(d,s);


m.irc.a1=m.max_force; %Elements represent the a1 values of each of the muscles. Order: R_FDP, R_FDS, R_EI, R_EC, R_ECR, R_ECU
m.irc.a2=a2*ones(1, gen.num_muscles);
m.irc.a3=a3*ones(1, gen.num_muscles);

end