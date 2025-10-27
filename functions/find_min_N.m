function [min_N] = find_min_N(cell_arr)
%FIND_MIN_N Finds the minimum length of each element in a cell array
N_arr=zeros(size(cell_arr));
for i=1:size(cell_arr,1)
    for j=1:size(cell_arr,2)
        N_arr(i,j)=size(cell_arr{i,j},1);
    end
end
min_N=min(min(N_arr));
end

