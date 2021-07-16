function FeatureExtraction()
global num_bad_windows flag data CardiacCycle fs slack

%Extraction of physiological Parameters
N = length(data);
num_bad_windows = 0;
goodSamples = length(data);
badEcgPeaks   = 0;
badPpgPeaks   = 0;
badPpgdPeaks  = 0;
badPpgValleys = 0;
badABPwave    = 0;
rej_ppgProcc  = 0;
rej_dppgProcc = 0;

for CardiacCycle = 1:N
% Get Signals
ecg = data(CardiacCycle).ecg;
ppg = data(CardiacCycle).ppg;
abp = data(CardiacCycle).abp;

%% Systolic time
%% Diastolic time
%% PIR 
%% PPG characteristic value

[ST,DT,PIR,PPG_k,middle_ppg] = PPG_processing(ecg,ppg,abp);
% [ST,DT,PIR,PPG_k,middle_ppg] = PPG_processing_withPlots(ecg,ppg,abp);

% Check window quality
if flag == 1
    % If flag is up, current window sucks and skips rest of iteration
    disp(['Cardiac cycle ' num2str(CardiacCycle)  ' discarded at PPG_processing'])
    goodSamples = goodSamples - 1;
    rej_ppgProcc = rej_ppgProcc + 1;
    flag = 0;
    num_bad_windows = num_bad_windows + 1;
    continue
end

%% dppg Height
%% dppg Width
%% ddppg Height
%% ddppg Width
%% ddppg PeakHeight
%% ddppg FootHeight

[dppgH, dppgW, ddppgH, ddppgW, ddppgPH, ddppgFH] = derivatives_PPG_processing(ecg,ppg,abp,middle_ppg);

% Check window quality
if flag == 1
    % If flag is up, current window sucks and skips rest of iteration
    disp(['Cardiac cycle ' num2str(CardiacCycle)  ' discarded at derivatives_PPG_processing'])
    goodSamples = goodSamples - 1;
    rej_dppgProcc = rej_dppgProcc + 1;
    flag = 0;
    num_bad_windows = num_bad_windows + 1;
    continue
end

%% Heart Rate
%% Augmentation Index
%% LASI
%% IPA
[heartRate, ai, lasi, s1, s2, s3, s4, ipa, causeOfDismissal] = featureExtraction2(CardiacCycle);

if flag == 1
    % If flag is up, current window sucks and skips rest of iteration
    disp(['Cardiac cycle ' num2str(CardiacCycle)  ' discarded at featureExtraction2'])
    flag = 0;
    num_bad_windows = num_bad_windows + 1;
    
    goodSamples = goodSamples - 1;
    switch causeOfDismissal
        case 'ecgPeaks'
            badEcgPeaks   = badEcgPeaks   + 1;
        case 'ppgPeaks'
            badPpgPeaks   = badPpgPeaks   + 1;
        case 'ppgdPeaks'
            badPpgdPeaks  = badPpgdPeaks  + 1;
        case 'ppgValleys'
            badPpgValleys = badPpgValleys + 1;
    end
    
    continue
end


%% PAT / PTT

[pat_p, pat_f, pat_d] = PAT_extract(ecg, ppg);

%% Determine SBP and DBP

[SBP, DBP] = BP_FeatureExtractor(abp);

% Check window quality
if flag == 1
    % If flag is up, current window sucks and skips rest of iteration
    disp(['Cardiac cycle ' num2str(CardiacCycle)  ' discarded at BP_FeatureExtractor'])
    goodSamples = goodSamples - 1;
    badABPwave = badABPwave + 1;
    flag = 0;
    num_bad_windows = num_bad_windows + 1;
    continue
end


%% Allocate Computed Features to global data structure

