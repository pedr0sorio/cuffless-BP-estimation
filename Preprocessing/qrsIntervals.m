function qrsIntervals(predata)
global data fs subject
% For each segment, crop into several windows containing one QRS complex
for s = 1 : size(predata.ecg, 2) % 'predata.ppg' and 'predata.abp' have the same length
    % Make R peaks more noticeable/detectable
    wt_ecg     = modwt(predata.ecg(:, s), 4, 'sym4');
    wt_ecg_rec = zeros(size(wt_ecg));
    
    % Select relevant coefficients
    wt_ecg_rec(2 : 3, :) = wt_ecg(2 : 3, :);
    
    % Reconstruct the signal
    ecg_rec = imodwt(wt_ecg_rec, 'sym4');
    
    % Make peak detection and determine mean interval between R peaks for heart rate estimation
    [Rpeaks, Rlocs] = findpeaks(ecg_rec, 'MinPeakHeight', 3 * std(ecg_rec), 'MinPeakDistance', ceil(0.4 * fs));
    % Vector of length of time intervals between R peaks
    RR = Rlocs(2 : end) - Rlocs(1 : end - 1);
    
    % ----- Middle QRS complexes
    for i = 2 : length(Rpeaks) - 2
        d1 = floor(RR(i - 1) / 2);
        d2 = floor(RR(i) + RR(i + 1) + 2);
        if (d2 + Rlocs(i) > 2500)
            continue
        else
            data(end + 1).ecg = predata.ecg(Rlocs(i) - d1 : Rlocs(i) + d2, s);
            data(end).ppg     = predata.ppg(Rlocs(i) - d1 : Rlocs(i) + d2, s);
            data(end).abp     = predata.abp(Rlocs(i) - d1 : Rlocs(i) + d2, s);
            data(end).subject = subject;
        end
        
    end
end
end