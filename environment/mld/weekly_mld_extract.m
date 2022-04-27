function [weekly_mld, lon_mld, lat_mld, time_mld, distance_mld] = weekly_mld_extract(echogram, file, day, weekly_mld, lon_mld, lat_mld, time_mld, distance_mld)

% Function to extract the mix layer depth data for a specific day


% Extraction of the variables in the mld file

mld_tmp = ncread(file, 'mlt');
mld(1:360,:)  =mld_tmp(361:720,:);
mld(361:720,:)=mld_tmp(1:360,:);
lon = ncread(file, 'xt_ocean')-180;
lat = ncread(file, 'yt_ocean');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);

% Extraction of mld

a = interp2(lon, lat, mld', lon_day, lat_day);
if isempty(weekly_mld)
weekly_mld = a';
lon_mld    = lon_day';
lat_mld    = lat_day';
time_mld   = time_day';
distance_mld = distance_day';
else
weekly_mld = [weekly_mld; a'];
lon_mld    = [lon_mld; lon_day'];
lat_mld    = [lat_mld; lat_day'];
time_mld   = [time_mld; time_day'];
distance_mld = [distance_mld; distance_day'];
end