% 21 Features
data(CardiacCycle).ST        = ST;
data(CardiacCycle).DT        = DT;
data(CardiacCycle).PIR       = PIR;
data(CardiacCycle).PPG_k     = PPG_k;
data(CardiacCycle).dppgH     = dppgH;
data(CardiacCycle).dppgW     = dppgW;
data(CardiacCycle).ddppgH    = ddppgH;
data(CardiacCycle).ddppgW    = ddppgW;
data(CardiacCycle).ddppgPH   = ddppgPH;
data(CardiacCycle).ddppgFH   = ddppgFH;
data(CardiacCycle).heartRate = heartRate;
data(CardiacCycle).AI        = ai;
data(CardiacCycle).LASI      = lasi;
data(CardiacCycle).S1        = s1;
data(CardiacCycle).S2        = s2;
data(CardiacCycle).S3        = s3;
data(CardiacCycle).S4        = s4;
data(CardiacCycle).IPA       = ipa;
data(CardiacCycle).pat_p      = pat_p;
data(CardiacCycle).pat_f      = pat_f;
data(CardiacCycle).pat_d      = pat_d;
% BP Variables
data(CardiacCycle).SBP       = SBP;
data(CardiacCycle).DBP       = DBP;

%% Plots (Uncomment if you want to plot the signals every 400 samples)
% 
% if (mod(CardiacCycle, 400) == 0)
%     % ECG
%     [~, Rlocs] = findpeaks(ecg, 'MinPeakHeight', mean(ecg) + 2.5 * std(ecg), 'MinPeakDistance', ceil(0.4 * fs));
%     subplot(5, 1, 1)
%     plot(ecg, 'k'); hold on; plot(Rlocs(1 : 2), ecg(Rlocs(1 : 2)), 'ok'); hold off
%     ylabel('ECG amplitude')
%     title(['Sample ', num2str(CardiacCycle)])
% 
%     % PPG
%     [systolicPeak, systolicPeakLoc] = findpeaks(middle_ppg, 'MinPeakHeight', mean(middle_ppg) + std(middle_ppg), 'MinPeakDistance', ceil(0.4 * fs));
%     systolicPeakLoc = systolicPeakLoc + ceil(length(ppg) / 3) - 1 + slack;
%     [~, ppgValleyLoc] = findpeaks(-middle_ppg(1 : floor(end / 3)), 'MinPeakHeight', mean(-middle_ppg), 'MinPeakDistance', 2 / 3 * floor(length(middle_ppg) / 3));
%     ppgValleyLoc = ppgValleyLoc + ceil(length(ppg) / 3) - 1 + slack;
%     subplot(5, 1, 2)
%     plot(ppg, 'k'); hold on; plot(systolicPeakLoc, systolicPeak, 'ok'); plot(ppgValleyLoc, ppg(ppgValleyLoc), 'ok'); hold off
%     ylabel('PPG amplitude')
% 
%     % 1st dPPG
%     ppgd = derivative(ppg);
%     mid_ppgd = derivative(middle_ppg);
%     [ppgdPeak, ppgdPeakLoc] = findpeaks(mid_ppgd(1 : floor(end / 2)), 'MinPeakHeight', mean(mid_ppgd) + 2 * std(mid_ppgd), 'MinPeakDistance', 5);
%     ppgdPeakLoc = ppgdPeakLoc + ceil(length(ppg) / 3) - 1 + slack;
%     [ppgdLilPeak, ppgdLilPeakLoc] = findpeaks(mid_ppgd(ceil(end / 2) : floor(4 / 5 * end)));
%     ppgdLilPeakLoc = ppgdLilPeakLoc(ppgdLilPeak == max(ppgdLilPeak)) + floor(length(mid_ppgd) / 2) + ceil(length(ppg) / 3) - 1 + slack;
%     ppgdLilPeak    = max(ppgdLilPeak);
%     subplot(5, 1, 3)
%     plot(ppgd, 'k'); hold on; plot([ppgdPeakLoc, ppgdLilPeakLoc], [ppgdPeak, ppgdLilPeak], 'ok'); hold off
%     ylabel('1st dPPG amplitude')
% 
%     % 2nd dPPG
%     ppgdd = derivative(ppgd);
%     mid_ppgdd = derivative(mid_ppgd);
%     [ddPPG_peaks, ddPPG_peaks_locs] = findpeaks(mid_ppgdd, 'MinPeakHeight', mean(mid_ppgdd) + 1.5*std(mid_ppgdd), 'MinPeakDistance', ceil(0.4 * fs));
%     ddPPG_peaks_locs = ddPPG_peaks_locs + ceil(length(ppg) / 3) - 1 + slack;
%     [ddPPG_Lower, ddPPG_Lower_locs] = findpeaks(-mid_ppgdd, 'MinPeakHeight', mean(-mid_ppgdd) + 0.75*std(mid_ppgdd), 'MinPeakDistance', ceil(0.4 * fs));
%     ddPPG_Lower_locs = ddPPG_Lower_locs + ceil(length(ppg) / 3) - 1 + slack;
%     ddPPG_Lower = -ddPPG_Lower;
%     subplot(5, 1, 4)
%     plot(ppgdd, 'k'); hold on; plot([ddPPG_peaks_locs(1), ddPPG_Lower_locs(1)], [ppgdd(ddPPG_peaks_locs(1)), ppgdd(ddPPG_Lower_locs(1))], 'ok'); hold off
%     ylabel('2nd dPPG amplitude')
%     
%     % ABP
%     n = length(abp);
%     full_abp = abp;
%     abp = abp(floor(n/8):(n-ceil(n/8)));
%     [SBPs, SBPs_locs] = findpeaks(abp, 'MinPeakHeight', mean(abp) + std(abp), 'MinPeakDistance', ceil(0.5 * fs));
%     SBPs_locs = SBPs_locs + floor(n/8) - 1;
%     [DBPs, DBPs_locs] = findpeaks(-abp, 'MinPeakHeight', mean(-abp) + 0.75*std(abp), 'MinPeakDistance', ceil(0.4 * fs));
%     DBPs_locs = DBPs_locs + floor(n/8) - 1;
%     DBPs = -DBPs;
%     SBP = SBPs(1);
%     DBP = DBPs(2);
%     subplot(5, 1, 5)
%     plot(full_abp, 'k'); hold on; plot([SBPs_locs(1), DBPs_locs(2)], [SBP, DBP], 'ok'); hold off
%     ylabel('ABP amplitude')
%     
% 
%     pause(2)
% end

