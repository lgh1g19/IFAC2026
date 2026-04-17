function [dead,sat] = a_to_dead_sat_year2(delta, gamma)
%Mapping from delta/gamma to deadband/ saturation parameter values

dead=log((gamma+20)/19)/delta; %Eqn (40) in IFAC paper
sat=log(19*gamma+20)/delta;

end