# Historias de usuario de FocusStrike

Extraído de [`SRS.md`](SRS.md); ante cualquier diferencia, manda `SRS.md`.

Historias de usuario (HU) de la versión 0.1, extraídas sin cambios de la sección 3.5 de la especificación de requisitos (`SRS.md`). Cada historia indica su actor, su prioridad (MoSCoW), los requisitos funcionales (RF) que la sustentan, los casos de uso (CU) asociados y sus criterios de aceptación en formato Dado/cuando/entonces.

Los CU asociados se toman de la matriz de trazabilidad 4.2 del SRS (RF de la historia y los CU de cada uno).

## Control de versiones

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1 | 2026-11-11 | Equipo FocusStrike | Línea base |

## Resumen

Total de historias de usuario: **65**.

| Módulo | Historias |
|---|---|
| AUT | 5 (HU-AUT-001 a HU-AUT-005) |
| PER | 7 (HU-PER-001 a HU-PER-007) |
| META | 16 (HU-META-001 a HU-META-015) |
| AGEN | 4 (HU-AGEN-001 a HU-AGEN-004) |
| POM | 2 (HU-POM-001 a HU-POM-002) |
| EVID | 6 (HU-EVID-001 a HU-EVID-006) |
| PUNT | 4 (HU-PUNT-001 a HU-PUNT-004) |
| RANK | 2 (HU-RANK-001 a HU-RANK-002) |
| ADM | 11 (HU-ADM-001 a HU-ADM-011) |
| IA | 4 (HU-IA-001 a HU-IA-004) |
| NOT | 2 (HU-NOT-001 a HU-NOT-002) |
| LOGR | 2 (HU-LOGR-001 a HU-LOGR-002) |

## Módulo AUT

### HU-AUT-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero registrarme con nombre, correo y una contraseña que cumpla la política, y declarar que soy mayor de 18 años, para crear mi cuenta y guardar mi progreso.
- **Prioridad:** Must
- **RF relacionados:** RF-AUT-001, RF-AUT-002, RF-AUT-011, RF-AUT-013, RF-AUT-015, RF-AUT-017
- **CU asociados:** CU-001, CU-003, CU-029
- **Criterios de aceptación:**
  - Dado que no tengo cuenta, cuando registro datos válidos, entonces el sistema crea mi cuenta con rol cliente y me permite iniciar sesión.
  - Dado un correo ya registrado, cuando intento registrarme, entonces el sistema me lo rechaza (HTTP 409).
  - Dado una contraseña de 7 caracteres, cuando intento registrarme, entonces el sistema la rechaza (HTTP 422).
  - Dado que me registro desde un navegador configurado en America/Argentina/Buenos_Aires, cuando se crea mi cuenta, entonces mi zona horaria queda en esa zona sin que yo la escriba.
  - Dado que no marco la declaración 'Declaro ser mayor de 18 años', cuando intento registrarme, entonces el sistema me lo rechaza (HTTP 422) y no crea mi cuenta.
  - Dado que registro datos válidos y marco la declaración, cuando se crea mi cuenta, entonces queda guardado el momento en que declaré ser mayor de 18 años y el sistema no me pide fecha de nacimiento.

### HU-AUT-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero iniciar sesión de forma segura, para acceder a mis metas y evidencias.
- **Prioridad:** Must
- **RF relacionados:** RF-AUT-003, RF-AUT-004
- **CU asociados:** CU-002
- **Criterios de aceptación:**
  - Dado un usuario registrado, cuando ingreso credenciales válidas, entonces el sistema emite un JWT y me lleva al inicio.
  - Dado un usuario registrado, cuando ingreso credenciales inválidas, entonces el sistema responde HTTP 401 sin token.

### HU-AUT-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero recuperar mi contraseña olvidada, para volver a entrar a mi cuenta.
- **Prioridad:** Must
- **RF relacionados:** RF-AUT-006, RF-AUT-007, RF-AUT-008, RF-AUT-010
- **CU asociados:** CU-003
- **Criterios de aceptación:**
  - Dado que olvidé mi contraseña, cuando solicito recuperación con mi correo registrado, entonces el sistema envía un código a mi buzón.
  - Dado un código vigente, cuando lo ingreso con una nueva contraseña válida, entonces el sistema me permite iniciar sesión con ella.
  - Dado un código con más de 10 minutos, cuando lo uso, entonces el sistema lo rechaza (HTTP 422).

### HU-AUT-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero cerrar sesión, para proteger mi cuenta en equipos compartidos.
- **Prioridad:** Should
- **RF relacionados:** RF-AUT-005
- **CU asociados:** CU-004
- **Criterios de aceptación:**
  - Dado que tengo sesión activa, cuando cierro sesión, entonces el token queda revocado y dejo de acceder a recursos protegidos.

### HU-AUT-005

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que mi cuenta se proteja temporalmente tras varios intentos fallidos y recibir un aviso por correo, para detectar accesos indebidos.
- **Prioridad:** Must
- **RF relacionados:** RF-AUT-009, RF-AUT-012, RF-AUT-014
- **CU asociados:** CU-002
- **Criterios de aceptación:**
  - Dado 5 intentos fallidos consecutivos, cuando intento un sexto inicio de sesión, entonces recibo HTTP 429 durante 15 minutos.
  - Dado el bloqueo temporal, cuando se activa, entonces recibo un correo informando el bloqueo.
  - Dado 3 intentos fallidos y un inicio exitoso, cuando consulto el contador, entonces vale 0.

## Módulo PER

### HU-PER-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver mi perfil con mis puntos y días activos, para conocer mi progreso.
- **Prioridad:** Should
- **RF relacionados:** RF-PER-001
- **CU asociados:** CU-017
- **Criterios de aceptación:**
  - Dado mi perfil, cuando lo abro, entonces veo mi nombre, puntaje acumulado y conteo de días activos.

