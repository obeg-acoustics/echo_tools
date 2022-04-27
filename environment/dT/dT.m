function [echogram] = dT(echogram, woapath)
% Scripts that reads and extracts the temperature gradient


% Extract reanalyis T gradient data *********************************** 

reanalysis_dT = [];
lon_dT = [];
lat_dT = [];
time_dT = [];
distance_dT = [];

[reanalysis_dT, lon_dT, lat_dT, time_dT, distance_dT] = reanalysis_dT_extract(echogram, woapath, reanalysis_dT, lon_dT, lat_dT, time_dT, distance_dT);


% Save dT vectors ********************************************************************************

% Output
echogram.dT.daily = reanalysis_dT;
echogram.dT.weekly = reanalysis_dT;
echogram.dT.lon = lon_dT;
echogram.dT.lat = lat_dT;
echogram.dT.time = time_dT;
echogram.dT.dist = distance_dT;
