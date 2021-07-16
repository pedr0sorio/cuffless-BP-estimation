function data_denoised = data_denoising(data_subject)
% Db8 is the wavelet that best preserves the ecg peaks in denoising
% applications [1].
% [1] - B. N. Singh et al., “Optimal selection of wavelet basis function applied
% to ECG signal denoising,” Digital Signal Process., vol. 16, no. 3, pp.
% 275–287, 2006.

global subject fs

data_denoised = data_subject;
% Get signal structure from data
ecgs = data_subject.ecg; %j=1
ppgs = data_subject.ppg; %j=2
abps = data_subject.abp; %j=3
N = size(ecgs,2);
local_data = {ecgs , ppgs, abps};
local_data_den = {[],[],[]};
remove_k = [];
remove_j = [];
% Filter each 20 sec window akak column
for j = 1:3
    for k = 1:N
        % Getting section
        section = local_data{j}(:,k);
        section = section';
        % Evaluate and process section
        % Remove sections with more than one second of zeros.
        second_of_zeros = zeros(1,fs);
        intersection = strfind(section, second_of_zeros);
        if isempty(intersection) % there is no intersection hence good di
            % Denoising high freq with thresholding
%             disp(['subj = ' num2str(subject) ', j = ' num2str(j) ', k = ' num2str(k)])
            section_hfdn = wden(section,'rigrsure','s','sln',10,'db8');
            if j == 1
            % Wavelet Decomposition for ECG
            wt = modwt(section_hfdn,10,'db8');
            wt_rec = zeros(size(wt));
            % Zeroing coeficients that hold very low freq components (d7, d8, d9, d10 and a10)
            wt_rec(1:6,:) = wt(1:6,:);
            % Reconstruct without very high freq and very low freq coef
            section_hfdn = imodwt(wt_rec,'db8');
%             elseif j == 2
%             % Wavelet Decomposition for PPG
%             wt = modwt(section_hfdn,10,'db8');
%             wt_rec = zeros(size(wt));
%             % Zeroing coeficients that hold very low freq components (d7, d8, d9, d10 and a10)
%             wt_rec(1:10,:) = wt(1:10,:);
%             % Reconstruct without very high freq and very low freq coef
%             section_hfdn = imodwt(wt_rec,'db8');  
%             section_hfdn = highpass(section_hfdn,0.5,fs,'ImpulseResponse','iir','Steepness',0.5);
            end
            % Allocate processed section to output variable
            local_data_den{j} = [local_data_den{j}, section_hfdn'];
        else
            if ismember(k,remove_k)==0
                remove_k = [remove_k, k];
                remove_j = [remove_j, j];
            end
        end
    end
end

for l=1:length(remove_k)
    j = remove_j(l);
    k = remove_k(l);
    jotas = [1,2,3];
    jotas(jotas~=j);
    for jota = 1:2
        local_data_den{jotas(jota)}(:,k) = [];
    end
end

data_denoised.ecg = local_data_den{1};
data_denoised.ppg = local_data_den{2};
data_denoised.abp = local_data_den{3};
end