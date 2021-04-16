function [echogram] = correct_echogram(echogram)
% This script corrects echograms and shape them to to similar formats

for k = 1:length(echogram.pings)
 
    if ~iscolumn(echogram.pings(k).distance)
        echogram.pings(k).distance = echogram.pings(k).distance';
    end
    if ~iscolumn(echogram.pings(k).lon)
        echogram.pings(k).lon = echogram.pings(k).lon';
    end
    if ~iscolumn(echogram.pings(k).lat)
        echogram.pings(k).lat = echogram.pings(k).lat';
    end
    if ~iscolumn(echogram.pings(k).range)
        echogram.pings(k).range = echogram.pings(k).range';
    end
    if ~iscolumn(echogram.pings(k).time)
        echogram.pings(k).time = echogram.pings(k).time';
    end

end
