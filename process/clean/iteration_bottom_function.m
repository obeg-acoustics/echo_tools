function [Svmatrix_candidatepeaks, rangematrix_candidatepeaks] = iteration_bottom_function(Svmatrix_candidatepeaks, rangematrix_candidatepeaks, window_radius, bottom_threshold, current_ping, window_beginning, window_ending,j,k)




if nanmax(current_ping(window_beginning:window_ending)) >= bottom_threshold
	Svmatrix_candidatepeaks(k,j) = nanmax(current_ping(window_beginning:window_ending));
%     rangematrix_candidatepeaks(k,j) =find(current_ping == Svmatrix_candidatepeaks(k,j));
	candidaterange = find(current_ping == Svmatrix_candidatepeaks(k,j));
        tmp            = candidaterange(find((candidaterange>=window_beginning).*(candidaterange<=window_ending))); 
	rangematrix_candidatepeaks(k,j) = tmp(1);%candidaterange(find((candidaterange>=window_beginning).*(candidaterange<=window_ending))); %% Warning : be careful here. In the same window, two Sv values can be equal, leading to a bug in the code.
else
	Svmatrix_candidatepeaks(k,j) = current_ping(rangematrix_candidatepeaks(k,j-1));
	rangematrix_candidatepeaks(k,j) = rangematrix_candidatepeaks(k,j-1);
end
