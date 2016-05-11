function [ data_output,date_output ] = ProcessDataOriginalPaper( data_input )
% Process data from the original paper and build the Vector Z

% Date Time Series
TSdates = data_input(:,1);

% Short Term Yield 
TBill = data_input(:,2);

% CPI
cpirate = data_input(:,3);

% Index Return (div. included) and log(
logDivPrice = data_input(:,4);
idxret_div_included = data_input(:,5);

% Long Term Retrun & Yield
LongBondRet = data_input(:,6);
LongBondYield = data_input(:,7);





% Benchmark Asset Variable (Cash Proxy)
RealTBill = log(1+TBill) - log(1+cpirate);

% Source Asset Variables - We need Log Excess Returns
exIndex = log(1+idxret_div_included) - log(1+TBill);						
exBond = log(1+LongBondRet) - log(1+TBill);						

%Source State Varaibales
%-- 1. log TBill
logTBill = log(1+TBill);

%-- 2. log Dividend/Price  ratio
% 
  
%-- 3. Yield spread between Long Term bond and T-bill
yield_spread = LongBondYield(1:rows(LongBondYield)-1) - ...
                        log(1+TBill(2:rows(TBill)));


% Build the output vectors
data_output = [RealTBill(5:rows(RealTBill)-1), ...
    exIndex(5:rows(exIndex)-1),...
    exBond(5:rows(exBond)-1), ...
    logTBill(6:rows(logTBill)),logDivPrice(6:rows(logDivPrice)), ...
    yield_spread(5:rows(yield_spread))];

date_output = TSdates(6:rows(logTBill),:);

end

