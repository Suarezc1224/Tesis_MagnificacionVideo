% DEMORIESZVIDEO Select a video and produce a magnified copy alongside it.
% Run this script from MATLAB. No EVM/PVM paths or MEX compilation needed.
addpath(fileparts(mfilename('fullpath')));
[name,folder] = uigetfile({'*.mp4;*.avi;*.mov;*.m4v','Videos'},'Selecciona un video');
if ~isequal(name,0)
    inputFile = fullfile(folder,name);
    [~,stem] = fileparts(name);
    % EXAMPLE parameters: adjust this band to your experiment, in Hz.
    alpha = 10;
    lowHz = 0.8;
    highHz = 1.2;
    outputFile = fullfile(folder,[stem '_riesz.avi']);
    info = rieszMagnifyVideo(inputFile,outputFile,alpha,lowHz,highHz);
    disp(info);
end
