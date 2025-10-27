function [close_val, index] = find_closest(value, array)
%FIND_CLOSEST Returns the value of the array element closest to the entered
%value, along with the index of that element
dist=zeros(size(array));

for i=1:size(array,1)
    for j=1:size(array,2)
        dist(i,j)=abs(array(i,j)-value);
    end
end
if(size(array,1)>1 && size(array,2)>1)
index=index_of_smallest(dist);
close_val=array(index(1), index(2));
else
[~,index]=min(dist);
close_val=array(index);
end

end

