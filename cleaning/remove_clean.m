function echogram = remove_clean(echogram,freq,nfreq)
% Update mask of the area to remove

p_start = echogram.clean(freq).p_start;
p_end   = echogram.clean(freq).p_end;
r_start = echogram.clean(freq).r_start;
r_end   = echogram.clean(freq).r_end;

[m,n] = size(echogram.pings(1).Sv);

p_start(find(p_start<0))=1;
p_start(find(p_start>n))=n;
p_end(find(p_end<0))=1;
p_end(find(p_end>n))=n;

r_start(find(r_start<0))=1;
r_start(find(r_start>m))=m;
r_end(find(r_end<0))=1;
r_end(find(r_end>m))=m;


for f = 1:nfreq
    for k = 1:length(p_start)
        echogram.mask(f).SvManual(r_start(k):r_end(k),p_start(k):p_end(k))=NaN;
    end
end



   