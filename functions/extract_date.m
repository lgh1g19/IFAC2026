function num_part = extract_date(input_str)
    % Extract the date from a file name string (chatGPT)
    pattern = '^\d+_\d+';
    matches = regexp(input_str, pattern, 'match');
    
    % If a match is found, return it; otherwise, return empty
    if ~isempty(matches)
        num_part = matches{1};
    else
        num_part = '';
    end
end
