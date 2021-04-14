function [weekly_sst] = weekly_sst_extract(echogram, file, day, weekly_sst)

% Function to extract the sst data for a specific day


% Extraction of the variables in the sst file

sst = ncread(file, 'sst');
sst = sst';
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);

% Extraction of sst

a = interp2(lon, lat, sst, lon_day, lat_day);
weekly_sst = [weekly_sst; a];

