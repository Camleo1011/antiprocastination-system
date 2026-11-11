# Reglas de negocio de FocusStrike

Extraído de [`SRS.md`](SRS.md); ante cualquier diferencia, manda `SRS.md`.

Reglas de negocio (BR) de la versión 0.1, extraídas sin cambios de la sección 3.6 de la especificación de requisitos (`SRS.md`). Cuando un RF y una BR enuncian la misma regla, ambos deben mantenerse sincronizados. Los RF relacionados salen de la columna BR de la matriz de trazabilidad 4.2 del SRS.

## Control de versiones

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1 | 2026-11-11 | Equipo FocusStrike | Línea base |

## Resumen

Total de reglas de negocio: **36**.

| ID | Nombre |
|---|---|
| BR-001 | Regla del 80 % (mínimo de entrega) |
| BR-002 | Máximo de dos envíos y rectificación |
| BR-003 | Cálculo del tiempo de gracia |
| BR-004 | Matriz de puntuación por ventana y dictamen |
| BR-005 | Dictámenes de evaluación |
| BR-006 | Inicio del reloj global |
| BR-007 | Pomodoro sin penalización |
| BR-008 | Reglas aplicables a submetas |
| BR-009 | Día activo |
| BR-010 | Metas sin evidencia |
| BR-011 | Límite de duración diaria (24 h por día) |
| BR-012 | Bloqueo temporal y bloqueo administrativo |
| BR-013 | Roles excluyentes |
| BR-014 | Semántica de la planificación de la meta |
| BR-015 | Umbral de 12 horas por día para la recomendación de la IA |
| BR-016 | Ventana de tiempo de una evidencia |
| BR-017 | Reintento de evaluación |
| BR-018 | Cierre de submeta |
| BR-019 | Cálculo de la racha de días |
| BR-020 | Catálogo inicial de logros |
| BR-021 | Niveles de acceso del administrador |
| BR-022 | Eventos y preferencias de notificación push |
| BR-023 | Elegibilidad y desempate del ranking |
| BR-024 | Catálogo de categorías de meta |
| BR-025 | Edición y eliminación de metas |
| BR-026 | Datos enviados al proveedor de LLM |
| BR-027 | Submeta manual no iniciada |
| BR-028 | Zona horaria |
| BR-029 | Estados de submeta, evaluación y ventana |
| BR-030 | Equivalencia entre porcentaje y puntos |
| BR-031 | Información no dependiente solo del color |
| BR-032 | Tiempo estipulado de la submeta |
| BR-033 | Acierto en el primer envío y racha perfecta |
| BR-034 | Calendario de actividad del perfil |
| BR-035 | Consentimiento de IA y funciones disponibles |
| BR-036 | Archivos de evidencia: eliminación y limpieza |

## Reglas

### BR-001 — Regla del 80 % (mínimo de entrega)

La carga de toda evidencia de una submeta (primer o segundo envío) solo se habilita cuando ha transcurrido al menos el 80 % de su tiempo estipulado (BR-032); es una regla antifraude. Se aplica en el frontend y se valida de nuevo en el backend (HTTP 409). Es una única regla para ambos envíos: el segundo envío, que solo ocurre tras el dictamen del primero, queda siempre por encima del umbral, por lo que esta versión no define ninguna otra restricción de tiempo mínimo. El porcentaje de tiempo transcurrido y la ventana de la evidencia se calculan con el instante de recepción (fecha_carga), la hora de inicio real de la submeta y su tiempo estipulado T; si el porcentaje o la ventana registrados no coinciden con ese cálculo (tolerancia de 1 s de T), la evidencia se rechaza con HTTP 409.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-EVID-001, RF-EVID-002

### BR-002 — Máximo de dos envíos y rectificación

(a) El máximo es de 2 envíos de evidencia por submeta; Reintentar una evaluación (BR-017) no cuenta como envío. (b) El primer envío solo puede hacerse tras el 80 % del tiempo estipulado (BR-001). (c) Si el primer envío es dictaminado Excelente, la submeta se cierra con ese puntaje y no admite otro envío. (d) Si el primer envío es dictaminado Incoherente o Inválida, el usuario puede enviar una única evidencia más, desde el dictamen y hasta el fin del tiempo de gracia, usando el tiempo restante del periodo inicial y el tiempo de gracia. (e) Un primer envío recibido en el tiempo de gracia (porque no se envió en el periodo inicial) se puntúa con la tabla de gracia y, si es Incoherente o Inválida, admite un segundo envío dentro de la gracia restante **[Supuesto S-37]**. (f) El segundo envío no se admite mientras el primero esté En evaluación o en Error. (g) El dictamen del segundo envío cierra la submeta (BR-018). (h) El segundo envío vale la mitad de la tabla del periodo inicial en cualquier ventana (BR-004). El tiempo de gracia es la ventana adicional del 10 % que sigue al tiempo estipulado.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-EVID-007, RF-EVID-012, RF-EVID-016, RF-PUNT-005

### BR-003 — Cálculo del tiempo de gracia

El tiempo de gracia equivale al 10 % del tiempo estipulado de la submeta (BR-032) y se cuenta desde la finalización del 100 % del tiempo inicial.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PUNT-007

### BR-004 — Matriz de puntuación por ventana y dictamen