### HU-PER-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver en un calendario de los últimos 12 meses, en verde, los días en que estuve activo, para visualizar mi constancia.
- **Prioridad:** Should
- **RF relacionados:** RF-PER-002, RF-PER-003
- **CU asociados:** CU-009, CU-013, CU-016, CU-031, CU-017
- **Criterios de aceptación:**
  - Dado un día en que inicié a mano una submeta, cuando veo mi calendario, entonces ese día aparece en verde.
  - Dado un día en que envié una evidencia, cuando veo mi calendario, entonces ese día aparece en el mismo tono de verde.
  - Dado un día en que solo inicié sesión, cuando veo mi calendario, entonces ese día no aparece en verde.
  - Dado un día anterior a los últimos 12 meses, cuando veo mi calendario, entonces ese día no se muestra.
  - Dado un día en que una submeta se inició sola a su hora programada y yo no actué, cuando veo mi calendario, entonces ese día no aparece en verde.
  - Dado un día en que mi submeta se cerró por vencimiento del tiempo sin que yo enviara evidencia, o la cerró un administrador, cuando veo mi calendario, entonces ese día no aparece en verde por ese cierre.

### HU-PER-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero conocer mi posición en el ranking y entrar a él desde mi perfil, para medir mi competitividad.
- **Prioridad:** Could
- **RF relacionados:** RF-PER-004, RF-RANK-002
- **CU asociados:** CU-017, CU-018
- **Criterios de aceptación:**
  - Dado mi perfil, cuando lo abro, entonces veo mi posición actual en el ranking.
  - Dado mi perfil, cuando selecciono ver ranking, entonces el sistema me muestra el ranking global.

### HU-PER-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver a qué hora empecé a trabajar cada día y cuántas submetas inicié a mano, para entender mi ritmo diario.
- **Prioridad:** Should
- **RF relacionados:** RF-PER-005, RF-PER-006, RF-PER-010, RF-PER-011
- **CU asociados:** CU-009, CU-031, CU-017
- **Criterios de aceptación:**
  - Dado que hoy inicié a mano mi primera submeta a las 08:12, cuando abro mi perfil, entonces veo 'Primera actividad del día: 08:12'.
  - Dado que un día inicié a mano 3 submetas, cuando selecciono ese día en el calendario, entonces veo '3 submetas'.

### HU-PER-005

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver mi racha actual, mi racha máxima y mi racha perfecta, para motivarme a mantener la constancia y la calidad de mis entregas.
- **Prioridad:** Should
- **RF relacionados:** RF-PER-007, RF-PER-009, RF-PER-012
- **CU asociados:** CU-017
- **Criterios de aceptación:**
  - Dado 3 días activos consecutivos hasta ayer, cuando abro mi perfil hoy antes de iniciar una submeta, entonces veo una racha de 3.
  - Dado que mi mejor racha fue de 5 días, cuando abro mi perfil, entonces veo una racha máxima de 5.
  - Dadas 3 submetas cerradas con acierto Excelente en el primer envío, cuando abro mi perfil, entonces veo una racha perfecta de 3; si la siguiente submeta cierra con 90 puntos, entonces mi racha perfecta vuelve a 0.

### HU-PER-006

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que mi zona horaria se detecte al registrarme y poder cambiarla en mi perfil, para que mis horarios y recordatorios coincidan con mi hora local.
- **Prioridad:** Must
- **RF relacionados:** RF-PER-008, RF-AUT-015, RF-PER-017, RF-AUT-016
- **CU asociados:** CU-027, CU-001, CU-002, CU-019
- **Criterios de aceptación:**
  - Dado que me registro desde un navegador en America/Argentina/Buenos_Aires, cuando se crea mi cuenta, entonces mi zona horaria es esa.
  - Dado que elijo otra zona válida en mi perfil, cuando guardo, entonces mis horarios se muestran en esa zona.
  - Dado una zona inexistente, cuando intento guardar, entonces el sistema la rechaza.
  - Dado que cambio mi zona horaria, cuando guardo, entonces mis submetas pendientes conservan su fecha y hora locales y mis días activos anteriores no cambian. **[Supuesto S-52]**
  - Dado que un administrador creó mi cuenta, cuando inicio sesión por primera vez desde un navegador en America/Argentina/Buenos_Aires, entonces mi zona horaria pasa a esa zona.

### HU-PER-007

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario que no distingue colores o que navega con teclado o lector de pantalla, quiero consultar mi calendario de actividad con etiquetas de texto, una tabla alternativa y navegación por teclado, para conocer mi constancia sin depender del color.
- **Prioridad:** Should
- **RF relacionados:** RF-PER-013, RF-PER-014, RF-PER-015, RF-PER-016, RF-PER-011
- **CU asociados:** CU-017, CU-031
- **Criterios de aceptación:**
  - Dado mi calendario de actividad, cuando lo recorro con un lector de pantalla, entonces cada día se anuncia con su fecha y si fue activo.
  - Dado mi calendario, cuando lo recorro solo con el teclado, entonces veo el foco y puedo abrir el detalle de un día con su fecha y número de submetas, y cerrarlo con Escape.
  - Dado mi calendario, cuando elijo la vista de tabla, entonces veo la lista de mis días activos de los últimos 12 meses con su número de submetas.

## Módulo META

### HU-META-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero crear metas con mis fechas, horario y horas totales, para planificar mis objetivos.
- **Prioridad:** Must
- **RF relacionados:** RF-META-001, RF-META-029
- **CU asociados:** CU-005
- **Criterios de aceptación:**
  - Dado el formulario de creación, cuando completo los parámetros obligatorios, entonces el sistema guarda la meta y la muestra en la agenda.
  - Dado una fecha de trabajo anterior a hoy, cuando intento guardar, entonces el sistema la rechaza.

### HU-META-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que la IA desglose mis metas largas en submetas diarias con descripción y consejos, para no abrumarme.
- **Prioridad:** Must
- **RF relacionados:** RF-META-003, RF-META-005, RF-META-007, RF-META-011, RF-META-024, RF-META-027
- **CU asociados:** CU-005, CU-006, CU-025, CU-032, CU-022, CU-008a
- **Criterios de aceptación:**
  - Dada una meta de más de 1 día con desglose por IA, cuando la creo, entonces la IA genera una submeta por fecha con su horario y su descripción, cada una de horas enteras (mínimo 1 h), y la suma de sus duraciones es mi tiempo total.
  - Dada una meta de más de 1 día, cuando se genera el desglose, entonces veo consejos generales.
  - Dado que la IA no responde, cuando se agotan los reintentos, entonces mi meta se conserva y puedo reintentar el desglose o armarlo yo mismo con el desglose manual.
  - Dada una meta multidía con menos horas totales que días destinados (por ejemplo 2 h en 3 días), cuando intento guardarla, entonces el sistema la rechaza (HTTP 422) porque cada submeta dura al menos 1 h.
  - Dada una meta con más días destinados que días en su rango de fechas, cuando intento guardarla, entonces el sistema la rechaza (HTTP 422).
  - Dada una meta multidía guardada con desglose por IA, cuando solicito el desglose, entonces espero la respuesta en la misma pantalla (hasta ~60 s) y, si la IA falla, mi meta sigue guardada sin submetas y se me ofrece el desglose manual.

