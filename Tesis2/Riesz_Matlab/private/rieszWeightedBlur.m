function result = rieszWeightedBlur(phase,amplitude,kernel)
den = imfilter(amplitude,kernel,'symmetric','conv');
num = imfilter(phase.*amplitude,kernel,'symmetric','conv');
result = zeros(size(phase),'like',phase);
valid = den > 0;
result(valid) = num(valid)./den(valid);
end
