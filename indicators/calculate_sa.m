function [sva_out] = calculate_sa(echogram, dL, rangeDepth, rangeMFI)

% This function calculates, from an echogram, the area backscattering coefficient
% Further, it only integrates at points where there are MFI values in the
% range it is given and up to the depth range it is given
 
% Input :
%	- echogram
%   - dL -> distance bin width (in km)
%   - rangeDepth -> determines the depth layer to process
%   - rangeMFI -> determines the MFI groups to process
% Output :
%   - sva_out.sva : a one dimension vector whose length is equal to the distance covered by the transtect, divided by the binning length dL. Each value is the area backscattering coefficient.
%   - sva_out.lat_sva : vector of mean latitude per distance bin
%   - sva_out.lon_sva : vector of mean longitude per distance bin
%   - sva_out.time_sva : vector of mean time per distance bin

for j=1:length(echogram.pings)

    % We convert the Sv values into sv values
    sv = 10.^(echogram.pings(j).Sv(rangeDepth,:)/10.*echogram.mask(j).SvManual(rangeDepth,1:size(echogram.pings(j).Sv,2)).*echogram.mask(j).SvFalseBot(rangeDepth,:).*echogram.mask(j).SvBot(rangeDepth,:));
                
    distance = echogram.pings(j).distance;
    lon = echogram.pings(j).lon;
    lat = echogram.pings(j).lat;
    time = echogram.pings(j).time;
    
    % We create indmfi to be NaN everywhere except where within MFI range
    % Use "find", faster than loops
    mfi = echogram.analysis.MFI(rangeDepth,:);
    indmfi = ((mfi>rangeMFI(1))&(mfi<rangeMFI(2)));

    % set sv to NaN everywhere except where an MFI_d is present, so those
    % values are ignored in the integration
    tmp = sv;
    sv  = NaN.*sv;
    sv(indmfi) = tmp(indmfi);
    
    % Initialise sva matrix
    sva      = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
    lon_sva  = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
    lat_sva  = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
    time_sva = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
    
    for i=1:length(sva)
        if i == length(sva)
            dist   = nanmin(distance)+(i-1)*dL;
            distp1 = nanmax(distance);
        else
            dist   = nanmin(distance)+(i-1)*dL;
            distp1 = nanmin(distance)+i*dL;
        end
        ind_dist = find((distance>=dist)&(distance<distp1));
        if ~isempty(ind_dist)
            % Distance bins
            X  = [dist;distance(ind_dist)]';
            dX = diff(X);

            % Select chunk of sv values within distance bin
            tmp1 = sv(:,ind_dist);
            tmp2 = nansum(tmp1(:,:),1);
            ind  = find(tmp2~=0);
            
            sva(i) = nansum(dX(ind).*tmp2(ind))./nansum(dX(ind));

            % Udpate coordinates for distance bin
            tmp  = lon(ind_dist)';
            lon_sva(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));
            tmp  = lat(ind_dist)';
            lat_sva(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));
            
            % Update time vector for distance bin
            tmp  = time(ind_dist)';
            time_sva(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));
        else
            sva(i) = NaN;
            lon_sva(i) = NaN;
            lat_sva(i) = NaN;
            time_sva(i) = NaN;
        end
    end
    sva_out(j).sva = sva;
    sva_out(j).NASC = 4.*pi*(1852)^2*sva;
    sva_out(j).lon_sva = lon_sva;
    sva_out(j).lat_sva = lat_sva;
    sva_out(j).time_sva = time_sva;
end
