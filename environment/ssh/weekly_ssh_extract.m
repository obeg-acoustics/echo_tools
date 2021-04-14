function [weekly_ssh, lon_ssh, lat_ssh, time_ssh] = weekly_ssh_extract(echogram, file, day, weekly_ssh, lon_ssh, lat_ssh, time_ssh)

% Function to extract the ssh data for a specific day


% Extraction of the variables in the ssh file

ssh = ncread(file, 'SLA');
sshtmp = ssh;
ssh(:,1:1080)=sshtmp(:,1081:2160);
ssh(:,1081:2160)=sshtmp(:,1:1080);
lon = ncread(file, 'Longitude') - 180;
lat = ncread(file, 'Latitude');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);

% Extraction of ssh

a = interp2(lon, lat, ssh, lon_day, lat_day);
weekly_ssh = [weekly_ssh; a];
lon_ssh = [lon_ssh; lon_day];
lat_ssh = [lat_ssh; lat_day];
time_ssh = [time_ssh; time_day];
