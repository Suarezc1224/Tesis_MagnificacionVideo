function archivoSalida = preparar_video_ligero(archivoEntrada, anchoMaximo, maxFotogramas, primerFotograma)
% PREPARAR_VIDEO_LIGERO Reduce memoria para las pruebas de EVM/PVM.
% Ejecutar sin argumentos para seleccionar un video.
% Conserva fotogramas consecutivos y los FPS de reproduccion del archivo.
% Para HFR 1000 fps, introducir Fs=1000 en el algoritmo de magnificacion.
% Ejemplo: preparar_video_ligero('F:\PRIVATE\M4ROOT\CLIP\Par_400.MP4',480,500,1)
% primerFotograma permite elegir un tramo estable, despues del arranque.

if nargin < 1 || isempty(archivoEntrada)
    [nombre, carpeta] = uigetfile({'*.mp4;*.avi;*.mov','Videos'}, 'Selecciona el video HFR original');
    if isequal(nombre, 0)
        archivoSalida = '';
        return;
    end
    archivoEntrada = fullfile(carpeta, nombre);
end
if nargin < 2, anchoMaximo = 480; end
if nargin < 3, maxFotogramas = 500; end
if nargin < 4, primerFotograma = 1; end
validateattributes(anchoMaximo, {'numeric'}, {'scalar','integer','>=',2,'finite'});
validateattributes(maxFotogramas, {'numeric'}, {'scalar','integer','>=',2,'finite'});
validateattributes(primerFotograma, {'numeric'}, {'scalar','integer','>=',1,'finite'});

lector = VideoReader(archivoEntrada);
escala = min(1, anchoMaximo / lector.Width);
alto = max(2, 2 * floor(lector.Height * escala / 2));
ancho = max(2, 2 * floor(lector.Width * escala / 2));
% La salida se guarda en Data/Audio/VideoLigero, dentro del proyecto.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
carpetaSalida = fullfile(raiz, 'Data', 'Audio', 'VideoLigero');
if ~exist(carpetaSalida, 'dir'), mkdir(carpetaSalida); end
[~, nombre] = fileparts(archivoEntrada);
archivoSalida = [tempname(carpetaSalida), '_', nombre, '_ligero.avi'];
escritor = VideoWriter(archivoSalida, 'Motion JPEG AVI');
escritor.Quality = 95;
escritor.FrameRate = lector.FrameRate;

% Saltar secuencialmente evita ambiguedades al buscar por tiempo en HFR.
for k = 1:primerFotograma-1
    if ~hasFrame(lector), error('El inicio solicitado supera el video.'); end
    readFrame(lector);
end
open(escritor);
cierre = onCleanup(@() close(escritor));
cantidad = 0;
while hasFrame(lector) && cantidad < maxFotogramas
    imagen = readFrame(lector);
    imagen = imresize(imagen, [alto, ancho]);
    writeVideo(escritor, imagen);
    cantidad = cantidad + 1;
end
clear cierre; % Finaliza el AVI antes de mostrar la ruta.
if cantidad < 2
    error('El tramo seleccionado contiene menos de dos fotogramas.');
end
fprintf('\nVideo de prueba: %s\n', archivoSalida);
fprintf('%d x %d, %d fotogramas consecutivos, reproduccion %.6g fps.\n', ...
    ancho, alto, cantidad, lector.FrameRate);
fprintf('Si la captura original fue HFR 1000 fps: Fs=1000, NO %.6g.\n', lector.FrameRate);
fprintf('No se han eliminado fotogramas intermedios. Esta copia usa compresion con perdida.\n');
fprintf('Conserva el original para el analisis final.\n');
end
