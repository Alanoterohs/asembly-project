/*
* @Author: Juana, Balduini
* @Author: Alan, Otero
*/

// EN README2.md SE ENCUENTRA LA EXPLICACIÓN SOLICITADA DE 2 LINEAS

.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,    32
.equ REST_BITS,         15    // cambia color cada cinco filas
.equ MAR,        100
//---Colores--//
colorCielo: .word 0x000000
colorMar: .word 0x004C99
colorPlataforma: .word 0x261F2C
colorRectangulo: .word 0x001933
colorVentana: .word 0xFFF779
colormarcoDer: .word 0x16254D
colorBarrotes: .word 0x000000
colorLineaVertical: .word 0x646E8A
colorTrianguloBarco: .word 0xFFFFFF
colorLineaVertical2: .word 0x000000
colorTrianguloIzq2: .word 0x660000
.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	//mov x20, x0	// Save framebuffer base address to x20
  mov x20, x0
  mov x21, x0
  mov x22, x0
  mov x9, SCREEN_WIDTH


  b cielo
//------------CIELO------------//
/*
*  Pinto cielo
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x3 - Variable que se usará como condicional para realizar degrades(de negro a azul) si x3 == REST_BITS entonce salto a deg
*
*/

cielo:
  ldr w10,colorCielo
  mov x3, 0
  mov x2,SCREEN_HEIGH    // Y Size
cielo1:
  mov x1,SCREEN_WIDTH    // X Size
cielo0:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1            // decrement X counter
  cbnz x1,cielo0          // If not end row jump
  sub x2,x2,1            // Decrement Y counter
  add x3, x3, 1
  cmp x2, MAR
  b.eq mar
  cmp x3, REST_BITS      // compara x3 con la fila 5
  b.eq deg               // si x3 == REST_BITS entonce salto a deg
end_deg:
  cbnz x2,cielo1          // if not last row, jump
deg:
  add x10, x10,4
  sub x3, x3, REST_BITS
  b end_deg

//------------MAR------------//
/**
   *  Pinto mar
   * @param x1 - Tamaño de X
   * @param x2 - Tamaño de Y, compara la x2 con la fila 100
   *
*/
mar:
  ldr w10,colorMar
  mov x2, MAR         // Y Size 480
mar1:
  mov x1, SCREEN_WIDTH         // X Size 640 aqui restaura el eje X
mar0:
  stur w10,[x0]      // Set color of pixel Nz
  add x0,x0,4        // Next pixel
  sub x1,x1,1        // decremento el eje X {640}
  cbnz x1,mar0      // si x1 == 0 no salto a loop0
  sub x2,x2,1        // decremento el eje Y {480}
  cmp x2, MAR       // compara la x2 con la fila 100
  b.eq mar0         // si x2 == plataforma entonces salto a loop2 // aqui cambiamos a color amarillo
  cbnz x2,mar1      // si x2 == 0 no salto a loop1
  b plataforma

//------------PLATAFORMA------------//
/**
*  Pinto plataforma debajo de torre
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x3 - Seteo ancho(columna 400) donde comienzo a pintar
* @param x4 - Seteo alto(fila 360) donde comienzo a pintar
* @param x5 - x5 = (x+(y*640))
* @param x9 - = 640
* @param x20 - direc.base.frame
* @constant
* add x0,x20,x5 --> direc.base.frame + 4*(x+(y*640))
*
*/
plataforma:
  ldr w10,colorPlataforma
  mov x3, 0x190  // Ancho --> 400  --> 640
  mov x4, 0x168  // Altura --> 360 --> 480
  mov x2, 200 //300
pixel:
  mov x0,x20
  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x20,x5
  mov x1, 240

plataforma4:
  stur w10,[x0]
  add x0,x0,4  //next pixel
  sub x1,x1,1
  cbnz x1,plataforma4
  sub x2,x2,1
  add x4,x4,1 //aumento mi'y' para calcular la base de la linea de abajo
  cbnz x2, pixel
//------------TORRE------------//

/**
 *  Pinto el rectangulo de la torre
 *
 * @param x1 - Tamaño de X
 * @param x2 - Tamaño de Y
 * @param x3 - Seteo ancho(column 448) donde comienzo a pintar
 * @param x4 - Seteo alto(row 162) donde comienzo a pintar
 * @param x5 - x5 = (x+(y*640))
 * @param x20 - direc.base.frame
 * @constant
 * add x0,x20,x5 --> direc.base.frame + 4*(x+(y*640))
 *
 */
rectangulo:
  ldr w10, colorRectangulo
  mov x3, 0x1C0    // Ancho --> 448  --> 640
  mov x4, 0xA2     // Altura --> 162 --> 480
  mov x2, 200
pixel1:
  mov x0,x20
  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x20,x5
  mov x20, x0

