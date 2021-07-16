function DimensionalityAnalysis(code)

global data

% Creating Input fro PCA analysis - only features rows=obs and col=feat
N = length(data);
N_feat = length(fieldnames(data)) - 7 - 2; % Number of fields minus SBP, DBP, subject_tag and signal fields
FieldNames = fieldnames(data);
FeatureNames = {FieldNames{8:end-2}};
PCA_input = [];
PCA_input_s1 = [];
PCA_input_s2 = [];
Output_var = [];
subject_row_full = [];
for sample = 1:N
    
    feat_row = [data(sample).ST, data(sample).DT, data(sample).PIR, data(sample).PPG_k, data(sample).dppgH ...
        , data(sample).dppgW, data(sample).ddppgH, data(sample).ddppgW, data(sample).ddppgPH, data(sample).ddppgFH ...
        , data(sample).heartRate, data(sample).AI, data(sample).LASI, data(sample).S1, data(sample).S2 ...
        , data(sample).S3, data(sample).S4, data(sample).IPA, data(sample).pat_p, data(sample).pat_f, data(sample).pat_d];
    
    subject_row_full = [subject_row_full; data(sample).subject];
    
    if data(sample).subject == 1
        feat_row_s1 = [data(sample).ST, data(sample).DT, data(sample).PIR, data(sample).PPG_k, data(sample).dppgH ...
            , data(sample).dppgW, data(sample).ddppgH, data(sample).ddppgW, data(sample).ddppgPH, data(sample).ddppgFH ...
            , data(sample).heartRate, data(sample).AI, data(sample).LASI, data(sample).S1, data(sample).S2 ...
            , data(sample).S3, data(sample).S4, data(sample).IPA, data(sample).pat_p, data(sample).pat_f, data(sample).pat_d];
        
        PCA_input_s1 = [PCA_input_s1 ; feat_row_s1];
        
    else
        feat_row_s2 = [data(sample).ST, data(sample).DT, data(sample).PIR, data(sample).PPG_k, data(sample).dppgH ...
            , data(sample).dppgW, data(sample).ddppgH, data(sample).ddppgW, data(sample).ddppgPH, data(sample).ddppgFH ...
            , data(sample).heartRate, data(sample).AI, data(sample).LASI, data(sample).S1, data(sample).S2 ...
            , data(sample).S3, data(sample).S4, data(sample).IPA, data(sample).pat_p, data(sample).pat_f, data(sample).pat_d];
        
        PCA_input_s2 = [PCA_input_s2 ; feat_row_s2];
        
    end
    
    BP_rows = [data(sample).SBP, data(sample).DBP];
    
    PCA_input = [PCA_input ; feat_row];
    
    Output_var = [Output_var; BP_rows];
end

if code == 1
    
    PCA_input = PCA_input_s1;
    
    % Normalisation
    for k=1:size((PCA_input),2)
        PCA_input(:,k) = zscore(PCA_input(:,k));
        % PCA_input(:,k) = PCA_input(:,k)/max(PCA_input(:,k));
    end
    
    % PCA
    [coeff,score,latent,tsquared,explained,mu] = pca(PCA_input);
    
    % Plotting Scree-Plot
    figure()
    suptitle('Scree-Plot - Subject 1')
    pareto(explained)
    xlabel('Principal Component')
    ylabel('Variance Explained (%)')
    
    figure
    suptitle('Subject 1')
    biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',FeatureNames);
    
    % Percentage weighting of each feature in each PC (Matrix C)
    C = coeff.^2;
    
    figure
    suptitle('Importance of each fetaure in PC1 - Subject 1')
    bar(categorical(FeatureNames),C(:,1))
    figure
    suptitle('Importance of each fetaure in PC2 - Subject 1')
    bar(categorical(FeatureNames),C(:,2))
    figure
    suptitle('Importance of each fetaure in PC3')
    bar(categorical(FeatureNames),C(:,3))
    
    
elseif code == 2
    
    PCA_input = PCA_input_s2;
    % Normalisation
    for k=1:size((PCA_input),2)
        PCA_input(:,k) = zscore(PCA_input(:,k));
        % PCA_input(:,k) = PCA_input(:,k)/max(PCA_input(:,k));
    end
    
    % PCA
    [coeff,score,latent,tsquared,explained,mu] = pca(PCA_input);
    
    % Plotting Scree-Plot
    figure()
    suptitle('Scree-Plot - Subject 2')
    pareto(explained)
    xlabel('Principal Component')
    ylabel('Variance Explained (%)')
    
    figure
    suptitle('Subject 2')
    biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',FeatureNames);
    
    % Percentage weighting of each feature in each PC (Matrix C)
    C = coeff.^2;
    
    figure
    suptitle('Importance of each fetaure in PC1 - Subject 2')
    bar(categorical(FeatureNames),C(:,1))
    figure
    suptitle('Importance of each fetaure in PC2 - Subject 2')
    bar(categorical(FeatureNames),C(:,2))
    figure
    suptitle('Importance of each fetaure in PC3')
    bar(categorical(FeatureNames),C(:,3))
    
elseif code == 0
    
    % Normalisation
    for k=1:size((PCA_input),2)
        PCA_input(:,k) = zscore(PCA_input(:,k));
        % PCA_input(:,k) = PCA_input(:,k)/max(PCA_input(:,k));
    end
    
    % PCA
    [coeff,score,latent,tsquared,explained,mu] = pca(PCA_input);
    
    % Plotting Scree-Plot
    figure()
    pareto(explained)
    xlabel('Principal Component')
    ylabel('Variance Explained (%)')
    
    % ------------- Plotting Biplot with cluster by subject
    
    PlotBiplot(coeff, score, FeatureNames, subject_row_full);
    
    % ------------------
    
    % Percentage weighting of each feature in each PC (Matrix C)
    C = coeff.^2;
    
    figure
    suptitle('Importance of each fetaure in PC1')
    bar(categorical(FeatureNames),C(:,1))
    figure
    suptitle('Importance of each fetaure in PC2')
    bar(categorical(FeatureNames),C(:,2))
    
end

end
