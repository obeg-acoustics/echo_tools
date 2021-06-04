function [echogram] = IN_filter(echogram, INthreshold, INsmooth, INn, INminSv)

% This function removes the Impulsive Noise (IN) in the data, which may result from the transmit pulse from an unsynchronized echosounder.

% Input :
%	- echogram : the echogram we want  to filter
%	- INthreshold : the threshold between a difference of data above which the data is removed because considered as an impulsive noise
%       - INsmooth : vertical smoothing window  
%	- INn : horizontal size of context window
%       - INminSv : exclusion threshold
% Output :
%	- echogram : the echogram filtered from Impulsive Noise


for i=1:length(echogram.pings) % Loop upon all the frequencies

        % SMOOTHED TRANSECT
        Svsmooth = movmean(echogram.pings(i).Sv,INsmooth,1,'omitnan');

	% PULSE LEFT
        Lind = find(Svsmooth(:,INn+1:end-INn) - Svsmooth(:,1:end-2*INn) > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.     
        % PULSE RIGHT
	Rind = find(Svsmooth(:,INn+1:end-INn) - Svsmooth(:,2*INn+1:end) > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.

	ind1 = intersect(Lind,Rind); % We extract the indexes where the two conditions are filled
        clear Lind, clear Rind
 
        % TVT
        SvTemp = echogram.pings(i).Sv(:,INn+1:end-INn); % We extract from Sv a submatrix SvTemp whose size is the same as Ldelta and Rdelta
        range = echogram.pings(i).range;
        TVT   = INminSv + 20*log10(repmat(range,[1,size(SvTemp,2)])) + 2 * echogram.calParms(i).absorptioncoefficient * (repmat(range,[1,size(SvTemp,2)])-1);
        ind2  = find(SvTemp>TVT);

	% CORRECT
        SvTemp(intersect(ind1,ind2)) = NaN; % At the indexes contained in ind, we replace in the SvTemp matrix the values of Sv with NaN
        echogram.pings(i).Sv(:,INn+1:end-INn) = SvTemp;
        clear SvTemp

        % NOISE
        if exist('echogram.pings(i).SvNoise','var')==0
            echogram.pings(i).SvNoise = single(zeros(size(echogram.pings(i).Sv)));
        end
	subSvNoise = echogram.pings(i).SvNoise(:,INn+1:end-INn);
	subSvNoise(intersect(ind1,ind2)) = subSvNoise(intersect(ind1,ind2)) + single(1);
	echogram.pings(i).SvNoise(:,INn+1:end-INn) = subSvNoise;

        clear subSvNoise,clear ind1, clear ind2
end