Los puntos de una evidencia dependen de su número de envío, de la ventana en que se recibe y de su dictamen. Primer envío en el periodo inicial: Excelente = 100, Incoherente = 50, Inválida = 0. Primer envío en el tiempo de gracia (la mitad): Excelente = 50, Incoherente = 25, Inválida = 0. Segundo envío (la mitad, en cualquier ventana, incluido el periodo inicial): Excelente = 50, Incoherente = 25, Inválida = 0. Sin evidencia en el periodo inicial: 0 provisionales. El puntaje de la submeta es la suma de los puntos de sus evidencias: con un solo envío es ese valor (máximo 100); con dos envíos es la suma con tope de 90, de modo que quien necesitó dos envíos no iguala a quien acertó en el primero. Ejemplos oficiales: Incoherente (50) + Excelente (50) = 100, que por el tope da 90; Incoherente (50) + Incoherente (25) = 75; Inválida (0) + Excelente (50) = 50; Incoherente (50) + Inválida (0) = 50; Inválida + Inválida = 0; primer envío Excelente en el periodo inicial = 100 y cierra. La tabla completa de las 25 combinaciones está en 3.6.1. El puntaje acumulado del usuario es la suma de los puntajes finales de sus submetas cerradas con calificación, con 1 % = 1 punto (BR-030).

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PUNT-001, RF-PUNT-002, RF-PUNT-003, RF-PUNT-004, RF-PUNT-005, RF-PUNT-006, RF-PUNT-010, RF-PUNT-014

### BR-005 — Dictámenes de evaluación

El LLM evalúa cada evidencia y retorna uno de tres dictámenes con una justificación. Inválida: la evidencia es legible pero no guarda relación con la submeta o es de otro tema (por ejemplo, una imagen en blanco o una captura de otra materia). Un archivo vacío, corrupto o ilegible al prepararlo, o de formato no soportado, no recibe dictamen: se rechaza al subirlo, sin llamar al LLM y sin consumir envío (RF-IA-012). Incoherente: la evidencia guarda relación con la submeta pero es insuficiente (por ejemplo, cubre una parte menor del trabajo declarado). Excelente: la evidencia corresponde a la submeta, es acorde y demuestra bien el trabajo realizado. **[Supuesto S-36]** Inválida es un dictamen que puntúa 0 y consume el envío; no es un Error. Error es solo un fallo técnico del servicio de IA (timeout tras los reintentos, error 5xx, cuota agotada o respuesta fuera del esquema) que no puntúa y admite Reintentar sin consumir envío. 'Sin envío' es la ausencia de evidencia dentro del tiempo estipulado inicial y no es un dictamen del LLM.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-EVID-006, RF-IA-008, RF-IA-012

### BR-006 — Inicio del reloj global

El reloj global de una submeta inicia a la hora programada de su fecha si el modo es automático; si el modo es manual, inicia cuando el usuario la inicia y su duración es el tiempo estipulado de la submeta (BR-032). El retraso en el inicio manual es responsabilidad del usuario (ver BR-027).

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-012, RF-META-013

### BR-007 — Pomodoro sin penalización

Las pausas, abandonos o la no utilización del Pomodoro no afectan la puntuación ni el reloj global de la submeta; solo rige el tiempo global de entrega.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-POM-006

### BR-008 — Reglas aplicables a submetas

Las submetas diarias se rigen por las mismas reglas de evidencia, puntuación y tiempo de gracia, que se aplican a cada submeta de forma independiente.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-005, RF-PUNT-010

### BR-009 — Día activo

Se considera día activo el día calendario, en la zona horaria del usuario, en que el usuario actúa: inicia a mano una submeta de modo manual o envía una evidencia (el día es el de recepción de la evidencia por el servidor); se cuenta una sola vez por día. No activan ningún día: el inicio automático de una submeta; los cierres que provoca el sistema (fin del tiempo de gracia, vencimiento de una meta sin evidencia, submeta manual nunca iniciada, BR-027); el cierre administrativo (RF-ADM-019); una carga rechazada (RF-IA-012); ni la finalización por sí misma, que cuenta solo como consecuencia de una evidencia enviada ese día, la cual ya activa el día por el envío. En una meta sin evidencia solo el inicio manual activa el día; una submeta automática de una meta sin evidencia no activa ninguno. Efecto aceptado: una meta sin evidencia con inicio automático nunca activa un día ni suma a la racha, y el inicio automático sí cuenta para el logro 'Primer paso' (BR-020). Un día activo solo por el envío de una evidencia tiene 0 submetas iniciadas a mano. Es la única definición de día activo: la usan la racha (BR-019), el calendario de actividad (BR-034) y la vista de inicio (RF-AGEN-005). La aplicación calcula la fecha local del día activo (la del instante del evento en la zona horaria del usuario) y la entrega al registro; la base de datos no la deriva.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PER-002, RF-PER-003, RF-ADM-019
- **Otros requisitos citados en el enunciado:** RF-IA-012, RF-AGEN-005

### BR-010 — Metas sin evidencia

Las submetas de metas que no requieren evidencia no generan puntaje ni evaluación LLM; al finalizar el tiempo estipulado se cierran como finalizadas 'sin calificación' (puntaje vacío, no cero) y no suman puntos al perfil.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-006, RF-META-026, RF-AGEN-003

