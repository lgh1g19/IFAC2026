function [u_k] = f_array(v_k,arr_map_obj)
%An updated version of array mapping that can deal with parameterisation of
%the array, as well as arrays of different sizes.
%arr_map_obj is an object that defines which elements of the electrode array
% activate each muscle and by how much. This is then used to map the input
% v_k to electrode array activation.

%(Can be used to account for translation and rotation)
obj=arr_map_obj;

if(size(v_k,1)==1)
    v_k_col=v_k';
else
    v_k_col=v_k;
end

R=zeros(obj.num_muscles, obj.height*obj.width);

for i=1:size(R,1)
    for j=1:size(R,2)
        R(i,j)=obj.musc_arr{i}(ceil(j/obj.width),mod(j-1, obj.width)+1);
    end
end

u_k=R*v_k_col;

end

