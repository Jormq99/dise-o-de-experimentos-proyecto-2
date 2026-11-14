# ----------------------------------------------------------------------------------------------------
# Instituto Tecnológico de Costa Rica (ITCR)
# Semestre II, 2026.
# Curso: Diseño de Experimentos
# Profesor: Ernesto Rivera Alvarado
# Estudiantes: 
# - Luis Fernando Solano Coto
# - Christopher Acosta Gómez
# - Jordani Mejía Quirós
# Entregable: Proyecto - Artículo Científico
# - Evaluación Experimental del Rendimiento de PBRT V3 según Entorno de Ejecución,
# Compilador y Estructura de Aceleración)
# 
# Noviembre 15, 2026.
# ----------------------------------------------------------------------------------------------------

#------------------------- 0. Instalación de paquetes requeridos. -------------------------
print("#------------------------- 0. Instalación de paquetes requeridos. -------------------------")

# Para mostrar los gráficos en navegador. En la consola de R, ejecutar:
# install.packages("httpgd") --> Para instalar el paquete.
# library(httpgd) --> Para cargarlo.
# hgd() --> Para que inicie el web socket.
# hgd_close() --> Para cerrar la sesión.


waitForGraph <- function(seconds = 3) {
  
  if (interactive()) {
    
    invisible(
      readline(prompt = "Presiona [Enter] para ver el siguiente gráfico...")
    )
    
  } else {
    
    Sys.sleep(seconds)
    
  }
}

if(!require(psych)) {install.packages("psych")}
if(!require(FSA)) {install.packages("FSA")}
if(!require(ggplot2)) {install.packages("ggplot2")}
if(!require(car)) {install.packages("car")}
if(!require(multcompView)) {install.packages("multcompView")}
if(!require(multcomp)) {install.packages("multcomp")}
if(!require(lsmeans)) {install.packages("lsmeans")}
if(!require(rcompanion)) {install.packages("rcompanion")}
if(!require(phia)) {install.packages("phia")}
if(!require(lmtest)) {install.packages("lmtest")}

#------------------------- 1. Carga de Datos y Ordenamiento. -------------------------
print("#------------------------- 1. Carga de Datos y Ordenamiento. -------------------------")

# ***** Data dummy y su formato experimental *****
# Variable respuesta: Tiempo total de ejecución de cada render, en segundos.
# Factores: 
# - Entorno (5 niveles)
# - Compilador (MSVC solo en Windows, GCC y Clang en entornos Linux),
# - Acelerador (bvh, kdtree)
# - Escena (4 niveles)
# - Repeticion (5 niveles).

