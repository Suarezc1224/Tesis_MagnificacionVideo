function state = rieszInitialize(firstFrame,fps,alpha,lowHz,highHz,varargin)
%RIESZINITIALIZE Initialize the online 2014 Riesz phase magnifier.
% Frames must be finite grayscale floating-point images. Recommended range [0,1].
% alpha is ADDED phase gain: alpha=0 gives the spatial reconstruction baseline;
% ideal total displacement gain in the passband is approximately 1+alpha.
p = inputParser;
addParameter(p,'Sigma',2,@(v) isnumeric(v)&&isscalar(v)&&isfinite(v)&&v>0);
addParameter(p,'Levels',[],@(v) isempty(v)||(isnumeric(v)&&isvector(v)&&all(isfinite(v))&&all(v>=1)&&all(v==fix(v))));
parse(p,varargin{:});
validateattributes(firstFrame,{'single','double'},{'2d','real','finite','nonempty'},mfilename,'firstFrame');
validateattributes(fps,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(alpha,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(lowHz,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(highHz,{'numeric'},{'scalar','real','finite','>',lowHz,'<',fps/2});
assert(all(size(firstFrame)>=10),'Riesz:FrameSize','Minimum frame size is 10 x 10.');
assert(exist('butter','file')~=0 && exist('imfilter','file')~=0, ...
    'Riesz:Toolboxes','Image Processing Toolbox and Signal Processing Toolbox are required.');
state.previous = rieszDecompose(firstFrame);
n = numel(state.previous.real);
levels = p.Results.Levels;
if isempty(levels), levels = 1:n; end
assert(all(levels<=n),'Riesz:Levels','Levels must be between 1 and %d (excluding residual).',n);
state.levels = reshape(unique(levels),1,[]);
[state.b,state.a] = butter(1,double([lowHz highHz])/(double(fps)/2),'bandpass');
sigma = double(p.Results.Sigma);
state.kernel = fspecial('gaussian',2*ceil(3*sigma)+1,sigma);
state.alpha = single(alpha);
state.frameSize = size(firstFrame);
state.framesProcessed = 1;
state.phaseX = cell(n,1); state.phaseY = cell(n,1);
state.zX = cell(n,1); state.zY = cell(n,1);
for k = state.levels
    z = zeros(state.previous.sizes(k,:),'single');
    state.phaseX{k} = z; state.phaseY{k} = z;
    state.zX{k} = {z,z}; state.zY{k} = {z,z};
end
end
