function [echogram] = chloro(echogram, chlpath_daily, chlpath_weekly, tagyear)
% Scripts that reads and extracts the chlorophyle data



% Load list of Chlorophyll file names
chlfiles_daily = dir(chlpath_daily);
chlfiles_weekly = dir(chlpath_weekly);

% List of dates for chlorophyll extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert date labels for MODIS data
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);

for k = 1:size(D_unique,1)
	index_tmp = datenum(str2num(Y_unique(k,:)),str2num(M_unique(k,:)),str2num(D_unique(k,:)));
	index_ref = datenum(str2double(tagyear),1,1);
	label_unique(k,:) = [Y_unique(k,:),num2str(index_tmp-index_ref+1,'%03d')];
end
YMD_unique = label_unique;


% Extract daily chlorphyll at the corresponding cruise lon/lat *********************************** 

daily_chl = [];
lon_chl = [];
lat_chl = [];
time_chl = [];

for k = 1:size(YMD_unique,1)
	for l = 1 : length(chlfiles_daily)
		if strfind(chlfiles_daily(l).name,YMD_unique(k,:))
                	[daily_chl, lon_chl, lat_chl, time_chl] = daily_chloro_extract(echogram, [chlpath_daily,chlfiles_daily(l).name], str2num(D_unique(k,:)), daily_chl, lon_chl, lat_chl, time_chl);
        	end
	end
end


% Extract weekly chlorphyll at the corresponding cruise lon/lat ***********************************

weekly_chl = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);

	% Case date is the last day of weekly file
	for l = 1 : length(chlfiles_weekly)		
		if strfind(chlfiles_weekly(l).name,['A',tagyear])
			if strfind(chlfiles_weekly(l).name(9:15),match_name)
				[weekly_chl] = weekly_chloro_extract(echogram, [chlpath_weekly,chlfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_chl);
				flag = 1;
			end
		end
	end

	% Other cases
	while (flag == 0)
        	match_name = str2num(match_name);
        	match_name = match_name + 1;
        	match_name = num2str(match_name);
		for l = 1 : length(chlfiles_weekly)
			if strfind(chlfiles_weekly(l).name,['A',tagyear])		
				if strfind(chlfiles_weekly(l).name(9:15),match_name)
					[weekly_chl] = weekly_chloro_extract(echogram, [chlpath_weekly,chlfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_chl);
					flag = 1;
				end
			end
		end
	end
end


% Save chl vectors ********************************************************************************

% Mixed chl vector where we  replace the NaNs in the daily_chl vector with weekly_chl values
chl_vector = daily_chl;
ind_nan = find(isnan(chl_vector));
chl_vector(ind_nan) = weekly_chl(ind_nan);

% Output
echogram.chl.daily_chl = daily_chl;
echogram.chl.weekly_chl = weekly_chl;
echogram.chl.mixed_chl = chl_vector;
echogram.chl.lon_chl = lon_chl;
echogram.chl.lat_chl = lat_chl;
echogram.chl.time_chl = time_chl;