### BR-011 — Límite de duración diaria (24 h por día)

Una meta DEBE cumplir tiempo total ÷ días destinados ≤ 24 horas (límite inclusivo). 24 h en 1 día es válido —con horario de 00:00 a 24:00, porque la hora de fin puede ser 24:00 (RF-META-005, RF-META-020)—; 25 h en 1 día no lo es; 250 h exigen al menos 11 días. Esta regla sustituye la formulación anterior 'mayor a 24 h' y la del script 'menor a 24'. El cociente es un promedio diario, no un tope por submeta (cada submeta, además, cabe en el horario diario de la meta, BR-014), y la duración de un horario se mide como la diferencia de las horas locales del reloj (fin menos inicio), sin ajustes por cambio de horario de verano. **[Supuesto S-49]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-008, RF-META-010, RF-META-035
- **Otros requisitos citados en el enunciado:** RF-META-005, RF-META-020

### BR-012 — Bloqueo temporal y bloqueo administrativo

Existen dos bloqueos independientes: (a) temporal, automático, de 15 min tras 5 intentos fallidos consecutivos (respuesta 429); (b) administrativo, indefinido, impuesto y retirado solo por un administrador (respuesta 403). Ningún evento ajeno (cierre de submeta, cambio de puntaje) puede levantar un bloqueo ni reiniciar el contador de intentos.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-AUT-012, RF-AUT-014, RF-ADM-004

### BR-013 — Roles excluyentes

Una cuenta tiene exactamente un rol: cliente o administrador. Las cuentas administrador no tienen metas, submetas, evidencias ni puntaje de ranking. Quien necesite ambas funciones usa dos cuentas con correos distintos. No se puede cambiar el rol de una cuenta que tenga datos: un cliente tiene datos si tiene al menos una meta, una sesión Pomodoro, un logro, un día activo o un puntaje mayor que 0, y un administrador tiene datos si cerró al menos una submeta (RF-ADM-019). La zona horaria, las preferencias de notificación, la aceptación de IA y las suscripciones push no cuentan como datos: se eliminan al pasar de cliente a administrador y, al pasar de administrador a cliente, se crean con valores por defecto, con zona America/Bogota hasta el primer inicio de sesión (RF-ADM-020, RF-AUT-016). **[Supuesto S-54]** Una cuenta con datos no cambia de rol: se elimina la cuenta o se crea una nueva. El rol solo cambia mediante la operación de cambio de rol (RF-ADM-009, RF-ADM-020; en el script, el procedimiento sp_cambiar_rol, que recibe el identificador del administrador que lo ejecuta y solo acepta a un super, BR-021); la base de datos rechaza la modificación directa del rol por cualquier otra vía. **[Supuesto S-48]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-AUT-013, RF-ADM-006, RF-ADM-009, RF-ADM-020, RNF-014
- **Otros requisitos citados en el enunciado:** RF-ADM-019, RF-AUT-016

### BR-014 — Semántica de la planificación de la meta

(1) Tiempo total = horas totales dedicadas a la meta, entero ≥ 1. (2) Días destinados = número de fechas de trabajo (entero ≥ 1). (3) El usuario define las fechas de trabajo eligiéndolas, o indica solo el número de días (≥ 2) dentro de un rango y la IA propone las fechas según la descripción de la meta; el usuario confirma. (4) Cada fecha de trabajo origina exactamente una submeta. (5) La suma de los tiempos estipulados de las submetas (BR-032) es igual al tiempo total. (6) Cada submeta cabe en el horario diario de la meta, cuya hora de fin puede ser 24:00. (7) Tipo: un_dia si hay 1 día destinado, multidia si hay 2 o más. Los días destinados caben en el rango de fechas de la meta (de fecha_inicio a fecha_fin, ambos inclusive): no puede haber más días destinados que días en el rango (numeral 11). (8) Un selector de días de la semana en la interfaz es solo una ayuda para preseleccionar fechas; lo persistido son fechas concretas. (9) Con desglose manual, el usuario define para cada fecha de trabajo el nombre, la hora de inicio y la duración de su submeta, que cumple de (4) a (6); la duración de cada submeta es un número entero de horas, mínimo 1 h; no hay más de una submeta por fecha, tampoco en el desglose manual (RF-META-033 a RF-META-035). (10) La duración de cada submeta es un número entero de horas, mínimo 1 h, también cuando la genera el Agente IA: el LLM debe devolver horas enteras de 1 h o más y el sistema lo valida (RF-IA-002, RF-META-003); como cada submeta dura al menos 1 h, el tiempo total de una meta multidía debe ser mayor o igual que los días destinados y, si no lo es, la meta no admite un desglose válido y se rechaza con HTTP 422 al crearla o editarla, antes de guardarla (CU-005, CU-008a, CU-025). (11) Los días destinados no superan el número de días del rango de fechas de la meta; si lo superan, la meta se rechaza con HTTP 422 en el mismo momento. **[Supuestos S-04, S-05, S-33, S-34]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-003, RF-META-015, RF-META-016, RF-META-017, RF-META-019, RF-META-020, RF-META-031, RF-META-033, RF-META-034, RF-META-035, RF-META-036, RNF-012, RNF-014
- **Otros requisitos citados en el enunciado:** RF-IA-002

### BR-015 — Umbral de 12 horas por día para la recomendación de la IA

