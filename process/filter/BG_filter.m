function [echogram] = BG_filter(echogram, BGn, BGm, noisemax, thresholdSNR)

% This function removes the background noise from the echogram, following De Robertis' paper : "A post-processing technique to estimate the signal-to-noise ratio (SNR) and remove echosounder background noise".

% Input :
%	- echogram to filter
%	- BGn : the number of pings that will be used to calulate the noise
%	- BGm : the number of range samples that will be used to calculate the noise
%	- noisemax : a maximum noise threshold we need to fix which enables not considering parts with transient noise (for instance) as noise
%	- thresholdSNR : values whose SNR are below this threshold will be removed
%
% Output :
%	- filtered echogram
%keyboard

for j=1:length(echogram.pings)

%% Here we calculate the TVG range (then create a matrix), which is useful to remove TVG from the measured data.
	rangeTVG = zeros(size(echogram.pings(j).range));
	rangeTVG = echogram.pings(j).range - (echogram.calParms(j).pulselength*(echogram.calParms(j).soundvelocity/4));
	echogram.pings(j).rangeTVG = rangeTVG;

	rangeTVGmatrix = repmat(echogram.pings(j).rangeTVG, 1, length(echogram.pings(j).time));


%% Calculation of powercal (following De Robertis' paper)

	powercal = zeros(size(echogram.pings(j).Sv));

% WARNING : Since the first values of rangeTVG vector can be negatives, it creates complex numbers with the log10. This is only for first values, which are not really important for the background noise because the noise to signal ratio is very low. So, in what's following, we keep the real part of the complex numbers, so that we avoid any kind of further problems using complex numbers.

	powercal = real(echogram.pings(j).Sv - (20*log10(rangeTVGmatrix) + 2*echogram.calParms(j).absorptioncoefficient*rangeTVGmatrix));


%% Calculation of noise vector (following De Robertis' paper)

% Mean along pings

	powercalmeanTemp = zeros(size(powercal,1), floor(size(powercal,2)/BGn)+1);
	for i=1:floor(size(powercal,2)/BGn)
		powercalmeanTemp(:,i) = nanmean(10.^(powercal(:,(i-1)*BGn+1:i*BGn)/10),2);
	end

	powercalmeanTemp(:,floor(size(powercal,2)/BGn)+1) = nanmean(10.^(powercal(:,(floor(size(powercal,2)/BGn))*BGn+1:end)/10),2);% Here we fill the end of powercalmeanTemp matrix.


% Mean along range

powercalmean = zeros(floor(size(powercal,1)/BGm)+1, floor(size(powercal,2)/BGn)+1);
	for i=1:floor(size(powercal,1)/BGm)
		powercalmean(i,:) = nanmean(powercalmeanTemp((i-1)*BGm+1:i*BGm,:),1);
	end

	powercalmean(floor(size(powercal,1)/BGm)+1,:) = nanmean(powercalmeanTemp((floor(size(powercal,2)/BGm))*BGm+1:end,:),1); % Here we fill the end of powercalmean matrix.


% We define noise vector
	noise = zeros(1, size(powercalmean, 2));
	indinf = find(10*log10(powercalmean)==-inf); % Sometimes, there's -Inf in powercalmean, which cannot be the background noise (too low)
	powercalmean(indinf) = 0;
	noise = nanmin(10*log10(powercalmean));

	for k=1:length(noise)
		if noise(k) > noisemax
			noise(k) = noisemax;
		end
	end

        clear powercalmean
        clear powercalmeanTemp

% We reshape the noise vector in order to have a matrix which has the same dimensions as Sv

	noisevect = zeros(1,size(powercal,2));

	for i=1:BGn:floor(size(powercal,2)/BGn)*BGn
		noisevect(i:i+BGn-1) = noise(floor(i/BGn +1));
	end

	noisevect(1,floor(size(powercal,2)/BGn)*BGn+1:end) = noise(end);

	echogram.pings(j).BGnoisevect = noisevect;

	noisematrix = repmat(noisevect, size(powercal,1),1);

% We calculate Svnoise matrix (following De Robertis' paper) (!!! This is not the SvNoise matrix in echogram structure !!!)

	Svnoise = double(zeros(size(powercal)));

        clear powercal

%% WARNING : Since the first values of rangeTVG vector can be negatives, it creates complex numbers with the log10. This is only for first values, which are not really important for the background noise because the noise to signal ratio is very low. So, in what's following, we keep the real part of the complex numbers, so that we avoid any kind of further problems using complex numbers.

	Svnoise = double(real(noisematrix + (20*log10(rangeTVGmatrix) + 2*echogram.calParms(j).absorptioncoefficient*rangeTVGmatrix)));

        clear rangeTVGmatrix

% We calculate Svcorr matrix (following De Robertis' paper)

	Svcorr = 10*log10(10.^(echogram.pings(j).Sv/10)-10.^(Svnoise/10)); % Warning : We have some complex values here, that will normally be removed later


% Signal to Noise Ratio matrix (SNR)

	SNR = Svcorr - Svnoise;

        clear Svnoise

% Removing the values of Svcorr when SNR is too low

	ind = find(real(SNR)<thresholdSNR);
	Svcorr(ind) = NaN;%NaN; % The complex values stated above are mostly removed here, but some complex values may stay. It depends on the thresholdSNR we choose.

	echogram.pings(j).Sv = Svcorr;

        clear Svcorr

%% Fill the SvNoise matrix of the echogram by adding 13 where background noise has been removed (the SvNoise matrix is created if it is the first call)
	if exist('echogram.pings(j).SvNoise(ind)','var') == 0
            SvNoise = zeros(size(echogram.pings(j).Sv));
            echogram.pings(j).SvNoise = single(SvNoise);
        end
	echogram.pings(j).SvNoise(ind) = echogram.pings(j).SvNoise(ind) + single(13);


end











