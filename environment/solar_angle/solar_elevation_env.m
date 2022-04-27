function [datastruct] = solar_elevation_env(datastruct)
% This script estimates the solar angle from time vector

elevation = nan(size(datastruct.time));

for i=1:length(datastruct.time)

   location.longitude 	= datastruct.lon(i);
   location.latitude 	= datastruct.lat(i); 
   location.altitude	= 0;

   day_time = datevec(datastruct.time(i));

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

datastruct.solar.daily = elevation';
datastruct.solar.weekly = elevation';
datastruct.solar.lon = datastruct.lon';
datastruct.solar.lat = datastruct.lat';
datastruct.solar.time = datastruct.time';
datastruct.solar.dist = datastruct.distance';
