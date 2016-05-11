function [ pvalues ] = r2_significance( input_r2stats, sample_size )

K_ = rows(input_r2stats);
n_ = sample_size;
Fstats = (input_r2stats/(K_-1)) ./ ((1-input_r2stats)/(n_-K_));
pvalues = 1 - cdf('F',Fstats,K_-1,n_-K_);


end

