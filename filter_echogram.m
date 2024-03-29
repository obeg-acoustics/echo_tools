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

% Compute distance vector
disp('Compute distance')
[echogram] = distance_vector(echogram);

% Correct dimensions
disp('Prepare echogram')
[echogram] = correct_echogram(echogram);

% Motion correction
disp('Motion correction')
[echogram] = motion_correction(echogram);

% Correct ranges
for k = 1:5
    echogram.pings(k).range = echogram.pings(k).range - (echogram.calParms(k).pulselength*(echogram.calParms(k).soundvelocity/4));
end

% Remove Impulsive Noise (IN)
% INthreshold = 6;
% INsmooth    = 5;
% INnmax      = 4; % (up to 4)
% INminSv     = -170;
disp('IN removal')
[echogram] = IN_filter(echogram, INthreshold, INsmooth, INnmax, INminSv);

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
% ASn         = 300; % In [30,300]
% R1          = 500;
% R2          = 600;
disp('AS removal')
[echogram] = AS_filter(echogram, ASthreshold, ASn, R1, R2);

% Remove Transient Noise (TN) ======
% TNthreshold = 15;
% TNprctile   = 15;
% TNsmooth    = 20;
% TNn         = 50;
% TNm         = 10;
% TNminSv     = -150;
% mindepth    = 250;
disp('TN removal')
[echogram] = TN_filter(echogram, TNthreshold, TNsmooth, TNn, TNm, TNminSv, mindepth, TNprctile);

% Background noise removal (BG) ====
% BGn              = 10;
% BGm              = 15;
% thresholdSNR     = 10;
% noisemax         = -100;
disp('BG removal')
[echogram] = BG_filter(echogram, BGn, BGm, noisemax, thresholdSNR);

% Residual noise removal (RN) ====
% RNthreshold = -50;
% RNminSv     = -160;
disp('RN removal')
[echogram] = RN_filter(echogram, RNthreshold, RNminSv);

% Bottom removal ===================
%disp('Bottom removal')
%vertical_binsize = 10;
%[echogram] = data_removal(echogram, meters_above_bottom_removal, vertical_binsize, upper_layer_height);

% Velocity vector ==================
disp('Compute velocities')
[echogram] = velocity_detection(echogram);

% Binning =========================
disp('Binning')
% We vertically bin this echogram chunk
[echogram] = vertical_binning(echogram, 1);
% Horizontal binning
[echogram] = horizontal_binning_time(echogram, 30);
%[echogram] = horizontal_binning_distance(echogram, 1000);
% Update distance for binned resolution
[echogram] = distance_correct(echogram);

% Correct absorption  =============
disp('Absorption correction')
[echogram] = absorption_correction(echogram);

% Interpolated bottom removal =====
disp('Bottom removal 2')
[echogram] = bottom_coarsening(echogram);
[echogram] = data_removal(echogram, meters_above_bottom_removal, upper_layer_height);


clock

save('echogram_filtered.mat','echogram','-v7.3')
