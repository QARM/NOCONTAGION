function ResultOut = FisherTransform(Results , NbMarkets)
% Perform Fisher Transforma and accept/reject contagion hypothesis
for i=1:NbMarkets

    Z_Full = 0.5*log((1+Results(i) .CorrelFull)/...
                        (1-Results(i) .CorrelFull));
    Z_Turmoil = 0.5*log((1+Results(i) .CorrelTurmoil)/...
                        (1-+Results(i) .CorrelTurmoil));
    
    var_stable = (1/(Results(i) .NObsStable - 3));
    var_turmoil = (1/(Results(i) .NObsTurmoil - 3));
    var_combined = sqrt(var_stable + var_turmoil);
    
    z_stat = (Z_Turmoil - Z_Full) / var_combined;
    
    %Store the results
    Results(i) .Z_stat=z_stat;
    if (z_stat > norminv(0.95,0,1))
        Results(i) .Contagion='C';
    else
        Results(i) .Contagion='N';
    end
    
end

ResultOut = Results;
