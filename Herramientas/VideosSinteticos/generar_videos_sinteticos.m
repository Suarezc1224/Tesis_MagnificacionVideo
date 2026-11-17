% Video sintetico: 400 x 400, 30 fps, 10 segundos, AVI sin compresion.
% La ruta de salida es independiente del directorio de trabajo.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
carpeta_salida = fullfile(raiz, 'Data');
if ~exist(carpeta_salida, 'dir'), mkdir(carpeta_salida); end
fps = 30; duracion = 10; num_frames = fps * duracion;
ancho = 400; alto = 400;
archivo_salida = fullfile(carpeta_salida, 'video_2d_malla.avi');
v = VideoWriter(archivo_salida, 'Uncompressed AVI');
v.FrameRate = fps;
open(v);
try
[X, Y] = meshgrid(1:ancho, 1:alto);
for t = 1:num_frames
    tiempo = (t - 1) / fps;
    % Deformacion espacial bidimensional de amplitud 0.20 pixeles.
    deformacion_x = 0.20 * sin(2 * pi * 2 * tiempo + X / 30);
    deformacion_y = 0.20 * cos(2 * pi * 2 * tiempo + Y / 30);
    X_mod = X + deformacion_x;
    Y_mod = Y + deformacion_y;
    espaciado = 40;
    lx = 0.5 * (1 - tanh((abs(mod(X_mod - 2 + 20, 40) - 20) - 2) / 0.8));
    ly = 0.5 * (1 - tanh((abs(mod(Y_mod - 2 + 20, 40) - 20) - 2) / 0.8));
    patron = 1 - (1 - lx) .* (1 - ly);
    frame = 0.2 * ones(alto, ancho);
    frame = 0.2 + 0.7 * patron;
    writeVideo(v, repmat(frame, [1, 1, 3]));
end
catch error_generacion
    close(v);
    rethrow(error_generacion);
end
close(v);
fprintf('Video generado: %s\n', archivo_salida);


% Video sintetico: 400 x 400, 30 fps, 10 segundos, AVI sin compresion.
% La ruta de salida es independiente del directorio de trabajo.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
carpeta_salida = fullfile(raiz, 'Data');
if ~exist(carpeta_salida, 'dir'), mkdir(carpeta_salida); end
fps = 30; duracion = 10; num_frames = fps * duracion;
ancho = 400; alto = 400;
archivo_salida = fullfile(carpeta_salida, 'video_2d_lissajous.avi');
v = VideoWriter(archivo_salida, 'Uncompressed AVI');
v.FrameRate = fps;
open(v);
try
[X, Y] = meshgrid(1:ancho, 1:alto);
x0 = ancho / 2; y0 = alto / 2;
for t = 1:num_frames
    tiempo = (t - 1) / fps;
    % Trayectoria subpixel: 2 Hz, amplitud 0.20 pixeles y desfase pi/2.
    dx = 0.20 * sin(2 * pi * 2.0 * tiempo);
    dy = 0.20 * sin(2 * pi * 2.0 * tiempo + pi/2);
    xc = x0 + dx; yc = y0 + dy;
    % Borde suave para desplazamientos subpixel continuos.
    radio = 30;
    mask = 0.5 * (1 - tanh((hypot(X - xc, Y - yc) - radio) / 0.8));
    frame = 0.5 * ones(alto, ancho);
    frame = 0.5 + 0.4 * mask;
    writeVideo(v, repmat(frame, [1, 1, 3]));
end
catch error_generacion
    close(v);
    rethrow(error_generacion);
end
close(v);
fprintf('Video generado: %s\n', archivo_salida);


% Video sintetico: 400 x 400, 30 fps, 10 segundos, AVI sin compresion.
% La ruta de salida es independiente del directorio de trabajo.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
carpeta_salida = fullfile(raiz, 'Data');
if ~exist(carpeta_salida, 'dir'), mkdir(carpeta_salida); end
fps = 30; duracion = 10; num_frames = fps * duracion;
ancho = 400; alto = 400;
archivo_salida = fullfile(carpeta_salida, 'video_sintetico_disco_ruido.avi');
v = VideoWriter(archivo_salida, 'Uncompressed AVI');
v.FrameRate = fps;
open(v);
try
[X, Y] = meshgrid(1:ancho, 1:alto);
x0 = ancho / 2; y0 = alto / 2;
[~, R] = cart2pol(X - x0, Y - y0);
freq_vibracion = 2;
radio_base = 50;
amplitud_pulsacion = 0.30;
nivel_ruido = 0.005;
% Semilla fija para reproducir el ruido en ejecuciones posteriores.
rng(0, 'twister');
for t = 1:num_frames
    tiempo = (t - 1) / fps;
    radio_actual = radio_base + amplitud_pulsacion * sin(2 * pi * freq_vibracion * tiempo);
    disco = exp(-(R / radio_actual).^2);
    ruido = nivel_ruido * randn(alto, ancho);
    frame = disco + ruido;
    frame = min(max(frame, 0), 1);
    frame_rgb = repmat(frame, [1, 1, 3]);
    writeVideo(v, frame_rgb);
end
catch error_generacion
    close(v);
    rethrow(error_generacion);
end
close(v);
fprintf('Video generado: %s\n', archivo_salida);


