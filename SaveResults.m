function SaveResults(results, filename)

ResultTab = struct2table(results);
writetable(ResultTab,filename); %'c:\temp\results.xls'


end