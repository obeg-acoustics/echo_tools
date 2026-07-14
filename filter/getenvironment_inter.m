function [Tint,Sint] = getenvironment_inter(D,lonpoints,latpoints,years,months,days)

% This script interpolate environmental conditions
pathT = ['soda/Temperature_inter_',num2str(years(1)),'.mat'];
pathS = ['soda/Salinity_inter_',num2str(years(1)),'.mat'];

load(pathT)
load(pathS)


M = datenum(unique([years,months,days],'rows'));
Mref = datenum([str2num(Temperature_inter.time(:,1:4)),str2num(Temperature_inter.time(:,5:6)),str2num(Temperature_inter.time(:,7:8))]);

Tint = D*NaN;
Sint = D*NaN;
for m = 1:length(M)
    
    % Environment
    ind = min(find(Mref>=M(m)));
    T = Temperature_inter.avg_val(:,:,:,ind);
    T(find(T>10^10)) = NaN;
T = fillmissing(T,'linear',1,'EndValues','nearest');
    S = Salinity_inter.avg_val(:,:,:,ind);
    S(find(S>10^10)) = NaN;
S = fillmissing(S,'linear',1,'EndValues','nearest');
 
    % Grid
    Lon = Temperature_inter.lon;
    Lat = Temperature_inter.lat;
    depth = Temperature_inter.depth;
   
    FT = griddedInterpolant({Lon,Lat,depth},T);
    FS = griddedInterpolant({Lon,Lat,depth},S);

    % Interpolate
    ind = find(datenum([years,months,days])==M(m));

    Tint(:,ind) = FT(repmat(lonpoints(ind),[size(D,1),1]),repmat(latpoints(ind),[size(D,1),1]),D(:,ind));
    Sint(:,ind) = FS(repmat(lonpoints(ind),[size(D,1),1]),repmat(latpoints(ind),[size(D,1),1]),D(:,ind));

end

% Fill missing values horizontally
Tint = fillmissing(Tint,'linear',2,'EndValues','nearest');
Sint = fillmissing(Sint,'linear',2,'EndValues','nearest');
% Fill missing values vertically
Tint = fillmissing(Tint,'linear',1,'EndValues','nearest');
Sint = fillmissing(Sint,'linear',1,'EndValues','nearest');

return
