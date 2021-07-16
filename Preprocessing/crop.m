function croppedSignal = crop(signals,fs,epochDuration,stdMultiple)
thr11 = mean(signals(:,1)) - stdMultiple*std(signals(:,1));
thr21 = mean(signals(:,1)) + stdMultiple*std(signals(:,1));
thr12 = mean(signals(:,2)) - stdMultiple*std(signals(:,2));
thr22 = mean(signals(:,2)) + stdMultiple*std(signals(:,2));
thr13 = mean(signals(:,3)) - stdMultiple*std(signals(:,3));
thr23 = mean(signals(:,3)) + stdMultiple*std(signals(:,3));
croppedSignal = {[],[],[]};
for k = 1 : floor(length(signals(:,1))/(fs*epochDuration))
    segments = [signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,1),...
                signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,2),...
                signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,3)];
    if ((min(segments(:,1))>thr11 && max(segments(:,1))<thr21) && ...
        (min(segments(:,2))>thr12 && max(segments(:,2))<thr22) && ...
        (min(segments(:,3))>thr13 && max(segments(:,3))<thr23))
        croppedSignal{1} = [croppedSignal{1}, segments(:,1)];
        croppedSignal{2} = [croppedSignal{2}, segments(:,2)];
        croppedSignal{3} = [croppedSignal{3}, segments(:,3)];
    end
end
if (k*fs*epochDuration < length(signals(:,1)))
    segments = [signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,1),...
                signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,2),...
                signals((k-1)*fs*epochDuration+1 : k*fs*epochDuration,3)];
    if ((min(segments(:,1))>thr11 && max(segments(:,1))<thr21) && ...
        (min(segments(:,2))>thr12 && max(segments(:,2))<thr22) && ...
        (min(segments(:,3))>thr13 && max(segments(:,3))<thr23))
        croppedSignal{1} = [croppedSignal{1}, segments(:,1)];
        croppedSignal{2} = [croppedSignal{2}, segments(:,2)];
        croppedSignal{3} = [croppedSignal{3}, segments(:,3)];
    end
end
end