In <- ("
Entorno           Compilador  Acelerador  Escena    Repeticion  Tiempo
'Windows nativo'  MSVC        bvh         Escena1   1           414.9
'Windows nativo'  MSVC        bvh         Escena1   2           415.9
'Windows nativo'  MSVC        bvh         Escena1   3           409.9
'Windows nativo'  MSVC        bvh         Escena1   4           400.8
'Windows nativo'  MSVC        bvh         Escena1   5           405.2
'Windows nativo'  MSVC        bvh         Escena2   1           686.1
'Windows nativo'  MSVC        bvh         Escena2   2           699.9
'Windows nativo'  MSVC        bvh         Escena2   3           691.9
'Windows nativo'  MSVC        bvh         Escena2   4           713.1
'Windows nativo'  MSVC        bvh         Escena2   5           706.2
'Windows nativo'  MSVC        bvh         Escena3   1           1327.1
'Windows nativo'  MSVC        bvh         Escena3   2           1363.7
'Windows nativo'  MSVC        bvh         Escena3   3           1335.7
'Windows nativo'  MSVC        bvh         Escena3   4           1354.7
'Windows nativo'  MSVC        bvh         Escena3   5           1291.9
'Windows nativo'  MSVC        bvh         Escena4   1           1922.5
'Windows nativo'  MSVC        bvh         Escena4   2           2035.7
'Windows nativo'  MSVC        bvh         Escena4   3           1954.9
'Windows nativo'  MSVC        bvh         Escena4   4           1968.1
'Windows nativo'  MSVC        bvh         Escena4   5           1935.1
'Windows nativo'  MSVC        kdtree      Escena1   1           1355.9
'Windows nativo'  MSVC        kdtree      Escena1   2           1395.4
'Windows nativo'  MSVC        kdtree      Escena1   3           1340.0
'Windows nativo'  MSVC        kdtree      Escena1   4           1375.8
'Windows nativo'  MSVC        kdtree      Escena1   5           1379.7
'Windows nativo'  MSVC        kdtree      Escena2   1           2363.9
'Windows nativo'  MSVC        kdtree      Escena2   2           2308.6
'Windows nativo'  MSVC        kdtree      Escena2   3           2331.1
'Windows nativo'  MSVC        kdtree      Escena2   4           2349.7
'Windows nativo'  MSVC        kdtree      Escena2   5           2425.0
'Windows nativo'  MSVC        kdtree      Escena3   1           4554.6
'Windows nativo'  MSVC        kdtree      Escena3   2           4374.7
'Windows nativo'  MSVC        kdtree      Escena3   3           4409.6
'Windows nativo'  MSVC        kdtree      Escena3   4           4470.0
'Windows nativo'  MSVC        kdtree      Escena3   5           4573.6
'Windows nativo'  MSVC        kdtree      Escena4   1           6685.5
'Windows nativo'  MSVC        kdtree      Escena4   2           6796.8
'Windows nativo'  MSVC        kdtree      Escena4   3           6679.9
'Windows nativo'  MSVC        kdtree      Escena4   4           6658.3
'Windows nativo'  MSVC        kdtree      Escena4   5           6722.3
'Linux nativo'    GCC         bvh         Escena1   1           369.3
'Linux nativo'    GCC         bvh         Escena1   2           363.2
'Linux nativo'    GCC         bvh         Escena1   3           366.3
'Linux nativo'    GCC         bvh         Escena1   4           357.6
'Linux nativo'    GCC         bvh         Escena1   5           374.9
'Linux nativo'    GCC         bvh         Escena2   1           658.8
'Linux nativo'    GCC         bvh         Escena2   2           647.5
'Linux nativo'    GCC         bvh         Escena2   3           649.0
'Linux nativo'    GCC         bvh         Escena2   4           660.3
'Linux nativo'    GCC         bvh         Escena2   5           629.0
'Linux nativo'    GCC         bvh         Escena3   1           1192.2
'Linux nativo'    GCC         bvh         Escena3   2           1198.4
'Linux nativo'    GCC         bvh         Escena3   3           1221.1
'Linux nativo'    GCC         bvh         Escena3   4           1225.4
'Linux nativo'    GCC         bvh         Escena3   5           1252.4
'Linux nativo'    GCC         bvh         Escena4   1           1783.2
'Linux nativo'    GCC         bvh         Escena4   2           1816.2
'Linux nativo'    GCC         bvh         Escena4   3           1737.0
'Linux nativo'    GCC         bvh         Escena4   4           1802.0
'Linux nativo'    GCC         bvh         Escena4   5           1850.8
'Linux nativo'    GCC         kdtree      Escena1   1           534.8
'Linux nativo'    GCC         kdtree      Escena1   2           534.7
'Linux nativo'    GCC         kdtree      Escena1   3           517.3
'Linux nativo'    GCC         kdtree      Escena1   4           530.0
'Linux nativo'    GCC         kdtree      Escena1   5           515.1
'Linux nativo'    GCC         kdtree      Escena2   1           911.0
'Linux nativo'    GCC         kdtree      Escena2   2           915.7
'Linux nativo'    GCC         kdtree      Escena2   3           907.3
'Linux nativo'    GCC         kdtree      Escena2   4           949.5
'Linux nativo'    GCC         kdtree      Escena2   5           928.5
'Linux nativo'    GCC         kdtree      Escena3   1           1717.1
'Linux nativo'    GCC         kdtree      Escena3   2           1777.8
'Linux nativo'    GCC         kdtree      Escena3   3           1656.8
'Linux nativo'    GCC         kdtree      Escena3   4           1675.8
'Linux nativo'    GCC         kdtree      Escena3   5           1703.9
'Linux nativo'    GCC         kdtree      Escena4   1           2505.2
'Linux nativo'    GCC         kdtree      Escena4   2           2606.6
'Linux nativo'    GCC         kdtree      Escena4   3           2503.9
'Linux nativo'    GCC         kdtree      Escena4   4           2636.6
'Linux nativo'    GCC         kdtree      Escena4   5           2544.5
'Linux nativo'    Clang       bvh         Escena1   1           361.2
'Linux nativo'    Clang       bvh         Escena1   2           353.7
'Linux nativo'    Clang       bvh         Escena1   3           346.9
'Linux nativo'    Clang       bvh         Escena1   4           351.3
'Linux nativo'    Clang       bvh         Escena1   5           361.3
'Linux nativo'    Clang       bvh         Escena2   1           629.5
'Linux nativo'    Clang       bvh         Escena2   2           624.6
'Linux nativo'    Clang       bvh         Escena2   3           615.5
'Linux nativo'    Clang       bvh         Escena2   4           633.7
'Linux nativo'    Clang       bvh         Escena2   5           598.3
'Linux nativo'    Clang       bvh         Escena3   1           1235.3
'Linux nativo'    Clang       bvh         Escena3   2           1166.3
'Linux nativo'    Clang       bvh         Escena3   3           1169.9
'Linux nativo'    Clang       bvh         Escena3   4           1215.0
'Linux nativo'    Clang       bvh         Escena3   5           1167.4
'Linux nativo'    Clang       bvh         Escena4   1           1785.7
'Linux nativo'    Clang       bvh         Escena4   2           1737.5
'Linux nativo'    Clang       bvh         Escena4   3           1685.6
'Linux nativo'    Clang       bvh         Escena4   4           1750.1
'Linux nativo'    Clang       bvh         Escena4   5           1775.5
'Linux nativo'    Clang       kdtree      Escena1   1           523.8
'Linux nativo'    Clang       kdtree      Escena1   2           508.8
'Linux nativo'    Clang       kdtree      Escena1   3           497.7
'Linux nativo'    Clang       kdtree      Escena1   4           506.2
'Linux nativo'    Clang       kdtree      Escena1   5           519.5
'Linux nativo'    Clang       kdtree      Escena2   1           879.7
'Linux nativo'    Clang       kdtree      Escena2   2           867.1
'Linux nativo'    Clang       kdtree      Escena2   3           880.6
'Linux nativo'    Clang       kdtree      Escena2   4           838.9
'Linux nativo'    Clang       kdtree      Escena2   5           866.4
'Linux nativo'    Clang       kdtree      Escena3   1           1752.9
'Linux nativo'    Clang       kdtree      Escena3   2           1665.8
'Linux nativo'    Clang       kdtree      Escena3   3           1631.3
'Linux nativo'    Clang       kdtree      Escena3   4           1698.2
'Linux nativo'    Clang       kdtree      Escena3   5           1649.8
'Linux nativo'    Clang       kdtree      Escena4   1           2527.1
'Linux nativo'    Clang       kdtree      Escena4   2           2564.8
'Linux nativo'    Clang       kdtree      Escena4   3           2539.7
'Linux nativo'    Clang       kdtree      Escena4   4           2525.6
'Linux nativo'    Clang       kdtree      Escena4   5           2515.3
'WSL 2'           GCC         bvh         Escena1   1           378.6
'WSL 2'           GCC         bvh         Escena1   2           385.5
'WSL 2'           GCC         bvh         Escena1   3           374.2
'WSL 2'           GCC         bvh         Escena1   4           381.7
'WSL 2'           GCC         bvh         Escena1   5           372.1
'WSL 2'           GCC         bvh         Escena2   1           650.4
'WSL 2'           GCC         bvh         Escena2   2           664.6
'WSL 2'           GCC         bvh         Escena2   3           656.9
'WSL 2'           GCC         bvh         Escena2   4           688.8
'WSL 2'           GCC         bvh         Escena2   5           645.4
'WSL 2'           GCC         bvh         Escena3   1           1268.1
'WSL 2'           GCC         bvh         Escena3   2           1250.3
'WSL 2'           GCC         bvh         Escena3   3           1245.0
'WSL 2'           GCC         bvh         Escena3   4           1271.9
'WSL 2'           GCC         bvh         Escena3   5           1249.3
'WSL 2'           GCC         bvh         Escena4   1           1854.8
'WSL 2'           GCC         bvh         Escena4   2           1868.1
'WSL 2'           GCC         bvh         Escena4   3           1861.5
'WSL 2'           GCC         bvh         Escena4   4           1852.0
'WSL 2'           GCC         bvh         Escena4   5           1856.7
'WSL 2'           GCC         kdtree      Escena1   1           553.0
'WSL 2'           GCC         kdtree      Escena1   2           550.2
'WSL 2'           GCC         kdtree      Escena1   3           540.8
'WSL 2'           GCC         kdtree      Escena1   4           555.9
'WSL 2'           GCC         kdtree      Escena1   5           549.3
'WSL 2'           GCC         kdtree      Escena2   1           932.3
'WSL 2'           GCC         kdtree      Escena2   2           956.6
'WSL 2'           GCC         kdtree      Escena2   3           973.4
'WSL 2'           GCC         kdtree      Escena2   4           976.3
'WSL 2'           GCC         kdtree      Escena2   5           972.1
'WSL 2'           GCC         kdtree      Escena3   1           1858.3
'WSL 2'           GCC         kdtree      Escena3   2           1756.6
'WSL 2'           GCC         kdtree      Escena3   3           1876.7
'WSL 2'           GCC         kdtree      Escena3   4           1746.1
'WSL 2'           GCC         kdtree      Escena3   5           1814.6
'WSL 2'           GCC         kdtree      Escena4   1           2708.0
'WSL 2'           GCC         kdtree      Escena4   2           2732.0
'WSL 2'           GCC         kdtree      Escena4   3           2659.2
'WSL 2'           GCC         kdtree      Escena4   4           2703.4
'WSL 2'           GCC         kdtree      Escena4   5           2720.9
'WSL 2'           Clang       bvh         Escena1   1           367.8
'WSL 2'           Clang       bvh         Escena1   2           367.8
'WSL 2'           Clang       bvh         Escena1   3           358.3
'WSL 2'           Clang       bvh         Escena1   4           378.0
'WSL 2'           Clang       bvh         Escena1   5           365.9
'WSL 2'           Clang       bvh         Escena2   1           634.8
'WSL 2'           Clang       bvh         Escena2   2           632.1
'WSL 2'           Clang       bvh         Escena2   3           622.3
'WSL 2'           Clang       bvh         Escena2   4           654.8
'WSL 2'           Clang       bvh         Escena2   5           644.3
'WSL 2'           Clang       bvh         Escena3   1           1252.7
'WSL 2'           Clang       bvh         Escena3   2           1244.2
'WSL 2'           Clang       bvh         Escena3   3           1250.8
'WSL 2'           Clang       bvh         Escena3   4           1192.8
'WSL 2'           Clang       bvh         Escena3   5           1181.2
'WSL 2'           Clang       bvh         Escena4   1           1846.7
'WSL 2'           Clang       bvh         Escena4   2           1798.3
'WSL 2'           Clang       bvh         Escena4   3           1760.8
'WSL 2'           Clang       bvh         Escena4   4           1857.5
'WSL 2'           Clang       bvh         Escena4   5           1737.7
'WSL 2'           Clang       kdtree      Escena1   1           555.1
'WSL 2'           Clang       kdtree      Escena1   2           540.5
'WSL 2'           Clang       kdtree      Escena1   3           538.0
'WSL 2'           Clang       kdtree      Escena1   4           537.0
'WSL 2'           Clang       kdtree      Escena1   5           522.2
'WSL 2'           Clang       kdtree      Escena2   1           945.7
'WSL 2'           Clang       kdtree      Escena2   2           935.2
'WSL 2'           Clang       kdtree      Escena2   3           917.0
'WSL 2'           Clang       kdtree      Escena2   4           983.0
'WSL 2'           Clang       kdtree      Escena2   5           939.5
'WSL 2'           Clang       kdtree      Escena3   1           1744.2
'WSL 2'           Clang       kdtree      Escena3   2           1775.0
'WSL 2'           Clang       kdtree      Escena3   3           1747.0
'WSL 2'           Clang       kdtree      Escena3   4           1818.1
'WSL 2'           Clang       kdtree      Escena3   5           1790.7
'WSL 2'           Clang       kdtree      Escena4   1           2661.9
'WSL 2'           Clang       kdtree      Escena4   2           2641.5
'WSL 2'           Clang       kdtree      Escena4   3           2632.9
'WSL 2'           Clang       kdtree      Escena4   4           2590.5
'WSL 2'           Clang       kdtree      Escena4   5           2576.6
'Hyper-V'         GCC         bvh         Escena1   1           531.9
'Hyper-V'         GCC         bvh         Escena1   2           534.4
'Hyper-V'         GCC         bvh         Escena1   3           539.8
'Hyper-V'         GCC         bvh         Escena1   4           552.1
'Hyper-V'         GCC         bvh         Escena1   5           551.5
'Hyper-V'         GCC         bvh         Escena2   1           948.1
'Hyper-V'         GCC         bvh         Escena2   2           936.7
'Hyper-V'         GCC         bvh         Escena2   3           918.4
'Hyper-V'         GCC         bvh         Escena2   4           929.7
'Hyper-V'         GCC         bvh         Escena2   5           927.2
'Hyper-V'         GCC         bvh         Escena3   1           1771.5
'Hyper-V'         GCC         bvh         Escena3   2           1751.3
'Hyper-V'         GCC         bvh         Escena3   3           1794.4
'Hyper-V'         GCC         bvh         Escena3   4           1774.0
'Hyper-V'         GCC         bvh         Escena3   5           1765.7
'Hyper-V'         GCC         bvh         Escena4   1           2552.1
'Hyper-V'         GCC         bvh         Escena4   2           2556.7
'Hyper-V'         GCC         bvh         Escena4   3           2584.7
'Hyper-V'         GCC         bvh         Escena4   4           2604.4
'Hyper-V'         GCC         bvh         Escena4   5           2670.4
'Hyper-V'         GCC         kdtree      Escena1   1           754.6
'Hyper-V'         GCC         kdtree      Escena1   2           751.2
'Hyper-V'         GCC         kdtree      Escena1   3           728.0
'Hyper-V'         GCC         kdtree      Escena1   4           747.9
'Hyper-V'         GCC         kdtree      Escena1   5           754.5
'Hyper-V'         GCC         kdtree      Escena2   1           1281.8
'Hyper-V'         GCC         kdtree      Escena2   2           1318.1
'Hyper-V'         GCC         kdtree      Escena2   3           1282.9
'Hyper-V'         GCC         kdtree      Escena2   4           1308.3
'Hyper-V'         GCC         kdtree      Escena2   5           1281.1
'Hyper-V'         GCC         kdtree      Escena3   1           2539.4
'Hyper-V'         GCC         kdtree      Escena3   2           2468.1
'Hyper-V'         GCC         kdtree      Escena3   3           2438.6
'Hyper-V'         GCC         kdtree      Escena3   4           2572.8
'Hyper-V'         GCC         kdtree      Escena3   5           2437.6
'Hyper-V'         GCC         kdtree      Escena4   1           3631.3
'Hyper-V'         GCC         kdtree      Escena4   2           3714.8
'Hyper-V'         GCC         kdtree      Escena4   3           3590.5
'Hyper-V'         GCC         kdtree      Escena4   4           3774.0
'Hyper-V'         GCC         kdtree      Escena4   5           3612.6
'Hyper-V'         Clang       bvh         Escena1   1           513.5
'Hyper-V'         Clang       bvh         Escena1   2           528.7
'Hyper-V'         Clang       bvh         Escena1   3           519.1
'Hyper-V'         Clang       bvh         Escena1   4           528.1
'Hyper-V'         Clang       bvh         Escena1   5           540.4
'Hyper-V'         Clang       bvh         Escena2   1           903.4
'Hyper-V'         Clang       bvh         Escena2   2           925.2
'Hyper-V'         Clang       bvh         Escena2   3           903.4
'Hyper-V'         Clang       bvh         Escena2   4           919.3
'Hyper-V'         Clang       bvh         Escena2   5           902.2
'Hyper-V'         Clang       bvh         Escena3   1           1711.4
'Hyper-V'         Clang       bvh         Escena3   2           1706.9
'Hyper-V'         Clang       bvh         Escena3   3           1705.1
'Hyper-V'         Clang       bvh         Escena3   4           1687.3
'Hyper-V'         Clang       bvh         Escena3   5           1706.3
'Hyper-V'         Clang       bvh         Escena4   1           2552.5
'Hyper-V'         Clang       bvh         Escena4   2           2516.1
'Hyper-V'         Clang       bvh         Escena4   3           2540.5
'Hyper-V'         Clang       bvh         Escena4   4           2508.5
'Hyper-V'         Clang       bvh         Escena4   5           2529.5
'Hyper-V'         Clang       kdtree      Escena1   1           732.5
'Hyper-V'         Clang       kdtree      Escena1   2           733.8
'Hyper-V'         Clang       kdtree      Escena1   3           736.9
'Hyper-V'         Clang       kdtree      Escena1   4           727.5
'Hyper-V'         Clang       kdtree      Escena1   5           747.8
'Hyper-V'         Clang       kdtree      Escena2   1           1259.7
'Hyper-V'         Clang       kdtree      Escena2   2           1274.5
'Hyper-V'         Clang       kdtree      Escena2   3           1266.6
'Hyper-V'         Clang       kdtree      Escena2   4           1266.1
'Hyper-V'         Clang       kdtree      Escena2   5           1299.0
'Hyper-V'         Clang       kdtree      Escena3   1           2444.4
'Hyper-V'         Clang       kdtree      Escena3   2           2366.5
'Hyper-V'         Clang       kdtree      Escena3   3           2412.4
'Hyper-V'         Clang       kdtree      Escena3   4           2367.6
'Hyper-V'         Clang       kdtree      Escena3   5           2383.2
'Hyper-V'         Clang       kdtree      Escena4   1           3558.9
'Hyper-V'         Clang       kdtree      Escena4   2           3562.1
'Hyper-V'         Clang       kdtree      Escena4   3           3590.6
'Hyper-V'         Clang       kdtree      Escena4   4           3505.3
'Hyper-V'         Clang       kdtree      Escena4   5           3415.5
'VirtualBox'      GCC         bvh         Escena1   1           552.0
'VirtualBox'      GCC         bvh         Escena1   2           533.6
'VirtualBox'      GCC         bvh         Escena1   3           543.5
'VirtualBox'      GCC         bvh         Escena1   4           554.8
'VirtualBox'      GCC         bvh         Escena1   5           558.3
'VirtualBox'      GCC         bvh         Escena2   1           923.3
'VirtualBox'      GCC         bvh         Escena2   2           982.0
'VirtualBox'      GCC         bvh         Escena2   3           918.5
'VirtualBox'      GCC         bvh         Escena2   4           954.9
'VirtualBox'      GCC         bvh         Escena2   5           929.6
'VirtualBox'      GCC         bvh         Escena3   1           1794.7
'VirtualBox'      GCC         bvh         Escena3   2           1776.4
'VirtualBox'      GCC         bvh         Escena3   3           1792.9
'VirtualBox'      GCC         bvh         Escena3   4           1756.6
'VirtualBox'      GCC         bvh         Escena3   5           1802.1
'VirtualBox'      GCC         bvh         Escena4   1           2652.1
'VirtualBox'      GCC         bvh         Escena4   2           2646.0
'VirtualBox'      GCC         bvh         Escena4   3           2627.8
'VirtualBox'      GCC         bvh         Escena4   4           2657.3
'VirtualBox'      GCC         bvh         Escena4   5           2588.5
'VirtualBox'      GCC         kdtree      Escena1   1           866.2
'VirtualBox'      GCC         kdtree      Escena1   2           859.7
'VirtualBox'      GCC         kdtree      Escena1   3           828.2
'VirtualBox'      GCC         kdtree      Escena1   4           851.7
'VirtualBox'      GCC         kdtree      Escena1   5           833.4
'VirtualBox'      GCC         kdtree      Escena2   1           1407.9
'VirtualBox'      GCC         kdtree      Escena2   2           1501.6
'VirtualBox'      GCC         kdtree      Escena2   3           1434.2
'VirtualBox'      GCC         kdtree      Escena2   4           1457.2
'VirtualBox'      GCC         kdtree      Escena2   5           1450.0
'VirtualBox'      GCC         kdtree      Escena3   1           2696.4
'VirtualBox'      GCC         kdtree      Escena3   2           2748.2
'VirtualBox'      GCC         kdtree      Escena3   3           2733.8
'VirtualBox'      GCC         kdtree      Escena3   4           2799.0
'VirtualBox'      GCC         kdtree      Escena3   5           2845.2
'VirtualBox'      GCC         kdtree      Escena4   1           4131.8
'VirtualBox'      GCC         kdtree      Escena4   2           4099.4
'VirtualBox'      GCC         kdtree      Escena4   3           4057.6
'VirtualBox'      GCC         kdtree      Escena4   4           4082.8
'VirtualBox'      GCC         kdtree      Escena4   5           4061.4
'VirtualBox'      Clang       bvh         Escena1   1           516.5
'VirtualBox'      Clang       bvh         Escena1   2           527.1
'VirtualBox'      Clang       bvh         Escena1   3           543.6
'VirtualBox'      Clang       bvh         Escena1   4           530.7
'VirtualBox'      Clang       bvh         Escena1   5           529.9
'VirtualBox'      Clang       bvh         Escena2   1           907.9
'VirtualBox'      Clang       bvh         Escena2   2           885.8
'VirtualBox'      Clang       bvh         Escena2   3           888.4
'VirtualBox'      Clang       bvh         Escena2   4           919.9
'VirtualBox'      Clang       bvh         Escena2   5           885.7
'VirtualBox'      Clang       bvh         Escena3   1           1687.6
'VirtualBox'      Clang       bvh         Escena3   2           1738.5
'VirtualBox'      Clang       bvh         Escena3   3           1724.7
'VirtualBox'      Clang       bvh         Escena3   4           1716.7
'VirtualBox'      Clang       bvh         Escena3   5           1732.9
'VirtualBox'      Clang       bvh         Escena4   1           2720.7
'VirtualBox'      Clang       bvh         Escena4   2           2634.7
'VirtualBox'      Clang       bvh         Escena4   3           2499.1
'VirtualBox'      Clang       bvh         Escena4   4           2512.5
'VirtualBox'      Clang       bvh         Escena4   5           2539.8
'VirtualBox'      Clang       kdtree      Escena1   1           804.8
'VirtualBox'      Clang       kdtree      Escena1   2           833.7
'VirtualBox'      Clang       kdtree      Escena1   3           827.8
'VirtualBox'      Clang       kdtree      Escena1   4           803.7
'VirtualBox'      Clang       kdtree      Escena1   5           827.1
'VirtualBox'      Clang       kdtree      Escena2   1           1433.2
'VirtualBox'      Clang       kdtree      Escena2   2           1447.8
'VirtualBox'      Clang       kdtree      Escena2   3           1409.0
'VirtualBox'      Clang       kdtree      Escena2   4           1441.2
'VirtualBox'      Clang       kdtree      Escena2   5           1425.2
'VirtualBox'      Clang       kdtree      Escena3   1           2679.4
'VirtualBox'      Clang       kdtree      Escena3   2           2713.9
'VirtualBox'      Clang       kdtree      Escena3   3           2680.4
'VirtualBox'      Clang       kdtree      Escena3   4           2792.1
'VirtualBox'      Clang       kdtree      Escena3   5           2743.3
'VirtualBox'      Clang       kdtree      Escena4   1           4159.4
'VirtualBox'      Clang       kdtree      Escena4   2           3942.7
'VirtualBox'      Clang       kdtree      Escena4   3           3864.7
'VirtualBox'      Clang       kdtree      Escena4   4           4157.0
'VirtualBox'      Clang       kdtree      Escena4   5           4011.4
")

Data <- read.table(textConnection(In), header=TRUE)

Data$Entorno <- factor(Data$Entorno, levels = unique(Data$Entorno))
Data$Compilador <- factor(Data$Compilador, levels = unique(Data$Compilador))
Data$Acelerador <- factor(Data$Acelerador, levels = unique(Data$Acelerador))
Data$Escena <- factor(Data$Escena, levels = unique(Data$Escena))
Data$Repeticion <- factor(Data$Repeticion)

# Factor combinado Entorno + Compilador (9 niveles). Se usa en el análisis global porque Windows
# solo cuenta con MSVC y, por lo tanto, Entorno y Compilador no están completamente cruzados.
print("----- INTERACTION -----")
Data$Configuracion <- interaction(Data$Entorno, Data$Compilador, sep = " - ", drop = TRUE, lex.order = TRUE)
print("----- INTERACTION -----")

# Subconjunto para el análisis factorial completo Entorno x Compilador (solo entornos Linux).
DataLinux <- droplevels(subset(Data, Entorno != "Windows nativo"))

library(psych)
print("----- headTail -----")
print(headTail(Data))
print("----- headTail -----")
print("----- str -----")
str(Data)
print("----- str -----")
print("----- summary -----")
print(summary(Data))
print("----- summary -----")

print("----- ftable -----")
# Verificación del balance del diseño: cada combinación debe tener 5 repeticiones.
print(ftable(xtabs(~ Configuracion + Acelerador + Escena, data = Data)))
rm(In)
print("----- ftable -----")


#------------------------- 2. Gráficos Simples de Interacción. -------------------------
print("#------------------------- 2. Gráficos Simples de Interacción. -------------------------")

# Líneas paralelas sugieren ausencia de interacción; líneas que se cruzan o se separan sugieren interacción.
# Son exploratorios: la significancia de cada interacción se evalúa con el ANOVA (sección 3).

# 2.1 Configuración x Acelerador.
interaction.plot(x.factor = Data$Acelerador, trace.factor = Data$Configuracion, response = Data$Tiempo,
fun = mean, type = "b", col = 1:9, pch = c(15:19, 15:18), fixed = TRUE, leg.bty = "o",
xlab = "Acelerador", ylab = "Tiempo promedio (s)", trace.label = "Configuración",
main = "Interacción Configuración x Acelerador")

# 2.2 Escena x Configuración.
interaction.plot(x.factor = Data$Escena, trace.factor = Data$Configuracion, response = Data$Tiempo,
fun = mean, type = "b", col = 1:9, pch = c(15:19, 15:18), fixed = TRUE, leg.bty = "o",
xlab = "Escena", ylab = "Tiempo promedio (s)", trace.label = "Configuración",
main = "Interacción Escena x Configuración")

# 2.3 Escena x Acelerador.
interaction.plot(x.factor = Data$Escena, trace.factor = Data$Acelerador, response = Data$Tiempo,
fun = mean, type = "b", col = c("black", "red"), pch = c(19, 17), fixed = TRUE, leg.bty = "o",
xlab = "Escena", ylab = "Tiempo promedio (s)", trace.label = "Acelerador",
main = "Interacción Escena x Acelerador")

# 2.4 Entorno x Compilador (solo entornos Linux).
interaction.plot(x.factor = DataLinux$Entorno, trace.factor = DataLinux$Compilador, response = DataLinux$Tiempo,
fun = mean, type = "b", col = c("black", "red"), pch = c(19, 17), fixed = TRUE, leg.bty = "o",
xlab = "Entorno", ylab = "Tiempo promedio (s)", trace.label = "Compilador",
main = "Interacción Entorno x Compilador (entornos Linux)")

# 2.5 Compilador x Acelerador (solo entornos Linux).
interaction.plot(x.factor = DataLinux$Acelerador, trace.factor = DataLinux$Compilador, response = DataLinux$Tiempo,
fun = mean, type = "b", col = c("black", "red"), pch = c(19, 17), fixed = TRUE, leg.bty = "o",
xlab = "Acelerador", ylab = "Tiempo promedio (s)", trace.label = "Compilador",
main = "Interacción Compilador x Acelerador (entornos Linux)")

# 2.6 Repetición x Configuración (control del bloque).
interaction.plot(x.factor = Data$Repeticion, trace.factor = Data$Configuracion, response = Data$Tiempo,
fun = mean, type = "b", col = 1:9, pch = c(15:19, 15:18), fixed = TRUE, leg.bty = "o",
xlab = "Repetición", ylab = "Tiempo promedio (s)", trace.label = "Configuración",
main = "Interacción Repetición x Configuración (control de bloque)")

#------------------------- 3. Modelo Lineal y Anova. -------------------------
print("#------------------------- 3. Modelo Lineal y Anova. -------------------------")

# Modelo A (global): Configuración (Entorno + Compilador) x Acelerador x Escena, con Repetición como bloque.
# Repetición entra solo como efecto aditivo (bloque): no se modelan sus interacciones.
modelA <- lm(Tiempo ~ Configuracion * Acelerador * Escena + Repeticion, data = Data)
print(summary(modelA))
library(car)
print(Anova(modelA, type = "II"))

# Modelo B (solo entornos Linux): factorial completo Entorno x Compilador x Acelerador x Escena.
modelB <- lm(Tiempo ~ Entorno * Compilador * Acelerador * Escena + Repeticion, data = DataLinux)
print(summary(modelB))
print(Anova(modelB, type = "II"))

#------------------------- 4. Análisis de Supuestos. -------------------------
print("#------------------------- 4. Análisis de Supuestos. -------------------------")
# Los supuestos se analizan sobre los residuos del modelo lineal, por eso se evalúan después de ajustarlo.
# Criterio de decisión en las pruebas formales: alfa = 0.05.

library(rcompanion)
library(car)
library(lmtest)

# 4.1 Normalidad de los residuos: histograma con curva normal, gráfico Q-Q y prueba de Shapiro-Wilk.
# H0: los residuos siguen una distribución normal.
verificarNormalidad <- function(model, titulo = "Modelo", alfa = 0.05) {
  x <- residuals(model)
  plotNormalHistogram(x, main = paste("Histograma de residuos -", titulo), xlab = "Residuos")
  qqPlot(x, main = paste("Gráfico Q-Q de residuos -", titulo), ylab = "Residuos", id = FALSE)
  prueba <- shapiro.test(x)
  print(prueba)
  if (prueba$p.value < alfa) {
    print(paste0("[", titulo, "] Normalidad: se rechaza H0 (p = ", signif(prueba$p.value, 4), "). Los residuos no son normales."))
  } else {
    print(paste0("[", titulo, "] Normalidad: no se rechaza H0 (p = ", signif(prueba$p.value, 4), "). Supuesto razonable."))
  }
  invisible(prueba)
}

# 4.2 Homocedasticidad: residuos vs. valores ajustados y prueba de Levene entre las celdas de tratamiento.
# H0: la varianza de los residuos es igual en todos los grupos.
# 'grupos' debe ser el factor de celdas de tratamiento (sin Repetición, para que cada grupo tenga 5 réplicas).
verificarHomocedasticidad <- function(model, grupos, titulo = "Modelo", alfa = 0.05) {
  plot(fitted(model), residuals(model), main = paste("Residuos vs. ajustados -", titulo),
       xlab = "Valores ajustados", ylab = "Residuos", pch = 19, col = "gray30")
  abline(h = 0, col = "red", lty = 2)
  prueba <- leveneTest(residuals(model) ~ grupos)
  print(prueba)
  p <- prueba[["Pr(>F)"]][1]
  if (p < alfa) {
    print(paste0("[", titulo, "] Homocedasticidad: se rechaza H0 (p = ", signif(p, 4), "). Varianzas no homogéneas."))
  } else {
    print(paste0("[", titulo, "] Homocedasticidad: no se rechaza H0 (p = ", signif(p, 4), "). Supuesto razonable."))
  }
  invisible(prueba)
}

# 4.3 Independencia: residuos en el orden de ejecución y prueba de Durbin-Watson.
# H0: no hay autocorrelación de primer orden entre residuos consecutivos.
# 'orden' es el orden real de ejecución de las corridas. Si no se indica, se usa el orden de las filas.
verificarIndependencia <- function(model, orden = NULL, titulo = "Modelo", alfa = 0.05) {
  if (is.null(orden)) { orden <- seq_along(residuals(model)) }
  plot(orden, residuals(model)[order(orden)], type = "b", pch = 19, cex = 0.6,
       main = paste("Residuos vs. orden de ejecución -", titulo), xlab = "Orden de ejecución", ylab = "Residuos")
  abline(h = 0, col = "red", lty = 2)
  prueba <- dwtest(model, order.by = orden)
  print(prueba)
  if (prueba$p.value < alfa) {
    print(paste0("[", titulo, "] Independencia: se rechaza H0 (p = ", signif(prueba$p.value, 4), "). Hay autocorrelación."))
  } else {
    print(paste0("[", titulo, "] Independencia: no se rechaza H0 (p = ", signif(prueba$p.value, 4), "). Supuesto razonable."))
  }
  invisible(prueba)
}

# Grupos (celdas de tratamiento) para la prueba de Levene de cada modelo.
gruposA <- interaction(Data$Configuracion, Data$Acelerador, Data$Escena, drop = TRUE)
gruposB <- interaction(DataLinux$Entorno, DataLinux$Compilador, DataLinux$Acelerador, DataLinux$Escena, drop = TRUE)

# 4.4 Aplicación sobre los datos originales (sin transformar).
verificarNormalidad(modelA, titulo = "Modelo A (original)")
verificarHomocedasticidad(modelA, gruposA, titulo = "Modelo A (original)")
verificarIndependencia(modelA, titulo = "Modelo A (original)")

verificarNormalidad(modelB, titulo = "Modelo B (original)")
verificarHomocedasticidad(modelB, gruposB, titulo = "Modelo B (original)")
verificarIndependencia(modelB, titulo = "Modelo B (original)")

# Gráficos diagnósticos estándar de R (complemento).
#plot(modelA)
#plot(modelB)

#------------------------- 5. Transformación de Datos. -------------------------
print("#------------------------- 5. Transformación de Datos. -------------------------")
# Si los supuestos no se cumplen con los datos originales, se aplican transformaciones de menor a mayor
# agresividad: raíz cuadrada -> raíz cúbica -> logaritmo.

# 5.1 Función de transformación de la variable respuesta.
transformar <- function(y, tipo = c("sqrt", "cub", "log")) {
  tipo <- match.arg(tipo)
  switch(tipo,
    sqrt = sqrt(y),
    cub  = sign(y) * abs(y)^(1/3),
    log  = log(y))
}

# 5.2 Función que ajusta el modelo con la respuesta transformada, imprime el ANOVA tipo II
# y evalúa los supuestos con las funciones de la sección 4.
# 'formula' es la del modelo original; solo se reemplaza la variable respuesta.
evaluarTransformacion <- function(formula, datos, grupos, tipo, titulo = "Modelo", orden = NULL, alfa = 0.05) {
  nombre <- switch(tipo, sqrt = "Raíz cuadrada", cub = "Raíz cúbica", log = "Logaritmo")
  etiqueta <- paste0(titulo, " (", nombre, ")")
  print(paste("------------------------- Transformación:", etiqueta, "-------------------------"))

  respuesta <- all.vars(formula)[1]
  datos$T_resp <- transformar(datos[[respuesta]], tipo)
  model <- lm(update(formula, T_resp ~ .), data = datos)
  print(Anova(model, type = "II"))

  pN <- verificarNormalidad(model, titulo = etiqueta, alfa = alfa)$p.value
  pH <- verificarHomocedasticidad(model, grupos, titulo = etiqueta, alfa = alfa)[["Pr(>F)"]][1]
  pI <- verificarIndependencia(model, orden = orden, titulo = etiqueta, alfa = alfa)$p.value

  invisible(list(tipo = tipo, model = model, p = c(Normalidad = pN, Homocedasticidad = pH, Independencia = pI), cumple = (pN >= alfa) & (pH >= alfa)))
}

# 5.3 Función que prueba las transformaciones en orden y se detiene en la primera suficiente.
# Criterio: normalidad y homocedasticidad.
seleccionarTransformacion <- function(formula, datos, grupos, titulo = "Modelo", orden = NULL, alfa = 0.05) {
  resumen <- data.frame()
  for (tipo in c("sqrt", "cub", "log")) {
    res <- evaluarTransformacion(formula, datos, grupos, tipo, titulo, orden, alfa)
    resumen <- rbind(resumen, data.frame(Transformacion = tipo, t(signif(res$p, 4)), Cumple = res$cumple))
    if (res$cumple) {
      print(paste0("[", titulo, "] Transformación seleccionada: ", tipo, " (la menos agresiva que cumple los supuestos)."))
      print(resumen)
      return(invisible(res))
    }
  }
  print(paste0("[", titulo, "] Ninguna transformación cumple ambos supuestos. ", "Considerar ANOVA robusto/no paramétrico (p. ej. ART) y reportarlo como limitación."))
  print(resumen)
  invisible(res)
}

# 5.4 Aplicación. Solo se ejecuta si los supuestos fallaron con los datos originales (sección 4).
library(car)
transA <- seleccionarTransformacion(formula(modelA), Data, gruposA, titulo = "Modelo A")
transB <- seleccionarTransformacion(formula(modelB), DataLinux, gruposB, titulo = "Modelo B")

# Modelos finales que se usarán en el post-hoc y los gráficos finales.
modelA_final <- transA$model
modelB_final <- transB$model

#------------------------- 6. Análisis Post-Hoc. -------------------------
print("#------------------------- 6. Análisis Post-Hoc. -------------------------")
library(lsmeans)
library(emmeans)
library(multcomp)

# Tipo de transformación seleccionada en la sección 5 ("none" si no hizo falta transformar).
tipoA <- if (exists("transA") && transA$cumple) transA$tipo else "none"
tipoB <- if (exists("transB") && transB$cumple) transB$tipo else "none"
if (!exists("modelA_final")) { modelA_final <- modelA }
if (!exists("modelB_final")) { modelB_final <- modelB }

gridTransformado <- function(model, tipo) {
  rg <- ref_grid(model)
  if (tipo == "none") return(rg)
  update(rg, tran = switch(tipo,
    sqrt = "sqrt",
    cub  = make.tran("power", 1/3),
    log  = "log"))
}

gridA <- gridTransformado(modelA_final, tipoA)
gridB <- gridTransformado(modelB_final, tipoB)

# 6.2 Configuración dentro de cada Acelerador (Modelo A).
marginal <- lsmeans(gridA, pairwise ~ Configuracion | Acelerador, adjust = "tukey")
print(marginal)
print(cld(marginal$lsmeans, alpha = 0.05, Letters = letters, adjust = "tukey"))

# 6.3 Acelerador dentro de cada Configuración (Modelo A): ¿bvh es más rápido en todos los entornos?
marginal <- lsmeans(gridA, pairwise ~ Acelerador | Configuracion, adjust = "tukey")
print(marginal)

# 6.4 Compilador dentro de cada Entorno y Acelerador (Modelo B, solo Linux): GCC vs Clang.
marginal <- lsmeans(gridB, pairwise ~ Compilador | Entorno * Acelerador, adjust = "tukey")
print(marginal)

# 6.5 Entorno dentro de cada Compilador y Acelerador (Modelo B): nativo vs WSL vs Hyper-V vs VirtualBox.
marginal <- lsmeans(gridB, pairwise ~ Entorno | Compilador * Acelerador, adjust = "tukey")
print(marginal)
print(cld(marginal$lsmeans, alpha = 0.05, Letters = letters, adjust = "tukey"))

# 6.6 Solo si la transformación es logarítmica: las diferencias se expresan como RAZONES de tiempo
#     (p. ej. 1.42 = 42% más lento), con intervalos de confianza al 95%. Base para la relevancia práctica.
if (tipoA == "log") {
  print(confint(pairs(lsmeans(gridA, ~ Configuracion | Acelerador), adjust = "tukey"), type = "response"))
}
if (tipoB == "log") {
  print(confint(pairs(lsmeans(gridB, ~ Compilador | Entorno * Acelerador)), type = "response"))
}

#------------------------- 7. Gráficos de Promedios. -------------------------
print("#------------------------- 7. Gráficos de Promedios. -------------------------")
# Promedios y error estándar en la escala usada para el análisis (transformada, si aplica).

library(FSA)
library(ggplot2)

etiquetaY <- function(tipo) {
  switch(tipo, none = "Tiempo (s)", sqrt = "Raíz cuadrada del tiempo",
         cub = "Raíz cúbica del tiempo", log = "Logaritmo del tiempo")
}

Data$T_final      <- if (tipoA == "none") Data$Tiempo else transformar(Data$Tiempo, tipoA)
DataLinux$T_final <- if (tipoB == "none") DataLinux$Tiempo else transformar(DataLinux$Tiempo, tipoB)

pd <- position_dodge(0.4)

# 7.1 Configuración x Acelerador (Modelo A).
Sum <- Summarize(T_final ~ Configuracion + Acelerador, data = Data, digits = 3)
Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits = 3)
print(Sum)

