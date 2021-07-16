function HPFilt_PPG(predata)

global subject

% Wavelet Decomposition for PPG
section_hfdn = predata(subject).ppg;
wt = modwt(section_hfdn,10,'db8');
wt_rec = zeros(size(wt));
% Zeroing coeficients that hold very low freq components (d7, d8, d9, d10 and a10)
wt_rec(1:6,:) = wt(1:6,:);
% Reconstruct without very high freq and very low freq coef
aux = imodwt(wt_rec,'db8');
offset = mean(predata(subject).ppg);
predata(subject).ppg = aux - mean(aux) + offset;
predata(subject).ppg = predata(subject).ppg';
disp('Done WT HPF')


end
