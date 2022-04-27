function [echogram] = rmnan(echogram)
% This script removes deep empty ranges chunk or empty ranges for faster computation

for k = 1:length(echogram.pings)
 
    range_size = length(echogram.pings(k).time);
    ind = find(size(echogram.pings(k).Sv)==length(echogram.pings(k).time));
    tmp = nansum(echogram.pings(k).Sv,ind);

    indcorr = find(tmp~=0);

    echogram.pings(k).range = echogram.pings(k).range(indcorr);
    echogram.pings(k).Sv    = echogram.pings(k).Sv(indcorr,:);

end