Se aplica por día de trabajo en toda meta, de 1 día o multidía: promedio diario = tiempo total ÷ días destinados. Hasta 12 h inclusive no se invoca la recomendación; más de 12 h y hasta 24 h activa la recomendación de la IA (RF-META-008), que el usuario puede aceptar, modificar o rechazar (RF-META-009) y que en metas multidía incluye descanso (RF-META-023); más de 24 h se rechaza y el usuario debe dedicar más días (BR-011). El umbral de 12 h es una recomendación de bienestar y nunca impide guardar una meta válida; sin aceptación del servicio externo de IA la recomendación no se obtiene (no se llama al LLM) y la meta se guarda igual (BR-035). El umbral es el promedio diario, no un tope por submeta, también en el desglose manual: allí cada fecha tiene una sola submeta, pero el umbral sigue siendo el promedio (tiempo total ÷ días destinados) y una submeta de más de 12 h no activa la recomendación por sí sola; el único límite duro es 24 h por día (BR-011). **[Supuesto S-49]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-004, RF-META-008, RF-META-023, RF-META-030
- **Otros requisitos citados en el enunciado:** RF-META-009

### BR-016 — Ventana de tiempo de una evidencia

Cada evidencia (primer o segundo envío) pertenece a la ventana (inicial o gracia) en la que el servidor la recibe. La evaluación de una evidencia recibida dentro del plazo se completa y puntúa aunque el plazo expire durante la evaluación. Pasado el fin del tiempo de gracia no se aceptan más evidencias.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-EVID-010, RF-EVID-011, RF-EVID-013

### BR-017 — Reintento de evaluación

Reintentar una evaluación en Error reevalúa la misma evidencia, no crea una evidencia nueva y no consume un intento de envío. La evidencia conserva la ventana en la que fue recibida (BR-016). Cada llamada al LLM del reintento genera su propio registro de uso (RF-ADM-007).

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-EVID-008
- **Otros requisitos citados en el enunciado:** RF-ADM-007

### BR-018 — Cierre de submeta

Una submeta pasa a finalizada solo cuando: (a) su primer envío recibe dictamen Excelente (100 puntos en el periodo inicial, 50 en gracia); (b) su segundo envío recibe dictamen, en cuyo caso se cierra en ese instante sin esperar el fin de la gracia **[Supuesto S-40]**; (c) expira el tiempo de gracia sin segundo envío y sin evaluaciones pendientes ni en Error, con el puntaje del primer envío o 0 si no hubo envío; si el dictamen del primer envío (Incoherente o Inválida) llega cuando la gracia ya terminó, la submeta se cierra en el instante del dictamen con el puntaje de ese envío, porque no admite segundo envío; (d) vence el tiempo estipulado de una meta sin evidencia (BR-010); (e) vence sin iniciar una submeta manual (BR-027: 0 puntos si la meta requiere evidencia, sin calificación si no la requiere); o (f) un administrador la cierra después de 48 horas de una evaluación en Error, con su puntaje provisional (RF-ADM-019). Mientras tanto permanece en curso con puntaje provisional: la suma de los puntos de las evidencias ya evaluadas (con tope de 90 si hay dos evaluadas), contando 0 para las evidencias en evaluación o en Error. Al cerrarse, su puntaje final se suma al del perfil en la misma transacción (RF-PUNT-014). Una evaluación en Error mantiene abierta la submeta hasta que se resuelva con Reintentar o hasta el cierre administrativo de la letra (f) **[Supuesto S-22]**.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PUNT-006, RF-PUNT-008, RF-PUNT-011, RF-PUNT-013, RF-ADM-019
- **Otros requisitos citados en el enunciado:** RF-PUNT-014

### BR-019 — Cálculo de la racha de días

La racha actual es el número de días calendario consecutivos con día activo (BR-009, la misma definición que usa el calendario de actividad, BR-034) hasta hoy; si hoy aún no hay actividad, cuenta hasta ayer y no se reinicia hasta que termine el día de hoy sin actividad. La racha máxima es el mayor valor histórico de la racha actual. **[Supuesto S-14]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PER-007, RF-PER-009, RF-AGEN-005

### BR-020 — Catálogo inicial de logros

**[Supuesto S-15]** (1) Primer paso: iniciar la primera submeta, a mano o por inicio automático; un inicio automático otorga el logro aunque no active el día (BR-009). (2) Constante: racha de 7 días. (3) Imparable: racha de 30 días. (4) Impecable: cerrar una submeta con acierto Excelente en el primer envío recibido en el periodo inicial (BR-033; 100 puntos). (5) Segunda oportunidad: cerrar una submeta en la que el segundo envío sumó puntos (más de 0). (6) Meta cumplida: finalizar todas las submetas de una meta multidía habiendo iniciado cada una; las cerradas por no inicio (BR-027) no cuentan. (7) Mil puntos: alcanzar 1 000 puntos acumulados. Los logros no otorgan puntos y no afectan el ranking **[Supuesto S-16]**. **[Supuesto S-38]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-LOGR-001, RF-LOGR-002

### BR-021 — Niveles de acceso del administrador

