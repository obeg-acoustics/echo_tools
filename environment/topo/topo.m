function [echogram] = topo(echogram,bathypath)

% Script to extract topography from ETOPO for a specific area.

load(bathypath)

bathy = griddata(LON, LAT, ETOPO, echogram.pings(1).lon, echogram.pings(1).lat);

echogram.topo.daily = bathy';
echogram.topo.weekly = bathy';
echogram.topo.time = echogram.pings(1).time';
echogram.topo.lon = echogram.pings(1).lon';
echogram.topo.lat = echogram.pings(1).lat';
echogram.topo.dist = echogram.pings(1).distance';
