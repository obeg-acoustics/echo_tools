function [echogram] = RN_filter(echogram, RNthreshold, RNminSv)

% This function removes the Residual Noise (IN) in the data.

% Input :
%	- echogram : the echogram we want  to filter
%	- RNthreshold : the threshold between a difference of data above which the data is removed because considered as an impulsive noise
%       - RNminSv : exclusion threshold
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

        % TVT
        SvTemp = echogram.pings(k).Sv(:,:);
        range = echogram.pings(k).range;
        range(find(range<0)) = NaN;
        TVT   = RNminSv + 20*log10(repmat(range,[1,size(SvTemp,2)])) + 2 * echogram.calParms(k).absorptioncoefficient * (repmat(range,[1,size(SvTemp,2)])-1);
        ind1  = find(SvTemp<TVT);
        TVT = [];

        % THREESHOLD
        ind2  = find(SvTemp>RNthreshold);

	
	% CORRECT
	SvTemp(ind1) = -999;
	SvTemp(ind2) = -999;

	% MEDIAN FILTER
	%SvTemp = medfilt2(SvTemp,[7 7]);
        %SvTemp = colfilt(SvTemp,[7 7],'sliding',fcn_med);
        SvTemp = movmedian(movmedian(SvTemp,7,2,'omitnan'),7,1,'omitnan');

	% CORRECT
	ind1 = find( (SvTemp<-998) );
	ind2 = find( (SvTemp>-20) );
        echogram.pings(k).Sv(ind1) = -999;
        echogram.pings(k).Sv(ind2) = -999;
        SvTemp = [];
	
        % NOISE
	echogram.pings(k).SvNoise([intersect(ind1,ind2),setdiff(ind1,ind2)]) = echogram.pings(k).SvNoise([intersect(ind1,ind2),setdiff(ind1,ind2)]) + single(17);

        ind1 = []; ind2 = [];

end
