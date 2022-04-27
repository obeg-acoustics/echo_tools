function [Y_bin,lon_bin,lat_bin,time_bin] = calculate_driver(Y, dL, time, lon, lat, distance)

% This function calculates, from colocated dirver conditions, binned driver values

% Input :
%   - dL distance resolution
%   - Y driver timeseries
%   - time time vector
%   - lon longitude vector
%   - lat latitude vector
%   - distance vector
% Output :
%   - Y_bin : a one dimension for the binned driver
%   - lon_bin : the binned longitude
%   - lat_bin : the binned latitude
%   - time_bin : the average time step

Y_bin = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
lon_bin = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
lat_bin = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );
time_bin = NaN*ones(1, round((nanmax(distance)-nanmin(distance))/dL) );

for i=1:length(Y_bin)
    if i == length(Y_bin)
        dist   = (i-1)*dL;
        distp1 = nanmax(distance);
        ind_dist = find((distance>=dist)&(distance<distp1));
        if ~isempty(ind_dist)
            X  = [dist;distance(ind_dist)];
        end
    else
        dist   = (i-1)*dL;
        distp1 = i*dL;
        ind_dist = find((distance>=dist)&(distance<distp1));
        if ~isempty(ind_dist)
            X  = [dist;distance(ind_dist);distp1];
            ind_dist = [ind_dist;ind_dist(end)+1]';
        end
    end
    if ~isempty(ind_dist)
        % Distance bins
        dX = diff(X);

        tmp1 = Y(ind_dist);
        ind  = find(~isnan(tmp1));

	if ~isempty(ind)
	    Y_bin(i) =  nansum(dX(ind).*tmp1(ind))./nansum(dX(ind));

	    % Udpate coordinates for distance bin
            tmp  = lon(ind_dist);
            lon_bin(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));
            tmp  = lat(ind_dist);
            lat_bin(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));

            % Update time vector for distance bin
            tmp  = time(ind_dist);
            time_bin(i) = nansum(dX(ind).*tmp(ind))./nansum(dX(ind));
        %Y_bin(i) = nansum(diff(X).*Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        %lon_bin(i) = nansum(diff(X).*lon(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        %lat_bin(i) = nansum(diff(X).*lat(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        %time_bin(i) = nansum(diff(X).*time(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        else
            Y_bin(i) = NaN;
            lon_bin(i) = NaN;
            lat_bin(i) = NaN;
            time_bin(i) = NaN;
        end
    end
end
