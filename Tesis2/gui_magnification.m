% GUI_MAGNIFICATION Interfaz para magnificacion Euleriana de video.
% Ejecute este archivo desde MATLAB para abrir la interfaz.
%
% La interfaz integra los algoritmos de vidmag-master y Riesz_Matlab.
% Las funciones originales de EVM/Phase-Based realizan el procesamiento de
% forma bloqueante; el dialogo de progreso permanece indeterminado mientras
% se ejecuta el algoritmo. Las vistas previas se reproducen en paralelo.



function gui_magnification()
    projectRoot = fileparts(mfilename('fullpath'));
    vidmagRoot = resolveToolFolder(projectRoot, 'vidmag-master');
    rieszRoot = resolveToolFolder(projectRoot, 'Riesz_Matlab');

    % Se agregan los arboles completos para incluir Linear, PhaseBased,
    % Filters, matlabPyrTools, pyrToolsExt y las funciones Riesz.
    if isfolder(vidmagRoot)
        addpath(genpath(vidmagRoot));
    end
    if isfolder(rieszRoot)
        addpath(genpath(rieszRoot));
    end

    previewTimers = cell(1, 3);
    previewStates = cell(1, 3);
    tabData = cell(1, 3);

    fig = uifigure( ...
        'Name', 'Magnificación de Video Euleriana - Universidad de Cuenca', ...
        'Position', [100 80 1280 820], ...
        'WindowState', 'maximized', ...
        'AutoResizeChildren', 'off', ...
        'Color', [0.96 0.97 0.98], ...
        'CloseRequestFcn', @closeApplication);

    mainGrid = uigridlayout(fig, [2 1]);
    mainGrid.RowHeight = {48, '1x'};
    mainGrid.Padding = [6 6 6 6];
    mainGrid.RowSpacing = 4;

    headerPanel = uipanel(mainGrid, ...
        'BackgroundColor', [0.04 0.22 0.38], ...
        'BorderType', 'none');
    headerPanel.Layout.Row = 1;
    headerGrid = uigridlayout(headerPanel, [1 2]);
    headerGrid.ColumnWidth = {65, '1x'};
    headerGrid.Padding = [6 3 6 3];
    headerGrid.ColumnSpacing = 16;

    logoContainer = uipanel(headerGrid, ...
        'BackgroundColor', [1 1 1], ...
        'BorderType', 'line');
    logoContainer.Layout.Column = 1;
    try
        logoPath = fullfile(projectRoot, 'u_cuenca_logo.png');
        if ~isfile(logoPath)
            error('GUI:LogoMissing', 'No se encontró u_cuenca_logo.png.');
        end
        uiimage(logoContainer, ...
            'ImageSource', logoPath, ...
            'ScaleMethod', 'fit', ...
            'Position', [2 2 60 36]);
    catch
        uilabel(logoContainer, ...
            'Text', 'Logo UCuenca', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'center', ...
            'FontWeight', 'bold', ...
            'FontColor', [0.04 0.22 0.38], ...
            'Position', [2 2 60 36]);
    end

    uilabel(headerGrid, ...
        'Text', 'Universidad de Cuenca - Magnificación de Video Euleriana', ...
        'FontSize', 16, ...
        'FontWeight', 'bold', ...
        'FontColor', [1 1 1], ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'center', ...
        'WordWrap', 'on');

    tabs = uitabgroup(mainGrid);
    tabs.Layout.Row = 2;
    evmTab = uitab(tabs, 'Title', 'Eulerian Video Magnification (EVM)');
    phaseTab = uitab(tabs, 'Title', 'Phase-Based EVM');
    rieszTab = uitab(tabs, 'Title', 'Riesz Pyramid Magnification');

    tabData{1} = buildEvmTab(evmTab);
    tabData{2} = buildPhaseTab(phaseTab);
    tabData{3} = buildRieszTab(rieszTab);
    fig.SizeChangedFcn = @resizeInterface;
    resizeInterface();

    function resizeInterface(~, ~)
        narrow = fig.Position(3) < 900;
        for n = 1:numel(tabData)
            data = tabData{n};
            if isempty(data), continue; end
            params = findall(data.parameterPanel, 'Type', 'uigridlayout');
            params.Scrollable = 'on';
            if n == 1, parameterHeight = 112; else, parameterHeight = 84; end
            if narrow
                data.actionGrid.ColumnWidth = {'1x', '1x', 18, 100, '1x'};
                data.previewGrid.ColumnWidth = {'1x'};
                data.previewGrid.RowHeight = {'1x', '1x'};
                data.inputPanel.Layout.Row = 1;
                data.inputPanel.Layout.Column = 1;
                data.outputPanel.Layout.Row = 2;
                data.outputPanel.Layout.Column = 1;
                if n == 3
                    params.ColumnWidth = {90, 90, 90, 90, 90, 90};
                else
                    params.ColumnWidth = {105, 140, 92, 100, 92, 100, 100, 100};
                end
            else
                data.actionGrid.ColumnWidth = {145, 165, 18, 100, 135};
                data.previewGrid.RowHeight = {'1x'};
                data.previewGrid.ColumnWidth = {'1x', '1x'};
                data.inputPanel.Layout.Row = 1;
                data.inputPanel.Layout.Column = 1;
                data.outputPanel.Layout.Row = 1;
                data.outputPanel.Layout.Column = 2;
                if n == 3
                    params.ColumnWidth = {90, '1x', 90, '1x', 90, '1x'};
                else
                    params.ColumnWidth = {105, '1x', 92, '1x', 92, '1x', 100, '1x'};
                end
            end
            data.tabGrid.RowHeight = {30, parameterHeight, 30, '1x'};
        end
    end

    function data = buildBaseTab(tab, algorithmName, runLabel, runCallback)
        tabGrid = uigridlayout(tab, [4 1]);
        tabGrid.RowHeight = {30, 112, 30, '1x'};
        tabGrid.Padding = [6 6 6 6];
        tabGrid.RowSpacing = 4;

        fileGrid = uigridlayout(tabGrid, [1 2]);
        fileGrid.Layout.Row = 1;
        fileGrid.ColumnWidth = {150, '1x'};
        fileGrid.Padding = [0 0 0 0];
        fileGrid.ColumnSpacing = 8;
        browseButton = uibutton(fileGrid, 'push', ...
            'Text', 'Seleccionar video...', ...
            'ButtonPushedFcn', @(~, ~) selectInputVideo(algorithmName));
        browseButton.Layout.Column = 1;
        pathField = uieditfield(fileGrid, 'text', ...
            'Editable', 'off', ...
            'Placeholder', 'Seleccione un archivo MP4, AVI o MOV');
        pathField.Layout.Column = 2;

        parameterPanel = uipanel(tabGrid, ...
            'Title', 'Parámetros', ...
            'BackgroundColor', [1 1 1]);
        parameterPanel.Layout.Row = 2;

        actionGrid = uigridlayout(tabGrid, [1 5]);
        actionGrid.Layout.Row = 3;
        actionGrid.ColumnWidth = {145, 165, 18, 100, 135};
        actionGrid.Padding = [0 0 0 0];
        actionGrid.ColumnSpacing = 8;
        runButton = uibutton(actionGrid, 'push', ...
            'Text', runLabel, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.05 0.39 0.62], ...
            'FontColor', [1 1 1], ...
            'ButtonPushedFcn', runCallback);
        runButton.Layout.Column = 1;
        playButton = uibutton(actionGrid, 'push', ...
            'Text', 'Reproducir ambos videos', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @(~, ~) playPreview(algorithmIndex(algorithmName)));
        playButton.Layout.Column = 2;
        playbackLamp = uilamp(actionGrid, 'Color', [0.8 0.1 0.1]);
        playbackLamp.Layout.Column = 3;
        playbackLabel = uilabel(actionGrid, 'Text', 'En pausa');
        playbackLabel.Layout.Column = 4;

        previewGrid = uigridlayout(tabGrid, [1 2]);
        previewGrid.Layout.Row = 4;
        previewGrid.ColumnWidth = {'1x', '1x'};
        previewGrid.Padding = [0 0 0 0];
        previewGrid.ColumnSpacing = 10;

        inputPanel = uipanel(previewGrid, 'Title', 'Video de entrada');
        inputPanel.Layout.Column = 1;
        outputPanel = uipanel(previewGrid, 'Title', 'Video procesado');
        outputPanel.Layout.Column = 2;
        inputAxesGrid = uigridlayout(inputPanel, [1 1]);
        inputAxesGrid.Padding = [4 4 4 4];
        outputAxesGrid = uigridlayout(outputPanel, [1 1]);

        outputAxesGrid.Padding = [4 4 4 4];
        inputAxes = uiaxes(inputAxesGrid);
        outputAxes = uiaxes(outputAxesGrid);
        outputAxes.Layout.Row = 1;
        exportButton = uibutton(actionGrid, 'push', ...
            'Text', 'Guardar video...', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @(~, ~) exportProcessedVideo(algorithmIndex(algorithmName)));
        exportButton.Layout.Column = 5;
        inputAxes.XTick = [];
        inputAxes.YTick = [];
        outputAxes.XTick = [];
        outputAxes.YTick = [];
        inputAxes.Visible = 'off';
        outputAxes.Visible = 'off';

        data = struct('inputPath', '', 'outputPath', '', ...
            'pathField', pathField, 'playButton', playButton, ...
            'parameterPanel', parameterPanel, 'inputAxes', inputAxes, ...
            'outputAxes', outputAxes, 'exportButton', exportButton, ...
            'playbackLamp', playbackLamp, 'playbackLabel', playbackLabel, ...
            'tabGrid', tabGrid, 'actionGrid', actionGrid, 'previewGrid', previewGrid, ...
            'inputPanel', inputPanel, 'outputPanel', outputPanel);
    end

    function data = buildEvmTab(tab)
        data = buildBaseTab(tab, 'EVM', 'Ejecutar EVM', @runEvm);
        pGrid = uigridlayout(data.parameterPanel, [3 8]);
        pGrid.ColumnWidth = {105, '1x', 88, '1x', 88, '1x', 90, '1x'};
        pGrid.RowHeight = {24, 24, 24};
        pGrid.Padding = [6 4 6 4];
        pGrid.RowSpacing = 4;
        pGrid.ColumnSpacing = 5;

        data.filter = addDropDown(pGrid, 1, 2, 'Filtro', ...
            {'Ideal', 'Butterworth', 'IIR'}, 'Butterworth');
        data.alpha = addNumberField(pGrid, 1, 4, 'Alpha', 20);
        data.lambda = addNumberField(pGrid, 1, 6, 'Lambda_c', 16);
        data.chroma = addNumberField(pGrid, 1, 8, 'Croma', 0);
        data.low = addNumberField(pGrid, 2, 2, 'f_low (Hz)', 0.5);
        data.high = addNumberField(pGrid, 2, 4, 'f_high (Hz)', 2);
        data.fs = addNumberField(pGrid, 2, 6, 'F_s (Hz)', 30);
        data.r1 = addNumberField(pGrid, 2, 8, 'r1 (IIR)', 0.4);
        data.r2 = addNumberField(pGrid, 3, 2, 'r2 (IIR)', 0.05);
        data.hint = uilabel(pGrid, ...
            'Text', 'IIR: r1 debe ser mayor que r2. Ideal/Butterworth: banda y F_s.', ...
            'FontColor', [0.25 0.25 0.25]);
        data.hint.Layout.Row = 3;
        data.hint.Layout.Column = [3 8];
        data.filter.ValueChangedFcn = @updateEvmControls;
        updateEvmControls();

        function updateEvmControls(~, ~)
            isIir = strcmp(data.filter.Value, 'IIR');
            setVisible(data.low, ~isIir);
            setVisible(data.high, ~isIir);
            setVisible(data.fs, ~isIir);
            setVisible(data.r1, isIir);
            setVisible(data.r2, isIir);
        end
    end

    function data = buildPhaseTab(tab)
        data = buildBaseTab(tab, 'Phase-Based', 'Ejecutar Fase', @runPhase);
        pGrid = uigridlayout(data.parameterPanel, [2 8]);
        pGrid.ColumnWidth = {110, '1x', 92, '1x', 92, '1x', 110, '1x'};
        pGrid.RowHeight = {24, 24};
        pGrid.Padding = [6 4 6 4];
        pGrid.RowSpacing = 4;
        pGrid.ColumnSpacing = 5;

        data.filter = addDropDown(pGrid, 1, 2, 'Filtro temporal', ...
            {'FIRWindowBP', 'differenceOfButterworths', 'differenceOfIIR'}, ...
            'FIRWindowBP');
        data.alpha = addNumberField(pGrid, 1, 4, 'Alpha', 15);
        data.low = addNumberField(pGrid, 1, 6, 'f_1 (Hz)', 0.5);
        data.high = addNumberField(pGrid, 1, 8, 'f_2 (Hz)', 2);
        data.fs = addNumberField(pGrid, 2, 2, 'F_s (Hz)', 30);
        data.pyramid = addDropDown(pGrid, 2, 4, 'Escalas/pirámide', ...
            {'octave', 'halfOctave', 'smoothHalfOctave', 'quarterOctave'}, ...
            'octave');
        data.sigma = addNumberField(pGrid, 2, 6, 'Suavizado sigma', 3);
        data.orientation = addNumberField(pGrid, 2, 8, 'Orientaciones', 4);
        data.orientation.Enable = 'off';
        data.orientation.Tooltip = ...
            'El código phaseAmplify fija automáticamente cuatro orientaciones.';
    end

    function data = buildRieszTab(tab)
        data = buildBaseTab(tab, 'Riesz', 'Ejecutar Riesz', @runRiesz);
        pGrid = uigridlayout(data.parameterPanel, [2 6]);
        pGrid.ColumnWidth = {110, '1x', 110, '1x', 110, '1x'};
        pGrid.RowHeight = {24, 24};
        pGrid.Padding = [6 4 6 4];
        pGrid.ColumnSpacing = 6;
        data.alpha = addNumberField(pGrid, 1, 2, 'Alpha', 10);
        data.low = addNumberField(pGrid, 1, 4, 'f_low (Hz)', 0.8);
        data.high = addNumberField(pGrid, 1, 6, 'f_high (Hz)', 1.2);
        data.fs = addNumberField(pGrid, 2, 2, 'F_s (Hz)', 30);
        data.fs.Tooltip = ...
            'Se carga el FPS del archivo. Edite F_s si conoce la tasa de captura de los fotogramas.';
    end

    function selectInputVideo(algorithmName)
        [fileName, folderName] = uigetfile( ...
            {'*.mp4;*.avi;*.mov;*.m4v', 'Videos (*.mp4, *.avi, *.mov, *.m4v)'}, ...
            ['Seleccionar video de entrada - ' algorithmName]);
        if isequal(fileName, 0)
            return;
        end
        index = algorithmIndex(algorithmName);
        clearProcessedPreview(index);
        tabData{index}.inputPath = fullfile(folderName, fileName);
        tabData{index}.pathField.Value = tabData{index}.inputPath;
        try
            videoFps = displayFrame(tabData{index}.inputAxes, tabData{index}.inputPath, 1);
            if index == 3
                tabData{index}.fs.Value = videoFps;
            end
        catch exception
            uialert(fig, exception.message, 'No se pudo previsualizar el video');
        end
    end

    function runEvm(~, ~)
        data = tabData{1};
        try
            validateVideo(data.inputPath);
            alpha = fieldValue(data.alpha, 'Alpha');
            lambda = fieldValue(data.lambda, 'Lambda_c');
            chroma = fieldValue(data.chroma, 'Croma');
            if alpha < 0 || lambda <= 0
                error('GUI:InvalidEVMParameters', ...
                    'Alpha debe ser no negativo y Lambda_c debe ser mayor que cero.');
            end
            filterName = data.filter.Value;

            if strcmp(filterName, 'IIR')
                r1 = fieldValue(data.r1, 'r1');
                r2 = fieldValue(data.r2, 'r2');
                if ~(r1 > r2 && r2 > 0 && r1 < 1)
                    error('GUI:InvalidIIR', 'Para IIR se requiere 0 < r2 < r1 < 1.');
                end
            else
                fs = fieldValue(data.fs, 'F_s');
                lowHz = fieldValue(data.low, 'f_low');
                highHz = fieldValue(data.high, 'f_high');
                if ~(lowHz > 0 && highHz > lowHz && highHz < fs/2)
                    error('GUI:InvalidBand', ...
                        'Requiere 0 < f_low < f_high < F_s/2 (límite de Nyquist).');
                end
            end

            resultsFolder = fullfile(pwd, 'EVM_results');
            ensureResultsFolder(resultsFolder);
            [~, stem] = fileparts(data.inputPath);
            outputPath = uniqueOutputPath(resultsFolder, stem, resultTag(data, 'EVM'));
            clearProcessedPreview(1);
            tempFolder = createTemporaryOutputFolder(resultsFolder);
            progress = uiprogressdlg(fig, ...
                'Title', 'Procesando EVM', ...
                'Message', '0% - Iniciando procesamiento', ...
                'Value', 0, 'Cancelable', 'off');
            drawnow;
            try
                switch filterName
                    case 'Ideal'
                        amplify_spatial_lpyr_temporal_ideal( ...
                            data.inputPath, tempFolder, alpha, lambda, ...
                            lowHz, highHz, fs, chroma, ...
                            @(fraction, message) updateProgress(progress, fraction, message));
                        generatedName = [stem '-ideal-from-' num2str(lowHz) ...
                            '-to-' num2str(highHz) '-alpha-' num2str(alpha) ...
                            '-lambda_c-' num2str(lambda) '-chromAtn-' ...
                            num2str(chroma) '.avi'];
                    case 'Butterworth'
                        amplify_spatial_lpyr_temporal_butter( ...
                            data.inputPath, tempFolder, alpha, lambda, ...
                            lowHz, highHz, fs, chroma, ...
                            @(fraction, message) updateProgress(progress, fraction, message));
                        generatedName = [stem '-butter-from-' num2str(lowHz) ...
                            '-to-' num2str(highHz) '-alpha-' num2str(alpha) ...
                            '-lambda_c-' num2str(lambda) '-chromAtn-' ...
                            num2str(chroma) '.avi'];
                    case 'IIR'
                        amplify_spatial_lpyr_temporal_iir( ...
                            data.inputPath, tempFolder, alpha, lambda, ...
                            r1, r2, chroma, ...
                            @(fraction, message) updateProgress(progress, fraction, message));
                        generatedName = [stem '-iir-r1-' num2str(r1) ...
                            '-r2-' num2str(r2) '-alpha-' num2str(alpha) ...
                            '-lambda_c-' num2str(lambda) '-chromAtn-' ...
                            num2str(chroma) '.avi'];
                end
                generatedPath = fullfile(tempFolder, generatedName);
                moveProcessedFile(generatedPath, outputPath);
                updateProgress(progress, 1, 'Procesamiento terminado');
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
            catch exception
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
                rethrow(exception);
            end
            preparePreview(1, data.inputPath, outputPath);
            uialert(fig, ['Resultado guardado en:' newline outputPath], ...
                'EVM finalizado', 'Icon', 'success');
        catch exception
            reportFailure('Error al ejecutar EVM', exception);
        end
    end

    function runPhase(~, ~)
        data = tabData{2};
        try
            validateVideo(data.inputPath);
            alpha = fieldValue(data.alpha, 'Alpha');
            lowHz = fieldValue(data.low, 'f_1');
            highHz = fieldValue(data.high, 'f_2');
            fs = fieldValue(data.fs, 'F_s');
            sigma = fieldValue(data.sigma, 'Sigma');
            if alpha < 0
                error('GUI:InvalidAlpha', 'Alpha debe ser mayor o igual que cero.');
            end
            validateBand(lowHz, highHz, fs);
            if sigma < 0
                error('GUI:InvalidSigma', 'Sigma debe ser mayor o igual que cero.');
            end
            if fs <= 0
                error('GUI:InvalidSamplingRate', 'F_s debe ser mayor que cero.');
            end

            filterFunction = str2func(data.filter.Value);
            resultsFolder = fullfile(pwd, 'Phase_results');
            ensureResultsFolder(resultsFolder);
            [~, stem] = fileparts(data.inputPath);
            outputPath = uniqueOutputPath(resultsFolder, stem, resultTag(data, 'PVM'));
            clearProcessedPreview(2);
            tempFolder = createTemporaryOutputFolder(resultsFolder);
            progress = uiprogressdlg(fig, ...
                'Title', 'Procesando Phase-Based EVM', ...
                'Message', '0% - Preparando procesamiento', ...
                'Value', 0, 'Cancelable', 'off');
            drawnow;
            try
                generatedName = phaseAmplify(data.inputPath, alpha, ...
                    lowHz, highHz, fs, tempFolder, ...
                    'sigma', sigma, ...
                    'pyrType', data.pyramid.Value, ...
                    'temporalFilter', filterFunction, ...
                    'progressFcn', ...
                    @(fraction, message) updateProgress(progress, fraction, message));
                generatedPath = fullfile(tempFolder, generatedName);
                moveProcessedFile(generatedPath, outputPath);
                updateProgress(progress, 1, 'Procesamiento terminado');
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
            catch exception
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
                rethrow(exception);
            end
            preparePreview(2, data.inputPath, outputPath);
            uialert(fig, ['Resultado guardado en:' newline outputPath], ...
                'Phase-Based finalizado', 'Icon', 'success');
        catch exception
            reportFailure('Error al ejecutar Phase-Based EVM', exception);
        end
    end

    function runRiesz(~, ~)
        data = tabData{3};
        try
            validateVideo(data.inputPath);
            alpha = fieldValue(data.alpha, 'Alpha');
            lowHz = fieldValue(data.low, 'f_low');
            highHz = fieldValue(data.high, 'f_high');
            fs = fieldValue(data.fs, 'F_s');
            if alpha < 0
                error('GUI:InvalidAlpha', 'Alpha debe ser mayor o igual que cero.');
            end
            if fs <= 0
                error('GUI:InvalidSamplingRate', 'F_s debe ser mayor que cero.');
            end
            if ~(lowHz > 0 && highHz > lowHz && highHz < fs/2)
                error('GUI:InvalidBand', ...
                    'Requiere 0 < f_low < f_high < F_s/2. Con F_s = %g Hz, f_high debe ser menor que %g Hz.', ...
                    fs, fs/2);
            end

            resultsFolder = fullfile(pwd, 'Riesz_results');
            ensureResultsFolder(resultsFolder);
            [~, stem] = fileparts(data.inputPath);
            outputPath = uniqueOutputPath(resultsFolder, stem, resultTag(data, 'Riesz'));
            clearProcessedPreview(3);
            tempFolder = createTemporaryOutputFolder(resultsFolder);
            tempOutput = fullfile(tempFolder, 'riesz_output.avi');
            progress = uiprogressdlg(fig, ...
                'Title', 'Procesando Riesz Pyramid', ...
                'Message', '0% - Preparando procesamiento', ...
                'Value', 0, 'Cancelable', 'off');
            drawnow;
            try
                rieszMagnifyVideo(data.inputPath, tempOutput, alpha, ...
                    lowHz, highHz, 'SamplingRate', fs, 'Overwrite', true, 'Verbose', false, ...
                    'ProgressFcn', ...
                    @(fraction, message) updateProgress(progress, fraction, message));
                moveProcessedFile(tempOutput, outputPath);
                updateProgress(progress, 1, 'Procesamiento terminado');
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
            catch exception
                close(progress);
                removeTemporaryOutputFolder(tempFolder);
                rethrow(exception);
            end
            preparePreview(3, data.inputPath, outputPath);
            uialert(fig, ['Resultado guardado en:' newline outputPath], ...
                'Riesz finalizado', 'Icon', 'success');
        catch exception
            reportFailure('Error al ejecutar Riesz Pyramid', exception);
        end
    end

    function exportProcessedVideo(index)
        data = tabData{index};
        try
            if isempty(data.outputPath) || ~isfile(data.outputPath)
                error('GUI:MissingOutput', 'Primero genere un video procesado.');
            end
            [~, nombre, extension] = fileparts(data.outputPath);
            [archivo, carpeta] = uiputfile( ...
                {['*' extension], ['Video procesado (' extension ')']}, ...
                'Guardar video procesado', [nombre extension]);
            if isequal(archivo, 0), return; end
            [~, ~, extensionElegida] = fileparts(archivo);
            if isempty(extensionElegida)
                archivo = [archivo extension];
            elseif ~strcmpi(extensionElegida, extension)
                error('GUI:ExportExtension', ...
                    'Conserve la extension %s del video procesado.', extension);
            end
            destino = fullfile(carpeta, archivo);
            if strcmpi(destino, data.outputPath)
                uialert(fig, 'El video ya esta guardado en esa ubicacion.', ...
                    'Video guardado', 'Icon', 'success');
                return;
            end
            [correcto, mensaje] = copyfile(data.outputPath, destino);
            if ~correcto, error('GUI:ExportFailed', '%s', mensaje); end
            uialert(fig, ['Video guardado en:' newline destino], ...
                'Exportacion completada', 'Icon', 'success');
        catch exception
            reportFailure('Error al exportar el video', exception);
        end
    end

    function tag = resultTag(data, algorithm)
        tag = [algorithm '_alpha' num2str(data.alpha.Value, 12)];
        if strcmp(algorithm, 'EVM') && strcmp(data.filter.Value, 'IIR')
            reader = VideoReader(data.inputPath);
            tag = [tag '_r1' num2str(data.r1.Value, 12) ...
                '_r2' num2str(data.r2.Value, 12) '_fs' num2str(reader.FrameRate, 12)];
        else
            tag = [tag '_flow' num2str(data.low.Value, 12) ...
                '_fhigh' num2str(data.high.Value, 12) '_fs' num2str(data.fs.Value, 12)];
        end
        if isfield(data, 'filter'), tag = [tag '_filter' data.filter.Value]; end
        if strcmp(algorithm, 'EVM')
            tag = [tag '_lambda' num2str(data.lambda.Value, 12) ...
                '_chroma' num2str(data.chroma.Value, 12)];
        elseif strcmp(algorithm, 'PVM')
            tag = [tag '_pyr' data.pyramid.Value '_sigma' num2str(data.sigma.Value, 12) '_ori4'];
        end
    end

    function preparePreview(index, inputPath, outputPath)
        stopPreview(index);
        data = tabData{index};
        data.outputPath = outputPath;
        data.playButton.Enable = 'on';
        data.exportButton.Enable = 'on';
        tabData{index} = data;
        displayFrame(data.inputAxes, inputPath, 1);
        displayFrame(data.outputAxes, outputPath, 1);
    end

    function clearProcessedPreview(index)
        stopPreview(index);
        data = tabData{index};
        data.outputPath = '';
        data.playButton.Enable = 'off';
        data.exportButton.Enable = 'off';
        cla(data.outputAxes);
        data.outputAxes.Visible = 'off';
        tabData{index} = data;
    end

    function setPlaybackStatus(index, playing)
        if isempty(tabData{index}), return; end
        data = tabData{index};
        if playing
            data.playbackLamp.Color = [0.1 0.75 0.2];
            data.playbackLabel.Text = 'Reproduciendo';
            data.playButton.Text = 'Pausar ambos videos';
        else
            data.playbackLamp.Color = [0.8 0.1 0.1];
            data.playbackLabel.Text = 'En pausa';
            data.playButton.Text = 'Reproducir ambos videos';
        end
    end

    function playPreview(index)
        activeTimer = previewTimers{index};
        if ~isempty(activeTimer) && isvalid(activeTimer)
            if strcmp(activeTimer.Running, 'on')
                stop(activeTimer);
                setPlaybackStatus(index, false);
            else
                for j = 1:numel(previewTimers)
                    if j ~= index, stopPreview(j); end
                end
                start(activeTimer);
                setPlaybackStatus(index, true);
            end
            return;
        end
        data = tabData{index};
        if isempty(data.outputPath) || ~isfile(data.outputPath)
            uialert(fig, 'Primero procese un video para habilitar la reproducción.', ...
                'Video procesado no disponible');
            return;
        end
        stopPreview(index);
        for otherIndex = 1:numel(previewTimers)
            if otherIndex ~= index
                stopPreview(otherIndex);
            end
        end
        inputPath = data.inputPath;
        outputPath = data.outputPath;
        state = struct( ...
            'inputReader', VideoReader(inputPath), ...
            'outputReader', VideoReader(outputPath), ...
            'inputPath', inputPath, ...
            'outputPath', outputPath);
        previewStates{index} = state;
        axesIn = tabData{index}.inputAxes;
        axesOut = tabData{index}.outputAxes;
        axesIn.Visible = 'on';
        axesOut.Visible = 'on';
        try
            cla(axesIn);
            cla(axesOut);
            state.inputImage = image(axesIn, readFrame(state.inputReader));
            state.outputImage = image(axesOut, readFrame(state.outputReader));
            axis(axesIn, 'image');
            axis(axesOut, 'image');
        catch exception
            stopPreview(index);
            rethrow(exception);
        end
        previewStates{index} = state;
        frameRate = min(state.inputReader.FrameRate, state.outputReader.FrameRate);
        playbackTimer = timer( ...
            'ExecutionMode', 'fixedRate', ...
            'BusyMode', 'drop', ...
            'Period', max(0.03, 1/frameRate), ...
            'TimerFcn', @(~, ~) tickPreview(index));
        previewTimers{index} = playbackTimer;
        start(playbackTimer);
        setPlaybackStatus(index, true);
    end

    function tickPreview(index)
        if isempty(previewStates{index})
            return;
        end
        state = previewStates{index};
        if ~hasFrame(state.inputReader) || ~hasFrame(state.outputReader)
            state.inputReader = VideoReader(state.inputPath);
            state.outputReader = VideoReader(state.outputPath);
        end
        if hasFrame(state.inputReader)
            frameIn = readFrame(state.inputReader);
            set(state.inputImage, 'CData', frameIn);
        end
        if hasFrame(state.outputReader)
            frameOut = readFrame(state.outputReader);
            set(state.outputImage, 'CData', frameOut);
        end
        previewStates{index} = state;
        drawnow limitrate;
    end

    function stopPreview(index)
        playbackTimer = previewTimers{index};
        if ~isempty(playbackTimer) && isvalid(playbackTimer)
            stop(playbackTimer);
            delete(playbackTimer);
        end
        previewTimers{index} = [];
        previewStates{index} = [];
        setPlaybackStatus(index, false);
    end

    function videoFps = displayFrame(ax, videoPath, frameIndex)
        reader = VideoReader(videoPath);
        videoFps = reader.FrameRate;
        frame = read(reader, frameIndex);
        cla(ax);
        image(ax, frame);
        axis(ax, 'image');
        ax.Visible = 'on';
        ax.XTick = [];
        ax.YTick = [];
    end

    function closeApplication(~, ~)
        for timerIndex = 1:numel(previewTimers)
            stopPreview(timerIndex);
        end
        delete(fig);
    end

    function reportFailure(titleText, exception)
        details = getReport(exception, 'basic', 'hyperlinks', 'off');
        fprintf(2, '%s\n%s\n', titleText, details);
        if isvalid(fig)
            uialert(fig, details, titleText, 'Icon', 'error');
        end
    end

    function updateProgress(progress, fraction, message)
        if isvalid(progress)
            percent = round(100*min(1, max(0, fraction)));
            currentPercent = round(100*progress.Value);
            if percent ~= currentPercent || percent == 100
                progress.Value = percent/100;
                progress.Message = sprintf('%d%% - %s', percent, message);
                drawnow;
            end
        end
    end
