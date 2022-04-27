function [reanalysis_dO2, lon_dO2, lat_dO2, time_dO2, distance_dO2] = reanalysis_dO2_extract(echogram, file, reanalysis_dO2, lon_dO2, lat_dO2, time_dO2, distance_dO2)

% Function to extract the O2 gradient at surface


% Extraction of the variables
load(file)

O2surf = squeeze(Oxygen_clim.avg_val(:,:,1,:)); 
O2surf(find(O2surf>10^30)) = NaN;
O2deep = squeeze(Oxygen_clim.avg_val(:,:,21,:)); % At 100 m depth
O2deep(find(O2deep>10^30)) = NaN;
gradO2 = O2surf-O2deep;

lon = Oxygen_clim.lon;
lat = Oxygen_clim.lat;

% Extraction in the echogram of the indexes that are at a specific month
date_mat = datevec(echogram.pings(1).time);

dO2 = [];
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

    mapO2 = gradO2(:,:,t)'; 
    mapO2 = fillmissing(mapO2,'nearest');

    a = interp2(lon, lat, mapO2, echogram.pings(1).lon(ind_month), echogram.pings(1).lat(ind_month));
    dO2 = [dO2,a];
    end
end

% Extraction of the monthly dO2

reanalysis_dO2 = [reanalysis_dO2; dO2'];
lon_dO2= [lon_dO2; lon_month'];
lat_dO2 = [lat_dO2; lat_month'];
time_dO2 = [time_dO2; time_month'];
distance_dO2 = [distance_dO2; distance_month'];
