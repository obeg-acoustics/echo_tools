function [echogram] = era(echogram, erapath, tagyear)
% Scripts that reads and extracts the surface wind data



% Load list of era file names
erafiles = dir(erapath);

%% List of dates for wind extraction
%timevector=datevec(echogram.pings(1).time);
%YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d'),num2str(timevector(:,4),'%02d')];
%YMD_unique = unique(YMD,'rows');
%
%% Convert date labels for MODIS data
%Y_unique=YMD_unique(:,1:4);
%M_unique=YMD_unique(:,5:6);
%D_unique=YMD_unique(:,7:8);
%H_unique=YMD_unique(:,9:10);
%
%for k = 1:size(D_unique,1)
%	index_tmp = datenum(str2num(Y_unique(k,:)),str2num(M_unique(k,:)),str2num(D_unique(k,:)));
%	index_ref = datenum(str2double(tagyear),1,1);
%	label_unique(k,:) = [Y_unique(k,:),num2str(index_tmp-index_ref+1,'%03d')];
%end
%YMD_unique = label_unique;


% Extract hourly wind at the corresponding cruise lon/lat *********************************** 

hourly_vel10 = [];
lon_vel10 = [];
lat_vel10 = [];
time_vel10 = [];
distance_vel10 = [];

%for k = 1:size(YMD_unique,1)
	for l = 1 : length(erafiles)
		if strfind(erafiles(l).name,tagyear)
                	[hourly_vel10, lon_vel10, lat_vel10, time_vel10, distance_vel10] = hourly_era_extract(echogram, [erapath,erafiles(l).name], hourly_vel10, lon_vel10, lat_vel10, time_vel10, distance_vel10);
        	end
	end
%end


% Save era vectors ********************************************************************************

% Output
echogram.vel10.daily = hourly_vel10;
echogram.vel10.weekly = hourly_vel10;
echogram.vel10.lon = lon_vel10;
echogram.vel10.lat = lat_vel10;
echogram.vel10.time = time_vel10;
echogram.vel10.dist = distance_vel10;
