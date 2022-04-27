function [daily_par, lon_par, lat_par, time_par, distance_par] = daily_par_extract(echogram, file, day, daily_par, lon_par, lat_par, time_par, distance_par)

% Function to extract the par data for a specific day


% Extraction of the variables in the par file

par = ncread(file, 'par');
par = par';
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);

% Extraction of the daily par

a = interp2(lon, lat, par, lon_day, lat_day);
daily_par = [daily_par; a'];
lon_par = [lon_par; lon_day'];
lat_par = [lat_par; lat_day'];
time_par = [time_par; time_day'];
distance_par = [distance_par; distance_day'];
