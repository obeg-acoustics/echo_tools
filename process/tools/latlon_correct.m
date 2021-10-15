function [echogram] = latlon_correct(echogram)

% This function correct a lat/lon vector after binning to match binned time vector 

lat_gps      = echogram.gps.lat;
lon_gps      = echogram.gps.lon;
time_gps     = echogram.gps.time;

ind = find(~isnan(time_gps));

for k = 1:length(echogram.pings)
    time_echo     = echogram.pings(k).time;
    % Correct latitude
    echogram.pings(k).lat = interp1(time_gps(ind),lat_gps(ind),time_echo);
    % Correct longitude
    echogram.pings(k).lon = interp1(time_gps(ind),lon_gps(ind),time_echo);
end
