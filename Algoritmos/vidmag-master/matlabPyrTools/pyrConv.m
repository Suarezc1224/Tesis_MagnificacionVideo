function result = pyrConv(operation, im, filt, edges, step, start, stop, result)
% Shared pure-MATLAB implementation of the corrDn and upConv operators.

validEdges = {'circular', 'reflect1', 'reflect2', 'qreflect2', ...
              'repeat', 'zero', 'extend', 'dont-compute'};
if ~any(strcmp(edges, validEdges))
  error('Unknown edge mode "%s".', edges);
end

if strcmp(operation, 'reduce')
  if strcmp(edges, 'extend')
    result = localReduceSlow(im, filt, edges, step, start, stop);
  else
    result = localReduceFast(im, filt, edges, step, start, stop);
  end
elseif strcmp(operation, 'expand')
  if strcmp(edges, 'extend')
    result = localExpandSlow(im, filt, edges, step, start, stop, result);
  else
    result = localExpandFast(im, filt, edges, step, start, stop, result);
  end
else
  error('Unknown convolution operation "%s".', operation);
end
end

function result = localReduceFast(im, filt, edges, step, start, stop)
filterSize = size(filt);
center = floor(filterSize / 2);
rowPositions = start(1):step(1):stop(1);
columnPositions = start(2):step(2):stop(2);
rowCoordinates = (1 - center(1)):(size(im, 1) + filterSize(1) - center(1) - 1);
columnCoordinates = (1 - center(2)):(size(im, 2) + filterSize(2) - center(2) - 1);
[mappedRows, validRows] = localBoundaryIndices(rowCoordinates, size(im, 1), edges);
[mappedColumns, validColumns] = localBoundaryIndices(columnCoordinates, size(im, 2), edges);

padded = im(mappedRows, mappedColumns);
padded(~validRows, :) = 0;
padded(:, ~validColumns) = 0;
correlated = conv2(padded, rot90(filt, 2), 'valid');
result = correlated(rowPositions, columnPositions);