igc <- ggplot(Sum, aes(x = Configuracion, y = mean, color = Acelerador)) +
geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.2, linewidth = 0.7, position = pd) +
geom_point(shape = 15, size = 4, position = pd) + theme_bw() +
theme(axis.title = element_text(face = "bold"), axis.text.x = element_text(angle = 45, hjust = 1)) +
scale_colour_manual(values = c("black", "red")) + ylab(etiquetaY(tipoA)) +
ggtitle("Promedio por Configuración y Acelerador")
print(igc)

# 7.2 Configuración x Acelerador, separado por Escena (¿el patrón se repite en cada escena?).
# Summarize() admite máximo dos factores, por lo que se calcula por escena y luego se unen los resultados.
Sum <- do.call(rbind, lapply(levels(Data$Escena), function(e) {
  s <- Summarize(T_final ~ Configuracion + Acelerador, data = droplevels(subset(Data, Escena == e)), digits = 3)
  s$Escena <- e
  s
}))
Sum$Escena <- factor(Sum$Escena, levels = levels(Data$Escena))
Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits = 3)
print(Sum)

igc <- ggplot(Sum, aes(x = Configuracion, y = mean, color = Acelerador)) +
geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.2, linewidth = 0.7, position = pd) +
geom_point(shape = 15, size = 3, position = pd) + theme_bw() + facet_wrap(~ Escena, scales = "free_y") +
theme(axis.title = element_text(face = "bold"), axis.text.x = element_text(angle = 45, hjust = 1)) +
scale_colour_manual(values = c("black", "red")) + ylab(etiquetaY(tipoA)) +
ggtitle("Promedio por Configuración y Acelerador, según Escena")
print(igc)

