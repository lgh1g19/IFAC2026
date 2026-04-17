function q_off=find_offset(q_in,in_data)
%Find offset using average over all data corresponding to zero input
sum_in=sum(in_data,2);


if(size(q_in,1)==1)
    q_vec=q_in';
else
    q_vec=q_in;
end

q_off=mean_w_NaN(q_vec(sum_in==0,:),1);

end