function [echogram] = solar_elevation(echogram)
% This script estimates the solar angle from time vector

elevation = nan(size(echogram.pings(1).time));

for i=1:length(echogram.pings(1).time)

   location.longitude 	= echogram.pings(1).lon(i);
   location.latitude 	= echogram.pings(1).lat(i); 
   location.altitude	= 0;

   day_time = datevec(echogram.pings(1).time(i));

   time.year		= day_time(1);
   time.month		= day_time(2);
   time.day		= day_time(3);
   time.hour		= day_time(4);
   time.min		= day_time(5);
   time.sec		= day_time(6);
    
   % Time should be already in UTC - so offset hour is 0
   time.UTC		= 0;
   
   sun = sun_position(time,location);

   elevation(i) = 90 - sun.zenith;
    
end

echogram.solar.daily = elevation';
echogram.solar.weekly = elevation';
echogram.solar.lon = echogram.pings(1).lon';
echogram.solar.lat = echogram.pings(1).lat';
echogram.solar.time = echogram.pings(1).time';
echogram.solar.dist = echogram.pings(1).distance';