rectangulo1:
  mov x1, 60
rectangulo0:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1
  cbnz x1, rectangulo0
  sub x2, x2, 1
  add x0, x0, 2320
  cbnz x2, rectangulo1
  b techoBajo

//---------------------------Techito debajo de faro :D ---------------------//
techoBajo:
  b trianguloIzq
//-------------------------------Triangulito izq :D----------------------//
/**
 *  Pinto el triángulo izquierdo
 *
 * @param x1 - Tamaño de X
 * @param x2 - Tamaño de Y
 * @param x5 - Lo uso para centrar torre(=80)
 * @param x13 - Contador --> 20, 19, 18... 0. Esto para que pinte de manera escalonada, para generar triángulo
 * @param x15 - Contador. Me sirve para correr el frame de manera que quede "escalonado"(para generar el triángulo)
 *
 */
trianguloIzq:
  mov x2, 20        // Y Size
  mov x1, 20        // X Size
  mov x13, x1       //  Primeras 20 columns, luego 19, 18, Tipo contador.
  mov x15, 0

  mov x5, 80
  sub x20,x20,x5    //  Para centrarme a la columna de la TORRE :D
  mov x0, x20

triangulo1Izq:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1            // decrement X counter
  cbnz x1,triangulo1Izq          // If not end row jump
  sub x2,x2,1
  add x15, x15, 4
  add x0, x0, x15
  add x0, x0, 2480
  sub x13, x13, 1
  mov x1, x13
  cbnz x2,triangulo1Izq
  b rect
//------------PARTE ABAJO DEL TECHO------------//
/**
*  Pinto un rectangulo entre dos triángulos
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
*
*/
rect:
  mov x0, x20
  add x0, x0, 80
  mov x3, 40
  mov x2, 20         // Y Size
rec1:
  mov x1, 60         // X Size
rec0:
  stur w10,[x0]      // Set color of pixel N
  add x0,x0,4          // Next pixel
  sub x1,x1,1          // decrement X counter
  cbnz x1, rec0
  add x0, x0, 2320
  sub x2, x2, 1
  cbnz x2, rec1
  b trianguloDer
//------------TRIANGULO DERECHO------------//
/**
*  Pinto el triángulo derecho
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x5 - Lo uso para centrar torre(=80)
* @param x13 - Contador --> 20, 19, 18... 0. Esto para que pinte de manera escalonada, para generar triángulo
* @param x15 - Contador. Me sirve para correr el frame de manera que quede "escalonado"(para generar el triángulo)
*
*/
trianguloDer:
  mov x0, x20
  add x0, x0, 320
  mov x2, 20      // Y Size
  mov x1, 20     // X Size
  mov x13, 20    //80
  mov x15, 0
triangulo1Der:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1            // decrement X counter
  cbnz x1,triangulo1Der          // If not end row jump
  sub x2,x2,1
  add x0, x0, 2480
  sub x13, x13, 1
  mov x1, x13
  add x0, x0, x15
  add x15, x15, 4
  cbnz x2,triangulo1Der
  b ventana

//------------VENTANA------------//
 /**
 *  Pinto el faro de color amarillo
 *
 * @param x1 - Tamaño de X
 * @param x2 - Tamaño de Y
 * @param x3 - Seteo ancho(columna 448) donde comienzo a pintar
 * @param x4 - Seteo alto(fila 100) donde comienzo a pintar
 * @param x5 - x5 = (x+(y*640))
 * @param x9 - = 640
 * @param x20 - direc.base.frame
 * @constant
 * add x0,x20,x5 --> direc.base.frame + 4*(x+(y*640))
 *
 */
ventana:
  ldr w10,colorVentana
  mov x0,x21 //guardo en x0 la direccion base del frame

  mov x3, 0x1C0  // Ancho --> 400  --> 640
  mov x4, 0x64  // Altura --> 360 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  mov x1, 240
  mov x2, 60         // Y Size
yellow1:
  mov x1, 50     // X Size
yellow0:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, yellow0	   // If not end row jump
  add x0, x0, 2360
  sub x2, x2, 1
  cbnz x2, yellow1

/*
*  Pinto el marco de arriba
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x3 - Uso ancho anterior
* @param x4 - Uso alto anterior
* @param x5 - x5 = (x+(y*640))
* @param x9 - = 640
* @param x20 - direc.base.frame
* @constant
* add x0,x20,x5 --> direc.base.frame + 4*(x+(y*640))
*
*/
marcoArriba:
  ldr w10,colormarcoDer
  mov x0,x21 //guardo en x0 la direccion base del frame
  mov x2, 200

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  mov x2, 10         // Y Size
marco1:
  mov x1, 60     // X Size
marco2:
  stur w10,[x0]	   // Set color of pixel N
  add x0, x0, 4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, marco2	   // If not end row jump
  add x0, x0, 2320
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, marco1	   // if not last row, jump