**[Supuesto S-17]** super: todas las funciones, incluida la creación y eliminación de administradores y la asignación de niveles. moderador: consultar cuentas, crear y editar cuentas cliente, bloquear y desbloquear cuentas cliente, consultar evidencias, ranking y métricas de uso de la aplicación, y listar y cerrar las submetas con evaluación en Error durante 48 horas (RF-ADM-018, RF-ADM-019) **[Supuesto S-43]**. soporte: solo lectura de cuentas, evidencias y ranking. Las métricas del LLM, la eliminación de cuentas, la creación o edición de cuentas administrador y el bloqueo y desbloqueo de cuentas administrador son exclusivas de super: el moderador que intenta bloquear o desbloquear una cuenta administrador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y no cambia nada. Siempre debe existir al menos un administrador super sin bloqueo administrativo: ninguna operación (eliminar, bloquear, cambiar el rol o cambiar el nivel) puede dejar al sistema sin él **[Supuesto S-47]**. Último super: el único administrador de nivel super sin bloqueo administrativo. Dos operaciones simultáneas que afecten a supers no pueden dejar al sistema sin él: una se completa y la otra responde HTTP 409. La única excepción es el arranque inicial, antes de que el despliegue cree el primer super con variables de entorno (RF-ADM-017), lo que ocurre solo si no existe ningún administrador super (pueden existir administradores de otros niveles, que no se modifican). Matriz por acción: consultar cuentas, evidencias y ranking —super, moderador y soporte—; métricas de uso de la aplicación, crear y editar cuentas cliente, bloquear y desbloquear cuentas cliente, y listar y cerrar evaluaciones en Error —super y moderador—; métricas del LLM, crear y editar cuentas administrador, bloquear y desbloquear cuentas administrador, asignar niveles, cambiar roles y eliminar cuentas —solo super—. El cambio de nivel de acceso y el cambio de rol los ejecuta siempre un actor identificado, que debe ser un administrador de nivel super: la operación recibe el identificador del administrador que la solicita y la rechaza (HTTP 403) si no existe o no es super.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-ADM-001, RF-ADM-004, RF-ADM-009, RF-ADM-010, RF-ADM-014, RF-ADM-015, RF-ADM-017, RF-ADM-018, RF-ADM-019, RNF-014

### BR-022 — Eventos y preferencias de notificación push

**[Supuesto S-19]** Eventos: recordatorio 10 min antes del inicio de una submeta, apertura de la carga de evidencia (80 %), apertura del tiempo de gracia, resultado de evaluación y logro obtenido. Solo se envía si la preferencia está activada y existe suscripción vigente. Los correos transaccionales (recuperación de contraseña, bloqueo temporal) se envían siempre, independientemente de esta preferencia.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-NOT-001, RF-NOT-003, RF-NOT-004, RF-NOT-005, RF-NOT-006, RF-NOT-007, RF-NOT-008

### BR-023 — Elegibilidad y desempate del ranking

El ranking de clientes incluye las cuentas con rol cliente no bloqueadas administrativamente. Empates: misma posición y orden alfabético por nombre. Se muestran solo nombre y puntaje. El ranking de administración (RF-ADM-005, CU-021) es distinto: incluye además las cuentas bloqueadas con su marca de estado. **[Supuestos S-18, S-20]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-RANK-003, RF-RANK-004, RF-RANK-005
- **Otros requisitos citados en el enunciado:** RF-ADM-005

### BR-024 — Catálogo de categorías de meta

Las categorías permitidas son: estudio, bienestar, juegos, hábitos de vida, deporte, lectura, programación, idiomas, trabajo, proyecto personal y otro.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-001

### BR-025 — Edición y eliminación de metas

Los parámetros de planificación (días, tiempo total, fechas, horario) solo son editables mientras ninguna submeta de la meta haya sido iniciada; al editarlos se regeneran las submetas. Eliminar una meta elimina sus submetas, evidencias y evaluaciones, pero no revierte los puntos ya sumados al perfil ni elimina los días activos del usuario. **[Supuestos S-11, S-12]** **[Supuesto S-54]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-002c, RF-META-027, RF-META-028, RF-META-037

### BR-026 — Datos enviados al proveedor de LLM

Al proveedor solo se envía el contenido estrictamente necesario: evidencia, nombre y descripción de la meta, descripción de la submeta y duración. No se envían nombre, correo ni identificadores del usuario ni el nombre original del archivo de la evidencia; las imágenes se envían sin metadatos EXIF (ubicación, fecha de captura y dispositivo) y con la resolución mínima útil para evaluarlas **[Supuesto S-R12]**. El usuario acepta explícitamente el uso de un servicio externo de IA antes de la primera llamada con sus datos, sea para desglose, recomendaciones, sugerencia de fechas o evaluación (RF-IA-007); si no acepta, se aplica BR-035. Los datos enviados no deben ser usados por el proveedor para entrenar modelos; esta condición se verifica al seleccionar el proveedor y se cumple con el plan de pago contratado. Con usuarios reales se usa solo un plan de pago del proveedor con límite de gasto configurado; la capa gratuita se usa únicamente con datos sintéticos de prueba y nunca con datos de usuarios reales. **[Supuesto S-25]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-IA-005, RF-IA-006, RF-IA-007, RF-IA-010

### BR-027 — Submeta manual no iniciada

