function [flood_events, event_peaks, event_dates] = find_flood_events(flow_data)
    % flow_data: vector of daily flow values
    % dates: vector of corresponding dates (as datetime objects)
    
    % Calculate the 95th percentile threshold
    threshold = prctile(flow_data(flow_data>=0), 95);
   
    % Initialize variables
    flood_events = {};
    event_peaks = [];
    event_dates = [];
    last_end_index = 0;
    
    % Loop through the time series
    for i = 15:length(flow_data)-15
        % Check if this point is a peak above the threshold
        if flow_data(i) > threshold && ...
           flow_data(i) == max([flow_data(i-14:i+15)])
            
            % Check if this peak is after the last event
            if i > last_end_index
                % Define the 30-day window
                start_index = i - 14;
                end_index = i + 15;
                
                % Extract the 30-day event
                event = flow_data(start_index:end_index);
                event_dates_range = [start_index:1:end_index];
                
                % Store the event, peak, and date
                flood_events{end+1} = event;
                event_peaks(end+1) = flow_data(i);
                event_dates{end+1} = event_dates_range;
                
                % Update the last end index
                last_end_index = end_index;
            end
        end
    end
end

