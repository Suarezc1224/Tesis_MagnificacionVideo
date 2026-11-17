% Tres casos analiticos sin ruido para estudiar magnificacion.
% Ejecutar completo. Reemplaza los tres AVI correspondientes en Data.
raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
salida = fullfile(raiz, 'Data');
if ~exist(salida, 'dir'), mkdir(salida); end
fps = 30; duracion = 10; ancho = 400; alto = 400;
amplitud = 0.20; frecuencia = 2; suavizado = 0.8;
fondo = 0.2; contraste = 0.6; amplitud_brillo = 0.02;
[X, Y] = meshgrid(1:ancho, 1:alto);
% H aproxima el escalon; permite movimiento subpixel continuo.
H = @(z) 0.5 * (1 + tanh(z / suavizado));
nombres = {'video_barra_horizontal.avi', ...
    'video_rectangulo_vertical.avi', 'video_circulo_brillo.avi'};
for caso = 1:3
    archivo = fullfile(salida, nombres{caso});
    v = VideoWriter(archivo, 'Uncompressed AVI');
    v.FrameRate = fps;
    open(v);
    try
        for k = 1:fps*duracion
            tiempo = (k - 1) / fps;
            s = sin(2*pi*frecuencia*tiempo);
            d = amplitud * s;
            switch caso
                case 1
                    % Barra vertical de ancho 40 que se desplaza en X.
                    P = H(X - 180 - d) - H(X - 220 - d);
                    frame = fondo + contraste * P;
                case 2
                    % Rectangulo 80 x 40 que se desplaza en Y.
                    Px = H(X - 160) - H(X - 240);
                    Py = H(Y - 180 - d) - H(Y - 220 - d);
                    frame = fondo + contraste * Px .* Py;
                case 3
                    % Circulo fijo de radio 30: solo varia la intensidad.
                    P = H(30 - hypot(X - 200, Y - 200));
                    frame = fondo + (contraste + amplitud_brillo*s) * P;
            end
            writeVideo(v, repmat(frame, [1 1 3]));
        end
    catch error_video
        close(v);
        rethrow(error_video);
    end
    close(v);
    lector = VideoReader(archivo);
    cantidad = 0;
    while hasFrame(lector)
        cuadro = readFrame(lector);
        assert(isequal(size(cuadro), [alto ancho 3]));
        cantidad = cantidad + 1;
    end
    assert(cantidad == fps*duracion && lector.FrameRate == fps);
    fprintf('VERIFICADO: %s, %d cuadros\n', archivo, cantidad);
end