Una submeta en modo manual puede iniciarse a cualquier hora de su fecha programada, de 00:00:00 a 23:59:59 en la zona horaria del usuario, también antes de su horario programado, que no limita el inicio; antes de su fecha programada no puede iniciarse (HTTP 409). Si no se inició durante su fecha, se cierra como finalizada, sin tiempo de gracia: con 0 puntos si la meta requiere evidencia y sin calificación (puntaje vacío, BR-010) si no la requiere. **[Supuesto S-09]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PER-002, RF-META-026

### BR-028 — Zona horaria

Todos los horarios de metas y submetas, el inicio automático, el día activo, el calendario de actividad y las notificaciones se interpretan en la zona horaria IANA del usuario, que se detecta del navegador al registrarse y se puede editar en el perfil; America/Bogota rige si el navegador no la informa y, hasta su primer inicio de sesión, en las cuentas cliente creadas por un administrador o convertidas desde administrador; en ese primer inicio se detecta la del navegador (RF-ADM-021, RF-AUT-016). La BD almacena marcas de tiempo absolutas para lo ocurrido (inicio real, cierre, evidencias) y fechas y horas locales para lo programado. Al cambiar la zona, las submetas pendientes conservan su fecha y hora locales y los días activos ya registrados no se recalculan (RF-PER-017). **[Supuesto S-27]** **[Supuesto S-52]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-AUT-015, RF-AUT-016, RF-PER-008, RF-PER-017, RF-META-013, RF-ADM-021

### BR-029 — Estados de submeta, evaluación y ventana

Submeta: pendiente → en curso (inicio manual o automático) → finalizada (BR-018); pendiente → finalizada (BR-027). Evaluación: en evaluación → evaluada | error; error → en evaluación (reintento, BR-017). Ventana (derivada, no es un estado): inicial desde el inicio del reloj hasta el 100 %; gracia durante el 10 % siguiente; cerrada después. Una submeta se considera iniciada cuando su reloj llegó a correr (tiene hora de inicio real). Meta (derivada de sus submetas, no editable), evaluada en este orden de precedencia: (1) pendiente si no tiene submetas (desglose pendiente, RF-META-024); (2) finalizada si todas sus submetas están finalizadas, aunque ninguna se haya iniciado (por ejemplo, todas cerradas por BR-027); (3) en curso si alguna fue iniciada y alguna no está finalizada; (4) pendiente en los demás casos (ninguna iniciada y alguna no finalizada). Una meta nunca es a la vez pendiente y finalizada. El estado pendiente_evidencia no existe: la carga habilitada, el tiempo de gracia, la evaluación pendiente y el puntaje provisional se derivan del reloj y de las entidades evidencia y evaluacion, y no se almacenan como estado.

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-024, RF-META-026, RF-AGEN-003, RF-PUNT-011

### BR-030 — Equivalencia entre porcentaje y puntos

El puntaje de una submeta se expresa de 0 a 100 y 1 % equivale a 1 punto del puntaje acumulado del perfil, sin ponderar por duración. **[Supuesto S-29]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PUNT-008, RF-PUNT-014

### BR-031 — Información no dependiente solo del color

Todo estado, resultado o ventana mostrado con color debe incluir además texto o ícono. (Soporte de RNF-009.)

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-AGEN-003
- **Otros requisitos citados en el enunciado:** RNF-009

### BR-032 — Tiempo estipulado de la submeta

El tiempo estipulado T de una submeta es la duración de su propio horario: hora de fin menos hora de inicio de la submeta (la hora de fin puede ser 24:00). Es la base de la regla del 80 % (BR-001), del tiempo de gracia (BR-003) y de las ventanas de puntaje. La suma de los T de las submetas de una meta es igual al tiempo total (BR-014). En una meta de 1 día la submeta única empieza en la hora de inicio del horario de la meta y dura exactamente el tiempo total (RF-META-031): una meta de 3 h con horario 08:00 a 12:00 da una submeta de 08:00 a 11:00 con T = 3 h; el horario de la meta es la franja disponible y no la duración de la submeta. En modo manual el reloj dura T desde el inicio real (BR-006). **[Supuesto S-33]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-031, RF-META-033, RF-EVID-001, RF-PUNT-007

### BR-033 — Acierto en el primer envío y racha perfecta

Acierto en el primer envío: la submeta se cerró porque su primer envío, recibido en el periodo inicial, fue dictaminado Excelente (100 puntos). El logro Impecable (BR-020) y la racha perfecta (número de submetas calificadas consecutivas, por orden de cierre, cerradas con acierto en el primer envío) solo cuentan con ese acierto: un primer envío Excelente recibido en el tiempo de gracia (50 puntos) no cuenta; tampoco una submeta cerrada por el segundo envío ni con cualquier otro resultado, y todas ellas reinician la racha perfecta a 0; una submeta sin calificación y una cerrada por un administrador tras un Error persistente (RF-ADM-019) no la alteran **[Supuesto S-44]**. La racha perfecta se alimenta solo del dictamen de las evidencias que envía el usuario; los cierres que provoca el sistema (fin de la gracia, BR-027) no son acciones del usuario ni activan el día (BR-009), pero, por ser calificados, reinician la racha perfecta como cualquier otro resultado. Los demás logros no otorgan puntos. **[Supuesto S-38]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PER-012, RF-LOGR-002
- **Otros requisitos citados en el enunciado:** RF-ADM-019

