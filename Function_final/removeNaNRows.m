function cleanedData = removeNaNRows(data)
    % Check if the input is a table
    if istable(data)
        % For tables, use the 'any' function along with 'ismissing'
        rowsToKeep = ~any(ismissing(data), 2);
        cleanedData = data(rowsToKeep, :);
    else
        % For matrices or arrays, use the 'isnan' function
        rowsToKeep = ~any(isnan(data), 2);
        cleanedData = data(rowsToKeep, :);
    end
    
    % Display information about removed rows
    numRowsRemoved = size(data, 1) - size(cleanedData, 1);
end