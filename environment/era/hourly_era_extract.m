function [hourly_vel10, lon_vel10, lat_vel10, time_vel10, distance_vel10] = hourly_era_extract(echogram, file, hourly_vel10, lon_vel10, lat_vel10, time_vel10, distance_vel10)

% Function to extract the wind velocity at surface


% Extraction of the variables in the velocity file

u10 = ncread(file, 'u10');
v10 = ncread(file, 'v10');
vel = sqrt(u10.^2+v10.^2);
lon = ncread(file, 'longitude');
lat = ncread(file, 'latitude');
time = datenum('01-Jan-1900','dd-mmm-yyyy') + double(ncread(file, 'time'))/24;

% Extraction in the echogram of the indexes that are at a specific hour
time_obs = floor(echogram.pings(1).time*24)/24;

hours = unique(time_obs);

vel10 = [];
lon_hours = [];
lat_hours = [];
time_hours = [];
distance_hours = [];
for t = 1:length(hours)
    ind_obs = find(time_obs==hours(t));
    ind = find(time==hours(t));

    lon_hours = [lon_hours,echogram.pings(1).lon(ind_obs)];
    lat_hours = [lat_hours,echogram.pings(1).lat(ind_obs)];
    time_hours = [time_hours,echogram.pings(1).time(ind_obs)];
    distance_hours = [distance_hours,echogram.pings(1).distance(ind_obs)];

    a = interp2(lon, lat, vel(:,:,ind)', echogram.pings(1).lon(ind_obs), echogram.pings(1).lat(ind_obs));
    vel10 = [vel10,a];
end
% Extraction of the daily chlorophylle

hourly_vel10 = [hourly_vel10; vel10'];
lon_vel10 = [lon_vel10; lon_hours'];
lat_vel10 = [lat_vel10; lat_hours'];
time_vel10 = [time_vel10; time_hours'];
distance_vel10 = [distance_vel10; distance_hours'];
