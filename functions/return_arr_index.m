function [a,b] = return_arr_index(d, width)
%RETURN_ARR_INDEX Returns the array index based on the element number (see Lucy EMMILC shifting report figure 2)
a=floor((d-1)/width)+1;
b=mod(d-1,width)+1;
end

