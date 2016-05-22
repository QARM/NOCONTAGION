%% Replication of R. Rigobon, J. Forbes
%% "No Contagion, Only Interdependence" 
%% Project 14



%% Clean Slate
clc, clear variables, close all

%% ------ Loading Sample Data ------
% Main Markext Index
mainMktIndex = 11-1; % Hong Kong (need to offset one column, to ignore date)
startNormalPeriod=19960101;
endNormalPeriod=19971016;
endTurmoilPeriod=19971117;


% Load the Index Returns
[data, headers] = xlsread('data\MSCI-PRICES-LOCAL.xlsx',1);

% Load the Interest Rates
[data_IR, headers_IR] = xlsread('data\IR 3M or ON.xlsx',1);

startIndex=find(data==startNormalPeriod);
endIndex=find(data==endNormalPeriod);
endTurmoilIndex=find(data==endTurmoilPeriod);

data = data(startIndex:endTurmoilIndex, :);
data_IR = data_IR(startIndex:endTurmoilIndex, :);

%% Process Data
% ------ The data returned is an array of Tx4 matrix log returns ------  
% ------ for each market pair (main vs. other) with columns:     ------
%	1. Log returns of Index on Main market
%	2. Log Retruns of Index on Other Market
%	3. Nominal Short rate of Main market
%	4. Nominal Short rate of Other market

[dataOUT,exoOUT, dates] = ProcessData(data, data_IR, mainMktIndex, 1);

%% Loop for each market and calculate standard deviation & correlation coefs. 

% Process Stable Period
input = dataOUT(:,:,startIndex:endIndex-2);

for i=1:cols(data)-1

    % Process the data and output results
    [market,stdDev, correl, t_obs] = CalculateVar(input, mainMktIndex...
        , i, 5, headers, false);

    %Store the results
    Results(i).Country=market;
    Results(i).StdDevMainStable=stdDev(1);
    Results(i).StdDevOtherStable=stdDev(2);
    Results(i).StdDevCrossStable=stdDev(3);
    Results(i).CorrelStable=correl;
    Results(i).NObsStable=t_obs;

end

% Process Turmoil Period
input = dataOUT(:,:,endIndex-1:endTurmoilIndex-2);
for i=1:cols(data)-1

    % Process the data and output results
    [market,stdDev, correl, t_obs] = CalculateVar(input, mainMktIndex...
        , i, 1, headers, false);

    %Store the results
    Results(i).StdDevMainTurmoil=stdDev(1);
    Results(i).StdDevOtherTurmoil=stdDev(2);
    Results(i).StdDevCrossTurmoil=stdDev(3);
    Results(i).CorrelTurmoil=correl;
    Results(i).NObsTurmoil=t_obs;
end

% Process Full Period
input = dataOUT(:,:,startIndex:endTurmoilIndex-2);
for i=1:cols(data)-1

    % Process the data and output results
    [market,stdDev, correl, t_obs] = CalculateVar(input, mainMktIndex...
        , i, 5, headers, false);

    %Store the results
    Results(i).StdDevMainFull=stdDev(1);
    Results(i).StdDevOtherFull=stdDev(2);
    Results(i).StdDevCrossFull=stdDev(3);
    Results(i).CorrelFull=correl;
    Results(i).NObsFull=t_obs;

end

% Calculate the fisher trsanformation
CondResults = FisherTransform(Results, cols(data)-1);

% Perform Corrrelation adjustment (unconditional corraltion and covariance)
ResultsAdj = Results;

for i=1:cols(data)-1
  delta = (Results(i).StdDevOtherTurmoil^2 /...
                                     Results(i).StdDevOtherFull^2)-1;
  AdjustedCorrelStable = Results(i).CorrelStable /... 
                             sqrt(1+ delta*(1-Results(i).CorrelStable^2));
  AdjustedCorrelTurmoil = Results(i).CorrelTurmoil /... 
                             sqrt(1+ delta*(1-Results(i).CorrelTurmoil^2));
  ResultsAdj(i).CorrelStable = AdjustedCorrelStable;
  ResultsAdj(i).CorrelTurmoil = AdjustedCorrelTurmoil;
  
  ResultsAdj(i).StdDevOtherStable=sqrt(ResultsAdj(i).CorrelStable ...
                                *ResultsAdj(i).StdDevMainStable^2 ...
                                    *ResultsAdj(i).StdDevOtherStable^2);
  
  ResultsAdj(i).StdDevOtherTurmoil=sqrt(ResultsAdj(i).CorrelTurmoil ...
                                *ResultsAdj(i).StdDevMainTurmoil^2 ...
                                    *ResultsAdj(i).StdDevOtherTurmoil^2);
end

% Calculate the fisher trsanformation on adjusted results
UncondResults = FisherTransform(ResultsAdj, cols(data)-1);

%% Save the resuts to a file 
SaveResults(CondResults, 'c:\temp\results_contagion.xls')
SaveResults(UncondResults, 'c:\temp\results_contagion_uncond.xls')