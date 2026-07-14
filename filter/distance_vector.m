function [echogram] = distance_vector(echogram)

% This function creates a distance vector, which is a vector that contains the distance covered by the boat since the beginning of the cruise. The first value of the distance vector added in the echogram might be a NaN, because of the interp1() function which is used in this script.

earth_radius = 6371000; % In m


lat_gps = echogram.gps.lat;
lon_gps = echogram.gps.lon;
time_gps = echogram.gps.time;

distance_gps = [0];
for i=2:length(lat_gps)
	ddist = distance(lat_gps(i-1),lon_gps(i-1),lat_gps(i),lon_gps(i))*pi*earth_radius/180;
        if isnan(ddist)
		ddist = 0;
	end
	dist = distance_gps(i-1) + ddist;
	distance_gps = [distance_gps, dist];
end
echogram.gps.distance = distance_gps';

for i=1:length(echogram.pings) % Warning, time vector might be different for the different frequencies
	time_ping = echogram.pings(i).time;
        time_gps(find(diff(time_gps)<=0)) = NaN;
        ind1 = find(~isnan(time_gps));
        [C,ind2] = unique(time_gps);
        [C,ind3] = unique(distance_gps);
        inda = intersect(ind1,ind2);
        indb = intersect(ind1,ind3); 
        distance_ping = interp1(time_gps(intersect(inda,indb)), distance_gps(intersect(inda,indb)), time_ping);
	echogram.pings(i).distance = distance_ping;
end

for i=1:length(echogram.pings)
        time_ping = echogram.pings(i).time;
        time_gps(find(diff(time_gps)<=0)) = NaN;
        ind1 = find(~isnan(time_gps));
        [C,ind2] = unique(time_gps);
        [C,ind3] = unique(distance_gps);
        inda = intersect(ind1,ind2);
        indb = intersect(ind1,ind3);
        echogram.gps.time = time_gps(intersect(inda,indb));
        lat_ping = interp1(echogram.gps.time, echogram.gps.lat(intersect(inda,indb)), time_ping);
	echogram.pings(i).lat = lat_ping;
        lon_ping = interp1(echogram.gps.time, echogram.gps.lon(intersect(inda,indb)), time_ping);
	echogram.pings(i).lon = lon_ping;
end
echogram.gps.lat = echogram.gps.lat(intersect(inda,indb));
echogram.gps.lon = echogram.gps.lon(intersect(inda,indb));
echogram.gps.distance = echogram.gps.distance(intersect(inda,indb));

