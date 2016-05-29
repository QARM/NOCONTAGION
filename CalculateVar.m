function [ market, stdDev, correl, n_obs ] = CalculateVar(dataInput,...
    mainMktIndex, otherMktIndex, nLags, headers, displayStats)
% Fit a VAR(nLag) model between two markets, and return residuals Var & Correl
% between the two markets
% Parameters:
%     dataInput: is an indexed array of Tx4 Matrix. 
%     Each Matrix contains 4 data series of T obsveration for a market 
%     (a given index of the array dataOut)
%     The 4 data series are in order:
%           1. Log returns of Index on Main market
%           2. Log Retruns of Index on Other Market
%           3. Nominal Short rate of Main market
%           4. Nominal Short rate of Other market
%
%     mainMktIndex: is the index of the main market in consideration
%
%     otherMktIndex: is the index of the other market we want to compare
%     
%     header: is an indexed array of market name (same index as dataInput)
% 
%     nLags ; is the number of lag to be used for the VAR
%
%     displayStats: is a boolean to indicate if we want to output stats.

% Scaling factor for IR return (VAR stability)
scale_IR=10;

% Ignore incomplete data in the series
offset = 1;
k=1;
while (isnan(dataInput(otherMktIndex,2,k)) || isnan(dataInput(otherMktIndex,4,k)))
    k=k+1;
    offset = offset+1;    
end

mainReturns = dataInput(otherMktIndex,1,offset:size(dataInput,3));
otherReturns = dataInput(otherMktIndex,2,offset:size(dataInput,3));
mainIR = dataInput(otherMktIndex,3,offset:size(dataInput,3));
otherIR = dataInput(otherMktIndex,4,offset:size(dataInput,3));

base = 252;  %% Annualization factor

if (otherMktIndex == mainMktIndex)
    market=headers{1,otherMktIndex+1};
    stdDev=[std(otherReturns)*100/sqrt(252), std(otherReturns)*100/sqrt(252)...
        , std(otherReturns)*100/sqrt(252)];
    correl=1;
    n_obs = size(dataInput,3) - offset + 1;
    return
end

if (displayStats)
    %------ Calculate and display sample-statistics ------
    meanState1 = (mean(mainReturns)+0.5*var(mainReturns)/base)*100;
    meanState2 = (mean(otherReturns)+0.5*var(otherReturns)/base)*100;
    meanState3 = (mean(mainIR)+0.5*var(mainIR))*100;
    meanState4 = (mean(otherIR)+0.5*var(otherIR))*100;

    stdState1 = std(mainReturns)*100/sqrt(base);
    stdState2 = std(otherReturns)*100/sqrt(base);
    stdState3 = std(mainIR)*100;
    stdState4 = std(otherIR)*100;

    % Dsiplay Mean
    disp ('Mean of : Main Returns, Other Return, Main IR, Other IR');
    format long;
    [meanState1, meanState2, meanState3, meanState4]

    % Dsiplay Standard Deviation
    disp ('Std. deviation of : Main Returns, Other Return, Main IR, Other IR');
    format long;
    [stdState1, stdState2, stdState3, stdState4]
end


% Build a Vector Y
Y = [mainReturns,otherReturns,mainIR*scale_IR,otherIR*scale_IR];
%X = [mainIR,otherIR]; %%,mainIR,otherIR];


%
%------ VAR Eestimation ------
%

% setup VAR model parameters
VAR2full = vgxset('ARsolve',[],'nAR',nLags,... %'bsolve',[], 'nX', 2,...
'Series',{'Main Returns', 'Other Return', 'Main IR', 'Other IR'});
%%'asolve',true(4,1),... 


% Define Pre-sample and estimate
YPre = squeeze(Y(1,:,1:5))';
T = size(Y,3);
YEst = squeeze(Y(1,:,6:T))';
%XEst = {squeeze(X(1,:,6:T))'};
%XEst = exoOUT{1}(6:T); % vgxvarx expect a cell array of matrix for exo. var

% Run VAR regression
[EstSpec2,EstStdErrors2,logL2,W2] = ...
    vgxvarx(VAR2full,YEst,[],YPre); %Xest

%vgxdisp(EstSpec2)
covar_W2 = cov(W2);
correl_W2 = corrcov(covar_W2);

if (displayStats)
    
    % Display the residual stdev + correl as in the paper
    stddev_diag__res_correl_offidag = (correl_W2+(diag(diag(correl_W2)).*-1))+(sqrt(diag(diag(cov(W2)))).*100);

    % Display VAR parameters
    res=vgxget(EstSpec2, 'AR');
    Phi1=res{:};
    disp('Coefficents estimates:');
    Phi1

    % Store Constant
    Phi0=vgxget(EstSpec2, 'a');

    % Store Contemporaneous Covarance matrix
    res_var=vgxget(EstSpec2, 'Q');
    Sigma_VAR=res_var;

    % Calculate R-Squared
    Y = squeeze(Y(1,:,:))';
    Rsq = zeros(cols(Y),1);
    errors = zeros(rows(Y)-1,cols(Y));

    for otherMktIndex = 1:cols(Y)
        y = Y(2:rows(Y),otherMktIndex);
        x = Y(1:rows(Y)-1,:);

        b = Phi1(otherMktIndex,:)';
        errors(:,otherMktIndex) = (y-x*b);
        Rsq(otherMktIndex) = 1 - var(errors(:,otherMktIndex))/var(y);
    end

    % Display T-Satistics
     res=vgxget(EstStdErrors2, 'AR');
     tstat=res{:};


    % T-Statistic
    disp('Coefficents error t-statistics:');
    Phi1 ./ tstat
    %vgxdisp(EstSpec, EstStdErrors, 'DoFAdj', true)

    % Display R-Squared
    disp('R-squared statistics:');
    Rsq

    %Display Co-Variance structure of innovations (correl. out of diag. 
    % and Std. dev*100 diag)
    disp('Cross Corelation of Residuals:');
    stddev_diag__res_correl_offidag
end

%Store the results
market=headers{1,otherMktIndex+1};
stdDev=[sqrt(covar_W2(1,1)), sqrt(covar_W2(2,2)), sqrt(covar_W2(1,2))];
correl=correl_W2(1,2);
n_obs = size(dataInput,3) - offset + 1;