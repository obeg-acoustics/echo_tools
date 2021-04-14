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
        dist   = nanmin(distance)+(i-1)*dL;
        distp1 = nanmax(distance);
    else
        dist   = nanmin(distance)+(i-1)*dL;
        distp1 = nanmin(distance)+i*dL;
    end
    ind_dist = find((distance>=dist)&(distance<distp1)); 
    if ~isempty(ind_dist)
        % Distance bins
        X = [dist;distance(ind_dist)];

        Y_bin(i) = nansum(diff(X).*Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        lon_bin(i) = nansum(diff(X).*lon(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        lat_bin(i) = nansum(diff(X).*lat(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
        time_bin(i) = nansum(diff(X).*time(ind_dist).*Y(ind_dist)./Y(ind_dist))./nansum(diff(X).*Y(ind_dist)./Y(ind_dist));
    else
        Y_bin(i) = NaN;
        lon_bin(i) = NaN;
        lat_bin(i) = NaN;
        time_bin(i) = NaN;
    end
end
