%% Replication of JY. Campbell, L. Viceira
%% "The Term Structure of the Risk-Return Tradeoff" 
%% Project 4



%% Clean Slate
clc, clear all, close all

%% ------ Loading Sample Data ------
%load dataQTR.asc;
%	[dataOUT2,dates2]  = GetDataQTR(dataQTR,3,8);      % 8th col = 5-yr bond;
%dataOUT = dataOUT2;
%dates = dates2(5:rows(dataOUT(:,1))+4,:);   

data = xlsread('data_US_replication.xls',1);
[dataOUT,dates] = ProcessDataOriginalPaper(data);




%% ------ The data returned is a matrix with the folowing columns (in log) ------
%	1) Real short yield (cash proxy)
%	2) Stock, excess return over nominal short rate
%	3) Nominal bond, excess return over nominal short rate
%	4) Nominal short yield
%	5) Dividend-price ratio
%	6) Yield spread

exrealshort = dataOUT(:,1);
equity = dataOUT(:,2);
bond = dataOUT(:,3);
nomshort = dataOUT(:,4);
dpratio = dataOUT(:,5);
yield = dataOUT(:,6);


%------ Calculate and display sample-statistics ------
meanState1 = (mean(exrealshort)+0.5*cov(exrealshort))*400;
meanState2 = (mean(equity)+0.5*cov(equity))*400;
meanState3 = (mean(bond)+0.5*cov(bond))*400;
meanState4 = mean(nomshort)*400;
meanState5 = mean(dpratio);
meanState6 = mean(yield)*400;
stdState1 = std(exrealshort)*100*sqrt(4);
stdState2 = std(equity)*100*sqrt(4);
stdState3 = std(bond)*100*sqrt(4);
stdState4 = std(nomshort)*100*sqrt(4);
stdState5 = std(dpratio);
stdState6 = std(yield)*100*sqrt(4);

% Dsiplay Mean
disp ('Mean of : 3M TBill Ex. Real,Eq. Excess Return, 5Y Bond Excess Return, 3M TBill Nom., DP Ratio, Yield Spread');
format long;
[meanState1, meanState2, meanState3, meanState4, meanState5, meanState6]

% Dsiplay Standard Deviation
disp ('Std. deviation of : 3M TBill Ex. Real,Eq. Excess Return, 5Y Bond Excess Return, 3M TBill Nom., DP Ratio, Yield Spread');
format long;
[stdState1, stdState2, stdState3, stdState4, stdState5, stdState6]


% Build a Vector Z
Y = [exrealshort,equity,bond,nomshort,dpratio,yield];


% Detrend mean, as done in paper
% mean_Y_vec = ones(rows(Y),1)*mean(Y);
% mean_Y_mat   = zeros(rows(Y),cols(Y));
% 
% for i=1:cols(Y)
%     mean_Y_mat(:,i) = ones(rows(Y),1)*mean_Y_vec(i);
% end;
% 
% mean_Y = ones(rows(Y),1)*mean(Y);
% Y = Y - mean_Y;

%
%------ VAR Eestimation ------
%

% setup VAR model parameters
VAR2full = vgxset('ARsolve',[],'nAR',1,'asolve',true(6,1),... 
'Series',{'3M TBill Ex. Real','Eq. Excess Return',...
'5Y Bond Excess Return','3M TBill Nom.', 'DP Ratio', 'Yield Spread'});


% Define Pre-sample and estimate
YPre = Y(1:1,:);
T = size(Y,1);
YEst = Y(2:T,:);

% Run VAR regression
[EstSpec2,EstStdErrors2,logL2,W2] = ...
    vgxvarx(VAR2full,YEst,[],YPre);

%vgxdisp(EstSpec2)
correl_W2 = corrcov(cov(W2));

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
Rsq = zeros(cols(Y),1);
errors = zeros(rows(Y)-1,cols(Y));

for i = 1:cols(Y)
	y = Y(2:rows(Y),i);
	x = Y(1:rows(Y)-1,:);

	b = Phi1(i,:)';
	errors(:,i) = (y-x*b);
	Rsq(i) = 1 - var(errors(:,i))/var(y);
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
