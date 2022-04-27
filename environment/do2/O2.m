function [echogram] = O2(echogram, woapath)
% Scripts that reads and extracts the oxygen at surface


% Extract reanalyis O2 data *********************************** 

reanalysis_O2 = [];
lon_O2 = [];
lat_O2 = [];
time_O2 = [];
distance_O2 = [];

[reanalysis_O2, lon_O2, lat_O2, time_O2, distance_O2] = reanalysis_O2_extract(echogram, woapath, reanalysis_O2, lon_O2, lat_O2, time_O2, distance_O2);


% Save O2 vectors ********************************************************************************

% Output
echogram.o2.daily = reanalysis_O2;
echogram.o2.weekly = reanalysis_O2;
echogram.o2.lon = lon_O2;
echogram.o2.lat = lat_O2;
echogram.o2.time = time_O2;
echogram.o2.dist = distance_O2;
