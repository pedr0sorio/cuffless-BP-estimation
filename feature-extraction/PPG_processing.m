function [ST,DT,PIR,PPG_k,middle_ppg] = PPG_processing(ecg,ppg,abp)
global fs flag CardiacCycle slack
% Relevant ppg is only the last two thirds of the window
ppg_full = ppg;
ppg = ppg( (ceil(end/3):end) );

[SystolicPeaks, SP_locs] = findpeaks(ppg, 'MinPeakHeight', mean(ppg) + std(ppg), 'MinPeakDistance', ceil(0.5 * fs));
[Foot, Foot_locs] = findpeaks(-ppg, 'MinPeakHeight', mean(-ppg) + 0.75*std(ppg), 'MinPeakDistance', ceil(0.4 * fs));
Foot = -Foot;

% Check for bad windows of signal
if (length(Foot_locs)~=2 || Foot_locs(1) > SP_locs(1) || Foot_locs(2) < SP_locs(1) || SP_locs(1) > (2 * length(ppg) / 3))
    
%     figure(1)
%     plot(ppg)
%     hold on
%     plot(Foot_locs, Foot, '*r')
%     plot(SP_locs, SystolicPeaks, '*r')
%     plot(ones(1,length(ppg)) * (mean(ppg) - 0.75*std(ppg)))
%     hold off
%     
%     figure(2)
%     plot(ppg_full)
%     
%     
%     figure(3); plot(ecg); figure(4); plot(abp)
    
    flag = 1;
    PPG_k=0;PIR=0;ST=0;DT=0;middle_ppg=ppg;
else
    %% Systolic time
    ST = (SP_locs(1) - Foot_locs(1)) / fs;
    %% Diastolic time
    DT = (Foot_locs(2) - SP_locs(1)) / fs;
    %% PIR
    PIR = SystolicPeaks(1) /  Foot(1);
    %% PPG characteristic value
    T = (Foot_locs(2) - Foot_locs(1)) / fs;
    periodPPG = ppg(Foot_locs(1):Foot_locs(2));
    periodPPG = periodPPG - min(periodPPG);
    
    step = 1/fs;
    pm = (trapz(periodPPG) * step) / T;
    pd = Foot(1);
    ps = SystolicPeaks(1);
    
    PPG_k = (pm - pd) / (ps - pd);
    
    %% Extract Middle PPG wave
    folga1 = 10; folga2 = 0;
    if (Foot_locs(1)-folga1) > 0
        middle_ppg = ppg((Foot_locs(1)-folga1):(Foot_locs(2)+folga2));
        slack = Foot_locs(1) - folga1 - 1;
    else
        middle_ppg = ppg(1:(Foot_locs(2)+folga2));
        slack = 0;
    end
%     
%         figure()
%         plot(ppg)
%         hold on
%         plot(SP_locs, SystolicPeaks, '*r')
%         hold off
%     
%         figure()
%         plot(ppg)
%         plot(diff(middle_ppg)/step)
%     
%     
%         figure()
%         plot(ppg)
%         figure(); plot(data(7714).ecg)
%         plot(ppg)
%         hold on
%         plot(Foot_locs, Foot, '*r')
%         plot(ones(1,length(ppg)) * (mean(ppg) - 0.75*std(ppg)))
%         hold off
%     
end
end