function [daily_sst, lon_sst, lat_sst, time_sst, distance_sst] = daily_sst_extract(echogram, file, day, daily_sst, lon_sst, lat_sst, time_sst, distance_sst,daynight)

% Function to extract the sst data for a specific day


% Extraction of the variables in the sst file

if strcmp(daynight,'day')
    sst = ncread(file, 'sst');
elseif strcmp(daynight,'night')
    sst = ncread(file, 'sst4');
end
sst = sst';
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);
 
% Extraction of the daily sst

a = interp2(lon, lat, sst, lon_day, lat_day);
daily_sst = [daily_sst; a'];
lon_sst = [lon_sst; lon_day'];
lat_sst = [lat_sst; lat_day'];
time_sst = [time_sst; time_day'];
distance_sst = [distance_sst; distance_day'];
