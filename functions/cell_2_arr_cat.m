function [array] = cell_2_arr_cat(cell_arr)
%CELL_2_ARR_CAT Takes in a cell array and returns a regular array where
%each column consists of an element of the cell array, concatenated so
%they're all the same length

min_N=find_min_N(cell_arr);

array=[];
for i=1:length(cell_arr)
    array=[array, cell_arr{i}(1:min_N, :)];
end
end

