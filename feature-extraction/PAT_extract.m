
function [pat_p, pat_f, pat_d] = PAT_extract(ecg, ppg)
%Extracts PAT features, which are equal to the time interval between ECG
%R-peak and PPG maximum poeak (pat_p), PPG minimum (pat_f) and maximum
%slope of PPG (pat_d)

global fs flag data CardiacCycle

% Find R peak of the leftmost wave

[~, r_peaks_locs] = findpeaks(ecg, 'MinPeakHeight', mean(ecg) + std(ecg), 'MinPeakDistance', ceil(0.4 * fs));
r_peak_loc = r_peaks_locs(1);


% Compute PATp
n = length(ppg);
ppg_3 = ppg(ceil(n/3):n);
time_offset = floor(n/3);

[SystolicPeaks, systolic_peak_locs] = findpeaks(ppg_3, 'MinPeakHeight', mean(ppg_3) + std(ppg_3), 'MinPeakDistance', ceil(0.5 * fs));
[Foot, Foot_locs] = findpeaks(-ppg_3, 'MinPeakHeight', mean(-ppg_3) + 0.75*std(ppg_3), 'MinPeakDistance', ceil(0.4 * fs));
Foot = -Foot;

% correct with offset
systolic_peak_locs = systolic_peak_locs + time_offset;
Foot_locs = Foot_locs + time_offset;

systolic_peak_local = systolic_peak_locs(1);

pat_p = systolic_peak_local - r_peak_loc;

%figure
%plot(ppg)
% hold on
% plot(ppg_mins_locs, ppg(ppg_mins_locs), '*r')
% hold off

% Compute PATf
pat_f = Foot_locs(1) - r_peak_loc;


% Compute PATd

dif_ppg = diff(ppg_3);
[~, dif_ppg_peaks_locs] = findpeaks(dif_ppg, 'MinPeakHeight', mean(dif_ppg) + std(dif_ppg), 'MinPeakDistance', ceil(0.4 * fs));

dif_ppg_peak_loc = dif_ppg_peaks_locs(1) + time_offset;
pat_d = dif_ppg_peak_loc - r_peak_loc;


end