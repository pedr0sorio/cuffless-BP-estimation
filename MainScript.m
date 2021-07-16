%% PDSB Project - Cuffless Blood Pressure Estimation 

%%% Group B1
% Diogo Antunes no. 86979; Diogo Batista, no. 86767; Pedro Osório, no. 89777

%% 1. Initialization
clc;
close all;
clear all;
addpath('./dataset');
addpath('./feature-extraction');
addpath('./pca');
addpath('./preprocessing');

global subject fs data 
%% 2. Load and plot the signals
% The following signals:
% 's03386-2577-07-30-13-04m',
% 's30297-2903-04-30-12-46m', and
% 'p016129-2177-10-25-21-42m'
% have all three signals: ECG, PPG, and ABP.

filenames = {'s03386-2577-07-30-13-04m', ...
             's30297-2903-04-30-12-46m', ...
             'p016129-2177-10-25-21-42m'};

 fs = 125; % Hz

 for subject = 1 : length(filenames)-1
     files(subject) = load(['./dataset/' char(filenames(subject)) '_data.mat']);

     % Raw data
     predata(subject).ecg = files(subject).data.signal(:,strcmp({files(1).data.labels.Description},'II'));
     predata(subject).ppg = files(subject).data.signal(:,strcmp({files(1).data.labels.Description},'PLETH'));
     predata(subject).abp = files(subject).data.signal(:,strcmp({files(1).data.labels.Description},'ABP'));

%    Normalise PPG
     predata(subject).ppg = predata(subject).ppg / max(predata(subject).ppg);

     % Extra processing step to remove low freq in PPG signals
     signals = [predata(subject).ecg, predata(subject).ppg, predata(subject).abp];
     signals = nanremoval(signals);
     predata(subject).ecg = signals(:,1);
     predata(subject).ppg = signals(:,2);
     predata(subject).abp = signals(:,3);
     % HP filter PPG
     HPFilt_PPG(predata);
     
%    Plot Global signal
     subplot(length(filenames), 3, 3*subject-2)
     plot(predata(subject).ecg)
     title(['ECG ', num2str(subject)])
     subplot(length(filenames), 3, 3*subject-1)
     plot(predata(subject).ppg)
     title(['PPG ', num2str(subject)])
     subplot(length(filenames), 3, 3*subject)
     plot(predata(subject).abp)
     title(['ABP ', num2str(subject)])
 end

%% 3. Preprocessing
data = struct([]);
predata_denoised = predata;
for subject = 1 : length(predata)
    % Remove NaN values
    signals = [predata(subject).ecg, predata(subject).ppg, predata(subject).abp];
    signals = nanremoval(signals);
    
    
    
    % Remove bad segments
    if (subject == 2)
        signals = crop(signals, fs, 20, 4);
    else
        signals = crop(signals, fs, 20, 3);
    end
    
    predata(subject).ecg = signals{1};
    predata(subject).ppg = signals{2};
    predata(subject).abp = signals{3};
    
    % Remove noise (very low and very high freq components) - Every signal
    % section - ECG , PPG and ABP
    predata_denoised(subject) = data_denoising(predata(subject));
    % WIP
    disp('Data has been denoised')
    
    % Create QRS complex intervals
    qrsIntervals(predata_denoised(subject));
    disp('Data segmented into cardiac cycles')
end

%% Plot QRS complexes in ECG, PPG and ABP
figure
for i = 2 : 5
    subplot(3, 4, i - 1)
    plot(data(i).ecg)
    subplot(3, 4, i - 1 + 4)
    plot(data(i).ppg)
    subplot(3, 4, i - 1 + 8)
    plot(data(i).abp)
end

%% 4. Feature Extraction

FeatureExtraction();

%% 5. Dimensionality Analysis (PCA)

% Subject 1
DimensionalityAnalysis(1);
% Subject 2
DimensionalityAnalysis(2);
% Full Dataset
DimensionalityAnalysis(0);

%% 6.1.a. Stepwise Regression Models with Subject 1 and 2 Training Sets
predictorVars = [data.ST;        ...
                 data.DT;        ...
                 data.PIR;       ...
                 data.PPG_k;     ...
                 data.dppgH;     ...
                 data.dppgW;     ...
                 data.ddppgH;    ...
                 data.ddppgW;    ...
                 data.ddppgPH;   ...
                 data.ddppgFH;   ...
                 data.heartRate; ...
                 data.AI;        ...
                 data.LASI;      ...
                 data.S1;        ...
                 data.S2;        ...
                 data.S3;        ...
                 data.S4;        ...
                 data.IPA;       ...
                 data.pat_p;     ...
                 data.pat_f;     ...
                 data.pat_d      ]';

