% This script concatenates all chunks to generate a single sva vector with matching environmental conditions
%keyboard

clear all

% Load sva chunks
load sa_test.mat
target.val  = sva(1).sva;
target.lon  = sva(1).lon_sva;
target.lat  = sva(1).lat_sva;
target.time = sva(1).time_sva;

load sa_test.mat 
target.val  = cat(2,target.val,sva(1).sva);
target.lon  = cat(2,target.lon,sva(1).lon_sva);
target.lat  = cat(2,target.lat,sva(1).lat_sva);
target.time = cat(2,target.time,sva(1).time_sva);


% Load drivers chunks
load Env_echogram.mat
pred.solar  = solar.solar_angle_bin;
pred.chl    = chl.weekly_chl_bin;
pred.poc    = poc.weekly_poc_bin;
pred.par    = par.weekly_par_bin;
pred.sst    = sst.weekly_sst_bin;
pred.ssh    = ssh.weekly_ssh_bin;

load Env_echogram.mat
pred.solar  = cat(2,pred.solar,solar.solar_angle_bin);
pred.chl    = cat(2,pred.chl,chl.weekly_chl_bin);
pred.poc    = cat(2,pred.poc,poc.weekly_poc_bin);
pred.par    = cat(2,pred.par,par.weekly_par_bin);
pred.sst    = cat(2,pred.sst,sst.weekly_sst_bin);
pred.ssh    = cat(2,pred.ssh,ssh.weekly_ssh_bin);

% save
save('cruise.mat','target','pred')