/**
*  Pinto dos lineas verticales que unen con el marco de arriba y abajo, formando un cuadrado "vacío"
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
*
*/
marcoVertical:
  mov x2, 42         // Y Size
  b loop3
setx11:
  mov x1, 10
setx10:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1,x1,1	   // decrement X counter
  cbnz x1, setx10
  b setY
loop3:
  mov x1, 10         // X Size
loop2:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1,x1,1	   // decrement X counter
  cbnz x1,loop2	   // If not end row jump
  add x0, x0, 160
  b setx11
setY:
  add x0, x0, 2320
  sub x2,x2,1	   // Decrement Y counter
  cbnz x2,loop3	   // if not last row, jump
/**
*  Pinto el marco de abajo
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
*
*/
cuadroDown:
  mov x2, 10         // Y Size
loop6:
  mov x1, 60     // X Size
loop5:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, loop5	   // If not end row jump
  add x0, x0, 2320
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, loop6	   // if not last row, jump
  b barrotes
//------------BARROTES------------//
 /**
 *  Pinto barrotes
 *
 * @param x1 - Tamaño de X
 * @param x2 - Tamaño de Y
 * @param x3 - uso ancho pasado
 * @param x4 - uso alto pasado
 * @param x5 - x5 = (x+(y*640))
 * @param x7 - Sirve como contador, con esto hago que se dibujen 'n' rejas/barrotes, en este caso 4
 * @param x9 - = 640
 * @param x21 - direc.base.frame
 *
 */
barrotes:
  ldr w10,colorBarrotes
  mov x0,x21 //guardo en x0 la direccion base del frame
  add x0, x0, 40

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  mov x2, 60         // Y Size 60
  mov x7, 4
  b barrotes1
movPixels:
  mov x7, 4
  add x0, x0, 2352
  sub x2, x2, 1
  cbz x2, lineaVertical
  b barrotes1
barrotes1:
  mov x1, 2     // X Size
barrotes0:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, barrotes0	   // If not end row jump
  add x0, x0, 44
  sub x7, x7, 1
  cbnz x7, barrotes1
  b movPixels

//------------TRIANGULO/TECHO------------//
/**
 *  Pinto linea vertical, muy cortita
 *
 * @param x1 - Tamaño de X
 * @param x2 - Tamaño de Y
 * @param x3 - Seteo ancho(columna 478) donde comienzo a pintar
 * @param x4 - Seteo alto(fila 54) donde comienzo a pintar
 * @param x5 - x5 = (x+(y*640))
 * @param x9 - = 640
 * @param x21 - direc.base.frame
 *
 */
lineaVertical:
  ldr w10,colorLineaVertical
  mov x0, x21
  mov x3, 0x1DE  // Ancho --> 448  --> 640
  mov x4, 0x36  // Altura --> 50 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  mov x2, 15         // Y Size
linea3:
  mov x1, 2
linea2:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, linea2	   // If not end row jump
  add x0, x0, 2552
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, linea3	   // if not last row, jump
  b triangle

triangle:
  mov x1, 1     // X Size
  mov x2, 0         // Y Size
  mov x13, 60
  mov x14, 1
  mov x25, 1
  bl techo1
addx14:
  add x14, x14, 2
  mov x1, x14
  bl techo1
techo1:
  mov x1, x1
techo0:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, techo0	   // If not end row jump
  cmp x13, x14
  b.lt trianguloBarco
  lsl x25, x14, 2         // mult = x14 * 4 /-----/ 1) 1*4=4 /-----/ 2) 3*4 = 12 /-----/ 3) 3*4 = 12
  add x0, x0, 2556
  sub x0, x0, x25
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, addx14	   // if not last row, jump
  b trianguloBarco

//------------BARCO------------//
/**
*  Dibuja un triángulo
*
* @param x1 - Tamaño de X que luego se estará incrementando
* @param x2 - Tamaño de Y que luego se estará incrementando
* @param x13 - Tamaño máximo del triángulo(lo uso para validar que así sea)
* @param x14 - Parámetro para realizar cálculos
* @param x25 - Esto da inicio desde donde debería pintarse --> x25 = x14 * 4
*                1) [4] ---- 2) [12] ---- 3) [20]
*
*/
barco:
trianguloBarco:
  ldr w10,colorTrianguloBarco
  add x0, x0, 400
  mov x1, 1     // X Size
  mov x2, 0         // Y Size
  mov x13, 140
  mov x14, 1
  mov x25, 1

  mov x0, x22
  mov x3, 0x96  // Ancho --> 448  --> 640
  mov x4, 0x100  // Altura --> 50 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  bl techoBarco0
ampliacionBase:
  add x14, x14, 2
  mov x1, x14
  mov x1,x1

