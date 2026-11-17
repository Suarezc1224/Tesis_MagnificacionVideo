function resumen = prepararCASME(varargin)
% PREPARARCASME Prepara imagenes RAW de CASME II para comparar EVM y PVM.
% Ejecutar desde esta carpeta:
%   resumen = prepararCASME;
%   resumen = prepararCASME('Sujeto','sub02','Secuencia','EP01_01');
% Todas las secuencias de un sujeto (o todos los sujetos con Sujeto='*'):
%   resumen = prepararCASME('Sujeto','sub01','Secuencia','*');
% ROI fija opcional: [x y ancho alto], en pixeles, con origen MATLAB (1,1).
%   resumen = prepararCASME('ROI',[100 50 300 300],'CrearLento',true);
%
% Genera AVI RGB sin compresion a 200 fps y un MAT con trazabilidad.
% La copia lenta es SOLO para visualizar; no usarla como entrada EVM/PVM.
% No interpola, estabiliza, repite ni elimina cuadros. No sobrescribe salidas.

base = fileparts(mfilename('fullpath'));
raiz = fileparts(fileparts(base));
p = inputParser;
addParameter(p,'Entrada',fullfile(raiz,'Data',['CASME ' char(8545)], ...
    'CASME2_RAW','CASME2-RAW'),@(x)ischar(x)||isstring(x));
addParameter(p,'Salida',fullfile(base,'output'),@(x)ischar(x)||isstring(x));
addParameter(p,'Sujeto','sub01',@(x)ischar(x)||isstring(x));
addParameter(p,'Secuencia','EP02_01f',@(x)ischar(x)||isstring(x));
addParameter(p,'FPS',200,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>0);
addParameter(p,'CrearLento',true,@(x)islogical(x)&&isscalar(x));
addParameter(p,'FPSLento',25,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>0);
addParameter(p,'ROI',[],@(x)isempty(x)||(isnumeric(x)&&numel(x)==4&& ...
    all(isfinite(x))&&all(x>=1)&&all(x==fix(x))));
parse(p,varargin{:});
c = p.Results;
assert(isfolder(c.Entrada),'No existe la carpeta RAW: %s',c.Entrada);
assert(~c.CrearLento || c.FPSLento<c.FPS, ...
    'FPSLento debe ser menor que FPS.');
sujetos = buscarCarpetas(c.Entrada,c.Sujeto);
assert(~isempty(sujetos),'No hay sujetos que coincidan con "%s" en %s', ...
    c.Sujeto,c.Entrada);
