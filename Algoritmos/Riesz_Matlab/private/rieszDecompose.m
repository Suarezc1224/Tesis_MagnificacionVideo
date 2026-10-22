function pyramid = rieszDecompose(frame)
% Official MIT spatial pyramid plus the approximate Riesz convolution kernels.
[pyramid.coefficients, pyramid.sizes] = buildNewPyr(single(frame));
n = size(pyramid.sizes,1)-1;
pyramid.real = cell(n,1);
pyramid.x = cell(n,1);
pyramid.y = cell(n,1);
kx = [0 0 0; .5 0 -.5; 0 0 0];
ky = kx';
for k = 1:n
    band = pyrBand(pyramid.coefficients, pyramid.sizes, k);
    pyramid.real{k} = band;
    pyramid.x{k} = imfilter(band, kx, 'symmetric', 'conv');
    pyramid.y{k} = imfilter(band, ky, 'symmetric', 'conv');
end
end
