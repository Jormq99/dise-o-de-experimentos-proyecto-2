# Evaluación experimental del rendimiento de PBRT

## Integrantes

- **Luis Fernando Solano Coto** — School of Computer Science, Costa Rica Institute of Technology, San José, Costa Rica — [l.solano.3@estudiantec.cr](mailto:l.solano.3@estudiantec.cr)
- **Christopher Littbars Acosta Gómez** — School of Computer Science, Costa Rica Institute of Technology, San José, Costa Rica — [amchrisag@estudiantec.cr](mailto:amchrisag@estudiantec.cr)
- **Jordani Mejía Quirós** — School of Computer Science, Costa Rica Institute of Technology, San José, Costa Rica — [jordanymq99@estudiantec.cr](mailto:jordanymq99@estudiantec.cr)

## Resumen

Este proyecto propone evaluar experimentalmente el rendimiento de PBRT V3 bajo distintos entornos de ejecución y configuraciones de compilación. El estudio contempla la ejecución nativa en Windows y Linux, Linux virtualizado sobre Windows y Windows Subsystem for Linux (WSL). Además, compara GCC y Clang para determinar si el compilador produce diferencias estadística y prácticamente relevantes en el tiempo de ejecución.

El diseño considera cuatro escenas oficiales de PBRT, los aceleradores `kdtree` y `bvh`, un mínimo de cinco repeticiones por combinación experimental y la ejecución sobre el mismo hardware físico. Los resultados se analizarán con métodos estadísticos adecuados al diseño y a los datos recolectados.

## Problema de investigación

Las comparaciones de rendimiento entre sistemas operativos y herramientas de compilación suelen basarse en observaciones no controladas. Por ello, no permiten establecer si las diferencias observadas son atribuibles al entorno, al compilador o a la variabilidad de las ejecuciones. El estudio plantea medir estos efectos bajo condiciones documentadas y reproducibles, sin extender las conclusiones más allá de las configuraciones evaluadas.

## Objetivo

Determinar cómo varía el tiempo de ejecución de PBRT según el entorno de ejecución, el acelerador seleccionado y el compilador utilizado, con énfasis en la comparación entre GCC y Clang cuando ambos puedan compilar el programa bajo condiciones equivalentes.

## Preguntas de investigación

1. ¿Existen diferencias estadísticamente significativas en el tiempo de ejecución de PBRT entre los entornos evaluados?
2. ¿El uso de `kdtree` o `bvh` afecta el tiempo de ejecución de las escenas?
3. ¿GCC y Clang producen diferencias estadística y prácticamente relevantes en el tiempo de ejecución?
4. ¿Cambian los efectos de los aceleradores o compiladores según el entorno o la escena?

## Diseño experimental propuesto

### Aplicación y carga de trabajo

La aplicación de referencia será PBRT V3. Se seleccionarán cuatro escenas del repositorio oficial de PBRT: ninguna deberá tardar menos de cinco minutos y al menos una deberá tardar cerca de treinta minutos o más en las condiciones de referencia.

### Hardware de referencia

Las ejecuciones experimentales se realizarán sobre el mismo equipo físico, con las siguientes especificaciones:

- **Procesador:** Intel Core i5-14600KF
- **Tarjeta gráfica:** Intel Arc B580
- **Memoria:** 16 GB DDR5-5600

### Factores

| Factor | Niveles previstos |
|---|---|
| Entorno de ejecución | Windows nativo, Linux nativo, Linux en máquina virtual sobre Windows y WSL |
| Escena | Cuatro escenas oficiales de PBRT |
| Acelerador | `kdtree` y `bvh` |
| Compilador | GCC y Clang, en las combinaciones de entorno donde ambos estén disponibles y sean comparables |

La variable de respuesta principal será el tiempo de ejecución de cada renderizado. Se mantendrán constantes, en la medida técnicamente posible, la versión de PBRT, las opciones de compilación, los parámetros de las escenas y el hardware físico. Se documentarán las diferencias inevitables entre entornos y compiladores; las comparaciones GCC–Clang se limitarán a compilaciones equivalentes y no se inferirán resultados para combinaciones no evaluadas.

Cada combinación experimental contará con al menos cinco repeticiones. El orden de ejecución, las condiciones del sistema, la configuración de la máquina virtual y los criterios de exclusión de corridas se definirán y registrarán antes del análisis.

## Análisis

El análisis describirá la distribución y variabilidad de los tiempos, verificará los supuestos de las pruebas seleccionadas y estimará la magnitud de los efectos con medidas de incertidumbre. La significancia estadística se distinguirá de la relevancia práctica; las conclusiones quedarán limitadas a las escenas, versiones, compiladores, configuraciones y hardware efectivamente examinados.

## Reproducibilidad y registro

Para cada corrida se conservarán un identificador, fecha y hora, escena, configuración completa, salida relevante de PBRT, evidencia temporal obtenida mediante `date` y observaciones sobre incidentes. También se registrarán las versiones de sistema operativo, hipervisor, PBRT y compiladores, junto con las opciones de compilación y los scripts utilizados. Las corridas descartadas y sus motivos quedarán identificados en la bitácora.

## Alcance y estado

Este repositorio contiene la propuesta del estudio. Los datos, resultados y conclusiones se incorporarán después de ejecutar el experimento y no se presuponen en esta etapa.
