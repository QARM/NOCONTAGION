function [dataOUT,date] = GetDataQTR(dataIN,SysId,m)

% Load in the all data and extract/compute the one we need.
% dataIN = dataQTR.asc = 52:II to 97:IV (183 obs).
% m = bond maturity used in study.
% dataOUT = 
%         

TBill = dataIN(:,11);												% 52:II to 96:IV %
cpirate = dataIN(:,12);
vwretd = dataIN(:,2);
vwindx = dataIN(:,3);
bondret = dataIN(:,m);
date = dataIN(:,1);
% -- Construct the Dividend -- @
T = rows(vwindx);														% Number of Observations/Quarters in original dataset %
div = (1+vwretd(2:T)).*vwindx(1:T-1) - vwindx(2:T);	   % Dividends: 52:III to 96:IV%

% -- Construct Log Excess Returns -- %
RealTBill = log(1+TBill) - log(1+cpirate);					% 52:II to 96:IV %
exStock = log(1+vwretd) - log(1+TBill);						% 52:II to 96:IV %
exBond = log(1+bondret) - log(1+TBill);						% 52:II to 96:IV %
logInf = log(1+cpirate);									% 52:II to 96:IV %

% -- Construct log dividend price ratio -- %
logdiv = zeros(rows(div)-3,1);									% Smoothed Dividends: 53:II to 96:IV %
for i=4:rows(div)   
   logdiv(i-3)=log(sum(div(i-3:i)));
end;
DivPrice = logdiv - log(vwindx(5:T));							% 53:II to 96:IV %

% -- Construct Nominal short rate minus 1-yr MA average -- %
% not used in respecification in SysId = 3
logTBill = log(1+TBill);											% 52:II to 96:IV %
MAavg = zeros(rows(logTBill),1);									
for i=5:rows(logTBill)
   MAavg(i) = sum(logTBill(i-4:i-1))/4;
end;
nomShort = logTBill(5:rows(logTBill))-MAavg(5:rows(MAavg));	% 53:II to 96:IV %

%for i=4:rows(logTBill)
%	MAavg(i) = sum(logTBill(i-3:i))/4;
%end;
%nomShort = logTBill(4:rows(logTBill))-MAavg(4:rows(MAavg));
% -- Construct Yield Spread -- %
%sprmk = yLmk - ySmk;									        		% 52:II to 96:III %
%sprfb1 = yLfb1 - ySmk;
%sprfb2 = yLfb2 - ySmk;
%sprmk = yLmk(1:rows(yLmk)-1) - log(1+TBill(2:rows(TBill)));			% 52:II to 96:II %
%sprfb1 = yLfb1(1:rows(yLfb1)-1) - log(1+TBill(2:rows(TBill)));
%sprfb2 = yLfb2(1:rows(yLfb2)-1) - log(1+TBill(2:rows(TBill)));

% Create yield spread between 5-yr bond and 90-day bill
y5mk = dataIN(:,13);
spr5_90 = y5mk(1:rows(y5mk)-1) - log(1+TBill(2:rows(TBill)));

% -- Collect the Series: 53:I to 96:III -- %
% RealTBill = 52:II to 96:IV
% exStock   = 52:II to 96:IV 
% exBond    = 52:II to 96:IV
% DivPrice  = 53:II to 96:IV
% nomShort  = 53:II to 96:IV
%

if SysId == 1
   dataOUT = [RealTBill(5:rows(RealTBill)), exStock(5:rows(exStock)),exBond(5:rows(exBond)), DivPrice(1:rows(DivPrice)), nomShort(1:rows(nomShort))];
elseif SysId == 2
   dataOUT = [exBond(5:rows(exBond)-1), sprfb2(5:rows(sprfb2))];
   %dataOUT = [RealTBill(5:rows(RealTBill)-1), exStock(5:rows(exStock)-1), exBond(5:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), nomShort(2:rows(nomShort)-1), sprfb2(5:rows(sprfb2))];
   %dataOUT = [RealTBill(5:rows(RealTBill)), exStock(5:rows(exStock)), exBond(5:rows(exBond)), DivPrice, nomShort(2:rows(nomShort)), sprmk(5:rows(sprmk))];
   %dataOUT = [exBond, sprmk, sprfb1, sprfb2];
