function [echogram] = MFI(echogram, delta)

% Script made to create the MFI (multi-frequency indicator) indicator from the echogram, following Trenkel & Berger's paper

%keyboard

% In the paper, they apply a filter to the data, removing all the sv values that are below a threshold (log10(-85/10)) in order to "minimize the effect of background noise". As we applied the backgrtound noise filter to our data, following De Robertis'paper, we consider that we don't need to implement this step.


% After that, in the paper, they remove the data (or don't use it) when the wind speed is above a certain threshold (20 knots) because the quality of the data is degraded above it. But as we don't have informations about the wind speed, we cannot do that.


%% Calculation of the MFI

% We first calculate sv for each frequency

for i=1:length(echogram.pings)
	sv = zeros(size(echogram.pings(i).Sv));
	sv = 10.^(echogram.pings(i).Sv/10);
	echogram.pings(i).sv = sv;
end


% Make sure that all the matrices have the same size

depth_length = length(echogram.pings(1).range);
for i=2:length(echogram.pings)
	if length(echogram.pings(i).range) < depth_length
		depth_length = length(echogram.pings(i).range);
	end
end


time_length = length(echogram.pings(1).time);
for i=2:length(echogram.pings)
	if length(echogram.pings(i).time) < time_length
		time_length = length(echogram.pings(i).time);
	end
end

for i=1:length(echogram.pings)
	echogram.pings(i).sv = echogram.pings(i).sv(1:depth_length, 1:time_length);
end


% Compute MFI

MFImatrix = zeros(size(echogram.pings(1).sv));
numerator = zeros(size(echogram.pings(1).sv));
denominator = zeros(size(echogram.pings(1).sv));

dij = zeros(length(echogram.pings));
eij = zeros(length(echogram.pings));

for i=2:length(echogram.pings) % First sum of the numerator
	for j=1:i-1 % Second sum of the numerator
		dij(i,j) = 1 - exp(-abs(echogram.calParms(i).frequency/1000 - echogram.calParms(j).frequency/1000)/delta);
		eij(i,j) = 1/(echogram.calParms(i).frequency/1000)*1/(echogram.calParms(j).frequency/1000);
	end
end


for k=1:time_length
	for l=1:depth_length
		distrib = [];
		for i = 1:length(echogram.pings)
			distrib = [distrib, echogram.pings(i).sv(l,k)];
		end
		distrib = distrib/nanmax(distrib);	% Normalisation of sv distributions
		distrib(find(isnan(distrib))) = 0;
% These sum loops will have to be done for each pixel of the echogram

		for i=2:length(echogram.pings) % First sum of the numerator
			for j=1:i-1 % Second sum of the numerator
				numerator(l,k) = numerator(l,k) + dij(i,j)*distrib(i)*distrib(j)*eij(i,j);
				denominator(l,k) = denominator(l,k) + distrib(i)*distrib(j)*eij(i,j);
			end
		end
	end
end

MFImatrix = (numerator./denominator - 0.4)/0.6;

echogram.analysis.MFI = MFImatrix;

%ind1 = find(MFImatrix > 0.8);
%ind2 = find((MFImatrix > 0.7) & (MFImatrix <= 0.8));
%ind3 = find((MFImatrix > 0.4) & (MFImatrix <= 0.6));
%ind4 = find(MFImatrix <= 0.4);
%
%MFIind = zeros(size(MFImatrix));
%MFIind(ind1) = 1;
%MFIind(ind2) = 2;
%MFIind(ind3) = 3;
%MFIind(ind4) = 4;
















