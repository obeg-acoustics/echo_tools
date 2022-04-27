function [weekly_chl] = weekly_chloro_extract(echogram, file, day, weekly_chl)

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

% Extraction of chlorophylle

a = interp2(lon, lat, chl, lon_day, lat_day);
weekly_chl = [weekly_chl; a'];

