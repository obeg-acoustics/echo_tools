function [echogram] = distance_vector(echogram)

% This function creates a distance vector, which is a vector that contains the distance covered buy the boat since the beginning of the cruise. The first value of the distance vector added in the echogram might be a NaN, because of the interp1() function which is used in this script.


earth_radius = 6371000; % In m


lat_gps = echogram.gps.lat;
lon_gps = echogram.gps.lon;
time_gps = echogram.gps.time;

%keyboard

distance_gps = [0];

for i=2:length(lat_gps)
	dist = distance_gps(i-1) + distance(lat_gps(i-1),lon_gps(i-1),lat_gps(i),lon_gps(i))*pi*earth_radius/180;
	distance_gps = [distance_gps, dist];
end
echogram.gps.distance = distance_gps';

for i=1:length(echogram.pings) % Warning, time vector might be different for the different frequencies
	time_ping = echogram.pings(i).time;
    % Correction of the time vector for non monotonic segments (JG)
    time_gps(find(diff(time_gps)<=0)) = NaN;
	distance_ping = interp1(time_gps(find(~isnan(time_gps))), distance_gps(find(~isnan(time_gps))), time_ping);
	echogram.pings(i).distance = distance_ping;
end

for i=1:length(echogram.pings)
    % Correction of the time vector for non monotonic segments (JG)
    echogram.gps.time(find(diff(echogram.gps.time)<=0)) = NaN;
	lat_ping = interp1(echogram.gps.time(find(~isnan(echogram.gps.time))), echogram.gps.lat(find(~isnan(echogram.gps.time))), echogram.pings(i).time);
	lon_ping = interp1(echogram.gps.time(find(~isnan(echogram.gps.time))), echogram.gps.lon(find(~isnan(echogram.gps.time))), echogram.pings(i).time);
	echogram.pings(i).lat = lat_ping;
	echogram.pings(i).lon = lon_ping;
end



%for j=1:length(echogram.pings)

%	time_ping = echogram.pings(j).time; % Warning, time vector might be different for the different frequencies 

%	lat_ping = interp1(time_gps, lat_gps, time_ping);
%	lon_ping = interp1(time_gps, lon_gps, time_ping);

%	distance_vector = [];

%	for i=1:length(lat_ping)
%		if isnan(lat_ping(i))
%			distance_vector = [distance_vector, NaN];
%		elseif isnan(distance_vector(i-1))
%			distance_vector = [distance_vector, 0];
%		else
%			if length(distance_vector)==0
%				distance_vector = [distance_vector, 0];
%			else
%				dist = distance_vector(i-1) + distance(lat_ping(i-1),lon_ping(i-1),lat_ping(i),lon_ping(i))*pi*earth_radius/180;
%				distance_vector = [distance_vector, dist];
%			end
%		end
%	end
%	echogram.pings(j).distance_vector = distance_vector;
%end