### BR-034 — Calendario de actividad del perfil

El perfil muestra los últimos 12 meses móviles que terminan hoy (zona horaria del usuario; hasta 366 días) con una celda por día. Un día activo (BR-009, la misma definición que usa la racha, BR-019) se resalta con un único tono de verde, igual para todos los días activos, y un día no activo no se resalta. Ninguna información depende solo del color (BR-031): cada celda tiene etiqueta de texto y existe una alternativa textual equivalente (RF-PER-013).

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-PER-003, RF-PER-011, RF-PER-013, RF-PER-014, RF-PER-015, RF-PER-016

### BR-035 — Consentimiento de IA y funciones disponibles

Las funciones que envían datos al servicio externo de IA son el desglose automático (RF-META-003), las recomendaciones (RF-META-008), la sugerencia de fechas (RF-META-032) y la evaluación de evidencia (RF-EVID-005). Requieren la aceptación previa del usuario (RF-IA-007). Sin aceptación se permiten las metas que no requieren evidencia: de 1 día, o multidía con desglose manual (RF-META-033); se deniegan, con HTTP 403 y el aviso de consentimiento, las metas que requieren evidencia, el desglose automático, las fechas sugeridas, las recomendaciones y la carga de evidencia (RF-IA-011), tanto al crear como al editar una meta (RF-META-037). El aviso se muestra cada vez que el usuario intenta una de esas funciones y puede aceptarlo en cualquier momento. Las recomendaciones son informativas y nunca bloquean guardar una meta (BR-015): sin aceptación se deniega la solicitud de recomendaciones (HTTP 403, sin llamada al LLM), pero la meta que no requiere evidencia se guarda igual. El desglose manual está disponible también para quien aceptó la IA (RF-META-036). **[Supuesto S-46]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-027, RF-META-030, RF-META-033, RF-META-036, RF-META-037, RF-IA-007, RF-IA-010, RF-IA-011
- **Otros requisitos citados en el enunciado:** RF-META-003, RF-META-008, RF-META-032, RF-EVID-005

### BR-036 — Archivos de evidencia: eliminación y limpieza

El archivo físico de una evidencia vive y muere con su registro: se elimina del almacén cuando se elimina la evidencia, por la eliminación de su meta (RF-META-002c) o de su cuenta (RF-ADM-010), y el borrado cubre el 100 % de los archivos (RF-EVID-017). Si el borrado de un archivo falla, no se revierte la eliminación del registro: el fallo queda en el log y una limpieza programada, que se ejecuta al menos una vez cada 24 horas, elimina todo archivo del almacén que no tenga registro de evidencia (RF-EVID-018). Nunca se elimina un archivo que tenga registro ni uno sin registro con 1 hora o menos de antigüedad, porque puede ser una carga cuyo registro aún no se confirma. La antigüedad es el tiempo transcurrido desde que el archivo se escribió en el almacén, medido con el reloj del servidor, y no su fecha de modificación, que puede reiniciarse al copiarlo; el valor de 1 hora es el valor por defecto de un parámetro de configuración del despliegue, que puede aumentarse (por ejemplo a 24 horas) sin cambiar el modelo ni el procedimiento **[Supuesto S-55]**. **[Supuesto S-53]**

- **Fuente:** SRS, sección 3.6.
- **RF y RNF relacionados (matriz 4.2):** RF-META-002c, RF-EVID-017, RF-EVID-018, RF-ADM-010

## Tablas de apoyo: tiempo y puntaje de una submeta


Sea T el tiempo estipulado de la submeta (BR-032) e inicio el instante en que arranca su reloj. Ventana inicial: de inicio a inicio + T. Umbral de carga: inicio + 0,8 T (BR-001), válido para todo envío. Ventana de gracia: de inicio + T a inicio + 1,1 T. Los minutos de los casos suponen T = 60 min (umbral en el minuto 48, fin del tiempo estipulado en el minuto 60 y fin de la gracia en el minuto 66).

| Envío y ventana de recepción | Excelente | Incoherente | Inválida |
|---|---|---|---|
| Primer envío, periodo inicial | 100 | 50 | 0 |
| Primer envío, tiempo de gracia (la mitad) | 50 | 25 | 0 |
| Segundo envío, cualquier ventana (la mitad) | 50 | 25 | 0 |

