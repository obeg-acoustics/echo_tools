function [echogram] = par(echogram, parpath_daily, parpath_weekly, tagyear)
% Scripts that reads and extracts the par data



% Load list of PAR file names
parfiles_daily = dir(parpath_daily);
parfiles_weekly = dir(parpath_weekly);

% List of dates for par extraction
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


% Extract daily par at the corresponding cruise lon/lat ****************************************** 

daily_par = [];
lon_par = [];
lat_par = [];
time_par = [];
distance_par = [];

for k = 1:size(YMD_unique,1)
	for l = 1 : length(parfiles_daily)
		if strfind(parfiles_daily(l).name,YMD_unique(k,:))
                	[daily_par, lon_par, lat_par, time_par, distance_par] = daily_par_extract(echogram, [parpath_daily,parfiles_daily(l).name], str2num(D_unique(k,:)), daily_par, lon_par, lat_par, time_par, distance_par);
        	end
	end
end


% Extract weekly par at the corresponding cruise lon/lat ***************************************** 

weekly_par = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);

        % Case date is the last day of weekly file
	for l = 1 : length(parfiles_weekly)	
                if strfind(parfiles_weekly(l).name,['A',tagyear])	
			if strfind(parfiles_weekly(l).name(9:15),match_name)
				[weekly_par] = weekly_par_extract(echogram, [parpath_weekly,parfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_par);
				flag = 1;
			end
		end
	end

	% Other cases	
	while (flag == 0)
        	match_name = str2num(match_name);
        	match_name = match_name + 1;
        	match_name = num2str(match_name);
		for l = 1 : length(parfiles_weekly)
                        if strfind(parfiles_weekly(l).name,['A',tagyear])		
				if strfind(parfiles_weekly(l).name(9:15),match_name)
					[weekly_par] = weekly_par_extract(echogram, [parpath_weekly,parfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_par);
					flag = 1;
				end
			end
		end
	end
end


% Save par vectors ********************************************************************************

% Mixed par vector where we  replace the NaNs in the daily_par vector with weekly_par values
par_vector = daily_par;
ind_nan = find(isnan(par_vector));
par_vector(ind_nan) = weekly_par(ind_nan);

% Output
echogram.par.daily = daily_par;
echogram.par.weekly = weekly_par;
echogram.par.mixed = par_vector;
echogram.par.lon = lon_par;
echogram.par.lat = lat_par;
echogram.par.time = time_par;
echogram.par.dist = distance_par;
