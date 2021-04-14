function [daily_chl, lon_chloro, lat_chloro, time_chl] = daily_chloro_extract(echogram, file, day, daily_chl, lon_chloro, lat_chloro, time_chl)

% Function to extract the chlorophylle data for a specific day


% Extraction of the variables in the chlorophylle file

chl = ncread(file, 'chlor_a');
chl = chl';
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);

% Extraction of the daily chlorophylle

a = interp2(lon, lat, chl, lon_day, lat_day);
daily_chl = [daily_chl; a];
lon_chloro = [lon_chloro; lon_day];
lat_chloro = [lat_chloro; lat_day];
time_chl = [time_chl; time_day];
