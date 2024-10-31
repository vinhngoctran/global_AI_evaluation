function [maxStreak, StartEndYear,idx] = checksystematic10(StartTime,data)
DATETIME = [StartTime:days(1):StartTime+days(numel(data)-1)]';
startDate = DATETIME(1);
endDate = DATETIME(end);
years = year(startDate):year(endDate);
completeYears = [];
threshold = 1;  

% Loop through each year
for y = years
    % Extract data for the current year
    yearData = data(year(DATETIME) == y, :);
    yearData = find(yearData>=0);
    % Calculate the number of days expected in this year
    if mod(y, 4) == 0 && (mod(y, 100) ~= 0 || mod(y, 400) == 0)
        expectedDays = 366;  % Leap year
    else
        expectedDays = 365;  % Non-leap year
    end
    
    % Check if the year has at least 95% of its data
    if height(yearData) >= threshold * expectedDays
        completeYears = [completeYears; y];
    end
end

% Find the longest continuous streak of complete years
if ~isempty(completeYears)
    diffs = diff(completeYears);
    streaks = find(diffs > 1);
    streakLengths = diff([0; streaks; length(completeYears)]);
    [maxStreak, maxStreakIndex] = max(streakLengths);
    
    if maxStreakIndex == 1
        streakStart = completeYears(1);
    else
        streakStart = completeYears(streaks(maxStreakIndex-1) + 1);
    end
    streakEnd = streakStart + maxStreak - 1;
    
%     fprintf('Longest continuous streak of complete years: %d years (%d-%d)\n', maxStreak, streakStart, streakEnd);
    StartEndYear = [streakStart,streakEnd];
    idx = find(DATETIME>=datetime(streakStart,1,1) & DATETIME<=datetime(streakEnd,12,31));
else
%     fprintf('No complete years found in the dataset.\n');
    maxStreak = 0;
    StartEndYear = [NaN,NaN];
    idx = NaN;
end
end