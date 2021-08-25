function [echogram] = correct_echogram(echogram)
% This script corrects echograms and shape them to to similar formats

for k = 1:length(echogram.pings)
 
    if isfield(echogram.pings(k),'distance') && iscolumn(echogram.pings(k).distance)
        echogram.pings(k).distance = echogram.pings(k).distance';
    end
    if isfield(echogram.pings(k),'lon') && iscolumn(echogram.pings(k).lon)
        echogram.pings(k).lon = echogram.pings(k).lon';
    end
    if isfield(echogram.pings(k),'lat') && iscolumn(echogram.pings(k).lat)
        echogram.pings(k).lat = echogram.pings(k).lat';
    end
    if isfield(echogram.pings(k),'range') && ~iscolumn(echogram.pings(k).range)
        echogram.pings(k).range = echogram.pings(k).range';
    end
    if isfield(echogram.pings(k),'time') && iscolumn(echogram.pings(k).time)
        echogram.pings(k).time = echogram.pings(k).time';
    end
    if isfield(echogram.pings(k),'pitch') && iscolumn(echogram.pings(k).pitch)
        echogram.pings(k).pitch = echogram.pings(k).pitch';
    end
    if isfield(echogram.pings(k),'roll') && iscolumn(echogram.pings(k).roll)
        echogram.pings(k).roll = echogram.pings(k).roll';
    end
    if isfield(echogram.pings(k),'soundvelocity') && iscolumn(echogram.pings(k).soundvelocity)
        echogram.pings(k).soundvelocity = echogram.pings(k).soundvelocity';
    end
    if isfield(echogram.pings(k),'transducerdepth') && iscolumn(echogram.pings(k).transducerdepth)
        echogram.pings(k).transducerdepth = echogram.pings(k).transducerdepth';
    end

    nrange = length(echogram.pings(k).range);
    ntime  = length(echogram.pings(k).time);
    if size(echogram.pings(k).Sv,1) ~= nrange
        echogram.pings(k).Sv = echogram.pings(k).Sv';
    end

end

if isfield(echogram.gps,'distance') && ~iscolumn(echogram.gps.distance)
    echogram.gps.distance = echogram.gps.distance';
end
if isfield(echogram.gps,'lat') && ~iscolumn(echogram.gps.lat)
    echogram.gps.lat = echogram.gps.lat';
end
if isfield(echogram.gps,'lon') && ~iscolumn(echogram.gps.lon)
    echogram.gps.lon = echogram.gps.lon';
end
if isfield(echogram.gps,'time') && ~iscolumn(echogram.gps.time)
    echogram.gps.time = echogram.gps.time';
end

% Correct NaN
[echogram] = rmnan(echogram);

return
