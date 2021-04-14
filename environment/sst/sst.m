function [echogram] = sst(echogram, sstpath_daily, sstpath_weekly)
% Scripts that reads and extracts the sst data



% Load Chlorophyll files
sstfiles_daily = dir(sstpath_daily);
sstfiles_weekly = dir(sstpath_weekly);

% List of dates for sst extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert for MODIS
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);


% Extract daily sst at the corresponding cruise lon/lat **************************************** 

daily_sst = [];
lon_sst = [];
lat_sst = [];
time_sst = [];

for k = 1:size(YMD_unique,1)
	for l = 1 : length(sstfiles_daily)
		if strfind(sstfiles_daily(l).name,YMD_unique(k,:))
                	[daily_sst, lon_sst, lat_sst, time_sst] = daily_sst_extract(echogram, [sstpath_daily,sstfiles_daily(l).name], str2num(D_unique(k,:)), daily_sst, lon_sst, lat_sst, time_sst);
        	end
	end
end


% Extract weekly sst at the corresponding cruise lon/lat *************************************** 

weekly_sst = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);
	
	% Case date is the last day of weekly file
	for l = 1 : length(sstfiles_weekly)		
        	if strfind(sstfiles_weekly(l).name,'MODIS')
			if strfind(sstfiles_weekly(l).name(21:28),match_name)
				[weekly_sst] = weekly_sst_extract(echogram, [sstpath_weekly,sstfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_sst);
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
					[weekly_sst] = weekly_sst_extract(echogram, [sstpath_weekly,sstfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_sst);
					flag = 1;
            			end
            		end
		end
	end
end


% Save sst vectors ********************************************************************************

% Mixed sst vector where we replace the NaNs in the daily_sst vector
sst_vector = daily_sst;
ind_nan = find(isnan(sst_vector));
sst_vector(ind_nan) = weekly_sst(ind_nan);

% Output
echogram.sst.daily_sst = daily_sst;
echogram.sst.weekly_sst = weekly_sst;
echogram.sst.mixed_sst = sst_vector;
echogram.sst.lon_sst = lon_sst;
echogram.sst.lat_sst = lat_sst;
echogram.sst.time_sst = time_sst;
