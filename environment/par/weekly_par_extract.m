function [weekly_par] = weekly_par_extract(echogram, file, day, weekly_par)

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

% Extraction of par

a = interp2(lon, lat, par, lon_day, lat_day);
weekly_par = [weekly_par; a'];

