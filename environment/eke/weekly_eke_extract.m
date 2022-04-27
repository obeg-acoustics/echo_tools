function [weekly_mld, lon_mld, lat_mld, time_mld, distance_mld] = weekly_eke_extract(echogram, file, day, weekly_mld, lon_mld, lat_mld, time_mld, distance_mld)

% Function to extract eke

% Compute average fields
for k = 1:size(file,1)
    u_tmp = ncread(file(k,:), 'u'); 
    v_tmp = ncread(file(k,:), 'v');
    if k == 1
        u_avg = nanmean(u_tmp(:,:,1:11),3);
        v_avg = nanmean(v_tmp(:,:,1:11),3);      
    else
        u_avg = u_avg + nanmean(u_tmp(:,:,1:11),3);
        v_avg = v_avg + nanmean(v_tmp(:,:,1:11),3);
    end
end
u_avg_tmp = u_avg/size(file,1);
u_avg(1:360,:)  =u_avg_tmp(361:720,:);
u_avg(361:720,:)=u_avg_tmp(1:360,:);
u_avg = fillmissing(u_avg,'nearest');
v_avg_tmp = v_avg/size(file,1);
v_avg(1:360,:)  =v_avg_tmp(361:720,:);
v_avg(361:720,:)=v_avg_tmp(1:360,:);
v_avg = fillmissing(v_avg,'nearest');

% Extraction of current field
u_tmp = ncread(file(4,:), 'u');
u(1:360,:)  =nanmean(u_tmp(361:720,:,1:11),3);
u(361:720,:)=nanmean(u_tmp(1:360,:,1:11),3);
u = fillmissing(u,'nearest');
v_tmp = ncread(file(4,:), 'u');
v(1:360,:)  =nanmean(v_tmp(361:720,:,1:11),3);
v(361:720,:)=nanmean(v_tmp(1:360,:,1:11),3);
v = fillmissing(v,'nearest');

% compute du with velocities averaged from surface to 115m depth (i.e. 1:11)
eke = 1/2 * (u.^2+v.^2) - 1/2 * (u_avg.^2+v_avg.^2); 

lon = ncread(file(4,:), 'xu_ocean')-180;
lat = ncread(file(4,:), 'yu_ocean');

% Extraction in the echogram of the indexes that are in a specific day
date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);
distance_day = echogram.pings(1).distance(ind_day);

% Extraction of eke
a = interp2(lon, lat, eke', lon_day, lat_day);
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
