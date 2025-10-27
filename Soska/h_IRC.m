function [w] = h_IRC(u, m_index, m_params)
%Isometric recruitment curve for muscle denoted by m_index


a1=m_params.max_force(m_index);
a2=m_params.irc.a2(m_index);
a3=m_params.irc.a3(m_index);

w=a1*((exp(a2*u)-1)/(exp(a2*u)+a3));

%%%Linear mapping to simplify things%%%
% w=a1*u/300;

end

