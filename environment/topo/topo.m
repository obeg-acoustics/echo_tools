function [echogram] = topo_extract(echogram,bathypath)

% Script to extract topography from ETOPO for a specific area.

load(bathypath)

bathy = griddata(LON, LAT, ETOPO, echogram.pings(1).lon, echogram.pings(1).lat);

echogram.topo.bathy = bathy;
echogram.topo.time_bathy = echogram.pings(1).time;
echogram.topo.lon_bathy = echogram.pings(1).lon;
echogram.topo.lat_bathy = echogram.pings(1).lat;