### HU-META-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero recibir recomendaciones de la IA si mi meta exige más de 12 horas por día, para cumplirla sin saturarme.
- **Prioridad:** Must
- **RF relacionados:** RF-META-008, RF-META-009, RF-META-030
- **CU asociados:** CU-007
- **Criterios de aceptación:**
  - Dada una meta de 1 día con 18 h, o de 3 días con 42 h (14 h por día), cuando la creo, entonces la IA ofrece recomendaciones y puedo aceptarlas, modificarlas o rechazarlas.
  - Dada una meta de 3 días con 36 h (12 h por día), cuando la creo, entonces no se me ofrecen recomendaciones.
  - Dado que la IA no está disponible, cuando creo una meta de 1 día con 18 h, entonces puedo guardarla sin recomendaciones.
  - Dado que no he aceptado el servicio externo de IA, cuando creo una meta de 1 día con 18 h que no requiere evidencia, entonces no se me ofrecen recomendaciones y puedo guardarla sin ellas.

### HU-META-004a

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero editar mis metas, para corregir o ajustar mis planes.
- **Prioridad:** Should
- **RF relacionados:** RF-META-002b, RF-META-028, RF-META-037
- **CU asociados:** CU-008a
- **Criterios de aceptación:**
  - Dada una meta sin submetas iniciadas, cuando la edito, entonces los cambios se guardan.
  - Dada una meta con una submeta iniciada, cuando intento cambiar su tiempo total, entonces el sistema me lo impide.
  - Dado que rechacé el aviso de IA, cuando edito una meta para que requiera evidencia, entonces el sistema me lo impide, me ofrece aceptar el aviso y mi meta no cambia.
  - Dada una meta con una submeta iniciada, cuando intento cambiar su modo de inicio o su requisito de evidencia, entonces el sistema me lo impide. **[Supuesto S-51]**

### HU-META-004b

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero eliminar mis metas, para descartar planes.
- **Prioridad:** Must
- **RF relacionados:** RF-META-002c
- **CU asociados:** CU-008b
- **Criterios de aceptación:**
  - Dada una meta existente, cuando la elimino y confirmo, entonces la meta y sus submetas quedan eliminadas y mi puntaje no cambia.
  - Dada una solicitud de eliminar una meta sin confirmación explícita, cuando se envía, entonces el sistema responde HTTP 422 y la meta no se elimina.

### HU-META-005

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero iniciar mis submetas manualmente o que el sistema las inicie a la hora programada, para que el reloj corra según mi preferencia.
- **Prioridad:** Must
- **RF relacionados:** RF-META-012, RF-META-013, RF-META-025, RF-META-026
- **CU asociados:** CU-009, CU-016
- **Criterios de aceptación:**
  - Dada una submeta en modo manual, cuando la inicio, entonces el reloj global empieza a contar desde ese momento.
  - Dada una submeta en modo automático, cuando llega su hora programada, entonces el reloj global inicia sin mi intervención.
  - Dada una submeta manual de una meta con evidencia que no inicié durante su fecha programada, cuando termina el día, entonces se cierra con 0 puntos.
  - Dada una submeta manual de una meta sin evidencia que no inicié durante su fecha programada, cuando termina el día, entonces se cierra sin calificación y no suma puntos.
  - Dada una submeta manual con horario de 14:00 a 15:00, cuando la inicio a cualquier hora de su fecha programada (por ejemplo a las 10:00), entonces el reloj empieza a contar desde ese momento.
  - Dada una submeta manual, cuando intento iniciarla antes de su fecha programada, entonces el sistema me lo rechaza (HTTP 409).

### HU-META-006

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero consultar el detalle de una de mis metas, para revisar su plan y los consejos de la IA.
- **Prioridad:** Should
- **RF relacionados:** RF-META-002a
- **CU asociados:** CU-022
- **Criterios de aceptación:**
  - Dada una meta propia, cuando la consulto, entonces veo sus datos, submetas y consejos.
  - Dada una meta de otro usuario, cuando intento consultarla, entonces el sistema responde que no existe.

### HU-META-007

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero guardar rápido una meta corta de un día sin intervención de la IA, para no esperar por algo simple.
- **Prioridad:** Must
- **RF relacionados:** RF-META-004, RF-META-019, RF-META-031
- **CU asociados:** CU-005, CU-007
- **Criterios de aceptación:**
  - Dada una meta de 1 día y 8 h, cuando la guardo, entonces no se invoca a la IA y se crea una submeta única.
  - Dada una meta de 1 día, 3 h y horario de 08:00 a 12:00, cuando la guardo, entonces mi submeta única va de 08:00 a 11:00 y su tiempo estipulado es de 3 h.

### HU-META-008

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que mis metas sin evidencia se cierren solas al terminar el tiempo, para no tener que justificarlas.
- **Prioridad:** Should
- **RF relacionados:** RF-META-006
- **CU asociados:** CU-016
- **Criterios de aceptación:**
  - Dada una meta sin evidencia, cuando termina el tiempo de su submeta, entonces la submeta se cierra 'sin calificación' y no suma puntos.