elseif SysId == 3
   %dataOUT = [logTBill(6:rows(logTBill)), exStock(5:rows(exStock)-1),exBond(5:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), spr5_90(5:rows(spr5_90)-0), logInf(5:rows(logInf)-1)];
   %before 6/16/00: (USE FOR GRAPHS.M)
   %dataOUT = [RealTBill(5:rows(RealTBill)-1), exStock(5:rows(exStock)-1),exBond(5:rows(exBond)-1), DivPrice(1:rows(DivPrice)-1), spr5_90(5:rows(spr5_90)-0), logTBill(6:rows(logTBill))];
   %John's new ordering as of 6/16/00 (DO NOT USE FOR GRAPHS.M)
   dataOUT = [RealTBill(5:rows(RealTBill)-1), exStock(5:rows(exStock)-1),exBond(5:rows(exBond)-1), logTBill(6:rows(logTBill)),DivPrice(1:rows(DivPrice)-1), spr5_90(5:rows(spr5_90)-0)];
   %me, 6/18:
   %dataOUT = [RealTBill(5:rows(RealTBill)-1), exStock(5:rows(exStock)-1),exBond(5:rows(exBond)-1), logTBill(6:rows(logTBill)), spr5_90(5:rows(spr5_90)-0), DivPrice(1:rows(DivPrice)-1)];
	%NOTE: IN SWITCHING AMONG THESE, DON'T FORGET TO ADJUST THE POSITION OF THE D/P ADJUSTMENT BELOW!!!!!!!!
end;



if 1		

% Re-form d/p as sampled from inferred monthly, not inferred from quarterly

load dataMTH_update.asc;
dataOUT_mo = GetDataInfMTH(dataMTH_update,SysId,5);	% for use in getting d/p ratio
								     % doesn't matter what maturity selected

dp_new = reshape([zeros(1,5) dataOUT_mo(:,4)' 0]', 12, (rows(dataOUT_mo)+6)/12)';
		%reshapes data to spill months across top, years going down
          %if rows(dataOUT_mo)+5+1 is not divis. by 12, we have made a mistake
dp_new = [dp_new(:,3) dp_new(:,6) dp_new(:,9) dp_new(:,12)];
		%selects out the appropriate columns of the data for quarter
          %beginnings, so now we have qtrs across top, years going down
dp_new = reshape(dp_new',rows(dp_new)*cols(dp_new),1);
          %reshapes into a single vector
dp_new = dp_new(2:rows(dp_new)-1);
		%eliminates observations from quarter where we don't have
          %complete quarterly data: 53Q1; 97Q3; 97Q4
dp_new(1) = dataOUT(1,5);
dataOUT(:,5) = dp_new;

%A = sortrows([randn(rows(dataOUT),1) dataOUT(:,3)],1);
%dataOUT(:,3) = A(:,2);

end

if 0
load dataMTH_update.asc;
dataOUT_mo = GetDataInfMTH(dataMTH_update,SysId,5);	% for use in getting d/p ratio
								     % doesn't matter what maturity selected

date_new = reshape([zeros(1,5) dataOUT_mo(:,6)'./1000000 0]', 12, (rows(dataOUT_mo)+6)/12)';
		%reshapes data to spill months across top, years going down
          %if rows(dataOUT_mo)+5+1 is not divis. by 12, we have made a mistake
date_new = [date_new(:,3) date_new(:,6) date_new(:,9) date_new(:,12)];
		%selects out the appropriate columns of the data for quarter
          %beginnings, so now we have qtrs across top, years going down
date_new = reshape(date_new',rows(date_new)*cols(date_new),1);
          %reshapes into a single vector
date_new = date_new(2:rows(date_new)-1);
		%eliminates observations from quarter where we don't have
          %complete quarterly data: 53Q1; 97Q3; 97Q4
dataOUT(:,5) = dp_new;

end
