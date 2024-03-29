function [Tint,Sint] = getenvironment(D,lonpoints,latpoints,months)

% This script interpolate environmental conditions
pathT = '/data/project1/data/WOA18/temperature/Temperature.mat';
pathS = '/data/project1/data/WOA18/salinity/Salinity.mat';

load(pathT)
load(pathS)

M = unique(months);

Tint = D*NaN;
Sint = D*NaN;
for m = 1:length(M)
    
    % Environment
    T = Temperature_clim.avg_val(:,:,:,M(m));
    T(find(T>10^10)) = NaN;
T = fillmissing(T,'linear',1,'EndValues','nearest');
    S = Salinity_clim.avg_val(:,:,:,M(m));
    S(find(S>10^10)) = NaN;
S = fillmissing(S,'linear',1,'EndValues','nearest');
 
    % Grid
    Lon = Temperature_clim.lon;
    Lat = Temperature_clim.lat;
    depth = Temperature_clim.depth;
   
    FT = griddedInterpolant({Lon,Lat,depth},T);
    FS = griddedInterpolant({Lon,Lat,depth},S);

    % Interpolate
    ind = find(months==M(m));

    Tint(:,ind) = FT(repmat(lonpoints(ind),[size(D,1),1]),repmat(latpoints(ind),[size(D,1),1]),D(:,ind));
    Sint(:,ind) = FS(repmat(lonpoints(ind),[size(D,1),1]),repmat(latpoints(ind),[size(D,1),1]),D(:,ind));

end

% Fill nan values with nearest
%Tint = fillmissing(Tint,'nearest');
%Sint = fillmissing(Sint,'nearest');

% Fill missing values horizontally
Tint = fillmissing(Tint,'linear',2,'EndValues','nearest');
Sint = fillmissing(Sint,'linear',2,'EndValues','nearest');
% Fill missing values vertically
Tint = fillmissing(Tint,'linear',1,'EndValues','nearest');
Sint = fillmissing(Sint,'linear',1,'EndValues','nearest');
return
