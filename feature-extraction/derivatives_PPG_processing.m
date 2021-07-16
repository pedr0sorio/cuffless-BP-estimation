function [dppgH, dppgW, ddppgH, ddppgW, ddppgPH, ddppgFH] = derivatives_PPG_processing(ecg,full_ppg,abp,middle_ppg)

global fs flag data CardiacCycle

% relevant ppg in this section is the middle of the window
ppg = middle_ppg;
data(CardiacCycle).mid_ppg = ppg;
%% 1st derivative
% Adding full 1stDerivative o ppg to global var
step = 1/fs;
ppgd_full = diff(full_ppg)/step;
data(CardiacCycle).ppgd = ppgd_full;
% Middle PPG
ppgd = diff(ppg)/step;

[dPPG_peaks, dPPG_peaks_locs] = findpeaks(ppgd, 'MinPeakHeight', mean(ppgd) + std(ppgd), 'MinPeakDistance', ceil(0.4 * fs));
[dPPG_Foot, dPPG_Foot_locs] = findpeaks(-ppgd, 'MinPeakHeight', mean(-ppgd) + 0.5 * std(ppgd), 'MinPeakDistance', ceil(0.4 * fs));
dPPG_Foot = -dPPG_Foot;

% Check for bad dPPG wave - at least one peak (postive and negative) must be
% detectable - must not detect mor ethan two peaks of each kind
% simultaneously
if (length(dPPG_Foot_locs)>2 || isempty(dPPG_Foot_locs) || length(dPPG_peaks_locs)>2 || isempty(dPPG_peaks_locs))
     
%     figure(1)
%     plot(ppgd)
%     hold on
%     plot(dPPG_peaks_locs, dPPG_peaks, '*r')
%     plot(ones(1,length(ppgd))*(mean(ppgd) +  std(ppgd)))
%     plot(dPPG_Foot_locs, dPPG_Foot, '*r')
%     plot(ones(1,length(ppgd))*(mean(-ppgd) - 0.5 * std(ppgd)))
%     hold off
    
    flag = 1;
    dppgH = 0; dppgW = 0; ddppgH = 0; ddppgW = 0; ddppgPH = 0; ddppgFH = 0;
else
    
    dppgH = dPPG_peaks(1);
    dppgW = (dPPG_Foot_locs(1) - dPPG_peaks_locs(1)) / fs;
    
    %     figure()
    %     plot(ppgd)
    %     hold on
    %     plot(dPPG_peaks_locs, dPPG_peaks, '*r')
    %     plot(ones(1,length(ppgd))*(mean(ppgd) +  std(ppgd)))
    %     hold off
    %
    %     figure()
    %     plot(ppgd)
    %     hold on
    %     plot(dPPG_Foot_locs, dPPG_Foot, '*r')
    %     plot(ones(1,length(ppgd))*(mean(-ppgd) - 0.5 * std(ppgd)))
    %     hold off
    %
    %
    %     figure()
    %     middle_dppg = dppg((Foot_locs(2)-5):Foot_locs(3));
    %     middle_ppg = ppg((Foot_locs(2)):Foot_locs(3));
    %     plot(middle_dppg*0.7/max(middle_dppg))
    %     hold on
    %     plot(middle_ppg)
    %     plot(ones(1,length(middle_dppg))*mean(dppg))
    
    %% 2nd derivative
    % Adding full 2ndDerivative o ppg to global var
    ppgdd_full = diff(ppgd_full)/step;
    data(CardiacCycle).ppgdd = ppgdd_full;
    % Middle PPG
    ppgdd = diff(ppg)/step;
    
    [ddPPG_peaks, ddPPG_peaks_locs] = findpeaks(ppgdd, 'MinPeakHeight', mean(ppgdd) + 1.5*std(ppgdd), 'MinPeakDistance', ceil(0.4 * fs));
    [ddPPG_Lower, ddPPG_Lower_locs] = findpeaks(-ppgdd, 'MinPeakHeight', mean(-ppgdd) + 0.75*std(ppgdd), 'MinPeakDistance', ceil(0.4 * fs));
    ddPPG_Lower = -ddPPG_Lower;
    
    % Check for bad ddPPG wave - at least one peak (postive and negative) must be
    % detectable - must not detect mor ethan two peaks of each kind
    % simultaneously
    if (length(ddPPG_Lower)>2 || isempty(ddPPG_Lower) || length(ddPPG_peaks)>2 || isempty(ddPPG_peaks))
        
%         figure(2)
%         plot(ppgdd)
%         hold on
%         plot(ddPPG_peaks_locs, ddPPG_peaks, '*r')
%         plot(ones(1,length(ppgdd))*(mean(ppgdd) +  1.5*std(ppgdd)))
%         plot(ddPPG_Lower_locs, ddPPG_Lower, '*r')
%         plot(ones(1,length(ppgdd))*(mean(ppgdd) - 0.75*std(ppgdd)))
%         hold off
        
        flag = 1;
        dppgH = 0; dppgW = 0; ddppgH = 0; ddppgW = 0; ddppgPH = 0; ddppgFH = 0;
    else
        ddppgH = ddPPG_peaks(1) + abs(ddPPG_Lower(1));
        ddppgPH = ddPPG_peaks(1);
        ddppgFH = abs(ddPPG_Lower(1));
        ddppgW = (ddPPG_Lower_locs(1) - ddPPG_peaks_locs(1)) / fs;
        
        %
        %         figure()
        %         plot(ppgdd)
        %         hold on
        %         plot(ddPPG_peaks_locs, ddPPG_peaks, '*r')
        %         plot(ones(1,length(ppgdd))*(mean(ppgdd) +  1.5*std(ppgdd)))
        %         hold off
        %
        %         figure()
        %         plot(ppgdd)
        %         hold on
        %         plot(ddPPG_Lower_locs, ddPPG_Lower, '*r')
        %         hold off
        %
        %         figure()
        %         plot(ppgdd)
    end
end
end