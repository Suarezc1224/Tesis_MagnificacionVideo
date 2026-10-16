% RES = innerProd(MTX)
%
% Compute (MTX' * MTX) efficiently (i.e., without copying the matrix)
%
% This pure-MATLAB implementation works without a compiled MEX file.

function res = innerProd(mtx)

res = mtx' * mtx;
