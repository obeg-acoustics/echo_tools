function [echogram] = dO2(echogram, woapath)
% Scripts that reads and extracts the oxygen gradient


% Extract reanalyis O2 gradient data *********************************** 

reanalysis_dO2 = [];
lon_dO2 = [];
lat_dO2 = [];
time_dO2 = [];
distance_dO2 = [];

[reanalysis_dO2, lon_dO2, lat_dO2, time_dO2, distance_dO2] = reanalysis_dO2_extract(echogram, woapath, reanalysis_dO2, lon_dO2, lat_dO2, time_dO2, distance_dO2);


% Save dO2 vectors ********************************************************************************

% Output
echogram.do2.daily = reanalysis_dO2;
echogram.do2.weekly = reanalysis_dO2;
echogram.do2.lon = lon_dO2;
echogram.do2.lat = lat_dO2;
echogram.do2.time = time_dO2;
echogram.do2.dist = distance_dO2;