end

function root = resolveToolFolder(projectRoot, folderName)
    candidates = { ...
        fullfile(projectRoot, folderName), ...
        fullfile(projectRoot, '..', folderName), ...
        fullfile(getenv('USERPROFILE'), 'Desktop', folderName)};
    root = candidates{1};
    for candidateIndex = 1:numel(candidates)
        if isfolder(candidates{candidateIndex})
            root = candidates{candidateIndex};
            return;
        end
    end
end

function index = algorithmIndex(algorithmName)
    switch algorithmName
        case 'EVM'
            index = 1;
        case 'Phase-Based'
            index = 2;
        case 'Riesz'
            index = 3;
        otherwise
            error('GUI:UnknownAlgorithm', 'Algoritmo no reconocido.');
    end
end

function label = addParameterLabel(parent, row, column, text)
    label = uilabel(parent, 'Text', text, ...
        'HorizontalAlignment', 'right');
    label.Layout.Row = row;
    label.Layout.Column = column - 1;
end

function field = addNumberField(parent, row, column, labelText, defaultValue)
    label = addParameterLabel(parent, row, column, labelText);
    field = uieditfield(parent, 'numeric', ...
        'Value', defaultValue, ...
        'Limits', [-Inf Inf]);
    field.Layout.Row = row;
    field.Layout.Column = column;
    field.UserData = label;