### HU-META-009

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que el sistema me impida planificar más de 24 horas por día, para que mis metas sean realizables.
- **Prioridad:** Must
- **RF relacionados:** RF-META-010, RF-META-020
- **CU asociados:** CU-005
- **Criterios de aceptación:**
  - Dado 25 h en 1 día, cuando intento guardar, entonces el sistema rechaza la meta.
  - Dado 24 h en 1 día con horario de 00:00 a 24:00, cuando guardo, entonces el sistema acepta la meta.
  - Dado 24 h en 1 día con horario de 00:00 a 23:59, cuando guardo, entonces el sistema me indica que el horario no alcanza.
  - Dado 250 h en 10 días, cuando guardo, entonces el sistema me indica que necesito al menos 11 días.
  - Dado 40 h en 8 días con horario de 2 h diarias, cuando guardo, entonces el sistema me indica que el horario no alcanza.

### HU-META-010

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero indicar las horas totales de mi meta y elegir las fechas en que trabajaré, para controlar cuándo me dedico a ella.
- **Prioridad:** Must
- **RF relacionados:** RF-META-015, RF-META-016
- **CU asociados:** CU-005
- **Criterios de aceptación:**
  - Dado un tiempo total de 6 h y 3 fechas elegidas, cuando guardo la meta, entonces se crean 3 submetas en esas fechas que suman 6 h.

### HU-META-011

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero indicar solo cuántos días necesito y que la IA me sugiera las fechas más convenientes según mi meta, para no planificar a ciegas.
- **Prioridad:** Must
- **RF relacionados:** RF-META-017, RF-META-018, RF-META-032
- **CU asociados:** CU-025
- **Criterios de aceptación:**
  - Dado un rango de 14 días, 5 días y una descripción, cuando pido sugerencia, entonces la IA propone 5 fechas dentro del rango.
  - Dadas las fechas sugeridas, cuando las acepto, modifico o rechazo, entonces la meta se guarda según mi decisión.

### HU-META-012

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero describir mi meta, para que la IA entienda mi objetivo al planificar y evaluar.
- **Prioridad:** Should
- **RF relacionados:** RF-META-021, RF-META-022
- **CU asociados:** CU-005, CU-006, CU-025
- **Criterios de aceptación:**
  - Dada una descripción de la meta, cuando se desglosa o se evalúa una evidencia, entonces la IA recibe esa descripción como contexto.
  - Dado que pido fechas sugeridas sin descripción, cuando intento guardar, entonces el sistema me la exige.

### HU-META-013

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero recibir recomendaciones de descanso cuando mi meta multidía exige más de 12 horas diarias, para cuidar mi salud.
- **Prioridad:** Should
- **RF relacionados:** RF-META-023
- **CU asociados:** CU-006, CU-007
- **Criterios de aceptación:**
  - Dada una meta de 3 días y 42 h, cuando la creo, entonces la IA me ofrece recomendaciones que incluyen descanso y, si las acepto, las veo con los consejos de la meta.

### HU-META-014

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario que prefiere no usar un servicio externo de IA, quiero armar yo mismo las submetas de una meta de varios días (nombre, fecha, horario y duración), para planificar mi trabajo sin enviar mis datos a un tercero.
- **Prioridad:** Must
- **RF relacionados:** RF-META-033, RF-META-034, RF-META-035
- **CU asociados:** CU-005, CU-006, CU-007, CU-032, CU-008a
- **Criterios de aceptación:**
  - Dado que rechacé el aviso de IA, cuando creo una meta sin evidencia de 3 días y 6 h y defino una submeta de 2 h por cada fecha, entonces la meta se guarda con mis tres submetas, con su nombre, fecha y horario.
  - Dado un desglose cuyas duraciones suman 5 h para una meta de 6 h, cuando intento guardar, entonces el sistema me lo rechaza e indica que falta 1 h.
  - Dada una submeta que termina después de las 24:00 o fuera del horario diario de la meta, cuando intento guardar, entonces el sistema me indica el campo.
  - Dado que rechacé el aviso de IA, cuando intento crear la misma meta con evidencia o con desglose automático, entonces el sistema me lo impide y me ofrece aceptar el aviso.
  - Dada una submeta de 0 h o de 1,5 h, cuando intento guardar, entonces el sistema me indica que la duración debe ser en horas enteras, de 1 h o más.

### HU-META-015

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario que aceptó el servicio de IA, quiero poder elegir el desglose manual en lugar del automático, para decidir yo mismo cómo distribuyo mi tiempo.
- **Prioridad:** Should
- **RF relacionados:** RF-META-036
- **CU asociados:** CU-005, CU-032
- **Criterios de aceptación:**
  - Dado que acepté el servicio de IA, cuando creo una meta de varios días, entonces puedo elegir entre el desglose por IA y el desglose manual.
  - Dado que elijo el desglose manual en una meta con evidencia, cuando guardo la meta, entonces no se llama a la IA para desglosarla y mis evidencias se evalúan como las de cualquier otra meta.

## Módulo AGEN

### HU-AGEN-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver mi agenda con metas y submetas por fecha con color por meta, para organizar mi día.
- **Prioridad:** Must
- **RF relacionados:** RF-AGEN-001, RF-AGEN-002
- **CU asociados:** CU-010
- **Criterios de aceptación:**
  - Dado mi calendario, cuando consulto la agenda, entonces veo metas y submetas agrupadas por fecha y las submetas de cada meta en el mismo color.

### HU-AGEN-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver el estado de mis submetas y su ventana de tiempo, para saber qué me falta y cuánto tiempo queda.
- **Prioridad:** Should
- **RF relacionados:** RF-AGEN-003, RF-AGEN-006
- **CU asociados:** CU-010, CU-011
- **Criterios de aceptación:**
  - Dada una submeta, cuando la veo en la agenda, entonces distingo su estado (pendiente, en curso, finalizada) por color y texto.
  - Dada una submeta en tiempo de gracia, cuando veo su detalle, entonces veo la cuenta regresiva del tiempo de gracia.

### HU-AGEN-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver el detalle de una submeta desde la agenda, para consultar su puntaje, evidencias y evaluación.
- **Prioridad:** Should
- **RF relacionados:** RF-AGEN-004
- **CU asociados:** CU-011
- **Criterios de aceptación:**
  - Dada una submeta en la agenda, cuando la selecciono, entonces veo su horario, estado, puntaje, evidencias y estado de evaluación.