end

% Data still has bad samples (no features)
FeatureData_aux = data;

%% Removing samples without features
disp('...')
disp('Features have been Extracted')
disp('...')
disp('Creating Final Data Structure with Extracted Features')
disp('...')

badSamp = 0;
for sample = 1:N
    if isempty(data(sample).ST) % any feature
        FeatureData_aux(sample-badSamp) = [];
        badSamp = badSamp + 1;
    end
end

data = FeatureData_aux;

disp('DONE')
disp('...')
% Sample Balance
disp('Sample Balance:')
disp(['Number of GOOD samples: '    ,                       num2str(goodSamples)  ])
disp(['Number of BAD samples: '    ,                        num2str(num_bad_windows) ])
disp(['Number of bad PPG peaks at ppg_processing: ' ,       num2str(rej_ppgProcc)])
disp(['Number of bad d and ddPPG peaks at deriv_ppg_processing: ' , num2str(rej_dppgProcc)])
disp(['Number of bad ECG peaks: '   ,                       num2str(badEcgPeaks)  ])
disp(['Number of bad PPG peaks: '   ,                       num2str(badPpgPeaks)  ])
disp(['Number of bad dPPG peaks: '  ,                       num2str(badPpgdPeaks) ])
disp(['Number of bad PPG valleys: ' ,                       num2str(badPpgValleys)])
disp(['Number of bad ABP waves: ' ,                         num2str(badABPwave)])

end