- La ventana de un envío es la del instante en que el servidor lo recibe (RF-EVID-010). Solo el primer envío depende de ella: en el periodo inicial vale 100, 50 o 0 y en la gracia 50, 25 o 0. El segundo envío vale siempre la mitad de la tabla del periodo inicial (50, 25 o 0), se envíe en el periodo inicial o en la gracia (RF-PUNT-005).
- Un primer envío Excelente en el periodo inicial da 100 puntos, cierra la submeta y no está sujeto al tope. Con dos envíos, el puntaje de la submeta es la suma de ambos con tope de 90 (RF-PUNT-004); la mayor suma posible es 50 + 50 = 100, que por el tope da 90 (casos E-03 y E-06).
- Cierre (BR-018): en el instante del dictamen Excelente del primer envío; en el instante del dictamen del segundo envío; en el instante del dictamen del primer envío cuando llega con la gracia ya terminada; al expirar la gracia (minuto 66) si no hubo segundo envío y no hay evaluaciones pendientes ni en Error; o por cierre administrativo tras 48 horas de una evaluación en Error (RF-ADM-019).
- Puntaje del usuario: al cerrarse, el puntaje final de la submeta se suma al acumulado del perfil en la misma transacción (RF-PUNT-008, RF-PUNT-014) y el ranking ordena por ese acumulado (RF-RANK-001). Los puntajes provisionales y las submetas sin calificación no suman.
- Reintentar una evaluación en Error (RF-EVID-008) reevalúa la misma evidencia sin consumir envío ni cambiar su ventana (BR-017); una evaluación en curso se completa aunque el plazo expire (BR-016). Un dictamen Inválida no es un Error: puntúa 0 y consume el envío (BR-005).
- Observación: las filas que solo difieren en la ventana del segundo envío (E-03 y E-06, E-04 y E-07, E-05 y E-08, E-10 y E-13, E-11 y E-14, E-12 y E-15) dan el mismo puntaje; se conservan como casos de regresión de que esa ventana no cambia los puntos. Incoherente + Incoherente da 75 (caso E-04).

Tabla completa de las 25 combinaciones (T = 60 min). Cada caso tiene un caso de prueba (columna CP). Los CP que usan la ventana de gracia exigen reloj y LLM simulados (4.1).

| Caso | 1.er envío (ventana de recepción, dictamen) | 2.º envío (ventana de envío, dictamen; vale la mitad en toda ventana) | Pts 1.º | Pts 2.º | Puntaje final de la submeta | Cierre de la submeta | CP |
|---|---|---|---|---|---|---|---|
| E-01 | Inicial, Excelente | — | 100 | — | 100 | Al dictamen del 1.er envío | CP-010 |
| E-02 | Inicial, Incoherente | — | 50 | — | 50 | Al expirar la gracia (minuto 66); sin 2.º envío | CP-013 |
| E-03 | Inicial, Incoherente | Inicial, Excelente | 50 | 50 | 90 (tope; suma 100) | Al dictamen del 2.º envío | CP-011 |
| E-04 | Inicial, Incoherente | Inicial, Incoherente | 50 | 25 | 75 | Al dictamen del 2.º envío | CP-081 |
| E-05 | Inicial, Incoherente | Inicial, Inválida | 50 | 0 | 50 | Al dictamen del 2.º envío | CP-082 |
| E-06 | Inicial, Incoherente | Gracia, Excelente | 50 | 50 | 90 (tope; suma 100) | Al dictamen del 2.º envío | CP-083 |
| E-07 | Inicial, Incoherente | Gracia, Incoherente | 50 | 25 | 75 | Al dictamen del 2.º envío | CP-012 |
| E-08 | Inicial, Incoherente | Gracia, Inválida | 50 | 0 | 50 | Al dictamen del 2.º envío | CP-084 |
| E-09 | Inicial, Inválida | — | 0 | — | 0 | Al expirar la gracia (minuto 66); sin 2.º envío | CP-085 |
| E-10 | Inicial, Inválida | Inicial, Excelente | 0 | 50 | 50 | Al dictamen del 2.º envío | CP-086 |
| E-11 | Inicial, Inválida | Inicial, Incoherente | 0 | 25 | 25 | Al dictamen del 2.º envío | CP-087 |
| E-12 | Inicial, Inválida | Inicial, Inválida | 0 | 0 | 0 | Al dictamen del 2.º envío | CP-088 |
| E-13 | Inicial, Inválida | Gracia, Excelente | 0 | 50 | 50 | Al dictamen del 2.º envío | CP-089 |
| E-14 | Inicial, Inválida | Gracia, Incoherente | 0 | 25 | 25 | Al dictamen del 2.º envío | CP-090 |
| E-15 | Inicial, Inválida | Gracia, Inválida | 0 | 0 | 0 | Al dictamen del 2.º envío | CP-091 |
| E-16 | Gracia, Excelente | — | 50 | — | 50 | Al dictamen del 1.er envío | CP-092 |
| E-17 | Gracia, Incoherente | — | 25 | — | 25 | Al expirar la gracia (minuto 66); sin 2.º envío | CP-093 |
| E-18 | Gracia, Incoherente | Gracia, Excelente | 25 | 50 | 75 | Al dictamen del 2.º envío | CP-094 |
| E-19 | Gracia, Incoherente | Gracia, Incoherente | 25 | 25 | 50 | Al dictamen del 2.º envío | CP-095 |
| E-20 | Gracia, Incoherente | Gracia, Inválida | 25 | 0 | 25 | Al dictamen del 2.º envío | CP-096 |
| E-21 | Gracia, Inválida | — | 0 | — | 0 | Al expirar la gracia (minuto 66); sin 2.º envío | CP-097 |
| E-22 | Gracia, Inválida | Gracia, Excelente | 0 | 50 | 50 | Al dictamen del 2.º envío | CP-098 |
| E-23 | Gracia, Inválida | Gracia, Incoherente | 0 | 25 | 25 | Al dictamen del 2.º envío | CP-099 |
| E-24 | Gracia, Inválida | Gracia, Inválida | 0 | 0 | 0 | Al dictamen del 2.º envío | CP-100 |
| E-25 | Sin envío (periodo inicial y gracia) | — | — | — | 0 | Al expirar la gracia (minuto 66); sin envío | CP-013 |
