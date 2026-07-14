function [echogram] = IN_filter(echogram, INthreshold, INsmooth, INnmax, INminSv)

% This function removes the Impulsive Noise (IN) in the data, which may result from the transmit pulse from an unsynchronized echosounder.

% Input :
%	- echogram : the echogram we want  to filter
%	- INthreshold : the threshold between a difference of data above which the data is removed because considered as an impulsive noise
%       - INsmooth : vertical smoothing window  
%	- INnmax : maximum horizontal size of context window (1,2 or 3)
%       - INminSv : exclusion threshold
% Output :
%	- echogram : the echogram filtered from Impulsive Noise


% CHECK FOR NOISE MASKS
for k=1:length(echogram.pings)
        if exist('echogram.pings(k).SvNoise','var')==0
            echogram.pings(k).SvNoise = single(zeros(size(echogram.pings(k).Sv)));
        end
end


% PROCESSING
for k=1:length(echogram.pings) % Loop upon all the frequencies

        for INn = 1:INnmax

        % SMOOTHED TRANSECT
        nsmooth  = length(find(echogram.pings(k).range<INsmooth));
        Svsmooth = movmean(echogram.pings(k).Sv,nsmooth,1,'omitnan');


	% PULSE LEFT
        Lind = find(Svsmooth(:,INn+1:end-INn) - Svsmooth(:,1:end-2*INn) > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.     
        % PULSE RIGHT
	Rind = find(Svsmooth(:,INn+1:end-INn) - Svsmooth(:,2*INn+1:end) > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.


        % FIND PIXELS TO EXTRACT
	ind1 = intersect(Lind,Rind); % We extract the indexes where the two conditions are filled
        Svsmooth = []; Lind = []; Rind = [];

 
        % TVT
        SvTemp = echogram.pings(k).Sv(:,INn+1:end-INn); % We extract from Sv a submatrix SvTemp whose size is the same as Ldelta and Rdelta
        range = echogram.pings(k).range;
        range(find(range<0))= NaN;
        TVT   = INminSv + 20*log10(repmat(range,[1,size(SvTemp,2)])) + 2 * echogram.calParms(k).absorptioncoefficient * (repmat(range,[1,size(SvTemp,2)])-1);
        ind2  = find(SvTemp>TVT);


	% CORRECT
        SvTemp(intersect(ind1,ind2)) = NaN; % At the indexes contained in ind, we replace in the SvTemp matrix the values of Sv with NaN
        echogram.pings(k).Sv(:,INn+1:end-INn) = SvTemp;
        SvTemp = []; TVT = [];


        % NOISE
	subSvNoise = echogram.pings(k).SvNoise(:,INn+1:end-INn);
	subSvNoise(intersect(ind1,ind2)) = subSvNoise(intersect(ind1,ind2)) + single(1);
	echogram.pings(k).SvNoise(:,INn+1:end-INn) = subSvNoise;
        subSvNoise = []; ind1 = []; ind2 = [];

	end

end
