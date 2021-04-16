function [echogram] = mld(echogram, mldpath_weekly,yeartag)
% Scripts that reads and extracts the mld data
% keyboard

% Load mld files
mldfiles_weekly = dir(mldpath_weekly);

% List of dates for chlorophyll extraction
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


%% Extract daily chlorphyll at the corresponding cruise lon/lat 
%
%daily_chl = [];
lon_mld = [];
lat_mld = [];
time_mld = [];
%
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


% Extract weekly mld at the corresponding cruise lon/lat 

weekly_mld = [];

% List of 
for k = 1:size(YMD_unique,1)
	flag = 0;
	name = YMD_unique(k,:);
	match_name = YMD_unique(k,:);
	for l = 1 : length(mldfiles_weekly)		
		if strfind(mldfiles_weekly(l).name,yeartag)
		if strfind(mldfiles_weekly(l).name(26:35),match_name)
%             if strfind(chlfiles_weekly(l).name,'AVW')
			[weekly_mld, lon_mld, lat_mld, time_mld] = weekly_mld_extract(echogram, [mldpath_weekly,mldfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_mld, lon_mld, lat_mld, time_mld);
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
		for l = 1 : length(mldfiles_weekly)
			if strfind(mldfiles_weekly(l).name,yeartag)		
			if strfind(mldfiles_weekly(l).name(26:35),match_name)
%                 if strfind(chlfiles_weekly(l).name,'AVW')
				[weekly_mld, lon_mld, lat_mld, time_mld] = weekly_mld_extract(echogram, [mldpath_weekly,mldfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_mld, lon_mld, lat_mld, time_mld);
				flag = 1;
%                 end
			end
			end
		end
	end
end




%% We replace the NaNs in the daily_chl vector

echogram.mld.weekly_mld = weekly_mld;
echogram.mld.lon_mld = lon_mld;
echogram.mld.lat_mld = lat_mld;
echogram.mld.time_mld = time_mld;
