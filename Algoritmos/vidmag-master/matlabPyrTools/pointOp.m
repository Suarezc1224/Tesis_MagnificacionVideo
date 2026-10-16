% RES = pointOp(IM, LUT, ORIGIN, INCREMENT, WARNINGS)
%
% Apply the uniformly sampled lookup table LUT to IM using linear
% interpolation, with linear extrapolation outside the LUT domain.

function res = pointOp(im, lut, origin, increment, warnings)

if nargin < 4 || nargin > 5
  error('pointOp requires four or five input arguments.');
end
if ~isa(im, 'double') || ~isreal(im) || issparse(im)
  error('IM must be a real, full double array.');
end
if ~isa(lut, 'double') || ~isreal(lut) || issparse(lut) || ...
    isempty(lut) || (size(lut, 1) ~= 1 && size(lut, 2) ~= 1)
  error('LUT must be a nonempty, real, full double vector.');
end
origin = localScalar(origin, 'ORIGIN');
increment = localScalar(increment, 'INCREMENT');
if nargin < 5 || isempty(warnings)
  warnings = 1;
else
  warnings = localScalar(warnings, 'WARNINGS');
end

lut = lut(:);
if increment > 0 && numel(lut) < 2
  error('LUT must contain at least two values when INCREMENT is positive.');
end
if increment <= 0
  res = repmat(lut(1), size(im));
  return;
end

positions = (im(:) - origin) / increment;
left = positions < 0;
right = positions > numel(lut) - 1;
if warnings ~= 0 && any(left(:))
  warning('pointOp:ExtrapolateLeft', ...
      'Extrapolating to the left of the lookup table.');
end
if warnings ~= 0 && any(right(:))
  warning('pointOp:ExtrapolateRight', ...
      'Extrapolating to the right of the lookup table.');
end

lowerIndex = floor(positions);
lowerIndex = min(max(lowerIndex, 0), numel(lut) - 2);
fraction = positions - lowerIndex;
res = reshape(lut(lowerIndex + 1) + ...
    (lut(lowerIndex + 2) - lut(lowerIndex + 1)) .* fraction, size(im));

end

function value = localScalar(value, name)
if ~isa(value, 'double') || ~isreal(value) || issparse(value) || ...
    numel(value) ~= 1 || ~isfinite(value)
  error('%s must be a finite real double scalar.', name);
end
end
