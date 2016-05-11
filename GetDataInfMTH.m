function [dataOUT] = GetDataInfMTH(dataIN,SysId,mat)

% Construct the state variables.
% dataIN = 1952/6/30 to 1997/12/31.

TBill = dataIN(:,6);						% 1952/06 to 1997/12 %
cpirate = dataIN(:,7);
vwretd = dataIN(:,2);
vwindx = dataIN(:,3);
bondret = dataIN(:,mat);
longyield = dataIN(:,4)./1200;		% longyield is in logs.
date = dataIN(:,1); %%% for checking purposes -- JW
% -- Construct Log Excess Returns -- %
RealTBill = log(1+TBill) - log(1+cpirate);					% 1952/06 to 1997/12
exStock = log(1+vwretd) - log(1+TBill);						% 1952/06 to 1997/12
exBond = log(1+bondret) - log(1+TBill);						% 1952/06 to 1997/12
logInf = log(1+cpirate);											% 1952/06 to 1997/12

% -- Construct the Dividend -- @
T = rows(vwindx);														% Number of Observations/Quarters in original dataset %
div = (1+vwretd(2:T)).*vwindx(1:T-1) - vwindx(2:T);	   % Dividends: 1952/07 to 1997/12 %

% -- Construct log dividend price ratio -- %
logdiv = zeros(rows(div)-11,1);									% Smoothed Dividends: 1953/06 to 1997/12
for i=12:rows(div)
   logdiv(i-11)=log(sum(div(i-11:i)));
end;
DivPrice = logdiv - log(vwindx(13:T));							% DivPrice = 1953/06 to 1997/12

% -- Construct Nominal short rate minus 1-yr MA average -- %
logTBill = log(1+TBill);											% 1952/06 to 1997/12
MAavg = zeros(rows(logTBill),1);									
for i=13:rows(logTBill)
   MAavg(i) = sum(logTBill(i-12:i-1))/12;
end;
rb = logTBill(13:rows(logTBill))-MAavg(13:rows(MAavg));	% 1953/06 to 1997/12

% -- Construct Yield Spread -- %
spread = longyield(1:T-1) - logTBill(2:T) ;					% 1952/06 to 1997/11

% -- Collect the Series: 1953/06 to 1997/11 -- %

% RealTBill = 1952/06 to 1997/12
% exStock   = 1952/06 to 1997/12
% exBond    = 1952/06 to 1997/12
% DivPrice  = 1953/06 to 1997/12
% rb	  		= 1953/06 to 1997/12
% spread 	= 1952/06 to 1997/11
% logInf    = 1952/06 to 1997/12


if SysId == 1
   dataOUT = [RealTBill(13:rows(RealTBill)-1), exStock(13:rows(exStock)-1),exBond(13:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), rb(1:rows(rb)-1), logInf(13:rows(logInf)-1)];
elseif SysId == 2
   dataOUT = [RealTBill(13:rows(RealTBill)-1), exStock(13:rows(exStock)-1),exBond(13:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), rb(1:rows(rb)-1), spread(13:rows(spread))];   
elseif SysId == 3
   dataOUT = [RealTBill(13:rows(RealTBill)-1), exStock(13:rows(exStock)-1),exBond(13:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), rb(1:rows(rb)-1), date(13:rows(date)-1)];
   date = date(13:rows(date)-1);
end;