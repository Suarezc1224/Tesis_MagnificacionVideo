% RES = corrDn(IM, FILT, EDGES, STEP, START, STOP)
%
% Correlate IM with FILT and downsample the result. STEP, START, and STOP
% use [row column] order. The filter origin is floor(size(FILT)/2)+1.
%
% EDGES may be 'circular', 'reflect1', 'reflect2', 'repeat', 'zero',
% 'extend', or 'dont-compute'. The default is 'reflect1'.

function res = corrDn(im, filt, edges, step, start, stop)

if nargin < 2 || nargin > 6
  error('corrDn requires between two and six input arguments.');
end
if ~isa(im, 'double') || ~isreal(im) || issparse(im) || isempty(im) || ndims(im) > 2
  error('IM must be a nonempty, real, full double matrix.');
end
if ~isa(filt, 'double') || ~isreal(filt) || issparse(filt) || isempty(filt) || ndims(filt) > 2
  error('FILT must be a nonempty, real, full double matrix.');
end
if any(size(filt) > size(im))
  error('FILT dimensions cannot exceed IM dimensions.');
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
if nargin < 6 || isempty(stop)
  stop = size(im);
end

step = localVector(step, 'STEP');
start = localVector(start, 'START');
stop = localVector(stop, 'STOP');
if any(step < 1) || any(step ~= fix(step))
  error('STEP values must be positive integers.');
end
if any(start < 1) || any(start > size(im)) || any(start ~= fix(start))
  error('START values must be integer coordinates within IM.');
end
if any(stop < start) || any(stop > size(im)) || any(stop ~= fix(stop))
  error('STOP values must be integer coordinates between START and the size of IM.');
end

res = pyrConv('reduce', im, filt, edges, step, start, stop, []);

end

function value = localVector(value, name)
if ~isa(value, 'double') || ~isreal(value) || issparse(value) || numel(value) ~= 2
  error('%s must be a real, full double vector with two elements.', name);
end
value = reshape(value, 1, 2);
end
