function [echogram] = addnan(echogram,idcut)

% This script manually adds nans below a set depth for anomalous deep transects

for k = 1:length(echogram.pings)
 
    echogram.pings(k).Sv(idcut:end,:) = NaN;

end
