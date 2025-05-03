function [ID_USGS, temp_distance] = findclosestation_utm(ID_LATLON,USGS_All,MaxDistance)
[ID_LATLON(1), ID_LATLON(2), utmzone] = deg2utm(ID_LATLON(1), ID_LATLON(2));
[USGS_All(:,1), USGS_All(:,2), utmzone] = deg2utm(USGS_All(:,1), USGS_All(:,2));
Distance = sqrt((ID_LATLON(1)-USGS_All(:,1)).^2+(ID_LATLON(2)-USGS_All(:,2)).^2);

if min(Distance) < MaxDistance % 1000 m
    idx = find(Distance==min(Distance));
    ID_USGS = idx(1);
    temp_distance = Distance(idx(1));
%     ID_USGS = double([USGS_All(idx(1),1), min(Distance)]);
else
    ID_USGS = NaN;
    temp_distance = NaN;
end

end