function [weekly_mld, lon_mld, lat_mld, time_mld, distance_mld] = weekly_duy_extract(echogram, file, day, weekly_mld, lon_mld, lat_mld, time_mld, distance_mld)

% Function to extract horizontal u gradients


% Extraction of the variables in the mld file
u_tmp = ncread(file, 'u');
u(1:360,:)  =nanmean(u_tmp(361:720,:,1:11),3);
u(361:720,:)=nanmean(u_tmp(1:360,:,1:11),3);
u = fillmissing(u,'nearest');
u_lon = repmat(ncread(file, 'xu_ocean')-180,[1,330]);
u_lat = repmat([ncread(file, 'yu_ocean')]',[720,1]);

% compute du with velocities averaged from surface to 115m depth (i.e. 1:11)
du = (u(:,3:end)-u(:,1:end-2));
dy  = deg2km(distance(u_lat(:,3:end),u_lon(:,3:end),u_lat(:,1:end-2),u_lon(:,1:end-2)));
duy = du./dy;

lon = ncread(file, 'xu_ocean')-180;
lat = ncread(file, 'yu_ocean');

% Extraction in the echogram of the indexes that are in a specific day
date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);

% Extraction of duy
a = interp2(lon, lat(2:end-1), duy', lon_day, lat_day);
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
