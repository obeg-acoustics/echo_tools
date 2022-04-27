function [echogram] = T(echogram, woapath)
% Scripts that reads and extracts the oxygen at surface


% Extract reanalyis T data *********************************** 

reanalysis_T = [];
lon_T = [];
lat_T = [];
time_T = [];
distance_T = [];

[reanalysis_T, lon_T, lat_T, time_T, distance_T] = reanalysis_T_extract(echogram, woapath, reanalysis_T, lon_T, lat_T, time_T, distance_T);


% Save T vectors ********************************************************************************

% Output
echogram.T.daily = reanalysis_T;
echogram.T.weekly = reanalysis_T;
echogram.T.lon = lon_T;
echogram.T.lat = lat_T;
echogram.T.time = time_T;
echogram.T.dist = distance_T;
