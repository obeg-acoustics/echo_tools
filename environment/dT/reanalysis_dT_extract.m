function [reanalysis_dT, lon_dT, lat_dT, time_dT, distance_dT] = reanalysis_dT_extract(echogram, file, reanalysis_dT, lon_dT, lat_dT, time_dT, distance_dT)

% Function to extract the T gradient at surface


% Extraction of the variables
load(file)

Tsurf = squeeze(Temperature_clim.avg_val(:,:,1,:)); 
Tsurf(find(Tsurf>10^30)) = NaN;
Tdeep = squeeze(Temperature_clim.avg_val(:,:,21,:)); % At 100 m depth
Tdeep(find(Tdeep>10^30)) = NaN;
gradT = Tsurf-Tdeep;

lon = Temperature_clim.lon;
lat = Temperature_clim.lat;

% Extraction in the echogram of the indexes that are at a specific month
date_mat = datevec(echogram.pings(1).time);

dT = [];
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

    mapT = gradT(:,:,t)'; 
    mapT = fillmissing(mapT,'nearest');

    a = interp2(lon, lat, mapT, echogram.pings(1).lon(ind_month), echogram.pings(1).lat(ind_month));
    dT = [dT,a];
    end
end

% Extraction of the monthly dT

reanalysis_dT = [reanalysis_dT; dT'];
lon_dT= [lon_dT; lon_month'];
lat_dT = [lat_dT; lat_month'];
time_dT = [time_dT; time_month'];
distance_dT = [distance_dT; distance_month'];
