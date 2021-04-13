% Filtering Script
%
% This script filters extracted raw transects and bin the data
%
% Stanislas Bebin  -  Jerome Guiet
%keyboard


% Load the appropriate echogram to process
load echogram.mat
parameters
clock

[echogram] = distance_vector(echogram)


% Motion correction TO TEST
%[echogram] = motion_correction(echogram);


% Remove Impulsive Noise (IN)
% INthreshold = 10;
% INn = 1;
% INmin = -80;
disp('IN removal') 
[echogram] = IN_filter(echogram, INthreshold, INn, INmin);


%% Binning =========================
% % We vertically bin this echogram chunk
% [echogram] = vertical_binning3(echogram, 10);
% % Horizontal binning
% [echogram] = horizontal_binning_distance2(echogram, 1000);


% Bottom detection =================
% window_radius = 100;
disp('Bottom detect')
[echogram] = bottom_detection(echogram, bottom_threshold, window_radius, start_depth, Sv_max_chunks_threshold, warning_bottom_threshold);

% Remove Attenuation Signal (AS) ===
% ASthreshold = 8;
% ASn = 100; % In [30,300]
% R1  = 300;
% R2  = 400; 
disp('AS removal')
[echogram] = AS_filter(echogram, ASthreshold, ASn, R1, R2)

% Remove Transient Noise (TN) ======
% TNthreshold = 15;
% TNn = 50;
% TNm = 50; % ~10m
% TNmin = -70;
% mindepth = 300;
disp('TN removal')
[echogram] = TN_filter(echogram, TNthreshold, TNn, TNm, TNmin, mindepth)

% Background noise removal (BG) ====
% BGn              = 40;
% BGm              = 50;
% thresholdSNR     = 10;
% noisemax         = -125;
disp('BG removal')
[echogram] = BG_filter(echogram, BGn, BGm, noisemax, thresholdSNR);


% Bottom removal ===================
%disp('Bottom removal')
%vertical_binsize = 10;
%[echogram] = data_removal(echogram, meters_above_bottom_removal, vertical_binsize, upper_layer_height);


% Binning =========================
% We vertically bin this echogram chunk
[echogram] = vertical_binning(echogram, 1);
% Horizontal binning
[echogram] = horizontal_binning_time(echogram, 30);
% Update distance for binned resolution
[echogram] = distance_correct(echogram)

% Interpolated bottom removal =====
disp('Bottom removal 2')
[echogram] = bottom_coarsening(echogram)
[echogram] = data_removal(echogram, meters_above_bottom_removal, upper_layer_height);


clock

save('echogram_filtered.mat','echogram','-v7.3')
