function [echogram] = bottom_coarsening(echogram)

% Script whose goal is to interpolate the bottom depth on coarser resolution

% Input :
%	- echogram

% Output :
%	- echogram.bottom.bottom_indexes : a vector whose length is the same as echogram.pings(j).time, containing the range indexes of the bottom
%	- echogram.bottom.bottom_depth : a vector whose length is the same as echogram.pings(j).time, containing the depth of the bottom
%       - echogram.bottom.bottom_time : a vector whose length is the same as echogram.pings(j).time, containing the times matching bottom data

% Reference depth and times
time_fine    = echogram.bottom.bottom_time;
depth_fine   = echogram.bottom.bottom_depth;

% Coarse time vector for interpolation
time_coarse  = echogram.pings(1).time;
range_coarse = echogram.pings(1).range;

% Smoothing of ping to ping variability
depth_smooth = smoothdata(depth_fine,'movmean',10);

% Adjust lengths +/- 1 ping 
if length(time_fine)>length(depth_smooth)
    depth_smooth = [depth_smooth, NaN];
elseif length(time_fine)<length(depth_smooth) 
    time_fine = [time_fine, NaN];
end

% Remove redudant time steps
[time_fine, ia, ic] = unique(time_fine);

% Interpolate depth on coarser times 
depth_coarse = interp1(time_fine,depth_smooth(ia),time_coarse); %ATT 1:end-1 fix
depth_coarse = fillmissing(depth_coarse,'movmean',10);


% Find matching depth bin indexes
indexes_coarse = [];
for k = 1:length(depth_coarse)
   if ~isnan(depth_coarse(k))
       tmp = find(abs(range_coarse - depth_coarse(k))==min(abs(range_coarse - depth_coarse(k))));
       indexes_coarse = [indexes_coarse, tmp(1)];
   else
       indexes_coarse = [indexes_coarse,NaN];
   end
end

% save updated values
echogram.bottom.bottom_indexes = indexes_coarse;
echogram.bottom.bottom_depth   = depth_coarse;
echogram.bottom.bottom_time    = time_coarse;