end

function field = addDropDown(parent, row, column, labelText, items, defaultValue)
    label = addParameterLabel(parent, row, column, labelText);
    field = uidropdown(parent, ...
        'Items', items, ...
        'Value', defaultValue);
    field.Layout.Row = row;
    field.Layout.Column = column;
    field.UserData = label;
end

function setVisible(field, isVisible)
    if isVisible
        visibility = 'on';
    else
        visibility = 'off';
    end
    field.Visible = visibility;
    field.UserData.Visible = visibility;
end

function value = fieldValue(field, fieldName)
    value = field.Value;
    if ~isnumeric(value) || ~isscalar(value) || isnan(value) || isinf(value)
        error('GUI:InvalidParameter', '%s debe ser un número finito.', fieldName);
    end
end

function validateVideo(videoPath)
    if isempty(videoPath) || ~isfile(videoPath)
        error('GUI:NoVideo', 'Primero seleccione un video de entrada válido.');
    end
    reader = VideoReader(videoPath);
    if reader.Duration <= 0 || reader.FrameRate <= 0
        error('GUI:InvalidVideo', 'El archivo no contiene un video válido.');
    end
end

function validateBand(lowHz, highHz, samplingRate)
    if samplingRate <= 0
        error('GUI:InvalidSamplingRate', 'F_s debe ser mayor que cero.');
    end
    if ~(lowHz > 0 && highHz > lowHz && highHz < samplingRate/2)
        error('GUI:InvalidBand', ...
            'Requiere 0 < f_1 < f_2 < F_s/2 (límite de Nyquist).');
    end
