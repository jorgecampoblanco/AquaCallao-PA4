# AquaCallao — PA4
**ISIL | Programación Avanzada de Base de Datos (30627) | Grupo 02 | Periodo 202620**

## Scripts de la PA4

La carpeta [pa4](pa4/) de la rama principal reúne los cinco módulos. El proyecto utiliza las tablas y procedimientos de [PA3](pa3_base/).

| Responsable | Archivo | Uso |
|---|---|---|
| Lucero Helen Corrales Granda | [01_Triggers.sql](pa4/01_Triggers.sql) | Auditoría de entregas |
| Andy Alexandre Lescano Espino | [02_Funciones.sql](pa4/02_Funciones.sql) | Porcentaje disponible y entregas por sector. [Justificación](docs/A2_Funciones.md) |
| Fernando Álvaro Quispe Trigos | [03_Cursores.sql](pa4/03_Cursores.sql) | Resumen de cisternas con cursor y consulta equivalente |
| Farid Alessandro Mori Barrientos | [Seguridad (2)](pa4/04_Validación_seguridad%20%282%29.sql) y [Seguridad (1)](pa4/04_Validación_seguridad%20%281%29.sql) | Ejecutar primero (2) para crear usuarios y roles. (1) prueba sus permisos. |
| Jorge Raúl Campoblanco Noriega | [05_PruebasIntegracion.sql](pa4/05_PruebasIntegracion.sql) | Carga, entregas, auditoría, saldo y permisos en una transacción de prueba |

## Instalación y advertencias
1. Usar una instancia **de práctica**, sin otra base existente llamada AquaCallao. Ejecutar pa3_base/01_CrearTablas.sql una sola vez: crea base, esquema y datos iniciales.
2. Revisar antes de ejecutar los scripts de procedimientos en pa3_base/sql y el reporte pa3_base/06_reporte_sector.sql. Los archivos de PA3 incluyen también pruebas que insertan o actualizan registros; **no ejecutarlos en bloque sin revisar sus efectos**.
3. Cada integrante trabaja con su copia local de SQL Server. Nunca publicar contraseñas, credenciales o datos personales.
4. Para la integración, instalar los procedimientos de carga y entrega de PA3, las secciones de creación del trigger y las dos funciones, y la configuración de seguridad (2). Ejecutar 05_PruebasIntegracion.sql completo en una ventana nueva de SSMS.
5. Ejecutar pruebas sobre datos reproducibles, documentar resultado esperado y observado y revisar interferencias de los nuevos triggers con pruebas anteriores.

## Evaluación oficial (sesiones 11–13)
- Trigger con inserted/deleted y pruebas (3 puntos).
- Función escalar y de tipo tabla, uso y justificación (2 puntos).
- Cursor, alternativa en conjuntos y evaluación crítica (2 puntos).
- Usuarios, roles, permisos y seguridad, explicación de claves/certificados (3 puntos).
- GitHub y README (4); video público de YouTube con cámaras prendidas (3); asistencia, participación y avances (3).

## Entregables por completar
- Adjuntar resultados observados, pantallazos y conclusiones.
- Guardar las capturas de integración en evidencias/jorge/.
- Enlace al video público de YouTube (PENDIENTE).

**Fuentes del equipo:** repositorio AquaCallao-PA3 y enunciado PA4_30627_PROGRAMACION_AVANZADA_BD.pdf entregado por el profesor.
