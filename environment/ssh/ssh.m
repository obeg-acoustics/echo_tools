function [echogram] = ssh(echogram, sshpath_weekly)
% Scripts that reads and extracts the ssh data



% Load list of ssh file names
sshfiles_weekly = dir(sshpath_weekly);

% List of dates for ssh extraction
timevector=datevec(echogram.pings(1).time);
YMD = [num2str(timevector(:,1)),num2str(timevector(:,2),'%02d'),num2str(timevector(:,3),'%02d')];
YMD_unique = unique(YMD,'rows');

% Convert for tag name
Y_unique=YMD_unique(:,1:4);
M_unique=YMD_unique(:,5:6);
D_unique=YMD_unique(:,7:8);


% Extract ssh at the corresponding cruise lon/lat *********************************************** 

weekly_ssh = [];
lon_ssh = [];
lat_ssh = [];
time_ssh = [];
distance_ssh = [];

for k = 1:size(YMD_unique,1)
	flag = 0;
	match_name = YMD_unique(k,:);

	% Case date is the last day of weekly file
	for l = 1 : length(sshfiles_weekly)		
        	if strfind(sshfiles_weekly(l).name,'ssh_grids')
			if strfind(sshfiles_weekly(l).name(17:24),match_name)
				[weekly_ssh, lon_ssh, lat_ssh, time_ssh, distance_ssh] = weekly_ssh_extract(echogram, [sshpath_weekly,sshfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_ssh, lon_ssh, lat_ssh, time_ssh, distance_ssh);
				flag = 1;
        		end
        	end
	end

	% Other cases
	while (flag == 0)
        	match_name = str2num(match_name);
        	match_name = match_name + 1;
        	match_name = num2str(match_name);
		for l = 1 : length(sshfiles_weekly)	
            		if strfind(sshfiles_weekly(l).name,'ssh_grids')
				if strfind(sshfiles_weekly(l).name(17:24),match_name)
					[weekly_ssh, lon_ssh, lat_ssh, time_ssh, distance_ssh] = weekly_ssh_extract(echogram, [sshpath_weekly,sshfiles_weekly(l).name], str2num(D_unique(k,:)), weekly_ssh, lon_ssh, lat_ssh, time_ssh, distance_ssh);
					flag = 1;
            			end
            		end
		end
	end
end


% Save ssh vectors ********************************************************************************

% Output
echogram.ssh.weekly = weekly_ssh;
echogram.ssh.daily = weekly_ssh;
echogram.ssh.lon = lon_ssh;
echogram.ssh.lat = lat_ssh;
echogram.ssh.time = time_ssh;
echogram.ssh.dist = distance_ssh; 