end

function ensureResultsFolder(folder)
    if ~exist(folder, 'dir')
        [created, message] = mkdir(folder);
        if ~created
            error('GUI:CreateFolder', 'No se pudo crear %s: %s', folder, message);
        end
    end
end

function tempFolder = createTemporaryOutputFolder(resultsFolder)
    tempFolder = tempname(resultsFolder);
    [created, message] = mkdir(tempFolder);
    if ~created
        error('GUI:CreateTempFolder', ...
            'No se pudo crear la carpeta temporal: %s', message);
    end
end

function removeTemporaryOutputFolder(tempFolder)
    if exist(tempFolder, 'dir')
        [removed, message] = rmdir(tempFolder, 's');
        if ~removed
            error('GUI:RemoveTempFolder', ...
                'No se pudo limpiar la carpeta temporal %s: %s', tempFolder, message);
        end
    end
end

function outputPath = uniqueOutputPath(folder, videoStem, algorithmTag)

    baseName = [videoStem '_' algorithmTag];
    outputPath = fullfile(folder, [baseName '.avi']);
    suffix = 1;
    while isfile(outputPath)
        outputPath = fullfile(folder, ...
            [baseName '_' num2str(suffix) '.avi']);
        suffix = suffix + 1;
    end
end

function moveProcessedFile(sourcePath, destinationPath)
    if ~isfile(sourcePath)
        error('GUI:MissingOutput', ...
            'El algoritmo terminó sin generar el archivo esperado: %s', sourcePath);
    end
    [moved, message] = movefile(sourcePath, destinationPath);
    if ~moved
        error('GUI:MoveOutput', 'No se pudo guardar el resultado: %s', message);
    end
end
