function [echogram] = flip_echogram(echogram)
% This script flips echograms to account for downward or upward looking echosounders

for k = 1:length(echogram.pings)
    tmp = echogram.pings(k).Sv;
    echogram.pings(k).Sv = tmp(end:-1:1,:);
end


return
