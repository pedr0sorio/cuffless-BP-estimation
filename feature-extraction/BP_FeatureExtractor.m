function [SBP, DBP] = BP_FeatureExtractor(abp)

global fs flag CardiacCycle

% Selecting smaller window of abp signal
n = length(abp);
full_abp = abp;
abp = abp(floor(n/8):(n-ceil(n/8)));


[SBPs, SBPs_locs] = findpeaks(abp, 'MinPeakHeight', mean(abp) + std(abp), 'MinPeakDistance', ceil(0.5 * fs));
[DBPs, DBPs_locs] = findpeaks(-abp, 'MinPeakHeight', mean(-abp) + 0.75*std(abp), 'MinPeakDistance', ceil(0.4 * fs));
DBPs = -DBPs;

if (length(SBPs)~=2 || length(DBPs)~=2)
    
%     abp = data(5800).abp;
%     n = length(abp);
%     full_abp = abp;
%     abp = abp(floor(n/8):(n-ceil(n/8)));
%     figure(1)
%     plot(full_abp)
%     figure(2)
%     plot(abp)
%     hold on
%     plot(DBPs_locs, DBPs, '*r')
%     plot(ones(1,length(abp)) * (mean(abp) - 0.75*std(abp)))
%     plot(SBPs_locs, SBPs, '*r')
%     plot(ones(1,length(abp)) * (mean(abp) + std(abp)))
%     hold off
    
    flag = 1;
    SBP=0;DBP=0;
else
    SBP = SBPs(1);
    DBP = DBPs(2);
end

% figure()
% n = length(abp);
% plot(abp(floor(n/8):(n-ceil(n/8))))
% 
% figure()
% plot(abp)
% hold on
% plot(DBPs_locs, DBPs, '*r')
% plot(ones(1,length(abp)) * (mean(abp) - 0.75*std(abp)))
% hold off
% % 
% figure()
% plot(abp)
% hold on
% plot(SBPs_locs, SBPs, '*r')
% plot(ones(1,length(abp)) * (mean(abp) + std(abp)))
% hold off
% 


end
