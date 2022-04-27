function [weekly_sst] = weekly_dsst_extract(echogram, file, day, weekly_sst,daynight)

% Function to extract the sst data for a specific day


% Extraction of the variables in the sst file

if strcmp(daynight,'day')
    sst = ncread(file, 'sst');
elseif strcmp(daynight,'night') 
    sst = ncread(file, 'sst4');
end
sst = sst';

sst_lon = repmat([ncread(file, 'lon')]',[4320,1]);
sst_lat = repmat(ncread(file, 'lat'),[1,8640]);

% SST Gradient
Gx = nan*sst;
Gy = nan*sst;

dSSTx = sst(:,3:end)-sst(:,1:end-2);
dx = deg2km(distance(sst_lat(:,3:end),sst_lon(:,3:end),sst_lat(:,1:end-2),sst_lon(:,1:end-2)));
dSSTy = sst(3:end,:)-sst(1:end-2,:);
dy = deg2km(distance(sst_lat(3:end,:),sst_lon(3:end,:),sst_lat(1:end-2,:),sst_lon(1:end-2,:)));

Gx(:,2:end-1)=dSSTx./dx;
Gy(2:end-1,:)=dSSTy./dy;

%Gx(2:end-1,2:end-1) = sst(3:end,1:end-2)-sst(1:end-2,3:end)+sst(3:end,3:end)  -sst(1:end-2,1:end-2)-2*(sst(3:end,2:end-1)-sst(1:end-2,2:end-1));
%Gy(2:end-1,2:end-1) = sst(3:end,3:end)  -sst(1:end-2,3:end)+sst(3:end,1:end-2)-sst(1:end-2,1:end-2)+2*(sst(2:end-1,3:end)-sst(2:end-1,1:end-2));
dsst = sqrt(Gx.^2+Gy.^2);

lon = ncread(file, 'lon');
lat = ncread(file, 'lat');


% Extraction in the echogram of the indexes that are in a specific day

date_mat = datevec(echogram.pings(1).time);
ind_day = find(date_mat(:,3) == day);

lon_day = echogram.pings(1).lon(ind_day);
lat_day = echogram.pings(1).lat(ind_day);

% Extraction of sst

a = interp2(lon, lat, dsst, lon_day, lat_day);
weekly_sst = [weekly_sst; a'];