techoBarco0:
  stur w10,[x0]	       // Set color of pixel N
  add x0,x0,4	         // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	       // decrement X counter
  cbnz x1, techoBarco0	   // If not end row jump
  cmp x13, x14
  b.lt lineaVertical2
  lsl x25, x14, 2
  add x0, x0, 2556
  sub x0, x0, x25
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, ampliacionBase	   // if not last row, jump
  b lineaVertical2


/**
*  Pinto linea vertical
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x3 - Uso ancho pasado
* @param x4 - Uso alto pasado
* @param x5 - x5 = (x+(y*640))
* @param x9 - = 640
* @param x22 - direc.base.frame
*
*/
lineaVertical2:
  ldr w10,colorLineaVertical2
  mov x0, x22

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

  mov x2, 100         // Y Size
linea1:
  mov x1, 2
lineaX2:
  stur w10,[x0]	   // Set color of pixel N
  add x0,x0,4	   // Next pixel [0][4][8]--> fin loop --> [100*4] = [400] ---> Casillero
  sub x1, x1, 1	   // decrement X counter
  cbnz x1, lineaX2	   // If not end row jump
  add x0, x0, 2552
  sub x2, x2, 1	   // Decrement Y counter
  cbnz x2, linea1	   // if not last row, jump
  b trianguloIzq2

trianguloIzq2:
  ldr w10,colorTrianguloIzq2
  mov x2, 40        // Y Size
  mov x1, 40        // X Size
  mov x13, x1       //  Primeras 20 columns, luego 19, 18, Tipo contador.
  mov x15, 0

  mov x0, x22
  mov x3, 0x50  // Ancho --> 448  --> 640
  mov x4, 0x164  // Altura --> 50 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

/**
*  Pinto el triángulo izquierdo
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x3 - Uso ancho pasado
* @param x4 - Uso alto pasado
* @param x5 - x5 = (x+(y*640))
* @param x9 - = 640
* @param x13 - Contador --> 20, 19, 18... 0. Esto para que pinte de manera escalonada, para generar triángulo
* @param x15 - Contador. Me sirve para correr el frame de manera que quede "escalonado"(para generar el triángulo)
* @param x22 - direc.base.frame
*
*/
triangulo1Izq2:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1            // decrement X counter
  cbnz x1,triangulo1Izq2          // If not end row jump
  sub x2,x2,1
  add x15, x15, 4
  add x0, x0, x15
  add x0, x0, 2400
  sub x13, x13, 1
  mov x1, x13
  cbnz x2,triangulo1Izq2
  b rect2

/**
*  Pinto un rectangulo entre dos triángulos
*
* Funcionamiento similar al primer rectangulo sólo que ahora jugando con x0
*
*/
  rect2:
  add x0, x0, 160
  mov x3, 40    // fila 2                     //alto de la plataforma medido desde abajo
  mov x5, 350    // columna 2                 //inicio de la plataforma
  mov x2, 40         // Y Size

  mov x0, x22
  mov x3, 0x78  // Ancho --> 448  --> 640
  mov x4, 0x164  // Altura --> 50 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

loop1rec2:
  mov x1, 60         // X Size
loop0Rec2:
  stur w10,[x0]      // Set color of pixel Nz
  add x0,x0,4          // Next pixel
  sub x1,x1,1          // decrement X counter
  cbnz x1, loop0Rec2
  add x0, x0, 2320
  sub x2, x2, 1
  cbnz x2, loop1rec2
  b triangulo2

triangulo2:
  mov x2, 40      // Y Size
  mov x1, 40     // X Size
  mov x13, 40
  mov x15, 0

  mov x0, x22
  mov x3, 0xB2  // Ancho --> 448  --> 640
  mov x4, 0x164  // Altura --> 50 --> 480

  madd x5,x4,x9,x3
  lsl x5,x5,2
  add x0,x0,x5

/**
*  Pinto el triángulo derecho
*
* @param x1 - Tamaño de X
* @param x2 - Tamaño de Y
* @param x5 - Lo uso para centrar torre(=80)
* @param x13 - Contador --> 20, 19, 18... 0. Esto para que pinte de manera escalonada, para generar triángulo
* @param x15 - Contador. Me sirve para correr el frame de manera que quede "escalonado"(para generar el triángulo)
*
*/

trianDer2:
  stur x10,[x0]          // Set color of pixel N
  add x0,x0,4            // Next pixel
  sub x1,x1,1            // decrement X counter
  cbnz x1,trianDer2          // If not end row jump
  sub x2,x2,1
  add x0, x0, 2400
  sub x13, x13, 1
  mov x1, x13
  add x0, x0, x15
  add x15, x15, 4
  cbnz x2,trianDer2
  b endloop

	//--------------------------Infinite Loop--------------------------------//
endloop:

InfLoop:
	b InfLoop
