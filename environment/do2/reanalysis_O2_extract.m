function [reanalysis_O2, lon_O2, lat_O2, time_O2, distance_O2] = reanalysis_O2_extract(echogram, file, reanalysis_O2, lon_O2, lat_O2, time_O2, distance_O2)

% Function to extract the O2 at surface


% Extraction of the variables
load(file)

O2surf = squeeze(Oxygen_clim.avg_val(:,:,1,:)); 
O2surf(find(O2surf>10^30)) = NaN;

lon = Oxygen_clim.lon;
lat = Oxygen_clim.lat;

% Extraction in the echogram of the indexes that are at a specific month
date_mat = datevec(echogram.pings(1).time);

O2 = [];
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

    mapO2 = O2surf(:,:,t)';
    mapO2 = fillmissing(mapO2,'nearest');

    a = interp2(lon, lat, mapO2, echogram.pings(1).lon(ind_month), echogram.pings(1).lat(ind_month));
    O2 = [O2,a];
    end
end

% Extraction of the monthly O2

reanalysis_O2 = [reanalysis_O2; O2'];
lon_O2= [lon_O2; lon_month'];
lat_O2 = [lat_O2; lat_month'];
time_O2 = [time_O2; time_month'];
distance_O2 = [distance_O2; distance_month'];
