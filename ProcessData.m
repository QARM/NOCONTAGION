function [ data_output, exo_output, date_output ] = ...
    ProcessData( data_input, data_input_rates, main_idx, use_log )
% Process data and return a vector of Dates (Tx1) and a structure of 
% Vectors Y (Tx2) (Log Returns Main, Log Returns Other) 
% Vector X (Tx2) (IR Main, IT Other)
% T is the number of obeservations of the sample in consideration


%   Input data is organized as follow (in both input)
%	0. Date         9.  GERMANY     18. NETHERLANDS     27. THAILAND	
%	1. ARGENTINA    10. HONG KONG	19. PHILIPPINES     28. UK
%	2. AUSTRALIA    11. INDIA       20. RUSSIA          29. US
%	3. BELGIUM      12. INDONESIA	21. SINGAPORE       
%	4. BRAZIL       13. ITALY       22. SOUTHAFRICA			
%	5. CANADA       14. JAPAN       23. SPAIN		
%	6. CHILE        15. KOREA       24. SWEDEN	
%	7. CHINA        16. MALAYSIA	25. SWITZERLAND		
%	8. FRANCE       17. MEXICO      26. TAIWAN		


% Create an indexed structure to contains for each country a (T*4) matrix 
% 1st Column: Y1 (Log Returns Main)
% 2nd Column: Y2 (Log Retruns Another Market)
% 3rd Column: IR Main
% 4th Column: IR Another Market

n_markets = cols(data_input)-1;
n_periods = rows(data_input);
VAR_INPUT  = zeros(n_markets-1, 4, n_periods-2);
EXO_INPUT = cell(n_markets-1);

% Date Time Series
TSdates = data_input(:,1);

% Calculate  Returns
MavgMainReturns = zeros(rows(data_input)-2,n_markets);									
MainIRReturns = zeros(rows(data_input)-1,n_markets);

for j=2:cols(data_input)
    
    % Process Return using a 2 period moving avaerage & convert to annual
    % rates
    for i=3:rows(data_input)
       if (use_log==1)
           MavgMainReturns(i-2,j-1) = log((sum(data_input(i-1:i,j))/2) ...
                                        / (sum(data_input(i-2:i-1,j))/2))*252;
       else
            MavgMainReturns(i-2,j-1) = (((sum(data_input(i-1:i,j))/2) ...
                                        / (sum(data_input(i-2:i-1,j))/2))-1)*252;
       end
    end;

    % Take log returns IR
    for i=2:rows(data_input)-1
       if (use_log==1)
            MainIRReturns(i-1,j-1) = log(1+(sum(data_input_rates(i-1:i,j))/200));
       else
            MainIRReturns(i-1,j-1) = (sum(data_input_rates(i-1:i,j))/200);
       end
    end;

    %MainIRReturns(:, j-1) = log(1+ data_input_rates(:,j));
     
end

% Build VAR_INPUT
for j=1:n_markets
    %if (j ~= main_idx) 
    VAR_INPUT(j, 1, :) = MavgMainReturns(:, main_idx);
    VAR_INPUT(j, 2, :) = MavgMainReturns(:,j);
    VAR_INPUT(j, 3, :) = MainIRReturns(1:rows(MainIRReturns)-1, main_idx);
    VAR_INPUT(j, 4, :) = MainIRReturns(1:rows(MainIRReturns)-1, j);
    exoCells = cell(rows(MainIRReturns)-1,1);
    exoMatrix = zeros(1, 2);
    for z=1:(rows(MainIRReturns)-1)
            exoMatrix(1,1) = MainIRReturns(z, j);
            exoMatrix(1,2) = MainIRReturns(z, main_idx);
            exoCells{z}= exoMatrix;
    end    
    EXO_INPUT{j} = exoCells;

    %end
end


% Build the output vectors
data_output = VAR_INPUT;
date_output = TSdates(2:rows(MavgMainReturns)+1,:);
exo_output = EXO_INPUT;
end

