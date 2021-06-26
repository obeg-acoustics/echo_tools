function [echogram] = absorption_correction(echogram)

% This script corrects the sound absorption along transects from
% climatolofical environmental conditions.

% Default paramerters
pH = 7.8;

for k = 1:length(echogram.pings)
    
    % Interpolate environmental conditions along transect depths 
    times  = datevec(echogram.pings(k).time');
    depths = repmat(echogram.pings(k).range,[1,size(echogram.pings(k).Sv,2)]);
    [Tint,Sint] = getenvironment(depths,echogram.pings(k).lon,echogram.pings(k).lat,times(:,2));

    % Corrected sound speed 
    [speedcoef] = soundspeed(Tint,Sint,depths);
    for l = 1:length(echogram.pings(k).range)
        speedbar(l,:) = nanmean(speedcoef(1:l,:),1);
        depthsbar(l,:) = speedbar(l,:) ./ double(echogram.calParms(k).soundvelocity) .* depths(l,:);           
    end

    % Interpolate environmental conditions along corrected transect depths 
    [Tint,Sint] = getenvironment(depthsbar,echogram.pings(k).lon,echogram.pings(k).lat,times(:,2)');
    
    % Corrected absorption 
    [absorbcoef] = absorption(Tint,Sint,pH,depthsbar,echogram.calParms(k).frequency/1000);
    for l = 1:length(echogram.pings(k).range)
        absorbbar(l,:) = 10*log10( nanmean(10.^(absorbcoef(1:l,:)/10),1) );
    end

    % Corrected Sv 
    SvCorr_tmp = echogram.pings(k).Sv + 20 * log10(speedbar/double(echogram.calParms(k).soundvelocity)) + ...
                 2 * depths .* (absorbbar.*speedbar/double(echogram.calParms(k).soundvelocity)-double(echogram.calParms(k).absorptioncoefficient)) - ...
                 10 * log10(speedcoef/double(echogram.calParms(k).soundvelocity));
    Y = repmat(echogram.pings(k).distance',[size(depthsbar,1),1]);

    % Re-interpolate on depths ranges not corrected for abosorption
    F = scatteredInterpolant(depthsbar(:),Y(:),SvCorr_tmp(:));
    echogram.pings(k).Sv = F(depths,Y);

end

return
