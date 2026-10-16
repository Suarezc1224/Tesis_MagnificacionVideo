% [N, X] = histo(MTX, NBINS_OR_BINSIZE, BIN_CENTER)
%
% Compute a uniformly spaced histogram over all elements of MTX. A positive
% NBINS_OR_BINSIZE specifies the number of bins; a negative value specifies
% the negative of the bin width. The default is 101 bins. BIN_CENTER is the
% center of one bin and defaults to the mean of MTX.

function [N, X] = histo(mtx, nbinsOrBinSize, binCenter)

if nargin < 1 || nargin > 3
  error('histo requires between one and three input arguments.');
end
if ~isa(mtx, 'double') || ~isreal(mtx) || issparse(mtx) || isempty(mtx)
  error('MTX must be a nonempty, real, full double array.');
end
if any(~isfinite(mtx(:)))
  error('MTX must contain only finite values.');
end

values = mtx(:);
mn = min(values);
mx = max(values);
if nargin < 3 || isempty(binCenter)
  origin = mean(values);
else
  origin = localScalar(binCenter, 'BIN_CENTER');
end
if nargin < 2 || isempty(nbinsOrBinSize)
  bins = 101;
else
  bins = localScalar(nbinsOrBinSize, 'NBINS_OR_BINSIZE');
end

pad = 0.49999;
if bins < 0
  binSize = -bins;
  if binSize <= 0
    error('The bin size must be greater than zero.');
  end
  origin = origin - binSize * ceil((origin - mn - pad * binSize) / binSize);
  numberOfBins = ceil((mx - origin - pad * binSize) / binSize) + 1;
else
  numberOfBins = floor(bins + 0.5);
  if numberOfBins < 1
    error('NBINS must be greater than zero.');
  end
  binSize = (mx - mn) / (numberOfBins - 1 + 2 * pad);
  if binSize == 0
    binSize = 1;
  else
    offset = ceil((origin - mn - binSize / 2) / binSize);
    if mn < origin - offset * binSize - pad * binSize
      binSize = (origin - mn) / (offset + pad);
    elseif mx > origin + (numberOfBins - 1 - offset) * binSize + pad * binSize
      binSize = (mx - origin) / ((numberOfBins - 1 - offset) + pad);
    end
  end
  origin = origin - binSize * ceil((origin - mn - pad * binSize) / binSize);
end

if numberOfBins < 1 || numberOfBins > 20000
  error('The number of histogram bins must be between 1 and 20000.');
end

X = origin + binSize * (0:numberOfBins - 1);
binNumbers = fix((values - origin) / binSize + 0.5);
inside = binNumbers >= 0 & binNumbers < numberOfBins;
N = zeros(numberOfBins, 1);
if any(inside)
  N = accumarray(binNumbers(inside) + 1, 1, [numberOfBins 1]);
end
N = N';
if any(~inside)
  warning('histo:OutOfRange', ...
      'Some values fall outside the histogram range [%g, %g].', ...
      origin - 0.5 * binSize, origin + (numberOfBins - 0.5) * binSize);
end

end

function value = localScalar(value, name)
if ~isa(value, 'double') || ~isreal(value) || issparse(value) || ...
    numel(value) ~= 1 || ~isfinite(value)
  error('%s must be a finite real double scalar.', name);
end
end
