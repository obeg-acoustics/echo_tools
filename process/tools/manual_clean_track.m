function echogram = manual_clean_track(echogram,freq,nfreq)

for k=1:nfreq
    tmp = echogram.pings(freq).Sv.*echogram.mask(k).SvFalseBot.*echogram.mask(k).SvBot.*echogram.mask(k).SvManual;
end

figure, imagesc(tmp)
caxis([-100,-50])
finished = input('ZOOM/FINISH(=1) ?')
if isempty(finished)
    finished = 0;
end
if (finished ~=1)
    finished = 0;
end
p_start = [];
p_end = [];
r_start = [];
r_end = [];
while finished == 0
    display('SELECT SECTION TO REMOVE')
    [ping,range] = ginput(2);
    keep = input(['REMOVE SECTION ', num2str(ping(1)), ' TO ', num2str(ping(2)), ' (1/0): ']);
    if ~isempty(finished)
        if keep == 1
            p_start = [p_start,ping(1)];
            p_end = [p_end,ping(2)];
            r_start = [r_start,range(1)];
            r_end = [r_end,range(2)];
        end
    end
    finished = input('ZOOM/FINISH(=1)? ');
    if isempty(finished)
        finished = 0;
    end
    if (finished ~=1)
        finished = 0;
    end
end
echogram.clean(freq).p_start = p_start;
echogram.clean(freq).p_end = p_end;
echogram.clean(freq).r_start = r_start;
echogram.clean(freq).r_end = r_end;