function result = rieszShiftReal(realPart,x,y,phaseX,phaseY)
magnitude = hypot(phaseX,phaseY);
sincUnnormalized = ones(size(magnitude),'like',magnitude);
valid = magnitude > 0;
sincUnnormalized(valid) = sin(magnitude(valid))./magnitude(valid);
result = cos(magnitude).*realPart ...
    - sincUnnormalized.*(phaseX.*x + phaseY.*y);
end
