function info = rieszMagnifyVideo(inputFile,outputFile,alpha,lowHz,highHz,varargin)
%RIESZMAGNIFYVIDEO Read, magnify and write a video using the MIT Riesz method.
% info = rieszMagnifyVideo('input.mp4','output.avi',10,0.8,1.2)
% Options: Sigma (2), Levels ([] = all), Overwrite (false), Verbose (true).
% Output .avi uses Motion JPEG AVI; .mp4/.m4v uses MPEG-4 (even dimensions).
% Color: process NTSC/YIQ luminance only, preserve input chrominance. No audio.
p = inputParser;
addParameter(p,'Sigma',2);
addParameter(p,'Levels',[]);
addParameter(p,'Overwrite',false,@(v) islogical(v)&&isscalar(v));
addParameter(p,'Verbose',true,@(v) islogical(v)&&isscalar(v));
parse(p,varargin{:});
inputFile = char(inputFile); outputFile = char(outputFile);
assert(isfile(inputFile),'Riesz:Input','Input file does not exist: %s',inputFile);
assert(~isfile(outputFile)||p.Results.Overwrite,'Riesz:OutputExists','Output exists: %s',outputFile);
% Canonical paths also catch aliases such as input.avi versus ./input.avi.
inPath = char(java.io.File(inputFile).getCanonicalPath());
outPath = char(java.io.File(outputFile).getCanonicalPath());
assert(~strcmpi(inPath,outPath),'Riesz:SameFile','Input and output must differ.');
[folder,~,extension] = fileparts(outputFile);
assert(isempty(folder)||isfolder(folder),'Riesz:Folder','Output folder does not exist.');
reader = VideoReader(inputFile);
assert(hasFrame(reader),'Riesz:EmptyVideo','Input video contains no frames.');
first = readFrame(reader);
[luminance,chroma] = splitFrame(first);
state = rieszInitialize(luminance,reader.FrameRate,alpha,lowHz,highHz, ...
    'Sigma',p.Results.Sigma,'Levels',p.Results.Levels);
switch lower(extension)
    case '.avi'
        profile = 'Motion JPEG AVI';
    case {'.mp4','.m4v'}
        assert(all(mod(size(luminance),2)==0),'Riesz:EvenSize', ...
            'MPEG-4 requires even dimensions. Use .avi for odd dimensions.');
        profile = 'MPEG-4';
    otherwise
        error('Riesz:Extension','Output must be .avi, .mp4 or .m4v.');
end
writer = VideoWriter(outputFile,profile);
writer.FrameRate = reader.FrameRate;
writer.Quality = 95;
open(writer);
cleanup = onCleanup(@() close(writer));
timer = tic;
% Preserve frame count; first frame uses the same spatial synthesis baseline.
baseline = reconNewPyr(state.previous.coefficients,state.previous.sizes);
writeVideo(writer,mergeFrame(baseline,chroma));
count = 1;
while hasFrame(reader)
    [luminance,chroma] = splitFrame(readFrame(reader));
    [magnified,state] = rieszProcessFrame(luminance,state);
    writeVideo(writer,mergeFrame(magnified,chroma));
    count = count+1;
    if p.Results.Verbose && mod(count,100)==0
        fprintf('Riesz: %d frames processed\n',count);
    end
end
clear cleanup; % Close before returning; the callback also runs on errors.
info = struct('inputFile',inPath,'outputFile',outPath, ...
    'frames',count,'fps',reader.FrameRate,'alpha',alpha, ...
    'bandHz',[lowHz highHz],'sigma',p.Results.Sigma,'levels',state.levels, ...
    'elapsedSeconds',toc(timer),'profile',profile);
if p.Results.Verbose
    fprintf('Riesz: %d frames, %.2f s. Output: %s\n',count,info.elapsedSeconds,outPath);
end
end

function [y,chroma] = splitFrame(frame)
frame = im2single(frame);
if size(frame,3)==3
    yiq = rgb2ntsc(frame);
    y = single(yiq(:,:,1)); chroma = single(yiq(:,:,2:3));
else
    y = frame; chroma = [];
end
end

function frame = mergeFrame(y,chroma)
if isempty(chroma)
    frame = y;
else
    frame = ntsc2rgb(cat(3,y,chroma));
end
frame = im2uint8(min(max(frame,0),1));
end