filas = cell(0,8);
for s = 1:numel(sujetos)
    sujeto = sujetos(s).name;
    secuencias = buscarCarpetas(fullfile(c.Entrada,sujeto),c.Secuencia);
    for k = 1:numel(secuencias)
        nombre = secuencias(k).name;
        carpeta = fullfile(c.Entrada,sujeto,nombre);
        archivos = dir(fullfile(carpeta,'*.jpg'));
        tokens = regexp({archivos.name},'^img(\d+)\.jpg$','tokens','once');
        assert(~isempty(archivos)&&all(~cellfun(@isempty,tokens)), ...
            'Se esperaban archivos imgN.jpg en %s',carpeta);
        numeros = cellfun(@(t)str2double(t{1}),tokens);
        [numeros,orden] = sort(numeros);
        archivos = archivos(orden);
        assert(all(diff(numeros)==1), ...
            'Cuadros duplicados o faltantes en %s. No se modifica el tiempo.',carpeta);
        destino = fullfile(c.Salida,sujeto,nombre);
        if ~isfolder(destino), mkdir(destino); end
        analisis = fullfile(destino,[nombre '_analisis.avi']);
        lento = fullfile(destino,[nombre '_visualizacion_lenta.avi']);
        mat = fullfile(destino,[nombre '_metadata.mat']);
        assert(~isfile(analisis)&&~isfile(mat)&& ...
            (~c.CrearLento||~isfile(lento)), ...
            'Ya existen salidas en %s. Elija otra carpeta Salida.',destino);
        primero = leerCuadro(fullfile(carpeta,archivos(1).name),c.ROI);
        dimensiones = size(primero);
        escritor = VideoWriter(analisis,'Uncompressed AVI');
        escritor.FrameRate = c.FPS;
        escritorLento = [];
        try
            open(escritor);
            if c.CrearLento
                escritorLento = VideoWriter(lento,'Uncompressed AVI');
                escritorLento.FrameRate = c.FPSLento;
                open(escritorLento);
            end
            for j = 1:numel(archivos)
                cuadro = leerCuadro(fullfile(carpeta,archivos(j).name),c.ROI);
                assert(isequal(size(cuadro),dimensiones), ...
                    'Dimensiones inconsistentes: %s',archivos(j).name);
                writeVideo(escritor,cuadro);
                if c.CrearLento, writeVideo(escritorLento,cuadro); end
            end
            close(escritor);
            if c.CrearLento, close(escritorLento); end
        catch err
            try, close(escritor); catch, end
            if ~isempty(escritorLento)
                try, close(escritorLento); catch, end
            end
            % Quitar solamente archivos parciales creados por esta ejecucion.
            if isfile(analisis), delete(analisis); end
            if c.CrearLento && isfile(lento), delete(lento); end
            rethrow(err);
        end
        metadata = struct('sujeto',sujeto,'secuencia',nombre, ...
            'origen',carpeta,'archivos',{ {archivos.name} }, ...
            'indicesOriginales',numeros,'fpsCaptura',c.FPS, ...
            'tiempoRelativoSegundos',(0:numel(archivos)-1)/c.FPS, ...
            'roi',c.ROI,'dimensiones',dimensiones,'videoAnalisis',analisis);
        % Para una anotacion original A: indice de salida = A-numeros(1)+1.
        metadata.indiceSalida = 'indiceOriginal - indicesOriginales(1) + 1';
        if c.CrearLento
            metadata.videoLento = lento;
            metadata.fpsVisualizacion = c.FPSLento;
        end
        save(mat,'metadata');
        filas(end+1,:) = {sujeto,nombre,numel(archivos),c.FPS, ...
            numel(archivos)/c.FPS,dimensiones(2),dimensiones(1),analisis}; %#ok<AGROW>
        fprintf('%s/%s: %d cuadros, %.3f s a %g fps.\n', ...
            sujeto,nombre,numel(archivos),numel(archivos)/c.FPS,c.FPS);
    end
end
assert(~isempty(filas), ...
    'No hay secuencias "%s" en los sujetos "%s" de %s', ...
    c.Secuencia,c.Sujeto,c.Entrada);
resumen = cell2table(filas,'VariableNames',{'Sujeto','Secuencia','Cuadros', ...
    'FPS','DuracionVideo_s','Ancho','Alto','VideoAnalisis'});
disp(resumen);
fprintf('Use los AVI *_analisis.avi para ambos metodos con Fs = %g Hz.\n',c.FPS);
end

function carpetas = buscarCarpetas(padre,patron)
% dir(rutaExacta) lista el CONTENIDO, no la carpeta solicitada.
% Enumerar siempre el padre y filtrar sus nombres funciona tanto con
% nombres exactos como con patrones, por ejemplo sub01 o sub*.
carpetas = dir(padre);
carpetas = carpetas([carpetas.isdir] & ...
    ~ismember({carpetas.name},{'.','..'}));
expresion = ['^' regexptranslate('wildcard',char(patron)) '$'];
coincide = ~cellfun(@isempty,regexp({carpetas.name},expresion,'once'));
carpetas = carpetas(coincide);
end

function cuadro = leerCuadro(ruta,roi)
cuadro = imread(ruta);
assert(isa(cuadro,'uint8'),'Se esperaba una imagen JPEG uint8: %s',ruta);
if size(cuadro,3)==1, cuadro = repmat(cuadro,1,1,3); end
if ~isempty(roi)
    x = roi(1); y = roi(2); ancho = roi(3); alto = roi(4);
    assert(x+ancho-1<=size(cuadro,2)&&y+alto-1<=size(cuadro,1), ...
        'La ROI excede las dimensiones de %s',ruta);
    cuadro = cuadro(y:y+alto-1,x:x+ancho-1,:);
end
end
