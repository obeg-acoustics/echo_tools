function [echogram] = set_lonlat(echogram,LON,LAT)
% This script set fixed longitude/latitude for fixed platforms

for k = 1:length(echogram.pings)
 
%    if ~isfield(echogram.pings(k),'lon')
	tmp = ones(size(echogram.pings(k).time));
        echogram.pings(k).lon = LON*tmp;
%    elseif isempty(echogram.pings(k).lon)
%        tmp = ones(size(echogram.pings(k).time));
%        echogram.pings(k).lon = LON*tmp;
%    end
%    if ~isfield(echogram.pings(k),'lat')
	tmp = ones(size(echogram.pings(k).time));
        echogram.pings(k).lat = LAT*tmp;
%    elseif isempty(echogram.pings(k).lat)
%	tmp = ones(size(echogram.pings(k).time));
%        echogram.pings(k).lat = LAT*tmp;
%    end

end

%if ~isfield(echogram.gps,'lat')
    tmp = ones(size(echogram.pings(1).time));
    echogram.gps.lat = LAT*tmp;
%elseif isempty(echogram.gps.lat)
%    tmp = ones(size(echogram.pings(1).time));
%    echogram.gps.lat = LAT*tmp; 
%end

%if ~isfield(echogram.gps,'lon') 
    tmp = ones(size(echogram.pings(1).time));
    echogram.gps.lon = LON*tmp;
%elseif isempty(echogram.gps.lon)
%    tmp = ones(size(echogram.pings(1).time));
%    echogram.gps.lon = LON*tmp;
%end

return