### HU-AGEN-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver al entrar mi próxima submeta, mi puntaje y mi racha, para empezar rápido mi día.
- **Prioridad:** Could
- **RF relacionados:** RF-AGEN-005
- **CU asociados:** CU-024
- **Criterios de aceptación:**
  - Dado que inicio sesión, cuando se muestra el inicio, entonces veo mi próxima submeta de hoy, mi puntaje y mi racha.

## Módulo POM

### HU-POM-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero usar un pomodoro flexible que pueda iniciar, pausar, reanudar, abandonar y finalizar, para concentrarme sin presión.
- **Prioridad:** Should
- **RF relacionados:** RF-POM-001, RF-POM-004, RF-POM-005, RF-POM-006, RF-POM-007
- **CU asociados:** CU-012
- **Criterios de aceptación:**
  - Dado el temporizador activo, cuando lo pauso y lo reanudo, entonces continúa desde donde quedó.
  - Dado el temporizador activo, cuando lo abandono, entonces el estado cambia y no se penaliza mi submeta.
  - Dado el temporizador activo, cuando lo uso, entonces corre en mi navegador y no se registra nada en el servidor hasta que lo finalizo o lo abandono.

### HU-POM-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que mis sesiones pomodoro queden guardadas y vinculadas a una submeta en curso, para llevar mi historial.
- **Prioridad:** Should
- **RF relacionados:** RF-POM-002, RF-POM-003
- **CU asociados:** CU-012
- **Criterios de aceptación:**
  - Dada una sesión pomodoro finalizada o abandonada, cuando se cierra, entonces el sistema la guarda con su duración efectiva y la submeta vinculada (si la elegí).
  - Dada una sesión pomodoro de menos de 1 minuto de duración efectiva, cuando termina, entonces el sistema no la guarda.

## Módulo EVID

### HU-EVID-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero subir mi evidencia solo cuando el sistema lo permita, para demostrar mi cumplimiento de forma justa.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-001, RF-EVID-002, RF-EVID-013
- **CU asociados:** CU-013
- **Criterios de aceptación:**
  - Dado el reloj por debajo del 80 %, cuando intento cargar, entonces el botón está deshabilitado y el backend rechaza (HTTP 409).
  - Dado el reloj en o por encima del 80 %, cuando cargo, entonces el sistema acepta la evidencia.
  - Dado que terminó el tiempo de gracia, cuando intento cargar, entonces el sistema rechaza (HTTP 409).

### HU-EVID-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero subir evidencias en imagen, texto o Excel válidas y propias, para demostrar mi trabajo en mi formato preferido.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-003, RF-EVID-004, RF-EVID-014, RF-EVID-015, RF-IA-012
- **CU asociados:** CU-013, CU-014
- **Criterios de aceptación:**
  - Dado un archivo de imagen, texto o Excel de hasta 25 MB, cuando lo subo, entonces el sistema lo acepta.
  - Dado un archivo .gif, .docx, .doc, .xlsx o .xls, cuando lo subo, entonces el sistema lo acepta y lo convierte antes de evaluarlo (el .gif a una imagen PNG; los documentos y hojas a texto).
  - Dado un archivo de otro formato o mayor a 25 MB, cuando lo subo, entonces el sistema lo rechaza.
  - Dado una meta que no requiere evidencia, cuando intento subir una, entonces el sistema la rechaza.
  - Dado un archivo vacío, corrupto o ilegible, cuando lo subo, entonces el sistema lo rechaza al instante, no consume mi envío y puedo subir otro archivo.
  - Dado un archivo de un tipo no soportado, cuando lo subo, entonces el sistema responde HTTP 415; dado un archivo admitido que no se puede convertir, responde HTTP 422; en ambos casos no consume mi envío.

### HU-EVID-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero saber en qué estado está la evaluación de mi evidencia, para saber si fue aceptada.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-005, RF-EVID-006, RF-EVID-009
- **CU asociados:** CU-014, CU-023
- **Criterios de aceptación:**
  - Dado el envío de una evidencia, cuando consulto su estado, entonces veo En evaluación, Evaluada con dictamen y justificación, o Error.
  - Dado un archivo legible sin relación con mi submeta, cuando se evalúa, entonces la evaluación queda con dictamen Inválida y 0 puntos y consume mi envío.

### HU-EVID-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero poder enviar una segunda evidencia, una sola vez, si la primera sale Incoherente o Inválida, aun antes de terminar el tiempo, para corregir un error.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-007, RF-EVID-010, RF-EVID-012, RF-EVID-016
- **CU asociados:** CU-015, CU-013
- **Criterios de aceptación:**
  - Dado un dictamen Incoherente o Inválida al 90 % del tiempo, cuando consulto mi submeta, entonces puedo enviar una nueva evidencia de inmediato.
  - Dado que ya envié dos evidencias, cuando intento un tercer envío, entonces el sistema lo rechaza (HTTP 409).
  - Dada una primera evidencia aún En evaluación o dictaminada Excelente, cuando intento un segundo envío, entonces el sistema lo rechaza (HTTP 409).
  - Dada una evidencia recibida al 98 % cuyo dictamen llega al 103 %, cuando se puntúa, entonces cuenta como enviada a tiempo.

### HU-EVID-005

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero reintentar la evaluación cuando falla y que se complete aunque el plazo expire, para no perder mi esfuerzo por un fallo técnico.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-008, RF-EVID-011
- **CU asociados:** CU-023, CU-014
- **Criterios de aceptación:**
  - Dada una evaluación en Error, cuando selecciono Reintentar, entonces se reevalúa la misma evidencia y no consumo un intento.
  - Dada una evidencia recibida en el último segundo de la gracia, cuando el dictamen llega después, entonces se puntúa igualmente.
  - Dada una submeta que un administrador cerró tras un Error persistente, cuando selecciono Reintentar, entonces el sistema me informa de que no es posible.

### HU-EVID-006

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que al eliminar una meta o mi cuenta se borren también los archivos de mis evidencias, para que no quede información mía almacenada.
- **Prioridad:** Must
- **RF relacionados:** RF-EVID-017, RF-EVID-018
- **CU asociados:** CU-008b, CU-019, CU-033
- **Criterios de aceptación:**
  - Dada una meta con evidencias, cuando la elimino y confirmo, entonces los archivos de sus evidencias dejan de existir en el almacén.
  - Dado que el borrado de un archivo falló, cuando se ejecuta la limpieza programada, entonces el archivo se elimina sin afectar archivos que tengan registro. **[Supuesto S-53]**

