%%
function damarea = computearea(DamMap)
for i=1:size(DamMap,1)
%     i
    lat = DamMap(i).Y(1:end-1);  % Latitude values
    lon = DamMap(i).X(1:end-1);  % Longitude values    
%     lat_rad = deg2rad(lat);
%     lon_rad = deg2rad(lon);    
    wgs84 = wgs84Ellipsoid('km');    
    damarea(i,1) = sum(areaint(lat, lon, wgs84));
end
end