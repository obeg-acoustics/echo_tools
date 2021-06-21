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


% CHECK FOR NOISE MASKS
for k=1:length(echogram.pings)
        if exist('echogram.pings(k).SvNoise','var')==0
            echogram.pings(k).SvNoise = single(zeros(size(echogram.pings(k).Sv)));
        end
end


% PROCESSING
for k=1:length(echogram.pings)

	% POWER
	range = echogram.pings(k).range;
        range(find(range<0)) = NaN;
	powermap = echogram.pings(k).Sv - 20*log10(repmat(range,[1,size(echogram.pings(k).Sv,2)])) - 2*echogram.calParms(k).absorptioncoefficient * repmat(range,[1,size(echogram.pings(k).Sv,2)]);
  

        % CONTEXT AVERAGE
        % We create a vector that is a "block average" with BGnxBGm-sized-blocks.
        powerblock = powermap*0+1;
	powermap   = movsum(10.^(powermap/10),BGm,1,'omitnan');
        powermap   = movsum(powermap,BGn,2,'omitnan');
        powerblock = movsum(powerblock,BGm,1,'omitnan');
        powerblock = movsum(powerblock,BGn,2,'omitnan');
        powermap   = 10*log10(powermap./powerblock);
        indrm      = find(powerblock <= BGm);
        powerblock = powermap;
        powerblock(indrm) = NaN;
        powermap = [];
%        powerblock = zeros(size(power,1),size(power,2));
%        Ni = size(power,1);
%        Nj = size(power,2);
%        for i = 1:Ni
%            powerblock_par = zeros(1,Nj);
%            for j = 1:Nj
%                if i<=BGm/2
%                    if j<=BGn/2
%                        powerblock_par(j) = nanmean(power(1:BGm,1:BGn),'all');
%                    elseif j>=size(powerblock,2)-BGn/2
%                        powerblock_par(j) = nanmean(power(1:BGm,Nj-BGn:Nj),'all');
%                    else
%                        powerblock_par(j) = nanmean(power(1:BGm,j-BGn/2:j+BGn/2),'all');
%                    end
%                elseif i>=Ni-BGm/2
%                    if j<=BGn/2
%                        powerblock_par(j) = nanmean(power(Ni-BGm:Ni,1:BGn),'all');
%                    elseif j>=Nj-BGn/2
%                        powerblock_par(j) = nanmean(power(Ni-BGm:Ni,Nj-BGn:Nj),'all');
%                    else
%                        powerblock_par(j) = nanmean(power(Ni-BGm:Ni,j-BGn/2:j+BGn/2),'all');
%                    end
%                else
%                    if j<=BGn/2
%                        powerblock_par(j) = nanmean(power(i-BGm/2:i+BGm/2,1:BGn),'all');
%                    elseif j>=Nj-BGn/2
%                        powerblock_par(j) = nanmean(power(i-BGm/2:i+BGm/2,Nj-BGn:Nj),'all');
%                    else
%                        powerblock_par(j) = nanmean(power(i-BGm/2:i+BGm/2,j-BGn/2:j+BGn/2),'all');
%                    end
%                end
%            end
%            powerblock(i,:) = powerblock_par;
%        end


	% NOISE
        noise = nanmin((powerblock(:,:)),[],1);
	noise(find(noise>noisemax)) = noisemax;
        powerblock = [];
	
	% SV NOISE
	SvNoise = repmat(noise,[size(echogram.pings(k).Sv,1),1]) + 20*log10(repmat(range,[1,size(echogram.pings(k).Sv,2)])) + 2*echogram.calParms(k).absorptioncoefficient * repmat(range,[1,size(echogram.pings(k).Sv,2)]);
        noise = [];

	% SV CORRECTED
        SvCorrect = SvNoise * NaN ;
        ind       = find(10.^(echogram.pings(k).Sv/10)-10.^(SvNoise/10)>0);
	SvCorrect(ind) = 10*log10(10.^(echogram.pings(k).Sv(ind)/10)-10.^(SvNoise(ind)/10));


	% FIND PINGS TO CORRECT
	ind1 = find(SvCorrect - SvNoise < thresholdSNR);
        SvNoise = [];

	% CORRECT
	SvCorrect(ind1) = -999;
	echogram.pings(k).Sv = SvCorrect;


	% NOISE
	echogram.pings(k).SvNoise(ind1) = echogram.pings(k).SvNoise(ind1) + single(13);

	SvCorrect = []; ind1 = [];

end