## Módulo PUNT

### HU-PUNT-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ganar el 100 % de los puntos si entrego a tiempo y mi primera evidencia obtiene el dictamen Excelente, para ver mi disciplina recompensada.
- **Prioridad:** Must
- **RF relacionados:** RF-PUNT-001
- **CU asociados:** CU-016
- **Criterios de aceptación:**
  - Dado un primer envío a tiempo con dictamen Excelente, cuando se evalúa, entonces mi submeta cierra con 100 y se suma a mi perfil.

### HU-PUNT-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero tener una segunda oportunidad si mi entrega fue Incoherente o Inválida o si no entregué, para recuperarme.
- **Prioridad:** Must
- **RF relacionados:** RF-PUNT-002, RF-PUNT-003, RF-PUNT-007
- **CU asociados:** CU-016, CU-015
- **Criterios de aceptación:**
  - Dado un dictamen Incoherente a tiempo, cuando se evalúa, entonces obtengo 50 provisionales y mi submeta sigue abierta para enviar una segunda evidencia.
  - Dado que no envié a tiempo, cuando expira el tiempo inicial, entonces tengo 0 provisionales y se abre el tiempo de gracia (10 % del tiempo).
  - Dado que envío en el tiempo de gracia, cuando mi evidencia es Excelente, entonces obtengo 50 puntos (la mitad).

### HU-PUNT-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que los puntos de mi segundo envío valgan la mitad y se sumen a los del primero con un tope que premie el acierto en el primer envío, para que mi puntaje final refleje mi esfuerzo.
- **Prioridad:** Must
- **RF relacionados:** RF-PUNT-004, RF-PUNT-005, RF-PUNT-006, RF-PUNT-010
- **CU asociados:** CU-016, CU-015
- **Criterios de aceptación:**
  - Dado un 50 previo (Incoherente), cuando mi segundo envío es Excelente, entonces suma 50 y mi puntaje final es 90 (tope).
  - Dado un 50 previo, cuando mi segundo envío es Incoherente, entonces suma 25 y mi puntaje final es 75.
  - Dado un 0 previo (Inválida), cuando mi segundo envío es Excelente, entonces mi puntaje final es 50, enviado en el periodo inicial o en el tiempo de gracia.
  - Dado un 50 previo, cuando mi segundo envío es Inválida, entonces mi puntaje final es 50.
  - Dado un 50 previo y ningún segundo envío, cuando termina la gracia, entonces mi submeta cierra con 50.

### HU-PUNT-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que mi puntaje se actualice de forma consistente, que la submeta cierre en cuanto no haya nada más por hacer y ver cuál puntaje es provisional, para confiar en mi ranking.
- **Prioridad:** Must
- **RF relacionados:** RF-PUNT-008, RF-PUNT-011, RF-PUNT-012, RF-PUNT-013, RF-PUNT-014
- **CU asociados:** CU-016, CU-030, CU-011
- **Criterios de aceptación:**
  - Dada una submeta abierta con 50, cuando la veo, entonces aparece 'Provisional: 50' y mi perfil no suma esos puntos todavía.
  - Dado el dictamen de mi segundo envío, cuando se conoce, entonces mi submeta cierra en ese instante y mi acumulado aumenta una sola vez en su puntaje final.
  - Dado un fallo durante el cierre, cuando se reintenta, entonces no se duplican ni se pierden puntos.

## Módulo RANK

### HU-RANK-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver el ranking global de usuarios, para compararme.
- **Prioridad:** Should
- **RF relacionados:** RF-RANK-001, RF-RANK-005
- **CU asociados:** CU-018
- **Criterios de aceptación:**
  - Dado el ranking, cuando lo consulto, entonces veo las cuentas ordenadas de mayor a menor puntaje, sin cuentas bloqueadas.

### HU-RANK-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que el ranking sea justo con los empates y no exponga datos personales, para participar con confianza.
- **Prioridad:** Must
- **RF relacionados:** RF-RANK-003, RF-RANK-004
- **CU asociados:** CU-018
- **Criterios de aceptación:**
  - Dados puntajes 300, 200, 200 y 100, cuando veo el ranking, entonces las posiciones son 1, 2, 2 y 4.
  - Dado el ranking, cuando lo veo, entonces solo aparecen nombre y puntaje.

## Módulo ADM

### HU-ADM-001

- **Actor:** Administrador
- **Historia:** Como administrador, quiero crear, consultar, editar y eliminar cuentas, para gestionar la plataforma.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-001, RF-ADM-008, RF-ADM-009, RF-ADM-010, RF-ADM-020, RF-ADM-021, RF-AUT-018
- **CU asociados:** CU-019, CU-002
- **Criterios de aceptación:**
  - Dado el panel de administración, cuando creo, consulto, edito o elimino una cuenta, entonces el cambio queda reflejado.
  - Dado que intento eliminar mi propia cuenta o al último administrador super, cuando confirmo, entonces el sistema lo rechaza.
  - Dado un administrador moderador, cuando intento crear una cuenta administrador, entonces el sistema responde HTTP 403.
  - Dado una cuenta cliente con metas, cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409).
  - Dado que elimino una cuenta cliente y confirmo, cuando termina la operación, entonces se borran en cascada todos sus datos y la cuenta sale del ranking.
  - Dado un administrador que cerró submetas, cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409).
  - Dado un cliente cuyo único dato es un día activo (inició una submeta y eliminó su meta), cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409). **[Supuesto S-54]**
  - Dada una cuenta sin datos, cuando el super cambia su rol, entonces se eliminan los datos del rol anterior y se crean los del nuevo con sus valores por defecto. **[Supuesto S-54]**
  - Dado que creo una cuenta cliente, cuando se guarda, entonces su zona horaria es America/Bogota hasta su primer inicio de sesión, en el que se detecta la de su navegador.
  - Dado que elimino una cuenta con evidencias, cuando termina la operación, entonces los archivos de sus evidencias también se eliminan.
  - Dado que creo una cuenta cliente, cuando su titular inicia sesión por primera vez, entonces debe declarar que es mayor de 18 años antes de usar las funciones de cliente. **[SUPUESTO S-R9]**
  - Dada una solicitud de eliminar una cuenta sin confirmación explícita, cuando se envía, entonces el sistema responde HTTP 422 y la cuenta no se elimina.
  - Dado un administrador moderador o soporte, cuando intento cambiar el nivel de acceso de un administrador o el rol de una cuenta, entonces el sistema responde HTTP 403 y no cambia nada.

