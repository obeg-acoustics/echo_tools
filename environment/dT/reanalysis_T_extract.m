function [reanalysis_T, lon_T, lat_T, time_T, distance_T] = reanalysis_T_extract(echogram, file, reanalysis_T, lon_T, lat_T, time_T, distance_T)

% Function to extract the T at surface


% Extraction of the variables
load(file)

Tsurf = squeeze(Temperature_clim.avg_val(:,:,1,:)); 
Tsurf(find(Tsurf>10^30)) = NaN;

lon = Temperature_clim.lon;
lat = Temperature_clim.lat;

% Extraction in the echogram of the indexes that are at a specific month
date_mat = datevec(echogram.pings(1).time);

T = [];
lon_month = [];
lat_month = [];
time_month = [];
distance_month = [];
for t = 1:12
    ind_month = find(date_mat(:,2) == t);
    
    if ~isempty(ind_month)
    lon_month = [lon_month,echogram.pings(1).lon(ind_month)];
    lat_month = [lat_month,echogram.pings(1).lat(ind_month)];
    time_month = [time_month,echogram.pings(1).time(ind_month)];
    distance_month = [distance_month,echogram.pings(1).distance(ind_month)];

    mapT = Tsurf(:,:,t)';
    mapT = fillmissing(mapT,'nearest');

    a = interp2(lon, lat, mapT, echogram.pings(1).lon(ind_month), echogram.pings(1).lat(ind_month));
    T = [T,a];
    end
end

% Extraction of the monthly T

reanalysis_T = [reanalysis_T; T'];
lon_T= [lon_T; lon_month'];
lat_T = [lat_T; lat_month'];
time_T = [time_T; time_month'];
distance_T = [distance_T; distance_month'];
