% RES = upConv(IM, FILT, EDGES, STEP, START, STOP, RES)
%
% Upsample IM and convolve it with FILT. STEP, START, and STOP use
% [row column] order. The filter origin is floor(size(FILT)/2)+1.
%
% EDGES may be 'circular', 'reflect1', 'reflect2', 'repeat', 'zero',
% 'extend', or 'dont-compute'. The default is 'reflect1'. If an initial
% result matrix RES is supplied, the convolution is added to it.

function result = upConv(im, filt, edges, step, start, stop, result)

if nargin < 2 || nargin > 7
  error('upConv requires between two and seven input arguments.');
end
if ~isa(im, 'double') || ~isreal(im) || issparse(im) || isempty(im) || ndims(im) > 2
  error('IM must be a nonempty, real, full double matrix.');
end
if ~isa(filt, 'double') || ~isreal(filt) || issparse(filt) || isempty(filt) || ndims(filt) > 2
  error('FILT must be a nonempty, real, full double matrix.');
end

if nargin < 3 || isempty(edges)
  edges = 'reflect1';
end
if ~ischar(edges) || size(edges, 1) ~= 1
  error('EDGES must be a character vector.');
end
if nargin < 4 || isempty(step)
  step = [1 1];
end
if nargin < 5 || isempty(start)
  start = [1 1];
end
step = localVector(step, 'STEP');
start = localVector(start, 'START');
if any(step < 1) || any(step ~= fix(step))
  error('STEP values must be positive integers.');
end
if any(start < 1) || any(start ~= fix(start))
  error('START values must be positive integer coordinates.');
end

if nargin < 6 || isempty(stop)
  stop = step .* (floor((start - 1) ./ step) + size(im));
else
  stop = localVector(stop, 'STOP');
end
if any(stop < start) || any(stop ~= fix(stop))
  error('STOP values must be integer coordinates no smaller than START.');
end
if any(ceil((stop + 1 - start) ./ step) ~= size(im))
  error('IM dimensions and the upsampling arguments are incompatible.');
end

if nargin < 7 || isempty(result)
  result = zeros(stop);
else
  if ~isa(result, 'double') || ~isreal(result) || issparse(result) || ndims(result) > 2
    error('RES must be a real, full double matrix.');
  end
  if any(size(result) < stop)
    error('STOP values must lie within the dimensions of RES.');
  end
end
if any(size(filt) > size(result))
  error('FILT dimensions cannot exceed RES dimensions.');
end

result = pyrConv('expand', im, filt, edges, step, start, stop, result);

end

function value = localVector(value, name)
if ~isa(value, 'double') || ~isreal(value) || issparse(value) || numel(value) ~= 2
  error('%s must be a real, full double vector with two elements.', name);
end
value = reshape(value, 1, 2);
end