### HU-ADM-002

- **Actor:** Administrador
- **Historia:** Como administrador, quiero bloquear y desbloquear cuentas, para controlar el acceso.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-004, RF-ADM-012, RF-ADM-013
- **CU asociados:** CU-020
- **Criterios de aceptación:**
  - Dada una cuenta bloqueada, cuando intenta iniciar sesión, entonces recibe HTTP 403.
  - Dada una cuenta desbloqueada, cuando inicia sesión, entonces accede.
  - Dada una sesión activa, cuando bloqueo la cuenta, entonces su token deja de ser válido.
  - Dado el único administrador super sin bloquear, cuando un super intenta bloquearlo (incluido a sí mismo), entonces el sistema lo rechaza (HTTP 409).
  - Dado un administrador de nivel moderador, cuando intento bloquear o desbloquear una cuenta administrador, entonces el sistema responde HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y no cambia la cuenta; con una cuenta cliente sí se permite.

### HU-ADM-003

- **Actor:** Administrador
- **Historia:** Como administrador, quiero ver métricas de la aplicación y del uso del LLM, para vigilar el rendimiento y el costo.
- **Prioridad:** Should
- **RF relacionados:** RF-ADM-002, RF-ADM-011
- **CU asociados:** CU-021
- **Criterios de aceptación:**
  - Dado el panel de métricas, cuando lo consulto, entonces veo usuarios, metas, evidencias evaluadas y, por operación, llamadas, tokens, costo y latencia del LLM.

### HU-ADM-004

- **Actor:** Administrador
- **Historia:** Como administrador, quiero consultar las evidencias de los usuarios, para dar soporte.
- **Prioridad:** Should
- **RF relacionados:** RF-ADM-003
- **CU asociados:** CU-021
- **Criterios de aceptación:**
  - Dado el panel, cuando consulto evidencias, entonces puedo ver las de cualquier usuario con su dictamen y estado.

### HU-ADM-005

- **Actor:** Administrador
- **Historia:** Como administrador, quiero ver el ranking global incluyendo cuentas bloqueadas, para dar soporte competitivo.
- **Prioridad:** Should
- **RF relacionados:** RF-ADM-005
- **CU asociados:** CU-021
- **Criterios de aceptación:**
  - Dado el panel de administración, cuando consulto el ranking, entonces veo la lista completa con la marca de las cuentas bloqueadas.

### HU-ADM-006

- **Actor:** Administrador
- **Historia:** Como administrador, quiero que mi rol sea excluyente del de cliente y que los clientes no accedan a administración, para separar supervisión de actividad personal.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-006, RF-ADM-016
- **CU asociados:** CU-005, CU-019
- **Criterios de aceptación:**
  - Dada una sesión administrador, cuando intento crear una meta, entonces el sistema responde HTTP 403.
  - Dada una sesión cliente, cuando intento abrir una función de administración, entonces el sistema responde HTTP 403.

### HU-ADM-007

- **Actor:** Administrador
- **Historia:** Como administrador, quiero que cada llamada al LLM, incluidos los reintentos, quede registrada con su meta, evaluación y usuario, para auditar costos y errores.
- **Prioridad:** Should
- **RF relacionados:** RF-ADM-007, RF-IA-009
- **CU asociados:** CU-006, CU-014, CU-021
- **Criterios de aceptación:**
  - Dada una evaluación con un fallo y un reintento exitoso, cuando reviso los registros de uso, entonces existen dos registros vinculados a esa evaluación, cada uno con tokens, costo, latencia, proveedor, modelo y resultado.

### HU-ADM-008

- **Actor:** Administrador
- **Historia:** Como administrador, quiero conocer qué decisiones tomaron los usuarios sobre las recomendaciones de la IA, para analizar su efectividad.
- **Prioridad:** Should
- **RF relacionados:** RF-META-014
- **CU asociados:** CU-007
- **Criterios de aceptación:**
  - Dada una recomendación decidida, cuando consulto el registro, entonces veo la decisión y su fecha-hora.

### HU-ADM-009

- **Actor:** Administrador
- **Historia:** Como administrador, quiero asignar niveles de acceso a los administradores, para limitar lo que cada uno puede hacer.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-014, RF-ADM-015
- **CU asociados:** CU-019, CU-029
- **Criterios de aceptación:**
  - Dado un administrador de nivel soporte, cuando intenta bloquear una cuenta, entonces el sistema responde HTTP 403.
  - Dado un administrador super, cuando cambia el nivel de otro administrador, entonces el cambio se guarda.

### HU-ADM-010

- **Actor:** Administrador
- **Historia:** Como administrador, quiero que el despliegue cree una primera cuenta administrador de nivel super con variables de entorno, para poder gestionar la plataforma desde el primer día sin depender del autorregistro ni de una pantalla pública.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-017
- **CU asociados:** CU-029
- **Criterios de aceptación:**
  - Dada una base de datos sin ningún administrador super (aunque tenga un moderador), cuando el despliegue arranca con el correo y la contraseña iniciales en variables de entorno, entonces existe una cuenta administrador de nivel super que puede iniciar sesión.
  - Dada una base con un administrador super, cuando el despliegue arranca de nuevo, entonces no se crea otra cuenta (aunque exista un moderador).
  - Dado el sistema en ejecución, cuando busco una pantalla pública para crear el primer administrador, entonces no existe.

### HU-ADM-011

