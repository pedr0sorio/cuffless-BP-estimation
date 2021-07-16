function [heartRate, ai, lasi, s1, s2, s3, s4, ipa, causeOfDismissal] = featureExtraction2(k)
% Initialization
global fs data flag

causeOfDismissal = '';

% Feature extraction
ecg   = data(k).ecg;
ppg   = data(k).mid_ppg;
ppgd  = derivative(ppg);
ppgdd = derivative(ppgd);

% Heart rate
[~, Rlocs] = findpeaks(ecg, 'MinPeakHeight', mean(ecg) + 2.5 * std(ecg), 'MinPeakDistance', ceil(0.4 * fs));

if (length(Rlocs) < 2)
    flag = 1;
    causeOfDismissal = 'ecgPeaks';
    heartRate = 0;
    ai        = 0;
    lasi      = 0;
    s1        = 0;
    s2        = 0;
    s3        = 0;
    s4        = 0;
    ipa       = 0;
    
%     % Plots
%     subplot(4, 1, 1)
%     plot(ecg); hold on; plot(Rlocs, ecg(Rlocs), '*k'); hold off
%     ylabel('ECG')
%     title(['Sample ', num2str(k), ', reason: ', causeOfDismissal])
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 2)
%     plot(ppg);
%     ylabel('PPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 3)
%     plot(ppgd);
%     ylabel('dPPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 4)
%     plot(ppgdd);
%     ylabel('ddPPG')
%     set(gca, 'Color', 'r')
%     
%     pause(2)
    
    return
end

heartRate = fs / (Rlocs(2) - Rlocs(1)); % number of heartbeats per second

% Augmentation index (AI)
[systolicPeak, systolicPeakLoc] = findpeaks(ppg, 'MinPeakHeight', mean(ppg) + std(ppg), 'MinPeakDistance', ceil(0.4 * fs));

if (length(systolicPeak) ~= 1)
    flag = 1;
    causeOfDismissal = 'ppgPeaks';
    heartRate = 0;
    ai        = 0;
    lasi      = 0;
    s1        = 0;
    s2        = 0;
    s3        = 0;
    s4        = 0;
    ipa       = 0;
     
%     % Plots
%     subplot(4, 1, 1)
%     plot(ecg); hold on; plot(Rlocs, ecg(Rlocs), '*w'); hold off
%     ylabel('ECG')
%     title(['Sample ', num2str(k), ', reason: ', causeOfDismissal])
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 2)
%     plot(ppg); hold on; plot(systolicPeakLoc, ppg(systolicPeakLoc), '*w'); hold off
%     ylabel('PPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 3)
%     plot(ppgd); hold on;
%     ylabel('dPPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 4)
%     plot(ppgdd);
%     ylabel('ddPPG')
%     set(gca, 'Color', 'r')
%     
%     pause(2)

    return
end

[ppgdPeak   , ppgdPeakLoc   ] = findpeaks(ppgd(1             : floor(end / 2)    ), 'MinPeakHeight', mean(ppgd) + 2 * std(ppgd), 'MinPeakDistance', 5);
[ppgdLilPeak, ppgdLilPeakLoc] = findpeaks(ppgd(ceil(end / 2) : floor(4 / 5 * end)));

if (length(ppgdPeak) == 2)
    ppgdPeak    = (ppgdPeak(1) + ppgdPeak(2)) / 2;
    ppgdPeakLoc = round((ppgdPeakLoc(1) + ppgdPeakLoc(2)) / 2);
end

ppgdLilPeakLoc = ppgdLilPeakLoc(ppgdLilPeak == max(ppgdLilPeak)) + floor(length(ppgd) / 2);
ppgdLilPeak    = max(ppgdLilPeak);

if ((length(ppgdPeak) ~= 1) || (length(ppgdLilPeak) ~= 1))
    flag = 1;
    causeOfDismissal = 'ppgdPeaks';
    heartRate = 0;
    ai        = 0;
    lasi      = 0;
    s1        = 0;
    s2        = 0;
    s3        = 0;
    s4        = 0;
    ipa       = 0;
    
%     % Plots
%     subplot(4, 1, 1)
%     plot(ecg); hold on; plot(Rlocs, ecg(Rlocs), '*w'); hold off
%     ylabel('ECG')
%     title(['Sample ', num2str(k), ', reason: ', causeOfDismissal])
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 2)
%     plot(ppg); hold on; plot([systolicPeakLoc, ppgdPeakLoc', ppgdLilPeakLoc'], [systolicPeak, ppg(ppgdPeakLoc)', ppg(ppgdLilPeakLoc)'], '*w'); hold off
%     ylabel('PPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 3)
%     plot(ppgd); hold on; plot([ppgdPeakLoc', ppgdLilPeakLoc'], [ppgdPeak', ppgdLilPeak'], '*w'); hold off
%     ylabel('dPPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 4)
%     plot(ppgdd); hold on; plot([ppgdPeakLoc', ppgdLilPeakLoc'], [ppgdd(ppgdPeakLoc)', ppgdd(ppgdLilPeakLoc)'], '*w'); hold off
%     ylabel('ddPPG')
%     set(gca, 'Color', 'r')
% 
%     pause(2)
    
    return
end

inflectionPoint    = ppg(ppgdLilPeakLoc);
inflectionPointLoc = ppgdLilPeakLoc;

ai = systolicPeak / inflectionPoint;

% Large artery stiffness index (LASI)
lasi = fs / (inflectionPointLoc - systolicPeakLoc);

% Inflection point area ratio (IPA)
[~, ppgValleyLoc] = findpeaks(-ppg(1 : floor(end / 3)), 'MinPeakHeight', mean(-ppg), 'MinPeakDistance', 2 / 3 * floor(length(ppg) / 3));

if (length(ppgValleyLoc) ~= 1)
    flag = 1;
    causeOfDismissal = 'ppgValleys';
    heartRate = 0;
    ai        = 0;
    lasi      = 0;
    s1        = 0;
    s2        = 0;
    s3        = 0;
    s4        = 0;
    ipa       = 0;
    
%     % Plots
%     subplot(4, 1, 1)
%     plot(ecg); hold on; plot(Rlocs, ecg(Rlocs), '*w'); hold off
%     ylabel('ECG')
%     title(['Sample ', num2str(k), ', reason: ', causeOfDismissal])
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 2)
%     plot(ppg); hold on; plot([systolicPeakLoc, ppgdPeakLoc, ppgdLilPeakLoc, ppgValleyLoc'], [systolicPeak, ppg(ppgdPeakLoc), ppg(ppgdLilPeakLoc), ppg(ppgValleyLoc)'], '*w'); hold off
%     ylabel('PPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 3)
%     plot(ppgd); hold on; plot([ppgdPeakLoc, ppgdLilPeakLoc], [ppgdPeak, ppgdLilPeak], '*w'); hold off
%     ylabel('dPPG')
%     set(gca, 'Color', 'r')
% 
%     subplot(4, 1, 4)
%     plot(ppgdd); hold on; plot([ppgdPeakLoc, ppgdLilPeakLoc], [ppgdd(ppgdPeakLoc), ppgdd(ppgdLilPeakLoc)], '*w'); hold off
%     ylabel('ddPPG')
%     set(gca, 'Color', 'r')
% 
%     pause(2)
    
    return
end

startLoc    = ppgValleyLoc;
maxSlopeLoc = ppgdPeakLoc;

s1 = trapz(ppg(startLoc           : maxSlopeLoc       ) - min(ppg(startLoc : end))) / fs;
s2 = trapz(ppg(maxSlopeLoc        : systolicPeakLoc   ) - min(ppg(startLoc : end))) / fs;
s3 = trapz(ppg(systolicPeakLoc    : inflectionPointLoc) - min(ppg(startLoc : end))) / fs;
s4 = trapz(ppg(inflectionPointLoc : end               ) - min(ppg(startLoc : end))) / fs;
ipa = s4 / (s1 + s2 + s3);

% % Plots
% subplot(4, 1, 1)
% plot(ecg); hold on; plot(Rlocs, ecg(Rlocs), '*k'); hold off
% ylabel('ECG')
% title(['Sample ', num2str(k)])
% set(gca, 'Color', 'g')
% 
% subplot(4, 1, 2)
% plot(ppg); hold on; plot(systolicPeakLoc, ppg(systolicPeakLoc), '*k'); plot(ppgValleyLoc, ppg(ppgValleyLoc), '*k'); hold off
% ylabel('PPG')
% set(gca, 'Color', 'g')
% 
% subplot(4, 1, 3)
% plot(ppgd); hold on; plot([ppgdPeakLoc, ppgdLilPeakLoc], [ppgdPeak, ppgdLilPeak], '*k'); hold off
% ylabel('dPPG')
% set(gca, 'Color', 'g')
% 
% subplot(4, 1, 4)
% plot(ppgdd); hold on; plot([ppgdPeakLoc, ppgdLilPeakLoc], [ppgdd(ppgdPeakLoc), ppgdd(ppgdLilPeakLoc)], '*k'); hold off
% ylabel('ddPPG')
% set(gca, 'Color', 'g')
% 
% pause(0.05)
end