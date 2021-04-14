function [echogram] = poc(echogram, pocpath_daily, pocpath_weekly, tagyear)
% Scripts that reads and extracts the poc data


% Load list of Poc file names
pocfiles_daily = dir(pocpath_daily);
pocfiles_weekly = dir(pocpath_weekly);

% List of dates for poc extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert for MODIS
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);

for k = 1:size(D_unique,1)
	index_tmp = datenum(str2num(Y_unique(k,:)),str2num(M_unique(k,:)),str2num(D_unique(k,:)));
	index_ref = datenum(str2num(tagyear),1,1);
	label_unique(k,:) = [Y_unique(k,:),num2str(index_tmp-index_ref+1,'%03d')];
end
YMD_unique = label_unique;


% Extract daily poc at the corresponding cruise lon/lat *****************************************

daily_poc = [];
lon_poc = [];
lat_poc = [];
time_poc = [];
 
for k = 1:size(YMD_unique,1)
	for l = 1 : length(pocfiles_daily)
		if strfind(pocfiles_daily(l).name,YMD_unique(k,:))
                	[daily_poc, lon_poc, lat_poc, time_poc] = daily_poc_extract(echogram, [pocpath_daily,pocfiles_daily(l).name], str2num(D_unique(k,:)), daily_poc, lon_poc, lat_poc, time_poc);
        	end
	end
end


% Extract weekly poc at the corresponding cruise lon/lat ***************************************** 

weekly_poc = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);

        % Case date is the last day of weekly file
	for l = 1 : length(pocfiles_weekly)		
		if strfind(pocfiles_weekly(l).name,['A',tagyear])
			if strfind(pocfiles_weekly(l).name(9:15),match_name)
				[weekly_poc] = weekly_poc_extract(echogram, [pocpath_weekly,pocfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_poc);
				flag = 1;
			end
		end
	end

	% Other cases
	while (flag == 0)
        	match_name = str2num(match_name);
        	match_name = match_name + 1;
        	match_name = num2str(match_name);
		for l = 1 : length(pocfiles_weekly)	
			if strfind(pocfiles_weekly(l).name,['A',tagyear])	
				if strfind(pocfiles_weekly(l).name(9:15),match_name)
					[weekly_poc] = weekly_poc_extract(echogram, [pocpath_weekly,pocfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_poc);
					flag = 1;
				end
			end
		end
	end
end


% Save poc vectors ********************************************************************************

% Mixed poc vector where we  replace the NaNs in the daily_poc vector with weekly_poc values
poc_vector = daily_poc;
ind_nan = find(isnan(poc_vector));
poc_vector(ind_nan) = weekly_poc(ind_nan);

% Output
echogram.poc.daily_poc = daily_poc;
echogram.poc.weekly_poc = weekly_poc;
echogram.poc.mixed_poc = poc_vector;
echogram.poc.lon_poc = lon_poc;
echogram.poc.lat_poc = lat_poc;
echogram.poc.time_poc = time_poc;
