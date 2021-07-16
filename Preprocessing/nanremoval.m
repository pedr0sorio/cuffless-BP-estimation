function processedSignals = nanremoval(signals)
idx1 = isnan(signals(:,1));
idx2 = isnan(signals(:,2));
idx3 = isnan(signals(:,3));
idx = idx1 + idx2 + idx3;
processedSignals = signals(idx == 0,:);
end