# 7.3 Entorno x Compilador (Modelo B, solo Linux).
Sum <- Summarize(T_final ~ Entorno + Compilador, data = DataLinux, digits = 3)
Sum$se = Sum$sd / sqrt(Sum$n)
Sum$se = signif(Sum$se, digits = 3)
print(Sum)

igc <- ggplot(Sum, aes(x = Entorno, y = mean, color = Compilador)) +
geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.2, linewidth = 0.7, position = pd) +
geom_point(shape = 15, size = 4, position = pd) + theme_bw() +
theme(axis.title = element_text(face = "bold")) +
scale_colour_manual(values = c("black", "red")) + ylab(etiquetaY(tipoB)) +
ggtitle("Promedio por Entorno y Compilador (entornos Linux)")
print(igc)

#------------------------- 8. Gráfico de Datos Destransformados. -------------------------
print("#------------------------- 8. Gráfico de Datos Destransformados. -------------------------")
# Los promedios de mínimos cuadrados y sus IC se calculan en la escala transformada y se regresan
# a segundos con la función inversa (type = "response"). No se destransforma la desviación estándar,
# porque exp(sd), sd^2 o sd^3 no son una medida de dispersión válida en la escala original.
# Nota: con log, el promedio destransformado es una media geométrica.

graficoDestransformado <- function(grid, especificacion, x, color, titulo) {
  CLD <- cld(lsmeans(grid, especificacion), alpha = 0.05, Letters = letters, adjust = "tukey", type = "response")
  CLD <- as.data.frame(CLD)
  colY <- intersect(c("response", "lsmean", "emmean"), names(CLD))[1]
  CLD$.group = gsub(" ", "", CLD$.group)
  print(CLD)

  ggplot(CLD, aes(x = .data[[x]], y = .data[[colY]], color = .data[[color]], label = .group)) +
  geom_point(shape = 15, size = 4, position = pd) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2, linewidth = 0.7, position = pd) +
  geom_text(aes(y = upper.CL), vjust = -0.6, position = pd, show.legend = FALSE) +
  theme_bw() + scale_colour_manual(values = c("black", "red")) +
  theme(axis.title = element_text(face = "bold"), axis.text = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylab("Promedio de mínimos cuadrados\nTiempo de ejecución (s)") + ggtitle(titulo)
}

# 8.1 Configuración x Acelerador (Modelo A). Las letras comparan configuraciones dentro de cada acelerador.
print(graficoDestransformado(gridA, ~ Configuracion | Acelerador, "Configuracion", "Acelerador",
      "Tiempo de ejecución por Configuración y Acelerador (IC 95%)"))

# 8.2 Entorno x Compilador (Modelo B). Las letras comparan entornos dentro de cada compilador.
print(graficoDestransformado(gridB, ~ Entorno | Compilador, "Entorno", "Compilador",
      "Tiempo de ejecución por Entorno y Compilador, entornos Linux (IC 95%)"))