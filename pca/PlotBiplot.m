function PlotBiplot(coeff, score, FeatureNames, subject_row)

figure
h = biplot(coeff(:,1:2),'scores',score(:,1:2), 'varlabels',FeatureNames);
% Identify each handle
hID = get(h, 'tag'); 
% Isolate handles to scatter points
hPt = h(strcmp(hID,'obsmarker')); 
% Identify cluster groups
grp = findgroups(subject_row);    %r2015b or later - leave comment if you need an alternative
grpID = 1:max(grp); 
% assign colors and legend display name
clrMap = lines(length(unique(grp)));   % using 'lines' colormap
for i = 1:max(grp)
    set(hPt(grp==i), 'Color', clrMap(i,:), 'DisplayName', sprintf('Subject %d', grpID(i)))
end
% add legend to identify cluster
[~, unqIdx] = unique(grp);
legend(hPt(unqIdx))

end
