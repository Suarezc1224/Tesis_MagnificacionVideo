function results = runRieszTests(outputDirectory)
%RUNRIESZTESTS Numerical checks and a real VideoReader/VideoWriter round trip.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
if nargin<1, outputDirectory = fullfile(root,'tests','output'); end
if ~isfolder(outputDirectory), mkdir(outputDirectory); end
rng(7);
fps = 30; frequency = 2; alpha = 3;
[xx,yy] = meshgrid(single(0:95),single(0:63));
carrier = 2*pi/8;
first = single(.5+.2*cos(carrier*xx));
base = rieszInitialize(first,fps,0,1.5,2.5);
[reconstructed,~] = rieszProcessFrame(first,base);
interior = {10:55,10:87};
errorImage = reconstructed(interior{:})-first(interior{:});
results.reconstructionRMSE = sqrt(mean(errorImage(:).^2));
assert(results.reconstructionRMSE<0.01,'Spatial reconstruction error too large.');

% Black/flat regions and a static frame must stay finite at nonzero gain.
black = zeros(35,47,'single');
state = rieszInitialize(black,fps,20,1,3);
for t=1:5
    [out,state] = rieszProcessFrame(black,state);
    assert(all(isfinite(out(:))) && all(out(:)==0),'Black-frame instability.');
end
state = rieszInitialize(first,fps,20,1,3);
for t=1:10
    [out,state] = rieszProcessFrame(first,state);
    assert(max(abs(out(:)-reconstructed(:)))<1e-5,'Static input changed with gain.');
end

% Check actual displacement gain on a moving plane wave, in both directions.
gains = zeros(1,2);
for axis = 1:2
    coordinate = xx;
    if axis==2, coordinate = yy; end
    state = rieszInitialize(single(.5+.2*cos(carrier*coordinate)),fps,alpha,1.5,2.5);
    n = 240; measured = zeros(n,1);
    roi = {17:48,17:80}; % integer number of carrier periods in each direction
    projection = exp(-1i*double(carrier*coordinate(roi{:})));
    for t=1:n
        shift = .03*sin(2*pi*frequency*t/fps);
        frame = single(.5+.2*cos(carrier*(coordinate-shift)));
        [out,state] = rieszProcessFrame(frame,state);
        patch = double(out(roi{:}));
        coefficient = sum(patch(:).*projection(:));
        measured(t) = angle(coefficient);
    end
    keep = (121:n)';
    design = [sin(2*pi*frequency*keep/fps),cos(2*pi*frequency*keep/fps),ones(size(keep))];
    fit = design\unwrap(measured(keep));
    gains(axis) = hypot(fit(1),fit(2))/(double(carrier)*.03);
    h = freqz(state.b,state.a,[2*pi*frequency/fps,2*pi*frequency/fps]);
    expectedGain = abs(1+alpha*h(1));
    % The three-tap Riesz transform and spatial reconstruction are approximate;
    % displacement gain need not equal the ideal phase-filter gain exactly.
    assert(abs(gains(axis)-expectedGain)<.15*expectedGain && gains(axis)>2, ...
        'Motion gain on axis %d: measured %.3f, expected %.3f.',axis,gains(axis),expectedGain);
end
results.motionGainXY = gains;
results.expectedGain = expectedGain;
results.relativeGainTolerance = .15;

% Deliberately odd dimensions, RGB chrominance, and independent video outputs.
input = fullfile(outputDirectory,'synthetic_input.avi');
output = fullfile(outputDirectory,'synthetic_riesz.avi');
writer = VideoWriter(input,'Motion JPEG AVI'); writer.FrameRate = fps;
open(writer);
for t=0:39
    [vx,vy] = meshgrid(single(0:66),single(0:48));
    image = .5+.15*cos(2*pi/8*(vx-.05*sin(2*pi*frequency*t/fps)));
    writeVideo(writer,im2uint8(cat(3,image,.8*image,.6*image+.02*sin(vy))));
end
close(writer);
info = rieszMagnifyVideo(input,output,alpha,1.5,2.5,'Overwrite',true,'Verbose',false);
reader = VideoReader(output); count = 0;
while hasFrame(reader)
    image = readFrame(reader); count = count+1;
    assert(isequal(size(image),[49 67 3]),'Unexpected decoded frame dimensions.');
end
assert(count==40 && info.frames==40 && abs(reader.FrameRate-fps)<1e-6, ...
    'Video frame count or frame rate mismatch.');
mustFail(@()rieszMagnifyVideo(input,output,alpha,1.5,2.5),'Riesz:OutputExists');
mustFail(@()rieszMagnifyVideo(input,input,alpha,1.5,2.5,'Overwrite',true),'Riesz:SameFile');
mustFail(@()rieszMagnifyVideo(input,fullfile(outputDirectory,'odd.mp4'),alpha,1.5,2.5), ...
    'Riesz:EvenSize');
mustFail(@()rieszInitialize(first,fps,alpha,1,16),'');
mustFail(@()rieszInitialize(first,fps,alpha,1,3,'Levels',999),'Riesz:Levels');
selected = rieszInitialize(first,fps,alpha,1,3,'Levels',[1;2]);
[selectedOutput,~] = rieszProcessFrame(first,selected);
assert(all(isfinite(selectedOutput(:))),'Column-vector level selection failed.');
% Exercise MPEG-4 encoding separately on even dimensions.
evenInput = fullfile(outputDirectory,'even_input.avi');
mp4Output = fullfile(outputDirectory,'synthetic_riesz.mp4');
writer = VideoWriter(evenInput,'Motion JPEG AVI'); writer.FrameRate = fps;
open(writer);
for t=1:12, writeVideo(writer,im2uint8(first(1:48,1:64))); end
close(writer);
mp4Info = rieszMagnifyVideo(evenInput,mp4Output,alpha,1.5,2.5,'Overwrite',true,'Verbose',false);
reader = VideoReader(mp4Output); mp4Count = 0;
while hasFrame(reader)
    image = readFrame(reader); mp4Count = mp4Count+1;
    assert(size(image,1)==48 && size(image,2)==64,'MPEG-4 dimensions changed.');
end
assert(mp4Count==12 && mp4Info.frames==12,'MPEG-4 frame count mismatch.');
results.mp4Frames = mp4Count;
results.videoFrames = count;
results.matlab = version;
results.testedAt = char(datetime('now','TimeZone','America/Guayaquil'));
results.status = 'PASS';
save(fullfile(outputDirectory,'test_results.mat'),'results');
fid = fopen(fullfile(outputDirectory,'test_results.json'),'w');
fprintf(fid,'%s\n',jsonencode(results)); fclose(fid);
disp(results);
fprintf('All Riesz tests passed.\n');
end

function mustFail(action,identifier)
failed = false;
try
    action();
catch exception
    failed = true;
    if ~isempty(identifier), assert(strcmp(exception.identifier,identifier)); end
end
assert(failed,'Expected validation failure did not occur.');
end
