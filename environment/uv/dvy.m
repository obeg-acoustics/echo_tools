function [echogram] = dvy(echogram, mldpath_weekly, tagyear)
% Scripts that reads and extracts the dvy data



% Load dvy files
dvyfiles_weekly = dir(mldpath_weekly);

% List of dates for dvy extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert for MODIS
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);

for k = 1:size(D_unique,1)
label_unique(k,:) = [Y_unique(k,:),'_',M_unique(k,:),'_',D_unique(k,:)];
end
YMD_unique = label_unique;


%% Extract daily dvy at the corresponding cruise lon/lat 
lon_dvy = [];
lat_dvy = [];
time_dvy = [];
distance_dvy = [];

%% List of 
%for k = 1:size(YMD_unique,1)
%	for l = 1 : length(chlfiles_daily)
%		if strfind(chlfiles_daily(l).name,YMD_unique(k,:))
%%             if strfind(chlfiles_daily(l).name,'AVW')
%                [daily_chl, lon_chl, lat_chl, time_chl] = daily_chloro_extract(echogram, [chlpath_daily,chlfiles_daily(l).name], str2num(D_unique(k,:)), daily_chl, lon_chl, lat_chl, time_chl);
%%             end
%        end
%	end
%end


% Extract weekly dvy at the corresponding cruise lon/lat 

weekly_dvy = [];

% List of 
for k = 1:size(YMD_unique,1)
	flag = 0;
	name = YMD_unique(k,:);
	match_name = YMD_unique(k,:);
	for l = 1 : length(dvyfiles_weekly)		
		if strfind(dvyfiles_weekly(l).name,tagyear)
		if strfind(dvyfiles_weekly(l).name(26:35),match_name)
			[weekly_dvy, lon_dvy, lat_dvy, time_dvy, distance_dvy] = weekly_dvy_extract(echogram, [mldpath_weekly,dvyfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dvy, lon_dvy, lat_dvy, time_dvy, distance_dvy);
			flag = 1;
%             end
		end
		end
	end
	while (flag == 0)
% 		match_name = [str2num(match_name(1:4)) str2num(match_name(5:6)) str2num(match_name(7:8))];
% 		match_name = datenum(match_name);
% 		match_name = match_name-1;
% 		match_name = datevec(match_name);
% 		match_name = [num2str(match_name(:,1)),num2str(match_name(:,2),'%02d'),num2str(match_name(:,3),'%02d')];
        match_name_day = str2num(match_name(9:10));
        match_name_day = match_name_day + 1;
        match_name = [match_name(1:8),num2str(match_name_day,'%02d')];
		for l = 1 : length(dvyfiles_weekly)
			if strfind(dvyfiles_weekly(l).name,tagyear)		
			if strfind(dvyfiles_weekly(l).name(26:35),match_name)
%                 if strfind(chlfiles_weekly(l).name,'AVW')
				[weekly_dvy, lon_dvy, lat_dvy, time_dvy, distance_dvy] = weekly_dvy_extract(echogram, [mldpath_weekly,dvyfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dvy, lon_dvy, lat_dvy, time_dvy, distance_dvy);
				flag = 1;
%                 end
			end
			end
		end
	end
end




%% We replace the NaNs in the daily_dux vector
echogram.dvy.daily = weekly_dvy;
echogram.dvy.weekly = weekly_dvy;
echogram.dvy.lon = lon_dvy;
echogram.dvy.lat = lat_dvy;
echogram.dvy.time = time_dvy;
echogram.dvy.dist = distance_dvy;
