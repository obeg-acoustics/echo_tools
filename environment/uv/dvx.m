function [echogram] = dvx(echogram, mldpath_weekly, tagyear)
% Scripts that reads and extracts the dvx data



% Load dvx files
dvxfiles_weekly = dir(mldpath_weekly);

% List of dates for dvx extraction
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


%% Extract daily dvx at the corresponding cruise lon/lat 
lon_dvx = [];
lat_dvx = [];
time_dvx = [];
distance_dvx = [];

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


% Extract weekly dvx at the corresponding cruise lon/lat 

weekly_dvx = [];

% List of 
for k = 1:size(YMD_unique,1)
	flag = 0;
	name = YMD_unique(k,:);
	match_name = YMD_unique(k,:);
	for l = 1 : length(dvxfiles_weekly)		
		if strfind(dvxfiles_weekly(l).name,tagyear)
		if strfind(dvxfiles_weekly(l).name(26:35),match_name)
			[weekly_dvx, lon_dvx, lat_dvx, time_dvx, distance_dvx] = weekly_dvx_extract(echogram, [mldpath_weekly,dvxfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dvx, lon_dvx, lat_dvx, time_dvx, distance_dvx);
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
		for l = 1 : length(dvxfiles_weekly)
			if strfind(dvxfiles_weekly(l).name,tagyear)		
			if strfind(dvxfiles_weekly(l).name(26:35),match_name)
%                 if strfind(chlfiles_weekly(l).name,'AVW')
				[weekly_dvx, lon_dvx, lat_dvx, time_dvx, distance_dvx] = weekly_dvx_extract(echogram, [mldpath_weekly,dvxfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_dvx, lon_dvx, lat_dvx, time_dvx, distance_dvx);
				flag = 1;
%                 end
			end
			end
		end
	end
end




%% We replace the NaNs in the daily_dux vector
echogram.dvx.daily = weekly_dvx;
echogram.dvx.weekly = weekly_dvx;
echogram.dvx.lon = lon_dvx;
echogram.dvx.lat = lat_dvx;
echogram.dvx.time = time_dvx;
echogram.dvx.dist = distance_dvx;