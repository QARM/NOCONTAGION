function ResultOut = PCA_Analysis(stocks_ret, headers, displayGraphs)
% Perform Fisher Transforma and accept/reject contagion hypothesis

% Import data and define data

%[data,text]=xlsread('data\MSCI-PRICES-LOCAL.xlsx');
%stocks = data(1:end,2:end);
%stocks_ret = (stocks(2:end,:)-stocks(1:end-1,:))./stocks(1:end-1,:);
N = cols(stocks_ret);
T = rows(stocks_ret);
%% PCA
%Center the returns
for i = 1:N
    Cr(:,i) = (stocks_ret(:,i) - mean(stocks_ret(:,i)))/std(stocks_ret(:,i));
end
%correlation matrix

%Corre = (1/T)*Cr'*Cr;
Corre1 = corr(Cr);
% Decompose covariance matrix
[eigvec, lambda] = eig(Corre1);
% min(diag(lambda))bigger than 0, that is, covariance matrix is PD;
% Sort lambdas
sorted = flipdim(sort(diag(lambda)),1);
%select how many number of factors to explain return at least 45%
for i = 1:N;
 if sum(sorted(1:i))/sum(sorted)< 0.9; 
number = i +1;
 end
end

Mag1 = sum(sorted(1:1))/sum(sorted);    %the percentage of the first factor
Mag2 = sum(sorted(1:2))/sum(sorted);    %the percentage of the second facotr
Mag3 = sum(sorted(1:3))/sum(sorted); %the percentage of the third factor
Mag4 = sum(sorted(1:4))/sum(sorted); 
Mag5 = sum(sorted(1:5))/sum(sorted); 
Mag6 = sum(sorted(1:6))/sum(sorted); 
Mag7 = sum(sorted(1:7))/sum(sorted); 


rt = stocks_ret';
for i = 1:N
    Mu(:,i) = mean(stocks_ret(:,i))*ones(1,T);
end
pt = eigvec'*(rt - Mu');


%use three factor to explain the variability in rt
for i = 1:N
    OLS3 = LinearModel.fit(pt(1:3,:)',rt(i,:)','intercept',true);
    Gamma1(i,1) = OLS3.Coefficients.Estimate(2,1);
    Gamma2(i,1) = OLS3.Coefficients.Estimate(3,1);
    Gamma3(i,1) = OLS3.Coefficients.Estimate(4,1);
end

%ranking gamma
[SortedGM1,order1] = sort(abs(Gamma1));
[SortedGM2,order2] = sort(-Gamma2);
[SortedGM3,order3] = sort(-Gamma3);
names= headers(1,:);
A1 = names(order1(1,1));
B1 = names(order2(1,1));
C1 = names(order3(1,1));
for i = 2:N
    A = names(order1(i,1));
    A1 = [A1;A];
    B = names(order2(i,1));
    B1 = [B1;B];
    C = names(order3(i,1));
    C1 = [C1;C];
end

ResultOut = [SortedGM1, SortedGM2, SortedGM3];

if (displayGraphs)
    %Plot the first factor
    h= gca
    plot(flipdim(SortedGM1,1))
    set(gca,'XTicklabel',flipdim(order1,1));
    set(gca,'Xtick',1:29)
    xlabel('Country')
    axis([1 N 0.12 0.3])


    %Plot the second factor
    f = figure
    plot(flipdim(SortedGM2,1))
    axis([1 N -0.4 0.4])
    set(gca,'XTicklabel',flipdim(order2,1));
    set(gca,'Xtick',1:29)
    xlabel('Country')
    grid on



    f = figure
    plot(flipdim(SortedGM3,1))
    axis([1 N -0.4 0.4])
    set(gca,'XTicklabel',flipdim(order3,1));
    set(gca,'Xtick',1:29)
    xlabel('Country')
    grid on
end