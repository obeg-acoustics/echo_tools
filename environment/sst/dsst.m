function [echogram] = dsst(echogram, sstpath_daily, sstpath_weekly, daynight)
% Scripts that reads and extracts the sst gradient data



% Load SST files
sstfiles_daily = dir(sstpath_daily);
sstfiles_weekly = dir(sstpath_weekly);

% List of dates for dsst extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert for MODIS
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);


% Extract daily dsst at the corresponding cruise lon/lat **************************************** 

daily_dsst = [];
lon_dsst = [];
lat_dsst = [];
time_dsst = [];
distance_dsst = [];

for k = 1:size(YMD_unique,1)
        findmap = 0;
	for l = 1 : length(sstfiles_daily)
		if strfind(sstfiles_daily(l).name,YMD_unique(k,:))
                        findmap = 1; 
                	[daily_dsst, lon_dsst, lat_dsst, time_dsst, distance_dsst] = daily_dsst_extract(echogram, [sstpath_daily,sstfiles_daily(l).name], str2num(D_unique(k,:)), daily_dsst, lon_dsst, lat_dsst, time_dsst, distance_dsst,daynight);
        	end
	end
        if findmap == 0   
		disp('Warning, missing file')	
	end
end


% Extract weekly dsst at the corresponding cruise lon/lat *************************************** 

weekly_dsst = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);
	
	% Case date is the last day of weekly file
	for l = 1 : length(sstfiles_weekly)		
        	if strfind(sstfiles_weekly(l).name,'MODIS')
			if strfind(sstfiles_weekly(l).name(21:28),match_name)
				[weekly_dsst] = weekly_dsst_extract(echogram, [sstpath_weekly,sstfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dsst,daynight);
				flag = 1;
        		end
        	end
	end

	% Other cases
	while (flag == 0)
        	match_name = str2num(match_name);
        	match_name = match_name + 1;
        	match_name = num2str(match_name);
		for l = 1 : length(sstfiles_weekly)	
            		if strfind(sstfiles_weekly(l).name,'MODIS')
				if strfind(sstfiles_weekly(l).name(21:28),match_name)
					[weekly_dsst] = weekly_dsst_extract(echogram, [sstpath_weekly,sstfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dsst, daynight);
					flag = 1;
            			end
            		end
		end
	end
end


% Save dsst vectors ********************************************************************************

% Mixed dsst vector where we replace the NaNs in the daily_sst vector
dsst_vector = daily_dsst;
ind_nan = find(isnan(dsst_vector));
dsst_vector(ind_nan) = weekly_dsst(ind_nan);

% Output
if strcmp(daynight,'day')
    echogram.dsst.daily = daily_dsst;
    echogram.dsst.weekly = weekly_dsst;
    echogram.dsst.mixed = dsst_vector;
    echogram.dsst.lon = lon_dsst;
    echogram.dsst.lat = lat_dsst;
    echogram.dsst.time = time_dsst;
    echogram.dsst.dist = distance_dsst;
elseif strcmp(daynight,'night')
    echogram.dsst4.daily = daily_dsst;
    echogram.dsst4.weekly = weekly_dsst;
    echogram.dsst4.mixed = dsst_vector;
    echogram.dsst4.lon = lon_dsst;
    echogram.dsst4.lat = lat_dsst;
    echogram.dsst4.time = time_dsst;
    echogram.dsst4.dist = distance_dsst;
end
