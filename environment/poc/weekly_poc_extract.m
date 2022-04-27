function [weekly_poc] = weekly_poc_extract(echogram, file, day, weekly_poc)

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

% Extraction of poc

a = interp2(lon, lat, poc, lon_day, lat_day);
weekly_poc = [weekly_poc; a'];