- **Actor:** Administrador
- **Historia:** Como administrador, quiero ver y cerrar las submetas cuya evaluación lleva 48 horas en Error, para que un usuario no quede bloqueado por un fallo técnico.
- **Prioridad:** Must
- **RF relacionados:** RF-ADM-018, RF-ADM-019
- **CU asociados:** CU-023, CU-030
- **Criterios de aceptación:**
  - Dada una evaluación en Error desde hace 48 horas, cuando abro el listado, entonces la veo; si lleva 47 horas, no la veo.
  - Dada una submeta con 50 puntos provisionales y una evaluación en Error durante 48 horas, cuando la cierro, entonces queda finalizada con 50 y el acumulado del usuario aumenta en 50.
  - Dado un administrador de nivel soporte, cuando intento cerrar la submeta, entonces el sistema responde HTTP 403.

## Módulo IA

### HU-IA-001

- **Actor:** Administrador
- **Historia:** Como administrador, quiero poder cambiar el proveedor de IA sin modificar la lógica del sistema y con respuestas estructuradas y controladas, para reducir costo y dependencia.
- **Prioridad:** Must
- **RF relacionados:** RF-IA-001, RF-IA-002, RF-IA-003, RF-IA-004, RF-IA-005
- **CU asociados:** CU-006, CU-014, CU-013
- **Criterios de aceptación:**
  - Dada la configuración, cuando cambio de proveedor, entonces metas, evidencias y puntuación funcionan sin cambios.
  - Dada una respuesta fuera del esquema, cuando la recibo, entonces la operación pasa a Error sin persistir datos.
  - Dado un fallo transitorio, cuando se reintenta hasta 2 veces, entonces se persiste un único resultado.

### HU-IA-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero saber y aceptar que mis evidencias se procesan con un servicio externo de IA y que no se envían mis datos personales, para proteger mi privacidad.
- **Prioridad:** Must
- **RF relacionados:** RF-IA-005, RF-IA-006, RF-IA-007
- **CU asociados:** CU-013, CU-014, CU-005, CU-006, CU-007, CU-025
- **Criterios de aceptación:**
  - Dado que aún no acepté, cuando intento cargar mi primera evidencia o crear una meta que requiere IA, entonces el sistema me muestra el aviso y me pide aceptar.
  - Dada una evaluación, cuando se envía al proveedor, entonces no incluye mi nombre ni mi correo.
  - Dada una imagen con metadatos EXIF y un nombre de archivo con mi nombre, cuando se envía al proveedor, entonces se envía sin los metadatos EXIF y sin ese nombre de archivo.

### HU-IA-003

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero que la IA evalúe mi evidencia con el contexto de mi meta y me explique su dictamen, para entender el resultado.
- **Prioridad:** Must
- **RF relacionados:** RF-IA-008
- **CU asociados:** CU-014
- **Criterios de aceptación:**
  - Dada una evidencia, cuando se evalúa, entonces la IA recibe el nombre y la descripción de la meta y devuelve dictamen y justificación que puedo leer.

### HU-IA-004

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario que rechaza el uso de un servicio externo de IA, quiero seguir usando la aplicación con metas sin evidencia, de un día o de varios días con desglose manual, para proteger mi privacidad sin quedar fuera del producto.
- **Prioridad:** Must
- **RF relacionados:** RF-IA-010, RF-IA-011, RF-IA-007
- **CU asociados:** CU-005, CU-006, CU-007, CU-013, CU-025, CU-032
- **Criterios de aceptación:**
  - Dado que rechacé el aviso de IA, cuando creo una meta de 1 día que no requiere evidencia, entonces se guarda con su submeta única.
  - Dado que rechacé el aviso de IA, cuando creo una meta de varios días sin evidencia con desglose manual, entonces se guarda con mis submetas.
  - Dado que rechacé el aviso de IA, cuando intento crear o editar una meta con evidencia, pedir desglose automático, recomendaciones o fechas sugeridas, o cargar una evidencia, entonces el sistema me lo impide y me ofrece aceptar el aviso.
  - Dado que acepto el aviso más tarde, cuando repito la operación, entonces el sistema la realiza.

## Módulo NOT

### HU-NOT-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero activar o desactivar las notificaciones push, para controlar los avisos que recibo.
- **Prioridad:** Should
- **RF relacionados:** RF-NOT-001, RF-NOT-002, RF-NOT-007
- **CU asociados:** CU-027, CU-028
- **Criterios de aceptación:**
  - Dado que activo las notificaciones y concedo el permiso del navegador, cuando se produce un evento, entonces recibo el aviso.
  - Dado que las desactivo, cuando se produce un evento, entonces no recibo avisos.

### HU-NOT-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero recibir avisos push de inicio de submeta, apertura de evidencia, tiempo de gracia, resultado y logros, para no perder los plazos.
- **Prioridad:** Should
- **RF relacionados:** RF-NOT-003, RF-NOT-004, RF-NOT-005, RF-NOT-006, RF-NOT-008
- **CU asociados:** CU-028
- **Criterios de aceptación:**
  - Dada una submeta programada a las 08:00, cuando son las 07:50, entonces recibo un recordatorio.
  - Dada una submeta de 60 min, cuando llega el minuto 48, entonces recibo el aviso de que puedo subir mi evidencia.

## Módulo LOGR

### HU-LOGR-001

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero obtener logros automáticamente al cumplir hitos y ser avisado, para sentir reconocimiento.
- **Prioridad:** Should
- **RF relacionados:** RF-LOGR-001, RF-LOGR-002, RF-LOGR-004
- **CU asociados:** CU-026
- **Criterios de aceptación:**
  - Dado que inicio mi primera submeta (a mano o por inicio automático), cuando se registra, entonces obtengo 'Primer paso' una sola vez y veo un aviso.
  - Dado que cierro una submeta con acierto Excelente en el primer envío, cuando se cierra, entonces obtengo 'Impecable'; si el acierto fue en el segundo envío o en el tiempo de gracia, entonces no la obtengo.
  - Dado que ya vi el aviso de un logro, cuando la interfaz consulta de nuevo los logros desde el último instante visto, entonces el aviso no se repite.

### HU-LOGR-002

- **Actor:** Usuario (cliente)
- **Historia:** Como usuario, quiero ver mis logros obtenidos y los pendientes en mi perfil, para saber qué me falta.
- **Prioridad:** Should
- **RF relacionados:** RF-LOGR-003
- **CU asociados:** CU-017
- **Criterios de aceptación:**
  - Dado mi perfil, cuando lo abro, entonces veo los logros obtenidos con fecha y los demás como bloqueados.
