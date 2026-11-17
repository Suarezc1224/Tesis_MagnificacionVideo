function archivoSalida = preparar_video_ligero(archivoEntrada, anchoMaximo, maxFotogramas, primerFotograma, duracionSegundos)
% PREPARAR_VIDEO_LIGERO Reduce memoria para las pruebas de EVM/PVM.
% Ejecutar sin argumentos para seleccionar un video.
% Conserva fotogramas consecutivos y los FPS de reproduccion del archivo.
% Exporta MP4/H.264 para reproducir la copia fuera de MATLAB.
% Para HFR 1000 fps, introducir Fs=1000 en el algoritmo de magnificacion.
% Ejemplo: preparar_video_ligero('F:\PRIVATE\M4ROOT\CLIP\Par_400.MP4',480,500,1)
% primerFotograma permite elegir un tramo estable, despues del arranque.
% duracionSegundos limita el tramo desde primerFotograma (10 s por defecto).
% El tiempo corresponde a la reproduccion del archivo, no a captura HFR.
% Ejemplo de 5 segundos: preparar_video_ligero('video.mp4',480,Inf,1,5)

if nargin < 1 || isempty(archivoEntrada)
    [nombre, carpeta] = uigetfile({'*.mp4;*.avi;*.mov','Videos'}, 'Selecciona el video HFR original');
    if isequal(nombre, 0)
        archivoSalida = '';
        return;
    end
    archivoEntrada = fullfile(carpeta, nombre);
end
if nargin < 2 || isempty(anchoMaximo), anchoMaximo = 480; end
if nargin < 3 || isempty(maxFotogramas), maxFotogramas = Inf; end
if nargin < 4 || isempty(primerFotograma), primerFotograma = 1; end
% Modificar este valor para cambiar la duracion al ejecutar sin argumentos.
if nargin < 5 || isempty(duracionSegundos), duracionSegundos = 15; end
validateattributes(anchoMaximo, {'numeric'}, {'scalar','integer','>=',2,'finite'});
validateattributes(maxFotogramas, {'numeric'}, {'scalar','real','>=',2});
if ~isinf(maxFotogramas) && maxFotogramas ~= floor(maxFotogramas)
    error('maxFotogramas debe ser un entero o Inf.');
end
validateattributes(primerFotograma, {'numeric'}, {'scalar','integer','>=',1,'finite'});
validateattributes(duracionSegundos, {'numeric'}, {'scalar','real','positive','finite'});

lector = VideoReader(archivoEntrada);
limiteFotogramas = min(maxFotogramas, floor(duracionSegundos * lector.FrameRate));
if limiteFotogramas < 2
    error('La duracion solicitada debe permitir al menos dos fotogramas.');
end
escala = min(1, anchoMaximo / lector.Width);
alto = max(2, 2 * floor(lector.Height * escala / 2));
ancho = max(2, 2 * floor(lector.Width * escala / 2));
% La salida se guarda en Data/Audio/VideoLigero, dentro del proyecto.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
carpetaSalida = fullfile(raiz, 'Data', 'Audio', 'VideoLigero');
if ~exist(carpetaSalida, 'dir'), mkdir(carpetaSalida); end
[~, nombre] = fileparts(archivoEntrada);
archivoSalida = fullfile(carpetaSalida, [nombre, '_reducido.mp4']);
% MPEG-4 usa H.264; las dimensiones pares calculadas arriba evitan
% relleno del codificador y mejoran la compatibilidad con reproductores.
escritor = VideoWriter(archivoSalida, 'MPEG-4');
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
while hasFrame(lector) && cantidad < limiteFotogramas
    imagen = readFrame(lector);
    imagen = imresize(imagen, [alto, ancho]);
    writeVideo(escritor, imagen);
    cantidad = cantidad + 1;
end
clear cierre; % Finaliza el MP4 antes de mostrar la ruta.
if cantidad < 2
    error('El tramo seleccionado contiene menos de dos fotogramas.');
end
fprintf('\nVideo de prueba: %s\n', archivoSalida);
fprintf('%d x %d, %d fotogramas consecutivos, reproduccion %.6g fps.\n', ...
    ancho, alto, cantidad, lector.FrameRate);
fprintf('Duracion exportada: %.6g segundos (limite solicitado: %.6g s).\n', ...
    cantidad / lector.FrameRate, duracionSegundos);
fprintf('Si la captura original fue HFR 1000 fps: Fs=1000, NO %.6g.\n', lector.FrameRate);
fprintf('No se han eliminado fotogramas intermedios. Esta copia usa compresion con perdida.\n');
fprintf('Conserva el original para el analisis final.\n');
end
