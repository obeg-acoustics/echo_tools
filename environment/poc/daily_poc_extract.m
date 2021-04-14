function [daily_poc, lon_poc, lat_poc, time_poc] = daily_poc_extract(echogram, file, day, daily_poc, lon_poc, lat_poc, time_poc)

% Function to extract the poc data for a specific day


% Extraction of the variables in the poc file

poc = ncread(file, 'poc');
poc = poc';
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);
time_day = echogram.pings(1).time(ind_day);

% Extraction of the daily poc

a = interp2(lon, lat, poc, lon_day, lat_day);
daily_poc = [daily_poc; a];
lon_poc = [lon_poc; lon_day];
lat_poc = [lat_poc; lat_day];
time_poc = [time_poc; time_day];