if strcmp(edges, 'dont-compute')
  validOutputRows = rowPositions - center(1) >= 1 & ...
      rowPositions + filterSize(1) - center(1) - 1 <= size(im, 1);
  validOutputColumns = columnPositions - center(2) >= 1 & ...
      columnPositions + filterSize(2) - center(2) - 1 <= size(im, 2);
  validOutput = bsxfun(@and, validOutputRows(:), validOutputColumns(:)');
  result(~validOutput) = 0;
end
end

function result = localExpandFast(im, filt, edges, step, start, stop, result)
filterSize = size(filt);
center = floor(filterSize / 2);
rowPositions = start(1):step(1):stop(1);
columnPositions = start(2):step(2):stop(2);
expanded = zeros(size(result));

if strcmp(edges, 'dont-compute')
  validRows = rowPositions - center(1) >= 1 & ...
      rowPositions + filterSize(1) - center(1) - 1 <= size(result, 1);
  validColumns = columnPositions - center(2) >= 1 & ...
      columnPositions + filterSize(2) - center(2) - 1 <= size(result, 2);
  validSamples = bsxfun(@and, validRows(:), validColumns(:)');
  expanded(rowPositions, columnPositions) = im .* validSamples;
else
  expanded(rowPositions, columnPositions) = im;
end

convolved = conv2(expanded, filt, 'full');
if any(strcmp(edges, {'zero', 'dont-compute'}))
  rows = center(1) + (1:size(result, 1));
  columns = center(2) + (1:size(result, 2));
  result = result + convolved(rows, columns);
else
  rowCoordinates = (1 - center(1)):(size(result, 1) + filterSize(1) - center(1) - 1);
  columnCoordinates = (1 - center(2)):(size(result, 2) + filterSize(2) - center(2) - 1);
  mappedRows = localBoundaryIndices(rowCoordinates, size(result, 1), edges);
  mappedColumns = localBoundaryIndices(columnCoordinates, size(result, 2), edges);
  linearIndices = bsxfun(@plus, mappedRows(:), ...
      (mappedColumns(:)' - 1) * size(result, 1));
  folded = accumarray(linearIndices(:), convolved(:), [numel(result), 1]);
  result = result + reshape(folded, size(result));
end
end

function [indices, valid] = localBoundaryIndices(coordinates, dimension, edges)
valid = coordinates >= 1 & coordinates <= dimension;
switch edges
  case 'circular'
    indices = mod(coordinates - 1, dimension) + 1;
  case 'repeat'
    indices = min(max(coordinates, 1), dimension);
  case 'reflect1'
    if dimension == 1
      indices = ones(size(coordinates));
    else
      period = 2 * dimension - 2;
      reflected = mod(coordinates - 1, period);
      reflected(reflected >= dimension) = period - reflected(reflected >= dimension);
      indices = reflected + 1;
    end
  case {'reflect2', 'qreflect2'}
    period = 2 * dimension;
    reflected = mod(coordinates - 1, period);
    reflected(reflected >= dimension) = period - 1 - reflected(reflected >= dimension);
    indices = reflected + 1;
  otherwise
    indices = min(max(coordinates, 1), dimension);
end
end

function result = localReduceSlow(im, filt, edges, step, start, stop)
filterSize = size(filt);
center = floor(filterSize / 2);
rowPositions = start(1):step(1):stop(1);
columnPositions = start(2):step(2):stop(2);
result = zeros(numel(rowPositions), numel(columnPositions));
for outRow = 1:numel(rowPositions)
  rowIndices = rowPositions(outRow) + (1:filterSize(1)) - center(1) - 1;
  for outColumn = 1:numel(columnPositions)
    columnIndices = columnPositions(outColumn) + (1:filterSize(2)) - center(2) - 1;
    total = 0;
    for filterRow = 1:filterSize(1)
      [mappedRows, rowWeights] = localBoundaryMap( ...
          rowIndices(filterRow), size(im, 1), edges);
      if isempty(mappedRows)
        continue;
      end
      for filterColumn = 1:filterSize(2)
        [mappedColumns, columnWeights] = localBoundaryMap( ...
            columnIndices(filterColumn), size(im, 2), edges);
        if ~isempty(mappedColumns)
          sample = rowWeights' * im(mappedRows, mappedColumns) * columnWeights;
          total = total + filt(filterRow, filterColumn) * sample;
        end
      end
    end
    result(outRow, outColumn) = total;
  end
end
end

function result = localExpandSlow(im, filt, edges, step, start, stop, result)
filterSize = size(filt);
center = floor(filterSize / 2);
rowPositions = start(1):step(1):stop(1);
columnPositions = start(2):step(2):stop(2);
for inRow = 1:numel(rowPositions)
  rowIndices = rowPositions(inRow) + (1:filterSize(1)) - center(1) - 1;
  for inColumn = 1:numel(columnPositions)
    columnIndices = columnPositions(inColumn) + (1:filterSize(2)) - center(2) - 1;
    value = im(inRow, inColumn);
    for filterRow = 1:filterSize(1)
      [mappedRows, rowWeights] = localBoundaryMap( ...
          rowIndices(filterRow), size(result, 1), edges);
      if isempty(mappedRows)
        continue;
      end
      for filterColumn = 1:filterSize(2)
        [mappedColumns, columnWeights] = localBoundaryMap( ...
            columnIndices(filterColumn), size(result, 2), edges);
        if isempty(mappedColumns)
          continue;
        end
        contribution = value * filt(filterRow, filterColumn);
        for rowTerm = 1:numel(mappedRows)
          for columnTerm = 1:numel(mappedColumns)
            result(mappedRows(rowTerm), mappedColumns(columnTerm)) = ...
                result(mappedRows(rowTerm), mappedColumns(columnTerm)) + ...
                contribution * rowWeights(rowTerm) * columnWeights(columnTerm);
          end
        end
      end
    end
  end
end
end

function [indices, weights] = localBoundaryMap(index, dimension, edges)
indices = index;
weights = 1;
if index >= 1 && index <= dimension
  return;
end

switch edges
  case 'zero'
    indices = [];
    weights = [];
  case 'dont-compute'
    indices = [];
    weights = [];
  case 'circular'
    indices = mod(index - 1, dimension) + 1;
  case 'repeat'
    indices = min(max(index, 1), dimension);
  case {'reflect1', 'extend'}
    if strcmp(edges, 'extend')
      [indices, weights] = localExtendMap(index, dimension);
    elseif dimension == 1
      indices = 1;
    else
      period = 2 * dimension - 2;
      reflected = mod(index - 1, period);
      if reflected >= dimension
        reflected = period - reflected;
      end
      indices = reflected + 1;
  end
  case {'reflect2', 'qreflect2'}
    period = 2 * dimension;
    reflected = mod(index - 1, period);
    if reflected >= dimension
      reflected = period - 1 - reflected;
    end
      indices = reflected + 1;
end
end

function [indices, weights] = localExtendMap(index, dimension)
if dimension == 1
  indices = 1;
  weights = 1;
elseif index < 1
  [indices, weights] = localExtendMap(2 - index, dimension);
  [indices, weights] = localCombineTerms([indices 1], [-weights 2 * sum(weights)]);
elseif index > dimension
  [indices, weights] = localExtendMap(2 * dimension - index, dimension);
  [indices, weights] = localCombineTerms([indices dimension], [-weights 2 * sum(weights)]);
else
  indices = index;
  weights = 1;
end
end

function [indices, weights] = localCombineTerms(indices, weights)
uniqueIndices = unique(indices);
combinedWeights = zeros(size(uniqueIndices));
for term = 1:numel(indices)
  location = find(uniqueIndices == indices(term), 1);
  combinedWeights(location) = combinedWeights(location) + weights(term);
end
keep = combinedWeights ~= 0;
indices = uniqueIndices(keep);
weights = combinedWeights(keep);
end
