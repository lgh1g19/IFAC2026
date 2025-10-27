function [dead,sat] = a_to_dead_sat_year2(delta, gamma)
%Improved version of a_to_dead_sat that calcualtes values numercially
%rather than using best fit plots

dead=log(gamma/19+1/20)/delta;
sat=log(19*gamma+20)/delta;

end