SBPresponse = [data.SBP]';
[bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

DBPresponse = [data.DBP]';
[bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);

% b          - estimated coefficients
% se         - standard errors
% pval       - p-values
% finalModel - logical vector indicating which terms are in the final model
% stats      - additional statistics (including intercept)

disp(['The RMSE of the SBP model with subject 1 and 2 dataset is: ', num2str(statsSBP.rmse)])
disp(['The RMSE of the DBP model with subject 1 and 2 dataset is: ', num2str(statsDBP.rmse)])

%% 6.1.b. Stepwise Regression Models with Subject 1 and 2 Training Sets, and Cross-Validation
nLeftOut = length(data);
errorsSBP = zeros(nLeftOut, 1);
errorsDBP = zeros(nLeftOut, 1);

leftOutList = randperm(length(data), nLeftOut);

for k = 1 : length(leftOutList)
    test = leftOutList(k);
    predictorVars = [data.ST;        ...
                     data.DT;        ...
                     data.PIR;       ...
                     data.PPG_k;     ...
                     data.dppgH;     ...
                     data.dppgW;     ...
                     data.ddppgH;    ...
                     data.ddppgW;    ...
                     data.ddppgPH;   ...
                     data.ddppgFH;   ...
                     data.heartRate; ...
                     data.AI;        ...
                     data.LASI;      ...
                     data.S1;        ...
                     data.S2;        ...
                     data.S3;        ...
                     data.S4;        ...
                     data.IPA;       ...
                     data.pat_p;     ...
                     data.pat_f;     ...
                     data.pat_d      ]';
    leftOutFeats = predictorVars(test, :);
    predictorVars(test, :) = [];
    
    SBPresponse = [data.SBP]';
    SBPresponse(test) = [];
    [bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

    DBPresponse = [data.DBP]';
    DBPresponse(test) = [];
    [bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);
    
    testSBPestimate = stepwiseFittedModel(statsSBP.intercept, finalModelSBP, bSBP, leftOutFeats);
    testDBPestimate = stepwiseFittedModel(statsDBP.intercept, finalModelDBP, bDBP, leftOutFeats);
    
    errorsSBP(k) = data(test).SBP - testSBPestimate;
    errorsDBP(k) = data(test).DBP - testDBPestimate;
end

errorsSBP = abs(errorsSBP);
errorsDBP = abs(errorsDBP);

% Root-mean-squared errors (RMSE)
rmseSBP = sqrt(sum(errorsSBP .^ 2) / length(errorsSBP));
rmseDBP = sqrt(sum(errorsDBP .^ 2) / length(errorsDBP));
disp(['The RMSE of the SBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(rmseSBP)])
disp(['The RMSE of the DBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(rmseDBP)])

% Mean absolute errors (MAE)
maeSBP = mean(errorsSBP);
maeDBP = mean(errorsDBP);
disp(['The MAE of the SBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(maeSBP)])
disp(['The MAE of the DBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(maeDBP)])

% Standard deviation (STD)
stdSBP = std(errorsSBP);
stdDBP = std(errorsDBP);
disp(['The STD of the SBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(stdSBP)])
disp(['The STD of the DBP model with subject 1 and 2 dataset after cross-validation is: ', num2str(stdDBP)])

%% 6.2.a. Stepwise Regression Models with Subject 1 Training Set
sampleSubject = [data.subject];
dataset1 = [data(sampleSubject == 1)];
dataset2 = [data(sampleSubject == 2)];

predictorVars = [dataset1.ST;        ...
                 dataset1.DT;        ...
                 dataset1.PIR;       ...
                 dataset1.PPG_k;     ...
                 dataset1.dppgH;     ...
                 dataset1.dppgW;     ...
                 dataset1.ddppgH;    ...
                 dataset1.ddppgW;    ...
                 dataset1.ddppgPH;   ...
                 dataset1.ddppgFH;   ...
                 dataset1.heartRate; ...
                 dataset1.AI;        ...
                 dataset1.LASI;      ...
                 dataset1.S1;        ...
                 dataset1.S2;        ...
                 dataset1.S3;        ...
                 dataset1.S4;        ...
                 dataset1.IPA;       ...
                 dataset1.pat_p;     ...
                 dataset1.pat_f;     ...
                 dataset1.pat_d      ]';
             
SBPresponse = [dataset1.SBP]';
[bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

DBPresponse = [dataset1.DBP]';
[bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);

disp(['The RMSE of the SBP model with subject 1 dataset is: ', num2str(statsSBP.rmse)])
disp(['The RMSE of the DBP model with subject 1 dataset is: ', num2str(statsDBP.rmse)])

%% 6.2.b. Subject 1 Training Set and Cross-validation
nLeftOut = length(dataset1);
errorsSBP = zeros(nLeftOut, 1);
errorsDBP = zeros(nLeftOut, 1);

leftOutList = randperm(length(dataset1), nLeftOut);

for k = 1 : length(leftOutList)
    test = leftOutList(k);
    predictorVars = [dataset1.ST;        ...
                     dataset1.DT;        ...
                     dataset1.PIR;       ...
                     dataset1.PPG_k;     ...
                     dataset1.dppgH;     ...
                     dataset1.dppgW;     ...
                     dataset1.ddppgH;    ...
                     dataset1.ddppgW;    ...
                     dataset1.ddppgPH;   ...
                     dataset1.ddppgFH;   ...
                     dataset1.heartRate; ...
                     dataset1.AI;        ...
                     dataset1.LASI;      ...
                     dataset1.S1;        ...
                     dataset1.S2;        ...
                     dataset1.S3;        ...
                     dataset1.S4;        ...
                     dataset1.IPA;       ...
                     dataset1.pat_p;     ...
                     dataset1.pat_f;     ...
                     dataset1.pat_d      ]';
    leftOutFeats = predictorVars(test, :);
    predictorVars(test, :) = [];
    
    SBPresponse = [dataset1.SBP]';
    SBPresponse(test) = [];
    [bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

    DBPresponse = [dataset1.DBP]';
    DBPresponse(test) = [];
    [bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);
    
    testSBPestimate = stepwiseFittedModel(statsSBP.intercept, finalModelSBP, bSBP, leftOutFeats);
    testDBPestimate = stepwiseFittedModel(statsDBP.intercept, finalModelDBP, bDBP, leftOutFeats);
    
    errorsSBP(k) = dataset1(test).SBP - testSBPestimate;
    errorsDBP(k) = dataset1(test).DBP - testDBPestimate;
end

errorsSBP = abs(errorsSBP);
errorsDBP = abs(errorsDBP);

% Root-mean-squared errors (RMSE)
rmseSBP = sqrt(sum(errorsSBP .^ 2) / length(errorsSBP));
rmseDBP = sqrt(sum(errorsDBP .^ 2) / length(errorsDBP));
disp(['The RMSE of the SBP model with subject 1 dataset after cross-validation is: ', num2str(rmseSBP)])
disp(['The RMSE of the DBP model with subject 1 dataset after cross-validation is: ', num2str(rmseDBP)])

% Mean absolute errors (MAE)
maeSBP = mean(errorsSBP);
maeDBP = mean(errorsDBP);
disp(['The MAE of the SBP model with subject 1 dataset after cross-validation is: ', num2str(maeSBP)])
disp(['The MAE of the DBP model with subject 1 dataset after cross-validation is: ', num2str(maeDBP)])

% Standard deviation (STD)
stdSBP = std(errorsSBP);
stdDBP = std(errorsDBP);
disp(['The STD of the SBP model with subject 1 dataset after cross-validation is: ', num2str(stdSBP)])
disp(['The STD of the DBP model with subject 1 dataset after cross-validation is: ', num2str(stdDBP)])

%% 6.2.c. Subject 2 Testing Set
nTests = length(dataset2);
errorsSBP = zeros(nTests, 1);
errorsDBP = zeros(nTests, 1);

testSet = randperm(length(dataset2), nTests);

for k = 1 : length(testSet)
    testFeats = [dataset2(testSet(k)).ST;        ...
                 dataset2(testSet(k)).DT;        ...
                 dataset2(testSet(k)).PIR;       ...
                 dataset2(testSet(k)).PPG_k;     ...
                 dataset2(testSet(k)).dppgH;     ...
                 dataset2(testSet(k)).dppgW;     ...
                 dataset2(testSet(k)).ddppgH;    ...
                 dataset2(testSet(k)).ddppgW;    ...
                 dataset2(testSet(k)).ddppgPH;   ...
                 dataset2(testSet(k)).ddppgFH;   ...
                 dataset2(testSet(k)).heartRate; ...
                 dataset2(testSet(k)).AI;        ...
                 dataset2(testSet(k)).LASI;      ...
                 dataset2(testSet(k)).S1;        ...
                 dataset2(testSet(k)).S2;        ...
                 dataset2(testSet(k)).S3;        ...
                 dataset2(testSet(k)).S4;        ...
                 dataset2(testSet(k)).IPA;       ...
                 dataset2(testSet(k)).pat_p;     ...
                 dataset2(testSet(k)).pat_f;     ...
                 dataset2(testSet(k)).pat_d      ]';
    testSBPestimate = stepwiseFittedModel(statsSBP.intercept, finalModelSBP, bSBP, testFeats);
    testDBPestimate = stepwiseFittedModel(statsDBP.intercept, finalModelDBP, bDBP, testFeats);
    
    errorsSBP(k) = dataset2(testSet(k)).SBP - testSBPestimate;
    errorsDBP(k) = dataset2(testSet(k)).DBP - testDBPestimate;
end

errorsSBP = abs(errorsSBP);
errorsDBP = abs(errorsDBP);

% Root-mean-squared errors (RMSE)
rmseSBP = sqrt(sum(errorsSBP .^ 2) / length(errorsSBP));
rmseDBP = sqrt(sum(errorsDBP .^ 2) / length(errorsDBP));
disp(['The RMSE of the SBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(rmseSBP)])
disp(['The RMSE of the DBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(rmseDBP)])

% Mean absolute errors (MAE)
maeSBP = mean(errorsSBP);
maeDBP = mean(errorsDBP);
disp(['The MAE of the SBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(maeSBP)])
disp(['The MAE of the DBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(maeDBP)])

% Standard deviation (STD)
stdSBP = std(errorsSBP);
stdDBP = std(errorsDBP);
disp(['The STD of the SBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(stdSBP)])
disp(['The STD of the DBP model with subject 1 dataset after testing with subject 2 samples is: ', num2str(stdDBP)])

%% 6.3.a. Stepwise Regression Models with Subject 2 Dataset
predictorVars = [dataset2.ST;        ...
                 dataset2.DT;        ...
                 dataset2.PIR;       ...
                 dataset2.PPG_k;     ...
                 dataset2.dppgH;     ...
                 dataset2.dppgW;     ...
                 dataset2.ddppgH;    ...
                 dataset2.ddppgW;    ...
                 dataset2.ddppgPH;   ...
                 dataset2.ddppgFH;   ...
                 dataset2.heartRate; ...
                 dataset2.AI;        ...
                 dataset2.LASI;      ...
                 dataset2.S1;        ...
                 dataset2.S2;        ...
                 dataset2.S3;        ...
                 dataset2.S4;        ...
                 dataset2.IPA;       ...
                 dataset2.pat_p;     ...
                 dataset2.pat_f;     ...
                 dataset2.pat_d      ]';
             
SBPresponse = [dataset2.SBP]';
[bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

DBPresponse = [dataset2.DBP]';
[bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);

disp(['The RMSE of the SBP model with subject 2 dataset is: ', num2str(statsSBP.rmse)])
disp(['The RMSE of the DBP model with subject 2 dataset is: ', num2str(statsDBP.rmse)])

%% 6.3.b. Subject 2 Training Set and Cross-validation
nLeftOut = length(dataset2);
errorsSBP = zeros(nLeftOut, 1);
errorsDBP = zeros(nLeftOut, 1);

leftOutList = randperm(length(dataset2), nLeftOut);

for k = 1 : length(leftOutList)
    test = leftOutList(k);
    predictorVars = [dataset2.ST;        ...
                     dataset2.DT;        ...
                     dataset2.PIR;       ...
                     dataset2.PPG_k;     ...
                     dataset2.dppgH;     ...
                     dataset2.dppgW;     ...
                     dataset2.ddppgH;    ...
                     dataset2.ddppgW;    ...
                     dataset2.ddppgPH;   ...
                     dataset2.ddppgFH;   ...
                     dataset2.heartRate; ...
                     dataset2.AI;        ...
                     dataset2.LASI;      ...
                     dataset2.S1;        ...
                     dataset2.S2;        ...
                     dataset2.S3;        ...
                     dataset2.S4;        ...
                     dataset2.IPA;       ...
                     dataset2.pat_p;     ...
                     dataset2.pat_f;     ...
                     dataset2.pat_d      ]';
    leftOutFeats = predictorVars(test, :);
    predictorVars(test, :) = [];
    
    SBPresponse = [dataset2.SBP]';
    SBPresponse(test) = [];
    [bSBP, seSBP, pvalSBP, finalModelSBP, statsSBP] = stepwisefit(predictorVars, SBPresponse);

    DBPresponse = [dataset2.DBP]';
    DBPresponse(test) = [];
    [bDBP, seDBP, pvalDBP, finalModelDBP, statsDBP] = stepwisefit(predictorVars, DBPresponse);
    
    testSBPestimate = stepwiseFittedModel(statsSBP.intercept, finalModelSBP, bSBP, leftOutFeats);
    testDBPestimate = stepwiseFittedModel(statsDBP.intercept, finalModelDBP, bDBP, leftOutFeats);
    
    errorsSBP(k) = dataset2(test).SBP - testSBPestimate;
    errorsDBP(k) = dataset2(test).DBP - testDBPestimate;
end

errorsSBP = abs(errorsSBP);
errorsDBP = abs(errorsDBP);

% Root-mean-squared errors (RMSE)
rmseSBP = sqrt(sum(errorsSBP .^ 2) / length(errorsSBP));
rmseDBP = sqrt(sum(errorsDBP .^ 2) / length(errorsDBP));
disp(['The RMSE of the SBP model with subject 2 dataset after cross-validation is: ', num2str(rmseSBP)])
disp(['The RMSE of the DBP model with subject 2 dataset after cross-validation is: ', num2str(rmseDBP)])

% Mean absolute errors (MAE)
maeSBP = mean(errorsSBP);
maeDBP = mean(errorsDBP);
disp(['The MAE of the SBP model with subject 2 dataset after cross-validation is: ', num2str(maeSBP)])
disp(['The MAE of the DBP model with subject 2 dataset after cross-validation is: ', num2str(maeDBP)])

% Standard deviation (STD)
stdSBP = std(errorsSBP);
stdDBP = std(errorsDBP);
disp(['The STD of the SBP model with subject 2 dataset after cross-validation is: ', num2str(stdSBP)])
disp(['The STD of the DBP model with subject 2 dataset after cross-validation is: ', num2str(stdDBP)])

%% 6.3.c. Subject 1 test set
nTests = length(dataset1);
errorsSBP = zeros(nTests, 1);
errorsDBP = zeros(nTests, 1);

testSet = randperm(length(dataset1), nTests);

for k = 1 : length(testSet)
    testFeats = [dataset1(testSet(k)).ST;        ...
                 dataset1(testSet(k)).DT;        ...
                 dataset1(testSet(k)).PIR;       ...
                 dataset1(testSet(k)).PPG_k;     ...
                 dataset1(testSet(k)).dppgH;     ...
                 dataset1(testSet(k)).dppgW;     ...
                 dataset1(testSet(k)).ddppgH;    ...
                 dataset1(testSet(k)).ddppgW;    ...
                 dataset1(testSet(k)).ddppgPH;   ...
                 dataset1(testSet(k)).ddppgFH;   ...
                 dataset1(testSet(k)).heartRate; ...
                 dataset1(testSet(k)).AI;        ...
                 dataset1(testSet(k)).LASI;      ...
                 dataset1(testSet(k)).S1;        ...
                 dataset1(testSet(k)).S2;        ...
                 dataset1(testSet(k)).S3;        ...
                 dataset1(testSet(k)).S4;        ...
                 dataset1(testSet(k)).IPA;       ...
                 dataset1(testSet(k)).pat_p;     ...
                 dataset1(testSet(k)).pat_f;     ...
                 dataset1(testSet(k)).pat_d      ]';
    testSBPestimate = stepwiseFittedModel(statsSBP.intercept, finalModelSBP, bSBP, testFeats);
    testDBPestimate = stepwiseFittedModel(statsDBP.intercept, finalModelDBP, bDBP, testFeats);
    
    errorsSBP(k) = dataset1(testSet(k)).SBP - testSBPestimate;
    errorsDBP(k) = dataset1(testSet(k)).DBP - testDBPestimate;
end

errorsSBP = abs(errorsSBP);
errorsDBP = abs(errorsDBP);

% Root-mean-squared errors (RMSE)
rmseSBP = sqrt(sum(errorsSBP .^ 2) / length(errorsSBP));
rmseDBP = sqrt(sum(errorsDBP .^ 2) / length(errorsDBP));
disp(['The RMSE of the SBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(rmseSBP)])
disp(['The RMSE of the DBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(rmseDBP)])

% Mean absolute errors (MAE)
maeSBP = mean(errorsSBP);
maeDBP = mean(errorsDBP);
disp(['The MAE of the SBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(maeSBP)])
disp(['The MAE of the DBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(maeDBP)])

% Standard deviation (STD)
stdSBP = std(errorsSBP);
stdDBP = std(errorsDBP);
disp(['The STD of the SBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(stdSBP)])
disp(['The STD of the DBP model with subject 2 dataset after testing with subject 1 samples is: ', num2str(stdDBP)])

disp(['The RMSE of the SBP model is: ', num2str(statsSBP.rmse)])
disp(['The RMSE of the DBP model is: ', num2str(statsDBP.rmse)])
