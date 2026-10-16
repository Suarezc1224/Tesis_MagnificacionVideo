% [MIN, MAX] = range2(MTX)
%
% Compute the minimum and maximum values of a nonempty real matrix.

function [mn, mx] = range2(mtx)

if nargin ~= 1
  error('range2 requires exactly one input argument.');
end
if ~isa(mtx, 'double') || ~isreal(mtx) || issparse(mtx) || isempty(mtx)
  error('MTX must be a nonempty, real, full double array.');
end

mn = min(mtx(:));
mx = max(mtx(:));

end
