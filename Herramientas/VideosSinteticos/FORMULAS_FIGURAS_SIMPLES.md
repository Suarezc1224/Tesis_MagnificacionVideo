# Figuras simples para desarrollo manual

Ejecutar generar_videos_figuras_simples.m. Genera tres videos independientes
en Data, sin ruido: 400 x 400, 30 fps, 10 s, AVI sin compresion.
Los tres canales RGB contienen la misma intensidad.

Coordenadas x,y = 1,...,400; t = (k-1)/30 segundos, k = 1,...,300.
Definir s(t) = sin(4*pi*t), d(t) = 0.20*s(t) pixeles,
H(z) = [1+tanh(z/0.8)]/2, fondo B = 0.2 y contraste C = 0.6.
H es un escalon suave: evita saltos de un pixel de las mascaras binarias.
Las ecuaciones describen intensidades antes de cuantizar a 8 bits al escribir AVI.

## 1. Barra vertical que se desplaza horizontalmente

P(x) = H(x-180) - H(x-220).

I(x,y,t) = B + C*P(x-d(t)).

Para amplitud pequena, Taylor alrededor de d=0:

I(x,y,t) aproximadamente I0(x) - C*d(t)*P'(x).

H'(z) = sech(z/0.8)^2 / 1.6.

Es el caso mas sencillo para estudiar magnificacion de movimiento:
solo requiere una variable espacial y una derivada.

## 2. Rectangulo que se desplaza verticalmente

Px(x) = H(x-160) - H(x-240).
Py(y) = H(y-180) - H(y-220).

I(x,y,t) = B + C*Px(x)*Py(y-d(t)).

I aproximadamente I0(x,y) - C*d(t)*Px(x)*Py'(y).

Permite pasar a dos dimensiones conservando separacion de variables.

## 3. Circulo fijo con variacion de brillo

r(x,y) = sqrt((x-200)^2 + (y-200)^2).
P(x,y) = H(30-r(x,y)).

I(x,y,t) = B + [C + 0.02*s(t)]*P(x,y).

La componente temporal es exactamente 0.02*s(t)*P(x,y);
no hay movimiento geometrico ni se necesita Taylor.
Sirve para estudiar magnificacion de intensidad y distinguirla del movimiento.

## Modelo ideal de magnificacion temporal

Si un filtro ideal conserva la componente a 2 Hz y el algoritmo suma
alpha veces esa componente a la imagen original, la variacion resultante
se multiplica por (1+alpha). Para movimiento esta interpretacion utiliza
la aproximacion de Taylor y requiere desplazamientos amplificados pequenos
respecto a la escala espacial de los bordes. No garantiza el resultado
de cualquier algoritmo, filtro o nivel de piramide.

Orden sugerido para el calculo manual: circulo (intensidad), barra
(traslacion 1D), rectangulo (traslacion separable 2D).
