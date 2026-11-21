# AquaCallao — PA4
**ISIL | Programación Avanzada de Base de Datos (30627) | Grupo 02 | Periodo 202620**

## Estado actual
Este repositorio continúa el caso académico AquaCallao de PA3. Su modelo base ya existe: Cliente, Producto, Cisterna, CargaAgua y Entrega.
- **pa3_base/**: copias sin modificar de scripts del repositorio AquaCallao-PA3. No son scripts reejecutados ni certificados en esta migración; algunos contienen pruebas que modifican datos.
- **pa4/**: plantillas iniciales de las actividades pendientes: triggers, funciones, cursores, seguridad e integración.
- **evidencias/**: capturas, resultados y registro de seguimiento por agregar.

## Integrantes y módulos PA4 (propuesta)
| Integrante | Tarea | Rama |
|---|---|---|
| Lucero Helen Corrales Granda | Trigger, tabla de auditoría si corresponde, pruebas | pa4/triggers-helen |
| Andy Alexandre Lescano Espino | Función escalar y función de tabla, consumo y pruebas | pa4/funciones-andy |
| Fernando Álvaro Quispe Trigos | Cursor, alternativa basada en conjuntos y contraste | pa4/cursores-fernando |
| Farid Alessandro Mori Barrientos | Usuarios, roles, permisos, matriz y pruebas de seguridad | pa4/seguridad-farid |
| Jorge Raúl Campoblanco Noriega | Pruebas de integración, revisión general, README y coordinación de evidencias | pa4/integracion-jorge |

## Instalación y advertencias
1. Usar una instancia **de práctica**, sin otra base existente llamada AquaCallao. Ejecutar pa3_base/01_CrearTablas.sql una sola vez: crea base, esquema y datos iniciales.
2. Revisar antes de ejecutar los scripts de procedimientos en pa3_base/sql y el reporte pa3_base/06_reporte_sector.sql. Los archivos de PA3 incluyen también pruebas que insertan o actualizan registros; **no ejecutarlos en bloque sin revisar sus efectos**.
3. Cada integrante trabaja con su copia local de SQL Server. Nunca publicar contraseñas, credenciales o datos personales.
4. Completar los archivos pa4; son solo plantillas hasta que cada autor agregue código y evidencias.
5. Ejecutar pruebas sobre datos reproducibles, documentar resultado esperado y observado y revisar interferencias de los nuevos triggers con pruebas anteriores.

## Evaluación oficial (sesiones 11–13)
- Trigger con inserted/deleted y pruebas (3 puntos).
- Función escalar y de tipo tabla, uso y justificación (2 puntos).
- Cursor, alternativa en conjuntos y evaluación crítica (2 puntos).
- Usuarios, roles, permisos y seguridad, explicación de claves/certificados (3 puntos).
- GitHub y README (4); video público de YouTube con cámaras prendidas (3); asistencia, participación y avances (3).

## Entregables por completar
- Scripts PA4 ejecutables; pruebas, pantallazos, justificación y conclusiones.
- Instrucciones reproducibles en el README; participantes y roles definitivos.
- Enlace al video público de YouTube (PENDIENTE).

**Fuentes del equipo:** repositorio AquaCallao-PA3 y enunciado PA4_30627_PROGRAMACION_AVANZADA_BD.pdf entregado por el profesor.
