function [echogram] = rmnan(echogram)
% This script removes deep empty ranges chunk or empty ranges for faster computation

for k = 1:length(echogram.pings)
 
    tmp = nansum(echogram.pings(k).Sv,2);

    indcorr = find(tmp~=0);

    echogram.pings(k).range = echogram.pings(k).range(indcorr);
    echogram.pings(k).Sv    = echogram.pings(k).Sv(indcorr,:);

end
