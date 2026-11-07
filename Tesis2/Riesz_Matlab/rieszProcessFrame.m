function [output,state] = rieszProcessFrame(frame,state)
%RIESZPROCESSFRAME Process one new grayscale frame, preserving temporal state.
validateattributes(frame,{'single','double'},{'2d','real','finite','size',state.frameSize});
current = rieszDecompose(frame);
coefficients = current.coefficients;
for k = state.levels
    [dx,dy,amplitude] = rieszPhaseDifference( ...
        current.real{k},current.x{k},current.y{k}, ...
        state.previous.real{k},state.previous.x{k},state.previous.y{k});
    state.phaseX{k} = state.phaseX{k} + dx;
    state.phaseY{k} = state.phaseY{k} + dy;
    [fx,state.zX{k}] = rieszTemporalFilter(state.phaseX{k},state.zX{k},state.b,state.a);
    [fy,state.zY{k}] = rieszTemporalFilter(state.phaseY{k},state.zY{k},state.b,state.a);
    fx = rieszWeightedBlur(fx,amplitude,state.kernel);
    fy = rieszWeightedBlur(fy,amplitude,state.kernel);
    band = rieszShiftReal(current.real{k},current.x{k},current.y{k}, ...
        state.alpha.*fx,state.alpha.*fy);
    coefficients(pyrBandIndices(current.sizes,k)) = band(:);
end
% Unselected levels and the lowpass residual retain their current coefficients.
output = reconNewPyr(coefficients,current.sizes);
state.previous = current;
state.framesProcessed = state.framesProcessed + 1;
end
