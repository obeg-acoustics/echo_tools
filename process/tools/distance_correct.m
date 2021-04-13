function [echogram] = distance_correct(echogram)

% This function correct a distance vector after binning to match binned time vector 

lat_gps      = echogram.gps.lat;
lon_gps      = echogram.gps.lon;
time_gps     = echogram.gps.time;
distance_gps = echogram.gps.distance;

indt = find(~isnan(time_gps));
indd = find(~isnan(distance_gps));
ind = intersect(indt,indd);

for k = 1:length(echogram.pings)
    time_echo     = echogram.pings(k).time;
    % Correct distance
    echogram.pings(k).distance = interp1(time_gps(ind),distance_gps(ind),time_echo);
    % Correct latitude
    echogram.pings(k).lat = interp1(time_gps(ind),lat_gps(ind),time_echo);
    % Correct longitude
    echogram.pings(k).lon = interp1(time_gps(ind),lon_gps(ind),time_echo);
end
