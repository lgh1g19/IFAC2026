function [delta, gamma, fval] = dead_sat_to_a_year2(dead,sat)%#codegen
%DEAD_SAT_TO_A_YEAR2 Using analytic approach to find values of gamma and
%delta from dead/sat values 

%i.e. computing the inverse of (40) in IFAC paper


%%% Using Matlab eqn solver %%%
in_ratio=sat/dead;
syms gmma
eqn=log(19*gmma+20)/log(gmma/19+20/19)-in_ratio;

gamma=double(vpasolve(eqn,gmma));


fval=log(19*gamma+20)/log(gamma/19+20/19)-in_ratio;
delta=log(19*gamma+20)/sat;

%%%





end
