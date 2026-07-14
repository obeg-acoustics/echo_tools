% This script loads an echogram and permits manual cleaning of remaining
% noises (false bottom, CTDs...)
% 2020-2026 J Guiet
% 
% Processing steps (ends once all frequencies have been cleaned)
% RECOVERY (1/0) ?          1 yes, 0 no, permit recovery of partly processed transects
% ZOOM ?                    allow zoom in the transect window, type enter once adjusted
% SELECT SECTION TO REMOVE  use cursor to select box around area to remove
% REMOVE SECTION ??? TO ??? (1/0): 1 yes, 0 no, confirm area to remove
% MOVE/FINISH(=1)?          1 section fully processed, move to next frequency, any key otherwise

warning('off', 'all');
clear all

addpath('/Users/jguiet/Work/Acoustic/Tools/echo_tools/')

% Number of the transect chunk to manually clean **************************
numtrans = 1

% Load filtered transect chunk ********************************************
load(['echogram_filtered_part',num2str(numtrans),'C.mat'])

% Initialize masks ********************************************************
for f = 1:length(echogram.pings)
    echogram.mask(f).SvBot = ones(size(echogram.pings(f).Sv));         % Mask for bottom
    echogram.mask(f).SvFalseBot = ones(size(echogram.pings(f).Sv));    % Mask for false bottom
    echogram.mask(f).SvManual = ones(size(echogram.pings(f).Sv));      % Manual removal of noise
end

% Bottom cleaning
meters_above_bottom_removal = 20;    % This parameter comes with the belowbottom_removal function. We can choose a certain height above the bottom we want to remove. Just be careful, when the bottom is steep, it's hard to remove all the signal due to the bottom, or you can choose a high height. And also, this height cannot be above sea surface (if the maximum height bottom goes to 15 meters below sea surface, the maximum meters_above_bottom_removal you can choose is 14 meters).
[echogram] = remove_bottom(echogram, meters_above_bottom_removal);

% Manual clean data false bottom in raw data ******************************
% Follow command window to identify sequences of pings were CTD or false
% bottoms spoil the acoustic transect above a prefered depth
for k = 1:length(echogram.pings)
    echogram = manual_clean(echogram,k,length(echogram.pings));
    echogram = remove_clean(echogram,k,length(echogram.pings));
    clean_tmp = echogram.clean;
    save('echogram_clean_tmp.mat','clean_tmp','-v7.3')
    close all
end

% Save filtered and cleaned transect ready for analysis *******************
save(['echogram_filtered_cleaned_part',num2str(numtrans),'.mat'],'echogram','-v7.3')

% Generate figure *********************************************************
figure
for k = 1:length(echogram.pings)
    nfreq = length(echogram.pings);
    subplot(nfreq,1,k)
    imagesc(echogram.pings(k).time,echogram.pings(k).range,echogram.pings(k).Sv.*...
        echogram.mask(k).SvFalseBot.*echogram.mask(k).SvBot.*echogram.mask(k).SvManual)
    colorbar
    caxis([-100,-40])
end
saveas(gcf,['cruise_filtered_cleaned_freqs_part',num2str(numtrans),'C.png'])
