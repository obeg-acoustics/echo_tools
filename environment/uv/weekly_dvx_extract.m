function [weekly_mld, lon_mld, lat_mld, time_mld, distance_mld] = weekly_dvx_extract(echogram, file, day, weekly_mld, lon_mld, lat_mld, time_mld, distance_mld)

% Function to extract horizontal v gradients


% Extraction of the variables in the mld file
v_tmp = ncread(file, 'v');
v(1:360,:)  =nanmean(v_tmp(361:720,:,1:11),3);
v(361:720,:)=nanmean(v_tmp(1:360,:,1:11),3);
v = fillmissing(v,'nearest');
v_lon = repmat(ncread(file, 'xu_ocean')-180,[1,330]);
v_lat = repmat([ncread(file, 'yu_ocean')]',[720,1]);

% compute dv with velocities averaged from surface to 115m depth (i.e. 1:11)
dv = (v(3:end,:)-v(1:end-2,:));
dx  = deg2km(distance(v_lat(3:end,:),v_lon(3:end,:),v_lat(1:end-2,:),v_lon(1:end-2,:)));
dvx = dv./dx;

lon = ncread(file, 'xu_ocean')-180;
lat = ncread(file, 'yu_ocean');

% Extraction in the echogram of the indexes that are in a specific day
date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);

% Extraction of dvx
a = interp2(lon(2:end-1), lat, dvx', lon_day, lat_day);
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
