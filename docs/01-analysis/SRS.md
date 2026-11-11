# Sistema Anti Procrastinación (Focus Strike) — SRS v0.1

Especificación de Requisitos de Software, ISO/IEC/IEEE 29148. 11 de noviembre de 2026. Versión 0.1, línea base del proyecto.

Autores: Carlos Andrés Campos Cárdenas, Camilo José León Monsalve, Ángel David López. Proyecto formativo, SENA.


## Control de versiones

| Versión | Fecha | Responsable | Descripción del cambio | Sección(es) afectada(s) | Estado |
|---|---|---|---|---|---|
| 0.1 | 2026-11-11 | Equipo FocusStrike | Línea base | Documento completo | Línea base |


# 1. Introducción


## 1.1 Propósito

El presente documento define la Especificación de Requisitos de Software (SRS) del sistema Focus Strike, una aplicación web responsive orientada a la productividad. Su propósito es establecer, de manera formal, completa y verificable, los requisitos funcionales y no funcionales que el equipo de desarrollo, el equipo de QA y las partes interesadas deben utilizar como base para el diseño, la implementación y la validación del sistema. El documento se elabora conforme a la norma ISO/IEC/IEEE 29148.


## 1.2 Alcance

Focus Strike es una plataforma web orientada a la gestión de la productividad personal. El alcance de la versión 0.1 incluye:

- Gestión de identidades y control de acceso: registro con declaración de mayoría de edad, autenticación con tokens JWT, política de contraseña, recuperación de contraseña, bloqueo temporal por intentos fallidos y cierre de sesión (módulo AUT).
- Perfil de usuario: nombre, puntaje acumulado, días activos (días en que el usuario actúa; calendario de actividad de los últimos 12 meses, accesible, estilo GitHub), racha de días, racha perfecta, posición en el ranking y zona horaria detectada en el registro o, en las cuentas creadas por un administrador, en el primer inicio de sesión, y editable (módulo PER).
- Gestión de metas con IA: creación de metas con horas totales, horario diario (con hora de fin hasta 24:00), fechas elegidas por el usuario o sugeridas por la IA, descripción de la meta, desglose en submetas diarias hecho por la IA o armado manualmente por el usuario, consejos y recomendaciones del Agente IA (módulo META).
- Agenda: metas y submetas por fecha con colores por meta y por estado, detalle de submeta y vista de inicio (módulo AGEN).
- Sesión Pomodoro: temporizador flexible con persistencia y vínculo opcional a submetas en curso (módulo POM).
- Evidencias y evaluación LLM: carga restringida por la regla del 80 %, formatos de imagen, texto, documentos y hojas de cálculo (png, jpg, jpeg, webp, gif, txt, pdf, docx, doc, xlsx y xls; el gif, los documentos y las hojas se convierten antes de evaluar), rechazo en la carga de los archivos vacíos, corruptos, ilegibles o de formato no soportado, evaluación asíncrona con estados y tres dictámenes (Excelente, Incoherente, Inválida), hasta dos envíos por submeta, reintento de la evaluación y eliminación de los archivos al borrar la meta o la cuenta (módulo EVID).
- Puntuación y tiempo de gracia: tabla de puntos por ventana y dictamen, segundo envío a la mitad en cualquier ventana, suma de los dos envíos con tope de 90, tiempo de gracia del 10 % y cierre de la submeta (módulo PUNT).
- Ranking global de clientes (módulo RANK).
- Administración: gestión de cuentas, bloqueo y desbloqueo, métricas de la aplicación y del uso del LLM, consulta de evidencias y ranking, con niveles de acceso y cierre administrativo de submetas con evaluación en Error durante 48 horas (módulo ADM).
- Integración con el motor LLM independiente del proveedor, con consentimiento del usuario y uso de la aplicación sin IA para quien lo rechaza, con metas sin evidencia y desglose manual (módulo IA).
- Notificaciones push web (módulo NOT) y logros (módulo LOGR).
- Público: personas de 18 años o más. El registro exige la declaración 'Declaro ser mayor de 18 años' y guarda el instante en que se hizo; no se pide fecha de nacimiento.


### 1.2.1 Fuera de alcance y trabajo futuro

- Aplicaciones móviles nativas.
- Inicio de sesión con Google o GitHub: queda para una versión futura.
- Temporadas y dificultad de la meta: fuera de alcance por ahora.
- Módulos de pago o suscripción e integraciones con herramientas de terceros distintas del motor LLM, el servicio de correo y el servicio de notificaciones push web.
- Funciones no incluidas en esta versión: rango o identificador público (handle), eventos manuales en la agenda, historial de contraseñas, página de aterrizaje (landing) y vista 'Progreso'. No se incorporan sin una decisión explícita del usuario.
- Apelación o revisión humana del dictamen del LLM y cuotas de costo por usuario del LLM: trabajo futuro.
- Granularidad del tiempo total en minutos: esta versión usa horas enteras **[Supuesto S-04]**.
- Notificaciones por correo no transaccionales y preferencia de notificación por correo: fuera de alcance; la entidad cliente solo tiene la preferencia notificaciones_push.
- Autoescalado automático y disponibilidad mensual de 99,9 %: metas aspiracionales, no exigibles.
- Verificación de la edad con documento o fecha de nacimiento: fuera de alcance; solo se guarda la declaración con su sello de tiempo. Si más adelante se requiere, la fecha de nacimiento se agregaría como cambio nuevo.
- Más de una submeta por fecha de trabajo, también en el desglose manual (BR-014).


## 1.3 Definiciones, acrónimos y abreviaturas

| Término | Definición |
|---|---|
| BD | Base de datos (MariaDB 10.11 o superior; producción en 11.8 LTS o 12.3 LTS). |
| BR | Regla de negocio (Business Rule). |
| CP / CU / HU | Caso de prueba / Caso de uso / Historia de usuario. |
| RF / RNF | Requisito funcional / Requisito no funcional. |
| MoSCoW | Escala de prioridad: Must (debe, equivale a Alta), Should (debería, equivale a Media), Could (podría, equivale a Baja). |
| IA / LLM | Inteligencia artificial / Large Language Model. |
| Motor LLM | Servicio externo de IA, accedido a través de una interfaz intercambiable (IEXT-001). El proveedor inicial se define en el documento de decisiones de arquitectura; el contrato de integración es independiente de él. |
| Agente IA | Capacidad del sistema que usa al Motor LLM para desglosar metas, sugerir fechas, generar consejos y evaluar evidencias. |
| JWT | JSON Web Token: token firmado usado para autenticación por transacción HTTP. |
| Cliente / Usuario | Cuenta con rol cliente: persona que gestiona su productividad. En todo el documento 'Usuario (cliente)' denomina a este actor. |
| Administrador | Cuenta con rol administrador, excluyente del rol cliente, con un nivel de acceso (super, moderador o soporte). |
| Visitante | Persona sin sesión iniciada. |
| Meta | Objetivo de productividad con horas totales, fechas de trabajo y horario diario. |
| Desglose manual | Desglose de una meta multidía en submetas armado por el usuario: una por fecha de trabajo, con nombre, hora de inicio y duración en horas enteras (mínimo 1 h), sin intervención de la IA (RF-META-033, RF-META-035, BR-014). Se ofrece siempre que el desglose por IA falla o la IA no está disponible (RF-META-024). |
| Submeta | Unidad diaria de trabajo de una meta, con horario propio; sujeta a las reglas de evidencia y puntuación. |
| Tiempo estipulado | Duración programada de una submeta: hora de fin menos hora de inicio de la propia submeta (BR-032). En una meta de 1 día es el tiempo total de la meta **[Supuesto S-33]**. |
| Reloj global | Temporizador que define la ventana de entrega de una submeta (inicio, 80 %, 100 %). |
| Regla del 80 % | Restricción antifraude que impide cargar cualquier evidencia (primer o segundo envío) hasta que transcurra al menos el 80 % del tiempo estipulado (BR-001). |
| Ventana de tiempo | Intervalo en que se recibe una evidencia: inicial (hasta el 100 %) o gracia (10 % adicional). |
| Tiempo de gracia | 10 % del tiempo estipulado, contado desde el fin del 100 % del tiempo inicial, para rectificar o entregar. |
| Evidencia de rectificación | Segundo envío de una submeta; solo se admite tras un primer dictamen Incoherente o Inválida (BR-002). |
| Periodo inicial | Intervalo de inicio del reloj hasta el fin del tiempo estipulado (100 %); precede al tiempo de gracia. |
| Envío | Carga de una evidencia por el usuario aceptada por el servidor. Cada submeta admite como máximo dos envíos (BR-002); Reintentar una evaluación no es un envío, ni lo es una carga rechazada por archivo vacío, corrupto, ilegible o de formato no soportado (RF-IA-012). |
| Dictamen | Resultado de la evaluación del LLM sobre una evidencia: Inválida (contenido legible sin relación con la submeta o de otro tema), Incoherente (relacionada con la submeta pero insuficiente) o Excelente (acorde y bien) (BR-005). No es lo mismo que Error, que es un fallo técnico del servicio de IA, ni que el rechazo en la carga de un archivo vacío, corrupto, ilegible o de formato no soportado, que no genera dictamen (RF-IA-012). |
| Error (de evaluación) | Estado de la evaluación por un fallo técnico del servicio de IA (timeout tras los reintentos, error 5xx, cuota agotada o respuesta fuera del esquema); no es un dictamen, no puntúa y admite Reintentar sin consumir envío. Un archivo vacío, corrupto, ilegible o de formato no soportado no es un Error ni una Inválida: se rechaza al subirlo, sin evaluación ni dictamen y sin consumir envío (BR-005, RF-IA-012). |
| Cierre administrativo | Cierre de una submeta por un administrador de nivel super o moderador cuando su evaluación lleva 48 horas o más en Error, con el puntaje provisional como puntaje final (RF-ADM-019). |
| Cuenta con datos | Cuenta cliente con al menos una meta, una sesión Pomodoro, un logro, un día activo o un puntaje mayor que 0, o cuenta administrador que cerró al menos una submeta; su rol no puede cambiarse (BR-013, RF-ADM-009) **[Supuesto S-54]**. |
| Último super | El único administrador de nivel super sin bloqueo administrativo; ninguna operación puede dejar al sistema sin él (BR-021). |
| Limpieza programada | Proceso del sistema, ejecutado al menos cada 24 horas, que elimina del almacén los archivos de evidencia que no tienen registro y tienen más de 1 hora de antigüedad (RF-EVID-018, BR-036) **[Supuesto S-53]** **[Supuesto S-55]**. |
| Puntaje provisional / final | Provisional: suma de los puntos de las evidencias ya evaluadas de una submeta abierta, con tope de 90 si hay dos y 0 para las que están en evaluación o en Error; aún no suma al perfil. Final: el de la submeta cerrada, que se suma al acumulado del perfil. |
| Tope de 90 | Máximo del puntaje de una submeta que recibió dos envíos (BR-004); el primer envío Excelente en el periodo inicial da 100. |
| Acierto en el primer envío | Cierre de una submeta por dictamen Excelente del primer envío recibido en el periodo inicial; no cuenta el primer envío que cae en el tiempo de gracia (BR-033). |
| Racha perfecta | Número de submetas calificadas consecutivas cerradas con acierto en el primer envío (BR-033, RF-PER-012). |
| Sin envío | Ausencia de evidencia en el tiempo inicial. 'Sin envío' no es un dictamen del LLM. |
| Racha (de días) | Racha de días: número de días activos consecutivos del usuario (BR-019); el inicio automático de una submeta no suma. |
| Día activo | Día calendario, en la zona horaria del usuario, en que el usuario actúa: inicia a mano una submeta o envía una evidencia (BR-009). El inicio automático, los cierres del sistema o de un administrador y la finalización por sí misma no lo activan; en una meta sin evidencia solo el inicio manual lo activa. Es la misma definición para la racha, el calendario de actividad y la vista de inicio. |
| Calendario de actividad | Cuadrícula del perfil con los últimos 12 meses en la que los días activos aparecen en un único tono de verde (BR-034, RF-PER-003). |
| Consentimiento de IA | Aceptación explícita del usuario del uso de un servicio externo de IA; sin ella se pueden usar metas que no requieren evidencia, de 1 día o multidía con desglose manual (BR-035, RF-IA-010, RF-IA-011). |
| Logro | Reconocimiento automático por cumplir un hito del catálogo (BR-020). |
| Notificación push | Aviso entregado al navegador del usuario mediante el servicio de notificaciones push web. |
| [SUPUESTO S-nn] | Valor propuesto por el analista que se adopta por defecto; se lista en el Anexo A.1 y el usuario puede revocarlo o confirmarlo. |
| [Supuesto S-nn] | Valor que proviene de un supuesto S-nn confirmado; se lista en el Anexo A.2 y conserva la referencia a su ID. |
| Fuente de verdad del esquema | El script SQL con triggers para MariaDB. |


## 1.4 Referencias

- ISO/IEC/IEEE 29148:2018 — Ingeniería de sistemas y software — Procesos del ciclo de vida — Especificación de requisitos.
- Documentos de arquitectura y contrato de la API (decisiones de arquitectura, seguridad de la base de datos, planificador de trabajos, contrato OpenAPI y correspondencia entre casos de uso y endpoints), pendientes de publicar en la entrega 0.1.
- Script de esquema MariaDB database/schema.sql (fuente de verdad) y diccionario de datos docs/02-design/database/data-dictionary.xlsx.
- Diagrama de casos de uso (docs/02-design/uml/use-cases/use-cases.puml), diagramas de actividades (docs/02-design/uml/activities/CU-0NN-*.puml), modelo de dominio (docs/02-design/uml/domain-model/domain-model.puml), modelo entidad-relación y modelo relacional (docs/02-design/database/erd.puml y relational.puml) y diagramas de clases (docs/02-design/uml/classes/class-diagram*.puml).
- Diseño de interfaz: mockups en docs/02-design/mockups/. No son fuente de requisitos.
- Matriz de trazabilidad vigente: docs/01-analysis/traceability-matrix.xlsx.
- Ubicación de este documento: docs/01-analysis/SRS.md.
- Pautas de Accesibilidad para el Contenido Web (WCAG) 2.2.


## 1.5 Visión general del documento

La sección 1 introduce el propósito, el alcance, las definiciones y las referencias. La sección 2 describe el contexto del producto. La sección 3 especifica los requisitos: interfaces externas (3.1), requisitos funcionales por módulo (3.2), datos (3.3), requisitos no funcionales (3.4), historias de usuario (3.5), reglas de negocio (3.6), casos de uso (3.7) y casos de prueba (3.8). La sección 4 (Verificación y trazabilidad) presenta la estrategia de verificación y la matriz de trazabilidad, que incluye las reglas de negocio de cada requisito. La sección 1.6 propone una priorización por iteraciones. Los anexos recogen los supuestos (A: en A.1 los adoptados por defecto y en A.2 los confirmados), las preguntas y criterios adoptados (B) y los identificadores reservados (C). En todo el documento los actores se nombran 'Usuario (cliente)' y 'Administrador'; 'Usuario autenticado' no se usa como nombre de actor.


## 1.6 Priorización por iteraciones (corte de MVP sugerido)

Sugerencia de corte de MVP. No elimina ni renumera ningún requisito, no cambia ningún ID y requiere la aprobación del usuario; se apoya en la prioridad MoSCoW ya asignada a cada RF.

| Módulo | Must | Should | Could | Total RF |
|---|---|---|---|---|
| AUT | 16 | 2 | 0 | 18 |
| PER | 0 | 12 | 5 | 17 |
| META | 22 | 16 | 1 | 39 |
| AGEN | 1 | 3 | 2 | 6 |
| POM | 0 | 6 | 1 | 7 |
| EVID | 16 | 2 | 0 | 18 |
| PUNT | 12 | 1 | 0 | 13 |
| RANK | 1 | 2 | 2 | 5 |
| ADM | 16 | 5 | 0 | 21 |
| IA | 11 | 1 | 0 | 12 |
| NOT | 0 | 7 | 1 | 8 |
| LOGR | 0 | 3 | 1 | 4 |
| Total | 95 | 60 | 13 | 168 |

- Iteración 1 (MVP): los 95 RF Must. Cubre registro y acceso (incluida la declaración de mayoría de edad, la zona horaria del registro y la del primer inicio de sesión), metas con desglose por IA o manual, submetas, evidencias y evaluación, puntuación, ranking base, administración con niveles de acceso y cierre administrativo de submetas con Error persistente, integración con el LLM, consentimiento de IA y eliminación de cuentas y metas con sus archivos.
- Iteración 2: los 60 RF Should, que completan agenda, perfil (incluido el calendario de actividad accesible y su contador diario), Pomodoro, notificaciones push (módulo NOT, que puede planificarse completo), logros y la edición de metas con su consentimiento de IA.
- Iteración 3: los 13 RF Could (metadatos de perfil, vista de inicio, avisos de logro, desempates y otros).
- Dependencias de prioridad: RF-PER-006 y RF-PER-011 (contador de submetas por día) son Should porque los requieren RF-PER-013, RF-PER-015 y RF-PER-016; RF-ADM-018 y RF-ADM-019 (cierre administrativo) son Must porque RF-PUNT-011 (Must) mantiene la submeta abierta ante un Error y su única salida es ese cierre; RF-AUT-015 (zona horaria del registro) es Must porque RF-AUT-001 deja obligatoria la zona de la cuenta cliente.
- Dependencias de prioridad (continuación): RF-META-002c (eliminar una meta) es Must porque RF-EVID-017 y HU-EVID-006 (Must) se verifican al eliminar una meta y la iteración 1 incluye la eliminación de metas con sus archivos; RF-IA-011 (Must) incluye la denegación al editar una meta, función que depende de RF-META-002b y RF-META-037 (Should): en la iteración 1 la denegación rige en la creación de metas y se completa en la edición junto con ellos en la iteración 2; RF-AUT-016 (zona horaria del primer inicio de sesión) es Must como RF-AUT-015 y acompaña a RF-ADM-021.
- Prioridad de RF-AUT-017 y RF-AUT-018: RF-AUT-017 y RF-AUT-018 son Must porque el registro (RF-AUT-001, Must) y las cuentas creadas por un administrador (RF-ADM-001, Must) dependen de la declaración de mayoría de edad.
- Dependencias a revisar al fijar el corte: RF-META-020 (Should, capacidad del horario) sostiene BR-014(6) y conviene adelantarlo con el MVP; RF-META-027 (Must, regenerar submetas) y RF-META-037 (Should, consentimiento en la edición) acompañan a RF-META-002b (Should, editar meta), por lo que la edición completa puede planificarse junto con ellos; RF-IA-007, RF-IA-010 y RF-IA-011 (Must, consentimiento de IA, uso sin IA y denegación de funciones) deben estar antes de cualquier uso de la IA; RF-ADM-014 y RF-ADM-015 (niveles de acceso) son Must porque RF-ADM-001, RF-ADM-004, RF-ADM-010 y RF-ADM-017 dependen de ellos; RF-NOT-007 es Should para acompañar al módulo NOT; RF-META-001 (Must) cita a RF-META-021 (Should) y RF-PUNT-014 (Must) cita a RF-RANK-001 (Should) solo como referencia, sin depender de su funcionalidad; RF-AUT-016 y RF-ADM-021 (Must) citan a RF-PER-008 (Should, editar la zona horaria en el perfil) solo como referencia, sin depender de su funcionalidad: la detección y la asignación de la zona no requieren que exista la edición.
- Candidatas a implementarse como una sola unidad de diseño sin alterar los IDs: RF-POM-004 a RF-POM-007 (controles de sesión), RF-EVID-012 a RF-EVID-015 (validaciones de carga), RF-EVID-017 y RF-EVID-018 (archivos de evidencia), RF-NOT-003 a RF-NOT-006 y RF-NOT-008 (eventos, BR-022), RF-RANK-003 a RF-RANK-005 (BR-023) y RF-PER-003, RF-PER-006, RF-PER-011 y RF-PER-013 a RF-PER-016 (calendario de actividad, BR-034).


# 2. Descripción general


## 2.1 Perspectiva del producto

Focus Strike es un sistema web nuevo e independiente orientado a la productividad personal. Centraliza la intención del usuario y la transforma en métricas verificables mediante el desglose de metas con IA, el control de tiempos de entrega, la evaluación de evidencias con LLM y la gamificación con ranking, racha y logros. El producto se compone de:

- Cliente web (frontend): aplicación responsive en JavaScript con React y TailwindCSS.
- Backend en la nube: API REST en Python con Django. La persistencia usa MariaDB 10.11 o superior (versión mínima 10.11; producción en 11.8 LTS o 12.3 LTS); el esquema se define por el script SQL con triggers, que es la fuente de verdad, y no por migraciones de Django.
- Integraciones externas: motor LLM (proveedor inicial definido en el documento de decisiones de arquitectura; acceso por interfaz intercambiable), servicio de correo transaccional y servicio de notificaciones push web.

No sustituye a herramientas de productividad de terceros ni se integra con ellas en esta versión.


## 2.2 Funciones del producto (resumen)

| Módulo | Código | Función principal |
|---|---|---|
| Identidad y Autenticación | AUT | Registro, política de contraseña, login JWT, bloqueo temporal, recuperación de contraseña, logout. |
| Perfil de Usuario | PER | Puntos, calendario de actividad de 12 meses, racha de días, racha perfecta, posición en el ranking, zona horaria. |
| Gestión de Metas y Desglose IA | META | CRUD de metas, planificación por horas totales y fechas, desglose por IA o manual, descripción, consejos y recomendaciones. |
| Agenda | AGEN | Metas y submetas por fecha con colores, detalle de submeta y vista de inicio. |
| Sesión Pomodoro | POM | Temporizador flexible y persistente, vinculable a submetas. |
| Evidencias y Evaluación LLM | EVID | Carga post-80 %, formatos, rechazo en la carga de archivos inválidos, evaluación asíncrona con tres dictámenes, hasta dos envíos, reintento y eliminación de archivos. |
| Puntuación y Tiempo de Gracia | PUNT | Tabla de puntos por ventana y dictamen, suma con tope de 90, gracia del 10 % y cierre de la submeta. |
| Ranking Global | RANK | Ranking de clientes de mayor a menor puntaje. |
| Administración | ADM | Gestión de cuentas, bloqueo, métricas, evidencias, ranking, niveles de acceso y cierre administrativo de submetas con Error persistente. |
| Integración con el Motor LLM | IA | Interfaz intercambiable, salida estructurada, timeout, reintentos, privacidad y consentimiento de IA. |
| Notificaciones Push | NOT | Preferencias, suscripción y avisos de eventos. |
| Logros | LOGR | Catálogo, otorgamiento automático y visualización. |


## 2.3 Clases de usuarios (actores)

| Actor | Descripción | Acciones principales |
|---|---|---|
| Visitante | Persona sin sesión. | Registrarse declarando ser mayor de 18 años (CU-001), iniciar sesión (CU-002), recuperar contraseña (CU-003). |
| Usuario (cliente) | Persona de 18 años o más (lo declara al registrarse, RF-AUT-017, o en su primer inicio de sesión si la cuenta la creó un administrador, RF-AUT-018) con cuenta con rol cliente. | Gestionar metas (con desglose por IA o manual), iniciar submetas, usar Pomodoro, cargar evidencias, consultar agenda, perfil, logros y ranking, configurar preferencias. |
| Administrador | Cuenta con rol administrador, excluyente del rol cliente, con nivel super, moderador o soporte **[Supuesto S-17]**. | Gestionar cuentas, bloquear y desbloquear, consultar métricas, evidencias y ranking, y cerrar submetas con Error persistente, según su nivel. No usa las funciones de cliente (RF-ADM-006). |
| Responsable del despliegue | Persona que instala y configura el sistema. | Inicializar el primer administrador super (CU-029). |
| Motor LLM (actor técnico) | Servicio externo de IA. | Desglose, sugerencia de fechas, recomendaciones, consejos y evaluación de evidencias. |
| Servicio de correo (actor técnico) | Proveedor de correo transaccional. | Entregar el código de recuperación y el aviso de bloqueo temporal. |
| Servicio de notificaciones push (actor técnico) | Servicio de notificaciones web. | Entregar avisos al navegador del usuario. |
| Sistema (actor técnico) | Temporizadores y procesos internos. | Iniciar submetas automáticas, cerrar submetas, otorgar logros, enviar notificaciones. |


## 2.4 Entorno operativo

- Plataforma: aplicación web responsive (React y TailwindCSS) en las dos últimas versiones mayores de Chrome, Firefox, Edge y Safari de escritorio, y en Chrome Android y Safari iOS 16 o superior, desde 320 px de ancho.
- Infraestructura: backend en la nube (Django, API REST), base de datos MariaDB 10.11 o superior (producción en 11.8 LTS o 12.3 LTS), procesamiento asíncrono para las evaluaciones LLM y planificador para los inicios automáticos.
- Integraciones: motor LLM externo, servicio de correo transaccional y servicio de notificaciones push web. En Safari iOS las notificaciones push web requieren que la aplicación esté instalada en la pantalla de inicio; es una limitación del navegador.
- Conectividad: se requiere conexión a internet; no existe modo sin conexión.


## 2.5 Restricciones

- Tecnológicas: backend Python con Django; frontend JavaScript con React y TailwindCSS; base de datos MariaDB 10.11 o superior (versión mínima 10.11; producción en 11.8 LTS o 12.3 LTS); esquema definido por el script SQL; API REST con autenticación JWT; comunicaciones sobre HTTPS.
- Normativa: no existe normativa formal definida; por buena práctica se aplican los principios de protección de datos personales de la Ley 1581 de 2012 (Colombia) **[Supuesto S-32]**, además del cifrado de contraseñas y HTTPS.
- Presupuesto: sin presupuesto formalizado; el costo de las llamadas al LLM se registra (RF-ADM-007) y se muestra al administrador (RF-ADM-011). El uso con usuarios reales requiere un plan de pago del proveedor de LLM con límite de gasto (IEXT-001, BR-026).
- Proveedor LLM: el proveedor inicial se define en el documento de decisiones de arquitectura; el contrato de integración es independiente del proveedor (módulo IA, IEXT-001).
- Plazos: sujetos al cronograma del proyecto formativo (SENA).


## 2.6 Suposiciones y dependencias

- Dependencia del servicio LLM: si el proveedor no responde, el desglose automático queda pendiente y se ofrece siempre el desglose manual como alternativa (RF-META-024, CU-032), y las evaluaciones pasan a Error con opción de reintento (RF-EVID-008, RNF-018).
- Se requiere conexión a internet estable del lado del cliente.
- El servicio está dirigido a personas de 18 años o más y se apoya en la declaración del usuario; no se verifica con documento ni fecha de nacimiento.
- El usuario es responsable del inicio tardío de sus submetas en modo manual (BR-006, BR-027).
- El envío de correos depende de un proveedor de correo configurado (SMTP, SendGrid o Amazon SES).
- Las notificaciones push dependen de que el navegador del usuario las soporte y de que el usuario conceda el permiso. El uso de la IA depende de que el usuario acepte el servicio externo; sin esa aceptación quedan disponibles las metas sin evidencia, de 1 día o multidía con desglose manual (BR-035).
- Los supuestos S-R1 a S-R12 y S-API-01 a S-API-17 (Anexo A.1) están adoptados por defecto y el usuario puede revocarlos; los demás están confirmados (Anexo A.2). La pregunta OQ-04 (Anexo B), pendiente, verificada técnicamente y con acciones pendientes del responsable del despliegue, no bloquea el avance del proyecto. S-R12 es criterio de aceptación de RF-IA-005 y RF-IA-006 y S-API-17 precisa su aplicación en el servidor.


# 3. Requisitos del sistema


## 3.1 Requisitos de interfaces externas


### 3.1.1 Interfaz de usuario (UI)

Aplicación web responsive construida con React y TailwindCSS, accesible por los navegadores declarados en RNF-010 y conforme a WCAG 2.2 AA (RNF-009). Toda la interacción ocurre a través de esta UI; no existen clientes nativos. Las pantallas de administración (incluido el cierre de submetas con Error persistente), la creación de metas con desglose manual, la edición y eliminación de metas, los estados de evaluación, el aviso de consentimiento de IA y el calendario de actividad del perfil con su alternativa textual forman parte de la UI requerida. Los mockups están en docs/02-design/mockups/; este SRS prevalece sobre ellos.


### 3.1.2 Interfaces de hardware

No aplica. El sistema es 100 % web y no requiere componentes de hardware específicos.


### 3.1.3 Interfaces de software

| ID | Interfaz | Descripción |
|---|---|---|
| IEXT-001 | Motor LLM mediante interfaz de proveedor intercambiable | El sistema DEBE comunicarse por HTTPS con el motor LLM a través de una interfaz única e intercambiable (RF-IA-001) para: (a) desglose de metas, descripciones, consejos y recomendaciones; (b) sugerencia de fechas; (c) evaluación de coherencia de evidencias. El contrato DEBE definir: autenticación, esquema JSON versionado de entrada y salida (RF-IA-002), timeout de 30 s (RF-IA-003), reintentos (RF-IA-004), preparación de contenido por formato (RF-IA-005) y política de datos, que incluye la minimización de lo enviado (RF-IA-005, RF-IA-006, BR-026). Es independiente del proveedor (el proveedor inicial se define en el documento de decisiones de arquitectura). Con usuarios reales el acceso al proveedor DEBE hacerse con un plan de pago con límite de gasto configurado; la capa gratuita solo se usa con datos sintéticos de prueba, porque enviar datos reales exige la garantía de no entrenamiento de BR-026, propia de los términos del plan de pago. El SRS no fija precios ni cuotas, que cambian. |
| IEXT-002 | Servicio de correo electrónico (SMTP o proveedor tipo SendGrid o Amazon SES) | El sistema DEBE enviar correos transaccionales para el código de recuperación de contraseña (RF-AUT-007) y para el aviso de bloqueo temporal (RF-AUT-009). |
| IEXT-003 | API REST propia consumida por el frontend | El frontend React DEBE consumir la API REST propia mediante peticiones HTTP autenticadas con token JWT (RF-AUT-004). Las rutas, verbos y esquemas se definen en el contrato OpenAPI; este SRS no fija rutas. |
| IEXT-004 | Servicio de notificaciones push web | El sistema DEBE enviar las notificaciones push (RF-NOT-003 a RF-NOT-008) al servicio de notificaciones del navegador usando la suscripción registrada (RF-NOT-002). |


## 3.2 Requisitos funcionales (RF)

Prioridad MoSCoW: Must, Should, Could (equivalen a Alta, Media y Baja). Las rutas de la API no se fijan en este documento; se definen en el contrato OpenAPI. Los códigos HTTP de los criterios siguen la convención S-30 **[Supuesto S-30]**. RF-META-001 es un requisito de una sola acción (crear); sus campos se validan individualmente en los RF indicados. **RF-PUNT-009 es un identificador reservado** (ver Anexo C).


### Módulo AUT — Identidad y Autenticación

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-AUT-001 | El sistema DEBE permitir el registro de una cuenta nueva capturando nombre, correo electrónico, contraseña y la declaración de mayoría de edad (RF-AUT-017). | Must | Con datos válidos la API responde HTTP 201 y crea la cuenta; la contraseña queda almacenada solo como hash (RNF-005) y el usuario puede iniciar sesión con ella. Con nombre, correo o contraseña ausentes responde HTTP 422 indicando el campo faltante; sin la declaración de mayoría de edad responde HTTP 422 y no crea la cuenta (RF-AUT-017). |
| RF-AUT-002 | El sistema DEBE rechazar el registro cuando el correo electrónico ya existe. | Must | El registro con un correo duplicado (sin distinguir mayúsculas de minúsculas) responde HTTP 409 y no crea ningún registro. |
| RF-AUT-003 | El sistema DEBE autenticar al usuario con correo y contraseña válidos y emitir un token JWT con expiración de 60 minutos. **[Supuesto S-01]** | Must | Credenciales válidas: HTTP 200 con JWT firmado cuya expiración es 60 min posterior a su emisión. Credenciales inválidas: HTTP 401 sin token. |
| RF-AUT-004 | El sistema DEBE validar la firma, la vigencia y la no revocación del token JWT en cada petición a recursos protegidos. | Must | Petición sin token, con token inválido, vencido o revocado: HTTP 401. Token válido sin el rol requerido: HTTP 403. Ningún recurso protegido devuelve datos sin token válido. |
| RF-AUT-005 | El sistema DEBE permitir cerrar la sesión del usuario invalidando el token vigente. | Should | Tras cerrar sesión el token queda revocado y una petición posterior con ese token recibe HTTP 401. |
| RF-AUT-006 | El sistema DEBE permitir al usuario solicitar la recuperación de su contraseña ingresando su correo electrónico. | Must | La solicitud con cualquier correo bien formado responde HTTP 200 con el mismo mensaje genérico, sin revelar si el correo existe. |
| RF-AUT-007 | El sistema DEBE enviar el código de recuperación únicamente cuando el correo ingresado está registrado. | Must | Con correo registrado el buzón recibe un código de 6 dígitos **[Supuesto S-03]**; con correo inexistente no se envía ningún correo. |
| RF-AUT-008 | El sistema DEBE restablecer la contraseña cuando se presenta un código de recuperación vigente y no usado junto con una nueva contraseña que cumpla RF-AUT-011. **[Supuesto S-03]** | Must | Con código válido la contraseña se actualiza, el código queda marcado como usado y no puede reutilizarse. Con código inválido, usado o expirado: HTTP 422 sin cambios **[Supuesto S-30]**. |
| RF-AUT-009 | El sistema DEBE enviar un correo de notificación al titular de la cuenta cuando esta se bloquea temporalmente por intentos fallidos (RF-AUT-014). | Should | Al producirse el bloqueo por el 5.º intento fallido, el buzón del titular recibe en ≤ 60 s un correo que informa el bloqueo y su duración. |
| RF-AUT-010 | El sistema DEBE rechazar un código de recuperación con más de 10 minutos de antigüedad. | Must | Un código generado hace 10 min 1 s se rechaza con HTTP 422 **[Supuesto S-30]** y el usuario debe solicitar uno nuevo; uno de 9 min 59 s se acepta. |
| RF-AUT-011 | El sistema DEBE exigir que toda contraseña nueva (registro y restablecimiento) tenga al menos 8 caracteres, con al menos una letra y un número. **[Supuesto S-02]** | Must | Contraseñas de 7 caracteres, sin número o sin letra: HTTP 422 y no se crea ni actualiza la cuenta. 'Clave1234' se acepta. |
| RF-AUT-012 | El sistema DEBE reiniciar a cero el contador de intentos fallidos de una cuenta solo tras un inicio de sesión exitoso o al vencer el bloqueo temporal. | Must | Tras 3 intentos fallidos y un inicio de sesión exitoso el contador vale 0. Cerrar una submeta o actualizar el puntaje del usuario no modifica el contador ni el estado de bloqueo. |
| RF-AUT-013 | El sistema DEBE asignar el rol cliente a toda cuenta creada por autorregistro. | Must | Toda cuenta creada con el formulario de registro tiene rol cliente; ningún campo del registro permite elegir otro rol. |
| RF-AUT-014 | El sistema DEBE bloquear temporalmente durante 15 minutos la cuenta que acumule 5 intentos fallidos consecutivos de inicio de sesión y rechazar los intentos siguientes con HTTP 429. | Must | El 5.º intento fallido responde HTTP 401 y activa el bloqueo; los intentos 6.º en adelante, incluso con contraseña correcta, responden HTTP 429 con la cabecera Retry-After hasta cumplirse los 15 min. |
| RF-AUT-015 | El sistema DEBE asignar a la cuenta nueva, en el registro, la zona horaria IANA que informa el navegador del visitante y, si el navegador no la informa o no es una zona IANA válida, America/Bogota. **[Supuesto S-27]** | Must | Un registro desde un navegador configurado en America/Argentina/Buenos_Aires crea la cuenta con esa zona sin que el visitante la escriba; un registro cuyo navegador no informa zona, o informa un valor no válido (p. ej. 'Mars/Olympus'), crea la cuenta con America/Bogota. Las cuentas cliente creadas por un administrador o convertidas desde administrador no se rigen por este RF sino por RF-AUT-016. |
| RF-AUT-016 | El sistema DEBE sustituir America/Bogota por la zona horaria IANA que informa el navegador en el primer inicio de sesión de una cuenta cliente creada por un administrador o convertida desde administrador. | Must | Una cuenta cliente creada por un administrador tiene America/Bogota antes de su primer inicio de sesión; en el primer inicio exitoso (HTTP 200) desde un navegador en America/Argentina/Buenos_Aires su zona pasa a esa zona sin que el usuario la escriba; si el navegador no informa zona o informa un valor no válido (p. ej. 'Mars/Olympus'), la cuenta conserva America/Bogota; un intento fallido (HTTP 401) no cuenta como primer inicio; en los inicios siguientes la zona no se vuelve a sobrescribir (el usuario la edita en su perfil, RF-PER-008); lo mismo rige para la cuenta convertida desde administrador; una cuenta de autorregistro no se ve afectada (RF-AUT-015). |
| RF-AUT-017 | El sistema DEBE exigir, en el registro de una cuenta nueva, la declaración 'Declaro ser mayor de 18 años' y guardar el instante en que se hizo, sin pedir ni guardar la fecha de nacimiento. | Must | Un registro con datos válidos y con la declaración responde HTTP 201 y la cuenta guarda el sello de tiempo de la declaración (fecha_confirmacion_mayoria_edad, no nulo, que difiere del instante de recepción del registro en 5 s o menos); un registro sin la declaración (ausente o con valor falso) responde HTTP 422 con el motivo MAYORIA_EDAD_REQUERIDA y no crea la cuenta; el registro, las respuestas de la API y la base de datos no contienen ningún campo de fecha de nacimiento. |
| RF-AUT-018 | El sistema DEBE pedir la declaración 'Declaro ser mayor de 18 años' en el primer inicio de sesión exitoso de una cuenta cliente creada por un administrador o convertida desde administrador y guardar el instante en que se hizo. **[SUPUESTO S-R9]** | Must | Una cuenta cliente creada por un administrador no tiene sello de declaración antes de su primer inicio de sesión; en el primer inicio exitoso (HTTP 200) el sistema informa que la declaración está pendiente y, hasta que el usuario la haga, toda función de cliente responde HTTP 403 con el motivo MAYORIA_EDAD_REQUERIDA; al declarar queda guardado el sello de tiempo y las funciones de cliente quedan disponibles; en los inicios siguientes no se vuelve a pedir; un intento fallido (HTTP 401) no cuenta como primer inicio; lo mismo rige para la cuenta convertida desde administrador (RF-ADM-020); una cuenta de autorregistro no se ve afectada (RF-AUT-017). |


### Módulo PER — Perfil de Usuario

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-PER-001 | El sistema DEBE mostrar el perfil del usuario con su nombre, puntaje acumulado y número de días activos. | Should | La vista de perfil del usuario autenticado muestra nombre, puntos totales y conteo de días activos coincidentes con los datos almacenados. |
| RF-PER-002 | El sistema DEBE registrar como día activo el día calendario, en la zona horaria del usuario, en que el usuario inicia a mano una submeta o envía una evidencia (BR-009). | Should | Cada día cuenta como activo como máximo una vez; se registra cuando el usuario inicia a mano una submeta de modo manual o cuando el servidor acepta una evidencia que envía, y el día es el de recepción de la evidencia; no se registra al iniciar sesión, al iniciarse una submeta automática ni al rechazarse una carga (RF-EVID-002, RF-EVID-013, RF-IA-012). Una submeta que el usuario inicia a mano el martes a las 23:50 y cuya evidencia se recibe el miércoles hace activos ambos días; una evidencia recibida el martes a las 23:50 y dictaminada el miércoles a las 00:40 activa el martes y no el miércoles (salvo que el miércoles el usuario actúe). No activan ningún día el inicio automático, la finalización por sí misma (solo cuenta como consecuencia de una evidencia enviada ese día, que ya activa el día por el envío), el cierre por fin de la gracia, el de una meta sin evidencia al vencer su tiempo, el de una submeta manual nunca iniciada (BR-027) ni el cierre administrativo (RF-ADM-019). En una meta sin evidencia solo el inicio manual activa el día: una submeta automática de una meta sin evidencia no activa ningún día. |
| RF-PER-003 | El sistema DEBE mostrar en el perfil un calendario de actividad de los últimos 12 meses con cada día activo resaltado en un único tono de verde, igual para todos, y los días no activos sin resaltar. | Should | La vista de perfil muestra un calendario con una celda por día de los últimos 12 meses (BR-034); todo día activo (BR-009) aparece en el mismo tono de verde, sin gradaciones por número de submetas; un día no activo aparece sin resaltar; un día en que solo se inició sesión, solo hubo un inicio automático o solo hubo un cierre del sistema o administrativo no aparece en verde; un usuario sin actividad ve el calendario completo sin ningún día verde. |
| RF-PER-004 | El sistema DEBE mostrar en el perfil del usuario su posición actual en el ranking global. | Could | La vista de perfil muestra la posición con el formato 'Puesto #N de M', coherente con RF-RANK-001. |
| RF-PER-005 | El sistema DEBE registrar la fecha-hora de inicio de la primera submeta iniciada a mano en cada día activo. | Could | Al iniciar a mano la primera submeta del día se guarda su fecha-hora; iniciar a mano una segunda submeta el mismo día no modifica ese valor; un día activo solo por el envío de una evidencia no tiene valor. |
| RF-PER-006 | El sistema DEBE mantener, para cada día activo, el número de submetas iniciadas a mano en ese día. | Should | Tras iniciar a mano 3 submetas el mismo día el contador de ese día vale 3; al día siguiente el contador comienza en 1; los inicios automáticos no se cuentan y un día activo solo por el envío de una evidencia tiene contador 0. |
| RF-PER-007 | El sistema DEBE calcular y mostrar en el perfil la racha actual del usuario, entendida como el número de días activos consecutivos. **[Supuesto S-14]** | Should | Con días activos lunes, martes y miércoles: el jueves antes de actuar la racha muestra 3; si el jueves termina sin actividad pasa a 0; si el jueves el usuario inicia a mano una submeta o envía una evidencia muestra 4; un jueves con solo un inicio automático o un cierre del sistema cuenta como sin actividad. |
| RF-PER-008 | El sistema DEBE permitir al usuario consultar y modificar su zona horaria (zona IANA) en su perfil. **[Supuesto S-27]** | Should | Una zona válida (p. ej. America/Argentina/Buenos_Aires) se guarda y todos los horarios se muestran en ella; una zona inexistente responde HTTP 422 sin cambios; hasta que el usuario la cambie rige la zona asignada en el registro (RF-AUT-015) o, en una cuenta creada por un administrador o convertida, la detectada en su primer inicio de sesión (RF-AUT-016). |
| RF-PER-009 | El sistema DEBE calcular y mostrar en el perfil la racha máxima histórica del usuario. **[Supuesto S-14]** | Could | Si el usuario tuvo rachas de 3 y 5 días, el perfil muestra 5 como racha máxima; la racha máxima nunca disminuye. |
| RF-PER-010 | El sistema DEBE mostrar en el perfil la hora registrada del primer inicio manual de una submeta del día con la etiqueta 'Primera actividad del día'. | Could | Si la primera submeta del día se inició a mano a las 08:12, el perfil muestra 08:12 con esa etiqueta; sin ningún inicio manual hoy no muestra valor. |
| RF-PER-011 | El sistema DEBE mostrar en el calendario de días activos el número de submetas iniciadas a mano en cada día. | Should | Al seleccionar un día activo del calendario se muestra su contador (p. ej. '3 submetas'; 0 si el día es activo solo por el envío de una evidencia). |
| RF-PER-012 | El sistema DEBE calcular y mostrar en el perfil la racha perfecta actual del usuario: el número de submetas calificadas consecutivas, por orden de cierre, cerradas con acierto Excelente en el primer envío recibido en el periodo inicial (BR-033). **[Supuesto S-38]** | Could | Tras cerrar 3 submetas con 100 puntos por acierto en el primer envío del periodo inicial la racha perfecta muestra 3; una submeta cerrada con 90 o menos por dos envíos, con 50 por un primer envío Excelente recibido en gracia (que no cuenta) o con 0 la reinicia a 0; una submeta sin calificación (meta sin evidencia) o cerrada por un administrador tras un Error persistente no la altera. |
| RF-PER-013 | El sistema DEBE asignar a cada día del calendario de actividad una etiqueta de texto con su fecha y su condición (activo o sin actividad), de modo que la información no dependa solo del color. | Should | Un lector de pantalla anuncia cada celda como 'fecha, activo, N submetas' o 'fecha, sin actividad'; un día activo solo por el envío de una evidencia (sin submetas iniciadas a mano ese día) se anuncia como 'fecha, activo, 0 submetas'; con una simulación de daltonismo los días activos se identifican por texto o forma; el contraste de la celda activa frente a la no activa y de cada celda frente al fondo es ≥ 3:1 (criterio 1.4.11 de WCAG 2.2). |
| RF-PER-014 | El sistema DEBE permitir recorrer el calendario de actividad solo con el teclado, con foco visible y sin trampas de foco. | Should | Con solo el teclado se recorren los días con las flechas y se sale del calendario con Tab; el foco es visible con contraste ≥ 3:1 y no hay trampas de foco. |
| RF-PER-015 | El sistema DEBE mostrar el detalle de un día del calendario (fecha y número de submetas) en un tooltip accesible que aparece con el foco o con el puntero y se descarta sin mover el foco. | Should | Al enfocar un día o pasar el puntero aparece el detalle con la fecha y el número de submetas ('3 submetas'); se cierra con la tecla Escape sin mover el foco; permanece visible mientras el puntero está sobre él y un lector de pantalla lo anuncia (criterio 1.4.13 de WCAG 2.2). |
| RF-PER-016 | El sistema DEBE ofrecer una alternativa textual del calendario de actividad: una tabla o lista de los días activos de los últimos 12 meses con su fecha y su número de submetas. | Should | Existe una vista de tabla o lista con todos los días activos de los últimos 12 meses, cada uno con su fecha y su número de submetas (0 si el día es activo solo por el envío de una evidencia); un usuario sin actividad ve la tabla vacía con un aviso; desde 320 px de ancho la vista se usa sin desplazamiento horizontal (RNF-010). |
| RF-PER-017 | El sistema DEBE conservar la fecha y la hora locales de las submetas pendientes y los días activos ya registrados cuando el usuario cambia su zona horaria. **[Supuesto S-52]** | Should | Una submeta pendiente del 10/12 a las 08:00 en America/Bogota sigue programada para el 10/12 a las 08:00 en la nueva zona (por ejemplo America/Argentina/Buenos_Aires) y su inicio automático ocurre a esa hora local; el inicio real, el cierre y las evidencias ya registrados conservan su instante y se muestran en la nueva zona; una submeta en curso conserva su reloj; los días activos ya registrados y el calendario no se recalculan. |


### Módulo META — Gestión de Metas y Desglose IA

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-META-001 | El sistema DEBE permitir crear una meta capturando nombre, categoría, tiempo total (horas), fechas de trabajo, horario diario, si requiere evidencia y modo de inicio (manual o automático); la descripción es opcional (RF-META-021). | Must | Con todos los parámetros obligatorios válidos la API responde HTTP 201 y la meta queda visible en la agenda; con un parámetro obligatorio ausente responde HTTP 422 indicando el campo. Cada campo se valida en RF-META-010, 015 a 020 y 029. |
| RF-META-002a | El sistema DEBE permitir consultar una meta existente del usuario. | Should | La consulta de una meta propia devuelve HTTP 200 con sus datos, submetas y consejos; la de una meta ajena devuelve HTTP 404. |
| RF-META-002b | El sistema DEBE permitir editar una meta existente del usuario. | Should | La edición con parámetros válidos responde HTTP 200 y la meta queda actualizada; con parámetros inválidos responde HTTP 422 sin cambios. |
| RF-META-002c | El sistema DEBE permitir eliminar una meta existente del usuario, previa confirmación explícita, junto con sus submetas, evidencias y evaluaciones. | Must | La solicitud de eliminación lleva la confirmación explícita (confirmar=true), además de la confirmación de la interfaz: sin ella responde HTTP 422 y no elimina nada; con ella la eliminación responde HTTP 200; la meta y sus dependientes dejan de existir; los archivos de sus evidencias se eliminan del almacén (RF-EVID-017) **[Supuesto S-53]**; el puntaje acumulado del perfil no cambia **[Supuesto S-12]** y los días activos del usuario tampoco **[Supuesto S-54]**; los registros de uso del LLM de la meta se conservan con el vínculo a la meta vacío **[Supuesto S-45]**. |
| RF-META-003 | El sistema DEBE invocar al Agente IA, cuando el usuario elige el desglose por IA, en una operación síncrona que el cliente inicia tras guardar la meta, para desglosar una meta multidía en submetas diarias, una por fecha, de horas enteras (mínimo 1 h), con suma igual al tiempo total. | Must | Una meta de 3 días y 6 h totales con horario 08:00 a 10:00 y desglose por IA produce 3 submetas con horario dentro de 08:00 a 10:00 cuya duración suma 6 h; con desglose manual (RF-META-033) no hay llamada de desglose al LLM. Cada submeta generada dura un número entero de horas de 1 h o más (por ejemplo 2 h, 2 h y 2 h); una respuesta del LLM simulado con una submeta de 1,5 h, de 0 h o de duración negativa se trata como respuesta fuera del esquema (RF-IA-002): no se persiste ninguna submeta y la meta queda con el desglose pendiente (RF-META-024); una meta de 3 días y 2 h, que no admite un desglose válido porque cada submeta dura al menos 1 h, responde HTTP 422 (BR-014 numeral 10). El desglose es síncrono: la meta se guarda primero, sin submetas; el cliente solicita el desglose y espera la respuesta (p95 de hasta ~60 s, RNF-015), sin tareas en segundo plano, y las submetas existen al recibirla. |
| RF-META-004 | El sistema DEBE guardar una meta de 1 día con tiempo total menor o igual a 12 horas sin invocar al Agente IA; su submeta única se define en RF-META-031. | Must | Crear una meta de 1 día y 12 h no genera llamadas al LLM y queda guardada con una submeta (RF-META-031); 12 h ÷ 1 día = 12 no supera el umbral de 12 h por día (BR-015). |
| RF-META-005 | El sistema DEBE crear cada submeta vinculada a su meta padre con fecha, hora de inicio y hora de fin comprendidas en el horario diario de la meta; la hora de fin es posterior a la de inicio y puede ser 24:00. | Must | Cada submeta contiene el ID de la meta padre, una fecha de trabajo, hora de inicio y hora de fin dentro del horario diario. Una submeta de 22:00 a 24:00 es válida; una hora de fin igual o anterior a la de inicio, o posterior a 24:00, se rechaza con HTTP 422 (o, si proviene del Agente IA, la respuesta se descarta). |
| RF-META-006 | El sistema DEBE cerrar una submeta de una meta que no requiere evidencia al expirar su tiempo estipulado, sin calificación, sin puntaje y sin invocar al LLM. | Should | Al expirar el tiempo la submeta queda finalizada con puntaje vacío (sin calificación); no hay llamada al LLM ni suma de puntos al perfil. |
| RF-META-007 | El sistema DEBE generar una descripción para cada submeta creada por el Agente IA durante el desglose. | Should | Cada submeta generada por IA tiene un campo descripción no vacío que detalla qué hacer ese día. |
| RF-META-008 | El sistema DEBE invocar al Agente IA, en toda meta cuyo promedio diario (tiempo total ÷ días destinados) sea mayor a 12 h y hasta 24 h, para generar recomendaciones antes de confirmar la meta. **[Supuesto S-49]** | Must | Las recomendaciones comprenden hábitos saludables, descanso y división del tiempo. Una meta de 1 día con 18 h y una meta de 3 días con 42 h (14 h por día) disparan la intervención IA y muestran recomendaciones antes de confirmar; 1 día con 12 h y 3 días con 36 h (12 h por día) no invocan la recomendación; 1 día con 24 h la dispara (24 h por día es válido, BR-011); sin aceptación del servicio de IA no se invoca (RF-IA-011): la solicitud de recomendaciones responde HTTP 403 con el aviso de consentimiento, se registran 0 llamadas al LLM y la meta que no requiere evidencia se guarda igual, sin recomendaciones; con desglose manual el umbral se evalúa igualmente sobre el promedio diario y una submeta de más de 12 h no lo activa por sí sola; la recomendación nunca impide guardar la meta y el único límite duro es 24 h por día (RF-META-010) **[Supuesto S-49]**. |
| RF-META-009 | El sistema DEBE presentar las sugerencias del Agente IA al usuario y permitirle aceptarlas, modificarlas o rechazarlas (el usuario tiene la última palabra). | Must | Las recomendaciones se muestran antes de confirmar la meta; aceptar, editar o descartar nunca bloquea el guardado de la meta. |
| RF-META-010 | El sistema DEBE rechazar toda meta cuyo tiempo total dividido entre los días destinados sea mayor a 24 horas (máximo 24 h por día, inclusivo). | Must | 25 h en 1 día: HTTP 422 con el mínimo de días requerido (2); 24 h en 1 día con horario de 00:00 a 24:00: aceptada (límite inclusivo); 250 h en 10 días: HTTP 422 con el mínimo de días requerido (11); 240 h en 10 días con horario de 00:00 a 24:00: aceptada. La aceptación final depende además de la capacidad del horario (RF-META-020). |
| RF-META-011 | El sistema DEBE generar y conservar consejos generales sobre la meta cuando el Agente IA interviene en su planificación. | Could | Tras el desglose de una meta de más de 1 día se muestran consejos generales, y se vuelven a mostrar al consultar la meta (RF-META-002a). |
| RF-META-012 | El sistema DEBE iniciar el reloj global de una submeta en modo manual cuando el usuario la inicia en cualquier momento de su fecha programada, de 00:00:00 a 23:59:59 en la zona horaria del usuario, y no antes de esa fecha. | Must | Al iniciar la submeta se registra la hora de inicio real y el reloj global cuenta desde ese instante. Con una submeta de horario 14:00 a 15:00, el inicio a las 00:00:00, a las 10:00 (mitad de la mañana, antes de su horario) o a las 23:59:59 de su fecha programada se acepta y el reloj dura el tiempo estipulado desde el inicio real; el inicio el día anterior a su fecha responde HTTP 409 y la submeta sigue pendiente; iniciar una submeta que ya está en curso o finalizada responde HTTP 409. |
| RF-META-013 | El sistema DEBE iniciar automáticamente el reloj global de una submeta en modo automático a la hora programada de su fecha, en la zona horaria del usuario. | Must | Para una submeta automática programada a las 08:00 (zona del usuario) el reloj inicia sin intervención del usuario y nunca antes de las 08:00:00; el retraso máximo admitido se mide en RNF-024 (de 0 a +30 s en el 95 % de los casos). |
| RF-META-014 | El sistema DEBE persistir la decisión del usuario sobre cada recomendación IA (aceptada, modificada o rechazada) junto con su fecha-hora, conservando el historial si la meta genera nuevas recomendaciones. **[Supuesto S-13]** | Should | Tras decidir sobre una recomendación se guarda estado y fecha-hora de la decisión; una segunda recomendación para la misma meta no sobrescribe la primera. |
| RF-META-015 | El sistema DEBE interpretar el tiempo total de la meta como el número entero de horas totales dedicadas a la meta, sumando todos sus días de trabajo. **[Supuesto S-04]** | Must | Una meta de 3 días con tiempo total 6 se interpreta como 6 h en total (2 h/día de promedio); un valor 0, negativo o decimal responde HTTP 422. |
| RF-META-016 | El sistema DEBE permitir al usuario elegir las fechas concretas en que trabajará la meta y DEBE establecer los días destinados igual al número de fechas elegidas. | Must | Al elegir 4 fechas no consecutivas los días destinados valen 4 y se generan exactamente 4 submetas, una por fecha elegida. |
| RF-META-017 | El sistema DEBE permitir al usuario indicar solo el número de días (mínimo 2) dentro de un rango de fecha de inicio a fecha límite, en lugar de elegir las fechas concretas. **[Supuesto S-05]** | Must | Con un rango de 14 días y 5 días solicitados, el formulario acepta la solicitud y pasa a RF-META-032; un número de días menor que 2 o mayor que los días del rango responde HTTP 422 indicando el campo. |
| RF-META-018 | El sistema DEBE presentar las fechas sugeridas por la IA y permitir al usuario aceptarlas, modificarlas o rechazarlas antes de guardar la meta. | Must | Aceptar crea las submetas en las fechas sugeridas; modificar, en las fechas modificadas; rechazar vuelve a la elección manual; no se guarda ninguna meta sin confirmación. |
| RF-META-019 | El sistema DEBE clasificar la meta como un_dia cuando tiene 1 día destinado y como multidia cuando tiene 2 o más días destinados. | Should | Días destinados 1 produce tipo un_dia; 3 produce multidia; el sistema no admite una meta multidia con 1 día destinado. |
| RF-META-020 | El sistema DEBE rechazar una meta cuyo tiempo total supere los días destinados multiplicados por la duración del horario diario de ejecución (hora de fin, que puede ser 24:00, menos hora de inicio). **[Supuesto S-34]** | Should | 8 días, 40 h y horario 08:00 a 10:00 (capacidad 16 h): HTTP 422 con la capacidad y el horario mínimo requerido; 3 días, 6 h y horario 08:00 a 10:00: aceptada; 1 día, 24 h y horario 00:00 a 24:00 (capacidad exacta de 24 h): aceptada; 1 día, 24 h y horario 00:00 a 23:59 (capacidad 23 h 59 min): HTTP 422. |
| RF-META-021 | El sistema DEBE permitir registrar una descripción de la meta de hasta 1000 caracteres, obligatoria cuando el usuario solicita fechas sugeridas por la IA. **[Supuesto S-05]** | Should | Una descripción de 1001 caracteres responde HTTP 422; con fechas sugeridas por IA y descripción vacía responde HTTP 422; en los demás casos la descripción puede omitirse. |
| RF-META-022 | El sistema DEBE enviar la descripción de la meta como contexto al Agente IA en el desglose, en la sugerencia de fechas y en la evaluación de evidencias. | Should | La solicitud al LLM registrada en pruebas contiene el texto exacto de la descripción de la meta en las tres operaciones. |
| RF-META-023 | El sistema DEBE incluir recomendaciones de descanso, además de las de hábitos saludables, cuando RF-META-008 se activa en una meta multidía, y DEBE conservar con los consejos generales (RF-META-011) las recomendaciones que el usuario acepte o modifique. | Should | Meta de 3 días y 42 h (14 h por día): las recomendaciones incluyen descanso; si el usuario las acepta, aparecen en los consejos al consultar la meta; con 3 días y 30 h (10 h por día) no hay recomendaciones de descanso. |
| RF-META-024 | El sistema DEBE conservar la meta sin submetas cuando el desglose por IA falla tras agotar los reintentos de RF-IA-004 o la IA no está disponible, informar al usuario y ofrecerle reintentar el desglose o armarlo manualmente. **[Supuesto S-08]** | Must | Con el LLM simulado caído, la meta existe sin submetas y con aviso 'desglose pendiente' que ofrece las opciones 'Reintentar desglose' y 'Desglose manual' (CU-032); al reintentar con el LLM disponible se crean las submetas; al elegir el desglose manual el usuario define las submetas (RF-META-033 a RF-META-035), la meta queda con modo de desglose manual y no se registra ninguna llamada nueva al LLM; la opción manual se ofrece siempre, también en una meta con evidencia de un usuario que aceptó la IA; como el desglose se solicita después de guardar la meta (RF-META-003), un fallo del desglose síncrono nunca deshace la meta y el aviso llega en la misma respuesta. |
| RF-META-025 | El sistema DEBE iniciar al recuperarse una submeta automática cuya hora programada ocurrió mientras el sistema no estaba disponible, tomando la hora programada como inicio del reloj, siempre que su tiempo estipulado no haya vencido. **[Supuesto S-10]** | Should | Con el sistema detenido de 07:55 a 08:10 y submeta programada a las 08:00 de 60 min, al reanudar la submeta pasa a en curso con inicio 08:00 y 50 min restantes. |
| RF-META-026 | El sistema DEBE cerrar como finalizada la submeta manual no iniciada durante su fecha programada, hasta las 23:59:59 (zona horaria del usuario): con 0 puntos si la meta requiere evidencia y sin calificación (BR-010) si no la requiere. **[Supuesto S-09]** | Should | Una submeta manual de una meta con evidencia no iniciada al terminar su fecha pasa a las 00:00 siguiente a finalizada con 0 puntos y sin tiempo de gracia; la de una meta sin evidencia pasa a finalizada sin calificación (puntaje vacío); en ambos casos no hay tiempo de gracia. |
| RF-META-027 | El sistema DEBE regenerar las submetas de una meta cuando la edición modifica sus días, tiempo total, fechas u horario, mediante el modo de desglose que el usuario elija. | Must | Al cambiar el tiempo total de 6 h a 9 h en una meta de 3 días sin submetas iniciadas, las submetas existentes se sustituyen por otras cuya duración suma 9 h: con desglose por IA las genera el Agente IA (sujeto al consentimiento de IA, BR-035); con desglose manual el usuario las define en la misma edición (RF-META-033) y, si no cumplen RF-META-034 y RF-META-035, la API responde HTTP 422 y la meta no cambia; en una meta de 1 día se recalcula la submeta única (RF-META-031). |
| RF-META-028 | El sistema DEBE impedir la edición de días, tiempo total, fechas, horario, modo de inicio y requisito de evidencia de una meta que tenga alguna submeta iniciada. **[Supuesto S-11]** **[Supuesto S-51]** | Should | Editar el tiempo total, el modo de inicio o el requisito de evidencia de una meta con una submeta en curso o finalizada responde HTTP 409; editar solo nombre, categoría o descripción es aceptado. |
| RF-META-029 | El sistema DEBE rechazar fechas de trabajo anteriores a la fecha actual en la zona horaria del usuario al crear una meta. | Must | Una meta con una fecha de trabajo de ayer responde HTTP 422; con la fecha de hoy es aceptada. |
| RF-META-030 | El sistema DEBE permitir guardar una meta de 1 día con más de 12 h por día sin recomendaciones cuando el Agente IA no está disponible, informando al usuario. | Should | Con el LLM simulado caído, la meta de 1 día y 18 h se guarda con aviso 'recomendaciones no disponibles' y sin registro de recomendación (una meta multidía con el LLM caído sigue RF-META-024 y puede armarse con desglose manual, RF-META-033). |
| RF-META-031 | El sistema DEBE crear, para una meta de 1 día, una única submeta en la fecha de la meta, desde la hora de inicio de su horario y con duración igual al tiempo total (su tiempo estipulado). **[Supuesto S-33]** | Must | Meta de 1 día, 3 h y horario 08:00 a 12:00: una submeta de 08:00 a 11:00 con tiempo estipulado de 3 h; meta de 1 día, 24 h y horario 00:00 a 24:00: una submeta de 00:00 a 24:00; la suma de los tiempos estipulados de las submetas es igual al tiempo total (BR-014). |
| RF-META-032 | El sistema DEBE invocar al Agente IA para proponer fechas según la descripción de la meta, cuando el usuario indica solo el número de días, y descartar toda propuesta que no tenga exactamente ese número de fechas válidas. **[Supuesto S-05]** | Must | Con rango de 14 días, 5 días y descripción no vacía, la IA devuelve exactamente 5 fechas distintas dentro del rango y no anteriores a hoy; una respuesta con fechas fuera del rango, repetidas, anteriores a hoy o en cantidad distinta se descarta y se ofrece la elección manual (RF-META-016). |
| RF-META-033 | El sistema DEBE permitir crear una meta multidía con desglose manual: una submeta por fecha de trabajo, con nombre, hora de inicio y duración en horas enteras (mínimo 1 h), sin invocar al Agente IA. | Must | Un usuario que rechazó el servicio de IA crea una meta sin evidencia de 3 días (10, 11 y 12 de diciembre), 6 h y horario 08:00 a 12:00, con tres submetas ('Leer capítulo 1', 08:00, 2 h; 'Resumir', 09:00, 2 h; 'Ejercicios', 10:00, 2 h): la API responde HTTP 201, la meta queda con modo de desglose manual y esas tres submetas con su nombre, fecha y horario (la hora de fin es la de inicio más la duración, BR-032) y se registran 0 llamadas al LLM simulado; una duración de 0 h o de 1,5 h responde HTTP 422 (RF-META-035). |
| RF-META-034 | El sistema DEBE rechazar un desglose manual cuya suma de duraciones de las submetas sea distinta del tiempo total de la meta, indicando la diferencia. | Must | En una meta de 3 días y 6 h, submetas de 2 h, 2 h y 1 h responden HTTP 422 con la diferencia ('faltan 1 h'); de 2 h, 2 h y 3 h responden HTTP 422 ('sobran 1 h'); de 2 h, 2 h y 2 h se aceptan (BR-014 numeral 5). |
| RF-META-035 | El sistema DEBE exigir que cada submeta del desglose manual tenga fecha de trabajo distinta, dure horas enteras (mínimo 1 h), quepa en el horario diario de la meta y termine a más tardar a las 24:00. | Must | En una meta con horario 08:00 a 12:00, una submeta de 07:00 a 09:00 responde HTTP 422 indicando el campo; con horario 00:00 a 24:00, una submeta que inicia a las 22:00 y dura 2 h (fin 24:00) se acepta y una que dura 3 h responde HTTP 422; una duración de 1 h se acepta; responden HTTP 422 una duración de 0 h, negativa o no entera (por ejemplo 1,5 h), un nombre vacío o de más de 150 caracteres, una fecha repetida o ajena a las fechas de trabajo y dos submetas en la misma fecha; el límite de 24 h por día (BR-011) se cumple porque cada submeta cabe en un horario de 24 h como máximo. |
| RF-META-036 | El sistema DEBE ofrecer el desglose manual como alternativa al desglose por IA al usuario que aceptó el servicio de IA, también en metas que requieren evidencia. | Should | El usuario con aceptación registrada elige entre 'Desglose por IA' y 'Desglose manual' al crear una meta multidía; con el manual no se registra ninguna llamada de desglose al LLM simulado y la meta, con o sin evidencia, se guarda; si el promedio diario supera 12 h las recomendaciones de RF-META-008 se siguen mostrando antes de guardar; la evidencia de esa meta se evalúa como la de cualquier otra. |
| RF-META-037 | El sistema DEBE aplicar el consentimiento de IA a la edición de metas: sin aceptación del servicio, rechaza toda edición que requiera la IA y conserva la meta sin cambios. **[Supuesto S-51]** | Should | Un usuario sin aceptación que edita una meta no puede activar el requisito de evidencia, pasar una meta de 1 día a multidía con desglose por IA, ni pedir recomendaciones, fechas sugeridas o desglose automático: HTTP 403 con el aviso de consentimiento, 0 llamadas al LLM simulado y la meta sin cambios; sí puede editar nombre, categoría y descripción, y pasar la meta a multidía o cambiar sus fechas con un desglose manual válido; pasar la meta a multidía sin entregar un desglose manual válido (ni pedir el de IA) responde siempre HTTP 422 indicando el campo faltante o inválido (RF-META-034, RF-META-035), sin llamadas al LLM y con la meta sin cambios. |


### Módulo AGEN — Agenda

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-AGEN-001 | El sistema DEBE mostrar una agenda con las metas y sus submetas organizadas por fecha, para un rango consultado que por defecto es el mes calendario en curso y no excede 93 días. **[Supuesto S-39]** | Must | La agenda devuelve las metas y submetas del usuario agrupadas por día dentro del rango consultado, en su zona horaria; sin parámetro de rango muestra el mes en curso; un rango mayor de 93 días responde HTTP 422. |
| RF-AGEN-002 | El sistema DEBE mostrar las submetas de una misma meta con el mismo color distintivo y cada meta con un color diferente. | Should | En la agenda todas las submetas de una meta comparten un color y dos metas distintas muestran colores distintos. |
| RF-AGEN-003 | El sistema DEBE mostrar el estado de cada submeta (pendiente, en curso, finalizada) con un color propio por estado, combinado con el color de la meta. | Should | Cada submeta muestra el color de su meta y un indicador de estado; finalizada indica cierre, con calificación o sin calificación según BR-010. Los colores de estado no dependen solo del color (BR-031). |
| RF-AGEN-004 | El sistema DEBE permitir acceder al detalle de una submeta desde la agenda con su horario, estado, puntaje, evidencias y estado de la evaluación. | Should | Al seleccionar una submeta se muestran horario, estado, puntaje (o 'sin calificación'), evidencias enviadas y estado de la evaluación de cada una. |
| RF-AGEN-005 | El sistema DEBE mostrar tras el inicio de sesión una vista de inicio con la próxima submeta del día, el puntaje acumulado y la racha actual. **[Supuesto S-26]** | Could | Tras iniciar sesión se muestra la submeta pendiente o en curso más cercana de hoy, el puntaje y la racha; la racha es la de BR-019 y no suma los días en que solo hubo inicios automáticos; sin submetas hoy se muestra un mensaje de agenda libre. |
| RF-AGEN-006 | El sistema DEBE mostrar en el detalle de una submeta en curso la ventana vigente (inicial o gracia) y el tiempo restante de esa ventana. | Could | Durante el tiempo inicial se muestra 'Tiempo estipulado' con su cuenta regresiva; durante la gracia, 'Tiempo de gracia' con su cuenta regresiva. |


### Módulo POM — Sesión Pomodoro

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-POM-001 | El sistema DEBE permitir al usuario iniciar una sesión Pomodoro en cualquier momento. | Should | La acción Iniciar está disponible y pone en marcha un temporizador en el cliente (el navegador); iniciar no crea ningún registro en el servidor. |
| RF-POM-002 | El sistema DEBE guardar cada sesión Pomodoro finalizada o abandonada que dure al menos 1 minuto efectivo, con fecha, duración efectiva en minutos, submeta vinculada (si aplica) y estado final. **[Supuesto S-28]** | Should | Al finalizar o abandonar se persiste un registro con fecha-hora de inicio, minutos efectivos excluyendo pausas, submeta y estado. Una sesión de menos de 1 minuto efectivo no se guarda (el cliente no la envía; si llega, el servidor responde HTTP 422) y mientras la sesión está activa o en pausa no existe ningún registro en el servidor. |
| RF-POM-003 | El sistema DEBE permitir vincular una sesión Pomodoro a una submeta en curso del usuario. **[Supuesto S-28]** | Could | Al iniciar el temporizador solo se ofrecen submetas en curso del usuario y el vínculo queda registrado; una submeta ajena responde HTTP 404. |
| RF-POM-004 | El sistema DEBE permitir pausar una sesión Pomodoro activa. | Should | Al pausar, el temporizador se detiene y el tiempo en pausa no se cuenta en la duración efectiva; la pausa ocurre en el cliente y no genera registros en el servidor. |
| RF-POM-005 | El sistema DEBE permitir reanudar una sesión Pomodoro pausada. | Should | Al reanudar, el temporizador continúa desde el tiempo restante al momento de la pausa; la reanudación ocurre en el cliente y no genera registros en el servidor. |
| RF-POM-006 | El sistema DEBE permitir abandonar una sesión Pomodoro en cualquier momento sin afectar el reloj global ni el puntaje de la submeta. | Should | Tras abandonar, la sesión queda en estado abandonada y el estado, el reloj y el puntaje de la submeta vinculada no cambian. |
| RF-POM-007 | El sistema DEBE permitir finalizar una sesión Pomodoro. | Should | Al finalizar, la sesión queda en estado finalizada con su duración efectiva. |


### Módulo EVID — Evidencias y Evaluación LLM

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-EVID-001 | El sistema DEBE mantener deshabilitada la carga de toda evidencia (primer o segundo envío) de una submeta hasta que haya transcurrido al menos el 80 % de su tiempo estipulado (regla antifraude, BR-001). | Must | Antes del umbral el control de carga está deshabilitado en la interfaz; desde el umbral está habilitado. La regla se aplica a cada envío; el segundo envío solo es posible tras el dictamen del primero y por ello siempre queda por encima del umbral. |
| RF-EVID-002 | El sistema DEBE rechazar en el backend toda carga de evidencia realizada antes de transcurrido el 80 % del tiempo estipulado. | Must | Una carga a menos del 80 % responde HTTP 409 y no persiste la evidencia **[Supuesto S-30]**. |
| RF-EVID-003 | El sistema DEBE aceptar como evidencia archivos png, jpg, jpeg, webp, gif, txt, pdf, docx, doc, xlsx y xls de hasta 26 214 400 bytes (RF-EVID-004) y convertirlos antes de evaluarlos cuando el motor de IA no los admite de forma nativa: el gif a una imagen PNG de su primer fotograma y los documentos y hojas de cálculo (docx, doc, xlsx, xls) a texto o Markdown. | Must | Se aceptan imágenes (.png, .jpg, .jpeg, .webp, .gif), texto (.txt, .pdf, .docx, .doc) y hojas de cálculo (.xlsx, .xls). Las imágenes png, jpg, jpeg y webp, el pdf y el txt se envían a evaluar sin conversión; un .gif (animado o no) se convierte en una imagen PNG de su primer fotograma; un .docx, un .doc, un .xlsx y un .xls se convierten a texto o Markdown (las hojas conservan sus filas y columnas como tabla) antes de evaluarse (RF-IA-005). Cualquier otro formato (por ejemplo .exe, .zip o .csv) responde HTTP 415; un archivo de formato admitido que no se puede convertir (vacío, corrupto, protegido con contraseña o ilegible) responde HTTP 422 con el motivo; en ambos casos no se persiste la evidencia, no se consume el envío y no se llama al LLM (RF-IA-012). Límite conocido: la conversión conserva el texto y las tablas, pero pierde las imágenes, los gráficos y los objetos incrustados de los documentos y hojas, que el evaluador no ve. El .doc se convierte en el servidor; si esa conversión no es viable en el despliegue, el .doc se retira de la lista y responde HTTP 415. Aclaración de implementación, sin cambio funcional: el límite de subida de la aplicación (26 214 400 bytes) no cambia; el archivo, o su versión convertida, que supere el límite de solicitud en línea del proveedor de IA (20 MB al 2026-11-01) se procesa por el mecanismo de archivos del proveedor o se reduce antes de enviarlo, y esa elección es decisión de implementación; lo que se acepta y los códigos HTTP son los de este requisito. |
| RF-EVID-004 | El sistema DEBE rechazar todo archivo de evidencia con tamaño mayor a 25 MB. | Should | Un archivo de 25 MB (26 214 400 bytes) se acepta; uno de 25 MB + 1 byte responde HTTP 413. |
| RF-EVID-005 | El sistema DEBE enviar la evidencia al motor LLM de forma asíncrona para su análisis de coherencia. | Must | Tras la carga, una vez validado y preparado el archivo de forma síncrona (RF-IA-012), la API responde de inmediato HTTP 202 y el análisis se procesa en segundo plano. |
| RF-EVID-006 | El sistema DEBE registrar el estado de la evaluación asíncrona de cada evidencia: En evaluación, Evaluada (con dictamen Excelente, Incoherente o Inválida) o Error. **[Supuesto S-36]** | Must | Al cargar, la evaluación queda En evaluación; al recibir dictamen válido pasa a Evaluada; pasa a Error solo por un fallo técnico del servicio de IA: timeout tras agotar los reintentos automáticos (RF-IA-004), error 5xx o cuota agotada tras los reintentos, o respuesta fuera del esquema. Un archivo vacío, corrupto, ilegible o de formato no soportado nunca llega a evaluación: se rechaza al subirlo, sin evidencia, evaluación ni dictamen y sin consumir envío (RF-IA-012); un contenido legible sin relación con la submeta sí se evalúa y recibe dictamen Inválida (0 puntos, consume el envío); un Error no puntúa y admite Reintentar sin consumir envío (RF-EVID-008). |
| RF-EVID-007 | El sistema DEBE habilitar un único segundo envío de evidencia cuando el dictamen del primer envío es Incoherente o Inválida, desde ese dictamen hasta el fin del tiempo de gracia. **[Supuesto S-37]** | Must | Con dictamen Incoherente o Inválida al 90 % del tiempo, la carga del segundo envío se habilita de inmediato; con dictamen Excelente no se habilita (la submeta se cierra); tras el segundo envío no se habilitan más cargas. |
| RF-EVID-008 | El sistema DEBE permitir reintentar una evaluación en estado Error reevaluando la misma evidencia sin consumir un intento de envío. | Must | Al reintentar, la misma evidencia pasa de Error a En evaluación sin crear una evidencia nueva; el número de intentos de envío usados no cambia; si el Reintentar vuelve a fallar, la evaluación regresa a Error y la cuenta de 48 h de RF-ADM-018 comienza de nuevo; tras el cierre administrativo de la submeta (RF-ADM-019) Reintentar responde HTTP 409. |
| RF-EVID-009 | El sistema DEBE mostrar al usuario el estado de la evaluación de cada una de sus evidencias. | Must | El usuario ve En evaluación, Evaluada con dictamen y justificación, o Error con la acción Reintentar. |
| RF-EVID-010 | El sistema DEBE asignar cada evidencia (primer o segundo envío) a la ventana de tiempo (inicial o gracia) según el instante en que el servidor la recibe y no según el instante del dictamen, y rechazar con HTTP 409 la evidencia cuyo porcentaje de tiempo transcurrido o cuya ventana declarados por el cliente no coincidan con los que calcula el servidor a partir de su instante de recepción, la hora de inicio real de la submeta y su tiempo estipulado T (tolerancia de 1 s de T). El cliente puede declarar el porcentaje y la ventana solo como dato informativo; el servidor calcula siempre los suyos y son los que guarda. | Must | Una evidencia recibida al 98 % cuyo dictamen llega al 103 % se registra con ventana inicial y se puntúa como primer envío del periodo inicial; un segundo envío recibido a los 55 min o a los 62 min de una submeta de 60 min queda registrado con su ventana (inicial o gracia) y en ambos casos vale la mitad de la tabla del periodo inicial (RF-PUNT-005); una evidencia que declara un porcentaje de 85 % cuando su instante de recepción corresponde al 8 %, o la ventana gracia cuando corresponde a la inicial, se rechaza con HTTP 409 y no se persiste; una evidencia que no declara porcentaje ni ventana se acepta y se registra con los valores que calcula el servidor, y cuando los declarados coinciden también se guardan los del servidor. |
| RF-EVID-011 | El sistema DEBE completar la evaluación de una evidencia recibida antes del fin del tiempo de gracia aunque el plazo expire mientras se evalúa. | Must | Una evidencia recibida en el último segundo del tiempo de gracia cuyo dictamen llega 40 s después se evalúa, se puntúa y cierra la submeta. |
| RF-EVID-012 | El sistema DEBE aceptar como máximo 2 evidencias por submeta. | Must | Un tercer envío para la misma submeta responde HTTP 409 y no persiste la evidencia; Reintentar una evaluación (RF-EVID-008) no cuenta como envío. |
| RF-EVID-013 | El sistema DEBE rechazar toda carga de evidencia posterior al fin del tiempo de gracia. | Must | Una carga 1 s después de terminar el tiempo de gracia responde HTTP 409 y no persiste la evidencia **[Supuesto S-30]**. |
| RF-EVID-014 | El sistema DEBE rechazar la carga de evidencia para submetas de metas que no requieren evidencia. | Should | Una carga para una submeta de una meta con requiere evidencia en falso responde HTTP 409. |
| RF-EVID-015 | El sistema DEBE permitir cargar evidencia solo al propietario de la submeta. | Must | Una carga de un usuario distinto del propietario responde HTTP 404 y no persiste la evidencia. |
| RF-EVID-016 | El sistema DEBE rechazar un segundo envío mientras el primero no tenga dictamen Incoherente o Inválida. | Must | Un segundo envío con el primero En evaluación, en Error o dictaminado Excelente responde HTTP 409 y no persiste la evidencia; con el primero dictaminado Incoherente o Inválida se acepta. |
| RF-EVID-017 | El sistema DEBE eliminar del almacén el archivo físico de cada evidencia cuyo registro se elimina, ya sea por la eliminación de su meta o por la de su cuenta (RF-ADM-010). **[Supuesto S-53]** | Must | La aplicación lista las rutas de los archivos antes de eliminar las filas, porque las acciones referenciales de MariaDB no activan triggers (RNF-014). Tras eliminar una meta con 2 evidencias, los 2 archivos dejan de existir en el almacén y una solicitud a su ruta responde 404; tras eliminar una cuenta con evidencias en 3 metas no queda ningún archivo de esa cuenta en el almacén (inspección del almacén); los archivos de otras cuentas no se alteran. |
| RF-EVID-018 | El sistema DEBE eliminar, mediante una limpieza programada al menos cada 24 horas, todo archivo del almacén sin registro de evidencia y con más de 1 hora de antigüedad, sin revertir la eliminación de la meta o la cuenta. **[Supuesto S-53]** **[Supuesto S-55]** | Must | Si el borrado de un archivo falla (almacén no disponible), la eliminación de la meta o de la cuenta no se revierte, el fallo queda en el log con la ruta del archivo y el archivo permanece sin registro; en la siguiente ejecución de la limpieza el archivo se elimina; la limpieza no elimina ningún archivo que tenga registro de evidencia ni uno sin registro con 1 hora o menos de antigüedad, contada desde que el archivo se escribió en el almacén con el reloj del servidor (una carga cuyo registro aún no se confirma; el mínimo de 1 hora es el valor por defecto de un parámetro configurable del despliegue, BR-036): un archivo sin registro de 59 min se conserva y el mismo archivo, ya sin registro tras cumplir más de 1 hora, se elimina en la siguiente ejecución; con reloj simulado se verifica que dos ejecuciones consecutivas están separadas por 24 h o menos. |


### Módulo PUNT — Puntuación y Tiempo de Gracia

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-PUNT-001 | El sistema DEBE cerrar la submeta con 100 puntos, sin aplicar el tope de 90, cuando su primer envío se recibe en el periodo inicial y el LLM lo dictamina Excelente. | Must | Con dictamen Excelente del primer envío en el periodo inicial, la submeta cierra con 100 puntos y estos se suman al perfil (caso E-01 de 3.6.1). |
| RF-PUNT-002 | El sistema DEBE asignar a cada evidencia sus puntos según su dictamen, su número de envío y la ventana en que se recibe, conforme a la tabla de 3.6.1. | Must | Primer envío en el periodo inicial: Excelente 100, Incoherente 50 e Inválida 0; primer envío en el tiempo de gracia (la mitad): Excelente 50, Incoherente 25 e Inválida 0; segundo envío, en cualquier ventana (la mitad): Excelente 50, Incoherente 25 e Inválida 0. Un primer envío Incoherente recibido en el periodo inicial otorga 50 puntos provisionales y deja la submeta abierta; un segundo envío Excelente otorga 50 tanto en el periodo inicial como en la gracia; un envío Inválida otorga 0 en todos los casos (tabla completa en 3.6.1). |
| RF-PUNT-003 | El sistema DEBE asignar 0 puntos provisionales cuando no se recibe evidencia en el tiempo inicial, manteniendo la submeta abierta durante el tiempo de gracia. | Must | Al expirar el tiempo inicial sin evidencia la submeta muestra 0 puntos provisionales y se abre el tiempo de gracia. |
| RF-PUNT-004 | El sistema DEBE calcular el puntaje de una submeta con dos envíos como la suma de los puntos de ambos limitada a un máximo de 90. | Must | Incoherente (50) más Excelente (50) suma 100 y se limita a 90; Incoherente (50) más Incoherente (25) da 75; Inválida (0) más Excelente (50) da 50; Incoherente (50) más Inválida (0) da 50; Inválida más Inválida da 0 (los casos de dos envíos de 3.6.1: E-03 a E-08, E-10 a E-15, E-18 a E-20 y E-22 a E-24). |
| RF-PUNT-005 | El sistema DEBE puntuar el segundo envío con la mitad de la tabla del periodo inicial (Excelente 50, Incoherente 25, Inválida 0), sea cual sea la ventana, inicial o de gracia, en que se envía. | Must | Un segundo envío Excelente enviado en el minuto 55 de una submeta de 60 min otorga 50 puntos y enviado en el minuto 62 también otorga 50 (casos E-03 y E-06); un segundo envío Incoherente otorga 25 y uno Inválida otorga 0 en ambas ventanas. |
| RF-PUNT-006 | El sistema DEBE cerrar la submeta al expirar el tiempo de gracia, conservando el puntaje del primer envío (o 0 si no hubo envío), cuando no se recibió un segundo envío. | Must | Primer envío Incoherente inicial (50) sin segundo envío cierra con 50 al expirar la gracia; primer envío Inválida sin segundo envío cierra con 0; sin envío alguno cierra con 0. |
| RF-PUNT-007 | El sistema DEBE calcular el tiempo de gracia como el 10 % del tiempo estipulado de la submeta (BR-003, BR-032), contado desde que expira el 100 % del tiempo inicial. **[Supuesto S-33]** | Must | Para una submeta de 60 min el tiempo de gracia dura 6 min y comienza en el minuto 60. |
| RF-PUNT-008 | El sistema DEBE actualizar atómicamente el puntaje acumulado del perfil del usuario al cerrar cada submeta calificada, en la misma transacción que el estado final de la submeta. | Must | Si la transacción falla, ni el estado final de la submeta ni el puntaje del perfil se modifican; si tiene éxito, ambos se persisten juntos. |
| RF-PUNT-010 | El sistema DEBE calcular el puntaje de cada submeta, de forma independiente de las demás (BR-008), como la suma de los puntos de sus evidencias evaluadas, con máximo 100 con un envío y máximo 90 con dos envíos, y conservar los puntos de cada evidencia. | Must | Dos evidencias de 50 y 25 puntos producen un puntaje de submeta de 75 y cada evidencia conserva su valor; un único envío Excelente en el periodo inicial produce 100; dos envíos que suman 100 producen 90. |
| RF-PUNT-011 | El sistema DEBE mantener abierta la submeta (no finalizada) mientras el tiempo de gracia siga vigente y no se haya aplicado RF-PUNT-013, o exista una evaluación en curso o en Error. **[Supuesto S-22]** | Must | Con dictamen Incoherente al 90 % la submeta sigue en curso hasta enviar el segundo envío o expirar la gracia; con una evaluación en Error la submeta sigue abierta hasta resolverse con Reintentar o hasta que un administrador la cierre tras 48 h (RF-ADM-019, BR-018). |
| RF-PUNT-012 | El sistema DEBE mostrar al usuario el puntaje provisional de la submeta abierta, la suma de los puntos de sus evidencias ya evaluadas (con tope de 90 si hay dos y 0 para las que están en evaluación o en Error), distinguiéndolo del puntaje final. | Should | Con una evidencia evaluada de 50 puntos y la submeta abierta se muestra 'Provisional: 50'; con una segunda evidencia aún En evaluación sigue mostrando 'Provisional: 50'; al cerrarse se muestra 'Final: N'. |
| RF-PUNT-013 | El sistema DEBE cerrar la submeta en el instante del dictamen de su segundo envío, del dictamen Excelente de su primer envío o del dictamen de un primer envío que llega con la gracia ya terminada. **[Supuesto S-40]** | Must | Primer envío Excelente con dictamen en el minuto 51: la submeta pasa a finalizada en el minuto 51; segundo envío con dictamen en el minuto 63 de una submeta de 60 min: finaliza en ese instante y no a los 66 min; primer envío Incoherente recibido en el minuto 58 cuyo dictamen llega en el minuto 70 (gracia terminada): finaliza en el minuto 70 con 50 puntos; los puntos se suman al perfil en esa misma transacción. |
| RF-PUNT-014 | El sistema DEBE sumar al puntaje acumulado del usuario el puntaje final de cada submeta calificada al cerrarse, sin ponderar por duración, de modo que el puntaje acumulado sea la suma de los puntajes finales de sus submetas cerradas con calificación. **[Supuesto S-29]** | Must | Tras cerrar submetas con 100, 90 y 50 puntos el acumulado es 240; una submeta abierta con puntaje provisional, una cerrada sin calificación y la eliminación de una meta no alteran lo ya sumado; el ranking (RF-RANK-001) ordena por este acumulado. |


### Módulo RANK — Ranking Global

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-RANK-001 | El sistema DEBE mostrar el ranking global de las cuentas con rol cliente ordenado de mayor a menor puntaje acumulado. | Should | El ranking devuelve las cuentas elegibles con su puntaje en orden descendente. |
| RF-RANK-002 | El sistema DEBE permitir acceder al ranking global desde el módulo de perfil del usuario. | Could | Desde la vista de perfil existe una acción que navega al ranking global. |
| RF-RANK-003 | El sistema DEBE asignar la misma posición a las cuentas con igual puntaje y ordenarlas alfabéticamente por nombre. **[Supuesto S-20]** | Could | Con puntajes 300, 200, 200 y 100 las posiciones son 1, 2, 2 y 4, y las dos cuentas con 200 aparecen ordenadas por nombre. |
| RF-RANK-004 | El sistema DEBE mostrar en el ranking solo el nombre y el puntaje de cada cuenta, sin exponer su correo electrónico. | Must | La respuesta del ranking al cliente no contiene el campo correo ni otro dato de contacto. |
| RF-RANK-005 | El sistema DEBE excluir del ranking de los clientes a las cuentas bloqueadas por un administrador. **[Supuesto S-18]** | Should | Al bloquear una cuenta desaparece del ranking de clientes; al desbloquearla reaparece con su puntaje. |


### Módulo ADM — Administración

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-ADM-001 | El sistema DEBE permitir al administrador crear cuentas de usuario: cuentas cliente (nivel moderador o super) y cuentas administrador (solo el nivel super, con nivel de acceso obligatorio). **[Supuesto S-17]** | Must | El administrador moderador o super crea una cuenta cliente con nombre, correo y contraseña; solo el super crea una cuenta administrador (con nivel de acceso obligatorio, RF-ADM-014); un moderador que intenta crear un administrador recibe HTTP 403; correo duplicado responde HTTP 409; la cuenta cliente nace sin declaración de mayoría de edad, que se registra en su primer inicio de sesión (RF-AUT-018) **[SUPUESTO S-R9]**. |
| RF-ADM-002 | El sistema DEBE permitir al administrador consultar métricas de uso de la aplicación: usuarios registrados, metas creadas y evidencias evaluadas. | Should | La vista de métricas muestra esos tres totales, coincidentes con los datos almacenados; sin datos muestra cero. |
| RF-ADM-003 | El sistema DEBE permitir al administrador consultar las evidencias enviadas por los usuarios. | Should | El administrador lista y visualiza evidencias de cualquier usuario con su dictamen y estado de evaluación. |
| RF-ADM-004 | El sistema DEBE permitir al administrador bloquear una cuenta de usuario de forma indefinida hasta que otro administrador la desbloquee (bloqueo administrativo), salvo que el bloqueo deje al sistema sin ningún administrador super sin bloquear (BR-021). **[Supuesto S-47]** | Must | La cuenta bloqueada no puede iniciar sesión (HTTP 403) y su estado se muestra en administración; el bloqueo se conserva aunque la cuenta cierre submetas o reciba puntos (BR-012); bloquear al único administrador super sin bloquear, incluido uno mismo, responde HTTP 409 y no cambia la cuenta; un moderador que intenta bloquear una cuenta administrador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y la cuenta no cambia, porque solo el super bloquea cuentas administrador (BR-021). |
| RF-ADM-005 | El sistema DEBE permitir al administrador ver el ranking global de usuarios, incluidas las cuentas bloqueadas con su marca de estado. **[Supuesto S-18]** | Should | La vista de administración lista todas las cuentas con rol cliente, con puntaje, posición y marca 'bloqueada' cuando corresponda. |
| RF-ADM-006 | El sistema DEBE tratar los roles cliente y administrador como excluyentes: cada cuenta tiene exactamente uno y las cuentas administrador no pueden crear metas, iniciar submetas ni cargar evidencias. | Must | Una cuenta administrador que intenta crear una meta, iniciar una submeta o cargar una evidencia recibe HTTP 403; una cuenta no puede tener a la vez rol cliente y administrador. |
| RF-ADM-007 | El sistema DEBE registrar cada llamada al motor LLM, incluidos los reintentos automáticos y manuales, en un registro de uso vinculado a su origen: la meta, la evaluación o el usuario. **[Supuesto S-35]** | Should | Un desglose que falla dos veces y acierta a la tercera deja 3 registros con el mismo id de meta; una evaluación con una llamada fallida seguida de un Reintentar exitoso deja 2 registros con el mismo id de evaluación; una llamada del sistema tiene el usuario vacío; cada registro contiene tokens, costo, latencia, proveedor, modelo y resultado (exitosa o fallida); si luego se elimina la meta, la evaluación o la cuenta, el registro se conserva con ese vínculo vacío (RF-META-002c, RF-ADM-010). |
| RF-ADM-008 | El sistema DEBE permitir al administrador consultar el listado y el detalle de las cuentas de usuario. | Must | El administrador ve la lista paginada de cuentas con rol, estado de bloqueo y puntaje, y el detalle de cada una. |
| RF-ADM-009 | El sistema DEBE permitir al administrador editar el nombre y el correo de una cuenta y cambiar su rol únicamente cuando la cuenta no tiene datos (BR-013). **[Supuesto S-48]** **[Supuesto S-54]** | Must | Los cambios válidos de nombre y correo se guardan y un correo usado por otra cuenta responde HTTP 409. Cambiar el rol de una cuenta con datos responde HTTP 409 y no cambia nada: un cliente tiene datos con al menos una meta, una sesión Pomodoro, un logro, un día activo o un puntaje mayor que 0, y un administrador con al menos una submeta cerrada por él (RF-ADM-019). En una cuenta sin datos el cambio se acepta (a administrador exige el nivel de acceso, RF-ADM-014; los efectos están en RF-ADM-020); no se puede asignar un segundo rol (HTTP 422); solo el super edita cuentas administrador o cambia roles (otro nivel recibe HTTP 403); el cambio de rol lo ejecuta siempre un administrador identificado como actor de la operación y, sin un actor super identificado, no cambia nada; cambiar el rol o el nivel del último super responde HTTP 409 (BR-021). |
| RF-ADM-010 | El sistema DEBE permitir al administrador eliminar una cuenta, previa confirmación explícita, borrando en cascada todos sus datos asociados, incluidos los archivos de sus evidencias (RF-EVID-017), sin eliminar su propia cuenta ni al último super. **[Supuesto S-24]** **[Supuesto S-53]** | Must | Una solicitud sin la confirmación explícita (confirmar=true) responde HTTP 422 y no elimina nada. Tras confirmar, la cuenta y todos sus datos (metas, submetas, evidencias y sus archivos del almacén, evaluaciones, sesiones Pomodoro, recomendaciones, días activos, logros, suscripciones push, tokens y códigos de recuperación) dejan de existir y la cuenta desaparece del ranking; los registros de uso del LLM se conservan con el vínculo a la cuenta, a la meta y a la evaluación vacío **[Supuesto S-45]**; si la cuenta eliminada es un administrador que cerró submetas, estas se conservan finalizadas con su fecha de cierre administrativo y el administrador vacío; intentar eliminar la propia cuenta o al último super responde HTTP 409. |
| RF-ADM-011 | El sistema DEBE permitir al administrador consultar métricas de uso del motor LLM: número de llamadas, tokens, costo acumulado y latencia promedio, por operación. **[Supuesto S-35]** **[Supuesto S-45]** | Should | La vista muestra, para desglose, sugerencia de fechas, recomendación y evaluación, el número de llamadas (registros de RF-ADM-007, incluidas las fallidas), tokens, costo y latencia promedio coincidentes con esos registros, incluidos los que quedaron sin vínculo tras eliminar una cuenta (RF-ADM-010). |
| RF-ADM-012 | El sistema DEBE permitir al administrador desbloquear una cuenta bloqueada administrativamente. | Must | Tras desbloquear, la cuenta inicia sesión normalmente y reaparece en el ranking. Un moderador que intenta desbloquear una cuenta administrador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y la cuenta sigue bloqueada, porque solo el super desbloquea cuentas administrador (BR-021). |
| RF-ADM-013 | El sistema DEBE revocar las sesiones activas de una cuenta cuando un administrador la bloquea. | Must | Un token emitido antes del bloqueo recibe HTTP 401 en la petición siguiente al bloqueo. |
| RF-ADM-014 | El sistema DEBE asignar a cada cuenta administrador exactamente un nivel de acceso entre super, moderador y soporte. **[Supuesto S-17]** | Must | Una cuenta administrador sin nivel o con un nivel distinto de los tres se rechaza con HTTP 422; únicamente un administrador de nivel super puede asignar o cambiar niveles (otro nivel recibe HTTP 403). El cambio de nivel lo ejecuta siempre un administrador identificado como actor de la operación: sin un actor super identificado no se cambia ningún nivel. |
| RF-ADM-015 | El sistema DEBE restringir las funciones de administración según el nivel de acceso de la cuenta conforme a la matriz de BR-021. **[Supuesto S-17]** | Must | Con nivel soporte, bloquear una cuenta responde HTTP 403; con nivel moderador, eliminar una cuenta responde HTTP 403; con nivel super ambas se permiten; con nivel moderador, bloquear o desbloquear una cuenta administrador responde HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y bloquear o desbloquear una cuenta cliente se permite. |
| RF-ADM-016 | El sistema DEBE denegar el acceso a las funciones de administración a las cuentas con rol cliente. | Must | Una cuenta cliente que solicita cualquier recurso de administración recibe HTTP 403. |
| RF-ADM-017 | El proceso de despliegue DEBE crear, una sola vez, la primera cuenta administrador super con el correo y la contraseña iniciales definidos en variables de entorno, sin autorregistro ni pantalla pública de configuración. **[Supuesto S-41]** | Must | Al arrancar el despliegue con las variables de correo y contraseña inicial sobre una BD sin ningún administrador super (aunque existan administradores moderador o soporte, que no se modifican) existe exactamente una cuenta con rol administrador y nivel super que inicia sesión (CU-002); si ya existe algún super, bloqueado o no, el arranque no crea ninguna cuenta; la contraseña no queda en texto plano (RNF-005); un nuevo arranque, con o sin variables, no crea ni modifica cuentas; si el correo de las variables ya pertenece a una cuenta, esa cuenta no se modifica, no se crea otra y el arranque deja un aviso en el log; el sistema no ofrece ninguna pantalla ni endpoint público para crear el primer administrador (inspección de las rutas). |
| RF-ADM-018 | El sistema DEBE mostrar al administrador de nivel super o moderador el listado de evaluaciones que llevan 48 horas o más en estado Error sin resolverse, con su submeta, su usuario y el instante en que pasaron a Error. **[Supuesto S-43]** | Must | Una evaluación que pasa a Error y no se resuelve aparece en el listado al cumplirse 48 h desde ese instante y no antes (a las 47 h 59 min no aparece); si un Reintentar la devuelve a Error, la cuenta de 48 h comienza de nuevo; una evaluación resuelta o cuya submeta ya se cerró deja de aparecer; el nivel soporte recibe HTTP 403. |
| RF-ADM-019 | El sistema DEBE permitir al administrador super o moderador cerrar una submeta abierta cuya evaluación lleva 48 horas o más en Error, asignándole su puntaje provisional como puntaje final. **[Supuestos S-43, S-44]** | Must | Una submeta con primer envío Incoherente (50 puntos provisionales) y segundo envío en Error durante 48 h queda finalizada con 50 puntos al cerrarla el administrador; los puntos se suman al acumulado del usuario en la misma transacción, una sola vez, y el registro guarda el administrador y la fecha; si el único envío está en Error el puntaje final es 0; con menos de 48 h el cierre responde HTTP 409; tras el cierre, Reintentar esa evaluación responde HTTP 409; el cierre no activa el día activo (BR-009); el nivel soporte recibe HTTP 403. |
| RF-ADM-020 | El sistema DEBE, al cambiar el rol de una cuenta sin datos, eliminar los datos propios del rol anterior y crear los del nuevo con valores por defecto. **[Supuesto S-54]** | Must | De cliente a administrador: se eliminan la zona horaria, las preferencias de notificación, la fecha de aceptación de IA, la fecha de la declaración de mayoría de edad y las suscripciones push (la cuenta no tiene metas, sesiones Pomodoro, logros, días activos ni puntaje, por lo que no queda nada más que eliminar), y se crea la fila administrador con el nivel indicado (RF-ADM-014). De administrador a cliente: se elimina el nivel de acceso y se crea la fila cliente con zona America/Bogota hasta su primer inicio de sesión, en el que se detecta la del navegador (RF-AUT-016), notificaciones push activadas, sin aceptación de IA, sin declaración de mayoría de edad (la hace en su primer inicio de sesión, RF-AUT-018) y puntaje 0. En ambos casos la cuenta conserva su identificador, nombre, correo y registros de uso del LLM. |
| RF-ADM-021 | El sistema DEBE asignar la zona horaria America/Bogota a la cuenta cliente que crea un administrador, hasta su primer inicio de sesión. | Must | Una cuenta cliente creada por un administrador (RF-ADM-001) tiene la zona America/Bogota sin que nadie la escriba hasta su primer inicio de sesión, en el que se detecta la del navegador (RF-AUT-016); después el usuario puede cambiarla en su perfil (RF-PER-008). |


### Módulo IA — Integración con el Motor LLM (agnóstica al proveedor)

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-IA-001 | El sistema DEBE acceder al motor LLM únicamente a través de una interfaz de proveedor única e intercambiable, de modo que cambiar de proveedor no requiera modificar la lógica de negocio. | Must | El sistema funciona con al menos dos implementaciones de la interfaz (una real y una simulada) seleccionables por configuración, sin cambios en el código de metas, evidencias ni puntuación. |
| RF-IA-002 | El sistema DEBE exigir al motor LLM respuestas en formato estructurado (JSON) conforme a un esquema versionado y DEBE tratar toda respuesta que no cumpla el esquema como error. | Must | Una respuesta del LLM simulado que no cumple el esquema deja la operación en Error y no persiste submetas, fechas ni dictamen. En el desglose de metas el esquema exige que la duración de cada submeta sea un número entero de horas mayor o igual que 1, y el sistema valida la respuesta contra esa regla: una duración de 0 h, negativa o no entera (por ejemplo 1,5 h) deja la operación en Error y no persiste submetas. |
| RF-IA-003 | El sistema DEBE aplicar un timeout configurable a cada llamada al motor LLM, con valor por defecto de 30 segundos. **[Supuesto S-23]** | Must | Con un LLM simulado que responde a los 31 s, la llamada se corta y la operación se trata como fallo por timeout. |
| RF-IA-004 | El sistema DEBE reintentar automáticamente hasta 2 veces, con espera creciente, las llamadas al LLM que fallen por timeout, error 5xx o límite de tasa, sin duplicar efectos. **[Supuesto S-23]** | Must | Con un LLM simulado que falla 2 veces y responde a la 3.ª, la operación termina con éxito y se persiste un solo resultado; con 3 fallos termina en error. |
| RF-IA-005 | El sistema DEBE preparar el contenido de cada evidencia según su formato antes de enviarlo al LLM: imágenes como imagen (el gif como imagen PNG de su primer fotograma), pdf como PDF, txt como texto, documentos docx y doc como texto o Markdown y hojas xlsx y xls como texto tabular en Markdown. Antes de enviar una imagen, el sistema DEBE eliminar de la copia enviada todos sus metadatos EXIF (ubicación, fecha de captura y dispositivo), aplicando antes la rotación que indica su orientación, y DEBE limitar su resolución a la mínima útil para evaluarla, sin ampliarla. **[Supuesto S-R12]** | Must | Para un .pdf, un .txt, un .docx, un .doc, un .xlsx, un .xls, un .png y un .gif animado de prueba, la solicitud al LLM contiene respectivamente el PDF, el texto, el texto o Markdown del documento (en el .docx y el .doc), el contenido tabular de las hojas (en el .xlsx y el .xls), la imagen y la imagen PNG del primer fotograma del .gif; todo formato aceptado (RF-EVID-003) tiene un tratamiento, así que no existe el rechazo por 'formato no soportado por el proveedor'; si la conversión falla, la carga responde HTTP 422 sin persistir la evidencia ni consumir envío (RF-IA-012). El contenido convertido de un documento o una hoja no incluye sus imágenes incrustadas (límite conocido). Con un .jpg de prueba que lleva EXIF (orientación, coordenadas GPS, fecha de captura, marca y modelo de cámara), la imagen que recibe el LLM simulado no contiene ningún bloque EXIF ni esas etiquetas, conserva la misma orientación visual y no supera las dimensiones originales ni el máximo de resolución configurado en el entorno, y la evaluación de esa imagen produce dictamen; el archivo guardado del usuario no se modifica (CP-127). **[Supuesto S-R12]** **[SUPUESTO S-R12: la resolución máxima es un parámetro sin cifra en el SRS]** |
| RF-IA-006 | El sistema DEBE enviar al proveedor de LLM únicamente el contenido de la evidencia y el contexto de la meta y la submeta, sin nombre, correo, id ni otros identificadores personales del usuario y sin el nombre original del archivo de la evidencia. **[Supuesto S-R12]** | Must | La solicitud capturada hacia el LLM simulado no contiene, en el cuerpo, las cabeceras ni el nombre del archivo adjunto, el nombre, el correo ni el id del usuario ni el nombre original del archivo de la evidencia; el archivo de prueba lleva en su nombre el nombre y el correo del usuario de prueba (CP-127). |
| RF-IA-007 | El sistema DEBE informar al usuario que sus evidencias y descripciones se procesan por un servicio externo de IA y obtener su aceptación explícita antes de la primera llamada con sus datos, registrando la fecha. **[Supuesto S-25]** | Must | Sin aceptación registrada, toda función que enviaría datos al servicio (meta que requiere evidencia, desglose automático, recomendaciones, sugerencia de fechas, carga de evidencia) muestra el aviso y no realiza ninguna llamada hasta que el usuario acepta; tras aceptar no se vuelve a solicitar y queda registrada la fecha; si el usuario rechaza el aviso se aplican RF-IA-010 y RF-IA-011; una meta de 1 día de hasta 12 h que no requiere evidencia, o una meta multidía con desglose manual y promedio de hasta 12 h por día, se guarda sin solicitar la aceptación; una meta que no requiere evidencia cuyo promedio diario supera 12 h solo necesita el aviso para obtener las recomendaciones: si el usuario no lo acepta, se guarda igual, sin recomendaciones y sin llamar a la IA. |
| RF-IA-008 | El sistema DEBE incluir en la evaluación de cada evidencia el nombre y la descripción de la meta y, si existe, el nombre o la descripción de la submeta, y obtener un dictamen (Excelente, Incoherente o Inválida) con justificación. **[Supuesto S-36]** | Must | La solicitud de evaluación contiene nombre y descripción de la meta; la respuesta válida incluye uno de los tres dictámenes y su justificación, ambos guardados con la evaluación; un dictamen fuera de esos tres valores se trata como respuesta inválida (RF-IA-002). |
| RF-IA-009 | El sistema DEBE registrar, en cada llamada al LLM, el proveedor y el modelo utilizados. | Should | Cada registro de uso del LLM contiene proveedor y modelo no vacíos. |
| RF-IA-010 | El sistema DEBE permitir al usuario que no ha aceptado o que rechaza el servicio externo de IA seguir usando la aplicación con las metas que no requieren evidencia. **[Supuesto S-46]** | Must | Con el aviso rechazado, el usuario crea una meta de 1 día sin evidencia (con su submeta única y sin recomendaciones aunque supere 12 h por día) y una meta multidía sin evidencia con desglose manual (RF-META-033), inicia sus submetas y usa la agenda, el Pomodoro, el perfil y el ranking, todo con 0 llamadas al LLM simulado; si acepta después el aviso, las funciones de RF-IA-011 quedan disponibles. |
| RF-IA-011 | El sistema DEBE denegar al usuario sin aceptación del servicio externo de IA toda función que dependa de él: metas con evidencia, desglose automático, recomendaciones, fechas sugeridas y carga de evidencia. **[Supuesto S-46]** | Must | Crear o editar una meta para que requiera evidencia, pedir el desglose por IA, las recomendaciones o las fechas sugeridas, o cargar una evidencia, responde HTTP 403 con el aviso de consentimiento y registra 0 llamadas al LLM simulado; tras aceptar el aviso, la misma operación se realiza. El HTTP 403 de las recomendaciones recae solo en la solicitud de recomendaciones: no impide guardar una meta que no requiere evidencia, aunque su promedio diario supere 12 h (RF-META-008, BR-015). |
| RF-IA-012 | El sistema DEBE rechazar al subirla, sin invocar al Motor LLM ni consumir un envío, toda evidencia cuyo archivo esté vacío, corrupto o ilegible al prepararlo (RF-IA-005) o que no se pueda convertir (RF-EVID-003). | Must | Un archivo de 0 bytes, un .pdf truncado, un .docx con el archivo comprimido dañado, un .xlsx sin ninguna hoja con datos una imagen que no se puede decodificar y un .doc o un .xls que no se pueden convertir responden HTTP 422 con el motivo 'archivo vacío, corrupto o ilegible'; en todos los casos no se persiste la evidencia, no se crea evaluación ni dictamen, el número de envíos usados no cambia (el usuario puede subir otro archivo), se registran 0 llamadas al LLM simulado y no se activa el día activo; un formato no soportado (extensión no admitida o contenido que no corresponde a la extensión) responde HTTP 415 con los mismos efectos (RF-EVID-003, RNF-022); un fallo interno del servidor al preparar un archivo válido responde HTTP 500 sin consumir envío; un contenido legible sin relación con la submeta sí se evalúa y recibe dictamen Inválida (RF-EVID-006); un fallo del servicio de IA no es Inválida sino Error. La validación de legibilidad, la conversión (RF-EVID-003) y la preparación del contenido (RF-IA-005) se ejecutan de forma síncrona durante la carga, antes de persistir la evidencia y de responder HTTP 202; el análisis asíncrono (RF-EVID-005, CU-014) reutiliza el contenido ya preparado y no vuelve a rechazar el archivo. El contenido preparado no se persiste (ni en la base de datos ni en el almacén): al Reintentar una evaluación en Error (RF-EVID-008) se vuelve a calcular a partir del archivo almacenado. |


### Módulo NOT — Notificaciones Push

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-NOT-001 | El sistema DEBE permitir al usuario activar o desactivar las notificaciones push desde sus preferencias, con valor inicial activado. **[Supuesto S-19]** | Should | El cambio de preferencia se guarda y se refleja al reabrir las preferencias; una cuenta nueva tiene las notificaciones activadas. |
| RF-NOT-002 | El sistema DEBE solicitar el permiso de notificaciones del navegador y registrar la suscripción push del dispositivo cuando el usuario las activa. **[Supuesto S-19]** | Should | Al activar y conceder el permiso queda registrada una suscripción del dispositivo; si el usuario deniega el permiso, la preferencia queda desactivada con aviso. |
| RF-NOT-003 | El sistema DEBE enviar una notificación push 10 minutos antes de la hora programada de inicio de una submeta. **[Supuesto S-19]** | Should | Para una submeta programada a las 08:00 la notificación se entrega entre 07:49:30 y 07:50:30. |
| RF-NOT-004 | El sistema DEBE enviar una notificación push cuando se habilita la carga de evidencia de una submeta al alcanzar el 80 % de su tiempo. **[Supuesto S-19]** | Should | Al llegar al 80 % de una submeta de 60 min (minuto 48) se entrega una notificación 'Ya puedes subir tu evidencia'. |
| RF-NOT-005 | El sistema DEBE enviar una notificación push cuando se abre el tiempo de gracia de una submeta que sigue abierta y sin evaluación en curso, indicando su duración. **[Supuesto S-19]** | Should | Al expirar el tiempo inicial sin envío, o con un primer envío dictaminado Incoherente o Inválida, se entrega una notificación con los minutos de gracia (p. ej. 6 min); si hay una evaluación en curso, el aviso se emite solo si su dictamen no es Excelente y la gracia sigue vigente; si la submeta ya cerró no se envía. |
| RF-NOT-006 | El sistema DEBE enviar una notificación push cuando una evaluación termina con dictamen o en Error. **[Supuesto S-19]** | Should | Al pasar una evaluación a Evaluada o Error se entrega una notificación con el resultado. |
| RF-NOT-007 | El sistema NO DEBE enviar notificaciones push a una cuenta con la preferencia desactivada o sin suscripción registrada. **[Supuesto S-19]** | Should | Con la preferencia desactivada, ningún evento de RF-NOT-003 a RF-NOT-006 y RF-NOT-008 genera envío. |
| RF-NOT-008 | El sistema DEBE enviar una notificación push cuando el usuario obtiene un logro. **[Supuesto S-19]** | Could | Al otorgarse un logro se entrega una notificación con su nombre. |


### Módulo LOGR — Logros

| ID | Requisito (enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|
| RF-LOGR-001 | El sistema DEBE mantener un catálogo de logros predefinidos, cada uno con nombre, descripción y condición de obtención. **[Supuesto S-15]** | Should | El catálogo contiene los logros definidos en BR-020; cada uno tiene nombre, descripción y condición. |
| RF-LOGR-002 | El sistema DEBE otorgar un logro automáticamente, una sola vez por usuario, cuando se cumple su condición. **[Supuesto S-38]** | Should | Al iniciar la primera submeta, a mano o por inicio automático, se otorga 'Primer paso' (también cuando el inicio automático no activa el día); cerrar una submeta con acierto Excelente en el primer envío recibido en el periodo inicial otorga 'Impecable'; una submeta cerrada por el segundo envío o por un primer envío Excelente recibido en gracia no la otorga (BR-033); repetir la condición no vuelve a otorgarlo. |
| RF-LOGR-003 | El sistema DEBE mostrar en el perfil los logros obtenidos con su fecha y los logros aún no obtenidos como bloqueados. | Should | El perfil lista todos los logros del catálogo; los obtenidos muestran fecha y los demás aparecen bloqueados. |
| RF-LOGR-004 | El sistema DEBE mostrar un aviso en la interfaz cuando el usuario obtiene un logro, resolviéndolo con los logros obtenidos desde el último instante visto por el cliente (parámetro desde de la consulta de logros), sin estado 'visto' en el servidor. | Could | Al otorgarse un logro, el siguiente refresco de la interfaz, que consulta los logros obtenidos desde el último instante visto que guardó el cliente (parámetro desde), muestra un aviso con el nombre del logro; tras mostrarlo, el cliente actualiza ese instante y el aviso no se repite en la consulta siguiente; el servidor no guarda ningún estado 'visto' (la entidad no tiene esa columna). |


## 3.3 Requisitos de datos (modelo lógico mínimo)

Este apartado fija el modelo lógico mínimo con los nombres de las entidades del script SQL vigente, que es la fuente de verdad del esquema, e indica para cada entidad las reglas y restricciones que el modelo debe cumplir. El SRS no fija el número de triggers, vistas ni procedimientos. Entidades: 17 (16 de negocio y la tabla técnica cerrojo_sistema, sin RF propio, que apoya BR-021, RF-ADM-017 y RNF-014). Los datos del cliente (meta, evidencia, sesion_pomodoro, dia_activo, suscripcion_push y usuario_logro) referencian a cliente y no a usuario. El calendario de actividad es una consulta sobre dia_activo y no agrega entidades. En MariaDB las acciones referenciales de las llaves foráneas (ON DELETE CASCADE y SET NULL) no activan triggers, por lo que ninguna regla de este apartado, ni la limpieza ni la auditoría de un borrado en cascada, puede depender de un trigger sobre las filas afectadas por esas acciones (RNF-014).


#### usuario (base de la herencia JOINED; incluye al administrador)

**Atributos:** id_usuario (PK, autoincremental); nombre (VARCHAR 100, obligatorio); correo (VARCHAR 150, único, obligatorio); contrasena_hash (VARCHAR 255, obligatorio, RNF-005); puntaje_acumulado (INT, default 0, no negativo); estado_bloqueo (booleano, bloqueo administrativo); rol (cliente o administrador); intentos_fallidos (INT, default 0); bloqueado_hasta (DATETIME, nulo, bloqueo temporal); fecha_registro (DATETIME).

**Reglas y restricciones:** estado_bloqueo y bloqueado_hasta son independientes (BR-012). Actualizar el puntaje o cerrar una submeta no modifica el bloqueo ni el contador de intentos (RF-AUT-012, RF-ADM-004). puntaje_acumulado es la suma de los puntajes finales de las submetas cerradas con calificación (RF-PUNT-014). El rol solo cambia en cuentas sin datos (BR-013, RF-ADM-009). La eliminación de una cuenta borra en cascada todos sus datos (RF-ADM-010).


#### administrador (PK = FK a usuario)

**Atributos:** id_usuario; nivel_acceso (super, moderador o soporte, obligatorio); fecha_asignacion (DATETIME).

**Reglas y restricciones:** Un usuario con rol administrador tiene exactamente una fila aquí y ninguna en cliente (BR-013). Debe existir siempre al menos un administrador super sin bloquear (BR-021, RF-ADM-017). Un administrador que cerró alguna submeta (RF-ADM-019) tiene datos y no puede pasar a cliente (BR-013). El nivel de acceso solo cambia mediante la operación de cambio de nivel, que ejecuta un administrador super identificado como actor (BR-021, RF-ADM-014).


#### cliente (PK = FK a usuario)

**Atributos:** id_usuario; zona_horaria (zona IANA, obligatoria; el registro la asigna con la zona del navegador o con America/Bogota si no se detecta); notificaciones_push (booleano, default activado); fecha_aceptacion_ia (DATETIME, nulo); zona_pendiente_deteccion (booleano, default falso; verdadero en las cuentas creadas por un administrador o convertidas hasta su primer inicio de sesión); fecha_confirmacion_mayoria_edad (DATETIME, nulo; instante en que el usuario declaró 'Declaro ser mayor de 18 años'; no se guarda fecha de nacimiento).

**Reglas y restricciones:** fecha_aceptacion_ia registra el consentimiento de RF-IA-007. La entidad no tiene el campo notificaciones_email: no hay preferencia ni notificación por correo (1.2.1). zona_horaria acepta toda zona IANA válida, incluidas las de tres segmentos (por ejemplo America/Argentina/Buenos_Aires) (RF-PER-008). El registro (RF-AUT-001) crea esta fila con la zona detectada (RF-AUT-015). Un rechazo del consentimiento no se registra: el aviso se muestra de nuevo (BR-035). Las cuentas cliente creadas por un administrador o por conversión desde administrador reciben zona America/Bogota con zona_pendiente_deteccion verdadero, notificaciones push activadas y sin aceptación de IA (RF-ADM-021, RF-ADM-020); en su primer inicio de sesión exitoso la zona se sustituye por la que informa el navegador, si es válida, y el indicador pasa a falso (RF-AUT-016); sus filas se eliminan al pasar a administrador. fecha_confirmacion_mayoria_edad: el registro (RF-AUT-017) la guarda con el instante de la declaración, por lo que no es nula en las cuentas de autorregistro; es nula solo en las cuentas creadas por un administrador o convertidas desde administrador, hasta que declaran en su primer inicio de sesión (RF-AUT-018) **[SUPUESTO S-R9]**; una vez registrada no se modifica. La columna está en cliente y no en usuario porque solo los clientes declaran **[SUPUESTO S-R8]**; no existe columna de fecha de nacimiento.


#### suscripcion_push

**Atributos:** id_suscripcion (PK); id_usuario (FK a cliente); endpoint y claves de la suscripción (texto, obligatorios); fecha_creacion; vigente (booleano).

**Reglas y restricciones:** Soporta RF-NOT-002.


#### token_sesion

**Atributos:** id_token (PK); token_hash (único); fecha_emision (DATETIME, obligatoria; instante de emisión del token); fecha_expiracion; revocado (booleano); id_usuario (FK a usuario).

**Reglas y restricciones:** Soporta RF-AUT-004, RF-AUT-005 y RF-ADM-013. fecha_expiracion es posterior a fecha_emision (la vigencia del token es de 60 minutos, RF-AUT-003).


#### codigo_recuperacion

**Atributos:** id_codigo (PK); codigo_hash (único); fecha_generacion; fecha_expiracion (exactamente 10 min = 600 s después de fecha_generacion); usado (booleano); id_usuario (FK a usuario).

**Reglas y restricciones:** Soporta RF-AUT-007, RF-AUT-008 y RF-AUT-010. La vigencia de 600 s la impone un trigger (RNF-014): un código con otra vigencia se rechaza al insertarse.


#### dia_activo (PK compuesta id_usuario + fecha)

**Atributos:** id_usuario (FK a cliente); fecha (DATE); primera_submeta_inicio (DATETIME, nulo; primer inicio manual de una submeta del día); total_submetas_iniciadas (INT, default 0; submetas iniciadas a mano ese día; un día activo solo por el envío de una evidencia tiene 0).

**Reglas y restricciones:** Soporta RF-PER-002, 005, 006, 007, 009, 011, 013 y 014. La fila de un día se crea cuando el usuario inicia a mano una submeta o envía una evidencia; nunca por un inicio automático ni por un cierre del sistema o de un administrador (BR-009). Los días activos son datos de la cuenta (BR-013) **[Supuesto S-54]**, se conservan al eliminar una meta (RF-META-002c) y se eliminan en cascada con la cuenta (RF-ADM-010). La racha de días y el calendario de actividad de los últimos 12 meses se derivan de esta tabla mediante consultas (BR-019, BR-034).


#### meta

**Atributos:** id_meta (PK); id_usuario (FK a cliente); nombre (VARCHAR 150); categoria (catálogo BR-024); tipo (un_dia o multidia, derivado de dias_destinados); dias_destinados (INT ≥ 1); tiempo_total (INT, horas totales ≥ 1); fecha_inicio y fecha_fin (DATE); horario_inicio y horario_fin (TIME; horario_fin admite 24:00:00); requiere_evidencia (booleano); modo_inicio (manual o automatico); estado (derivado de sus submetas, BR-029); fecha_creacion; descripcion (TEXT, hasta 1000 caracteres, opcional); modo_planificacion (fechas_usuario o sugerida_ia); modo_desglose (ia o manual; nulo en una meta de 1 día); consejos_ia (TEXT, nulo).

**Reglas y restricciones:** tiempo_total ≤ 24 × dias_destinados (BR-011); tiempo_total ≤ dias_destinados × (horario_fin − horario_inicio) **[Supuesto S-34]**; tiempo_total ≥ dias_destinados, porque cada submeta dura al menos 1 h (BR-014 (10), RF-META-003); dias_destinados ≤ número de días del rango de fecha_inicio a fecha_fin, ambos inclusive (BR-014 (11)); horario_fin > horario_inicio y horario_fin ≤ 24:00 (RF-META-005); un_dia exige dias_destinados = 1 y multidia exige ≥ 2 (RF-META-019). Una meta con modo_desglose manual tiene una submeta por fecha de trabajo, definida por el usuario, con nombre y duración en horas enteras de 1 h o más (RF-META-033 a RF-META-035); la misma regla rige para las submetas generadas por la IA (RF-META-003, RF-IA-002). El estado de la meta es un valor calculado a partir de sus submetas con la precedencia de BR-029 (nunca pendiente y finalizada a la vez); si el esquema lo almacena, debe mantenerse sincronizado automáticamente y no ser editable directamente.


#### submeta

**Atributos:** id_submeta (PK); id_meta (FK); fecha_programada (DATE); horario_inicio y horario_fin (TIME; su diferencia es el tiempo estipulado, BR-032); hora_inicio_real y hora_fin_real (DATETIME, nulos); estado (pendiente, en_curso o finalizada, BR-029); puntaje_obtenido (INT 0 a 100, nulo si no cerrada o sin calificación); nombre (VARCHAR 150, nulo; obligatorio en las submetas de un desglose manual); descripcion_ia (TEXT, nulo); cerrada_por_administrador (booleano, default falso); id_administrador_cierre (FK a administrador, nulo, ON DELETE SET NULL); fecha_cierre_administrativo (DATETIME, nulo).

**Reglas y restricciones:** La pareja (id_meta, fecha_programada) es única: una submeta por fecha de trabajo, también en el desglose manual (BR-014, RNF-012). La duración de toda submeta (horario_fin menos horario_inicio) es un número entero de horas de 1 h o más, sea manual o generada por la IA; el esquema no almacena minutos (RNF-011). Puede estar finalizada con puntaje nulo cuando la meta no requiere evidencia o la submeta manual no se inició (BR-010, BR-027). El puntaje es la suma de los puntos de sus evaluaciones, con máximo 100 con un envío y 90 con dos, y el cierre es diferido y atómico con el puntaje del perfil (BR-004, BR-018). El cierre administrativo por Error persistente (RF-ADM-019) asigna puntaje_obtenido = puntaje provisional y registra al administrador y la fecha; si el administrador se elimina, la submeta conserva cerrada_por_administrador y la fecha, y id_administrador_cierre queda vacío (RF-ADM-010). El estado pendiente_evidencia no existe.


#### recomendacion_ia

**Atributos:** id_recomendacion (PK); id_meta (FK); sugerencia_habito (TEXT); propuesta_horario (VARCHAR 100); estado_aceptacion (aceptada, modificada o rechazada); fecha_decision (DATETIME).

**Reglas y restricciones:** Relación 1:N con meta (historial de decisiones) **[Supuesto S-13]** (RF-META-014).


#### sesion_pomodoro

**Atributos:** id_sesion (PK); fecha_hora_inicio (DATETIME); duracion_minutos (INT > 0, duración efectiva); estado (finalizada o abandonada); id_usuario (FK a cliente); id_submeta (FK a submeta, nulo, ON DELETE SET NULL).

**Reglas y restricciones:** Sin reglas adicionales.


#### evidencia

**Atributos:** id_evidencia (PK); id_submeta (FK); id_usuario (FK a cliente); archivo (VARCHAR 255; ruta del archivo físico en el almacén); formato (imagen, texto o excel); tamano (1 a 26 214 400 bytes); porcentaje_tiempo_transcurrido (DECIMAL 5,2, de 0 a 110); intento (1 o 2); ventana (inicial o gracia); fecha_carga (DATETIME).

**Reglas y restricciones:** UNIQUE(id_submeta, intento): máximo 2 envíos por submeta (RF-EVID-012). El archivo físico se elimina del almacén cuando se elimina el registro, operación que ejecuta la aplicación y no un trigger; si el borrado falla, la limpieza programada lo completa, pero solo borra archivos sin registro con más de 1 hora de antigüedad (RF-EVID-017, RF-EVID-018, BR-036) **[Supuesto S-53]** **[Supuesto S-55]**. Un archivo vacío, corrupto, ilegible, que no se puede convertir o de formato no soportado se rechaza al subirlo y no genera registro (RF-IA-012). El archivo almacenado es el original: la conversión de RF-EVID-003 solo sirve para evaluar y no se persiste. formato es la categoría del archivo: imagen (png, jpg, jpeg, webp, gif), texto (txt, pdf, docx, doc) o excel (xlsx, xls). El porcentaje puede superar 100 hasta 110 para los envíos en el tiempo de gracia; la ventana se fija por el instante de recepción (RF-EVID-010).


#### evaluacion

**Atributos:** id_evaluacion (PK); id_evidencia (FK, único); estado (en_evaluacion, evaluada o error); dictamen (excelente, incoherente o invalida; nulo mientras no esté evaluada); puntos_otorgados (INT, solo 0, 25, 50 o 100; nulo mientras no esté evaluada); justificacion (TEXT); fecha_evaluacion (DATETIME); fecha_ultimo_error (DATETIME, nulo; instante en que la evaluación pasó a Error por última vez, base de las 48 h de RF-ADM-018).

**Reglas y restricciones:** El reintento reutiliza la fila (BR-017). Inválida es un dictamen, no un estado de error (BR-005). Los puntos se asignan según BR-004 y solo toman los valores 0, 25, 50 o 100 (tabla 3.6.1).


#### uso_llm

**Atributos:** id_uso (PK); fecha; operacion (desglose, sugerencia_fechas, recomendacion o evaluacion); tokens_consumidos; costo (DECIMAL 10,4); latencia_ms; proveedor; modelo; resultado (exitosa o fallida); id_usuario (FK a usuario, anulable, ON DELETE SET NULL); id_meta (FK a meta, anulable, ON DELETE SET NULL); id_evaluacion (FK a evaluacion, anulable, ON DELETE SET NULL).

**Reglas y restricciones:** Un registro por llamada al LLM, sin límite de uno por evaluación, porque los reintentos automáticos y manuales generan registros adicionales **[Supuesto S-35]** (RF-ADM-007). Los tres vínculos son opcionales en el esquema. Al insertar el registro (regla de inserción, no un CHECK permanente) id_evaluacion se informa cuando operacion = evaluacion, id_meta cuando operacion = desglose e id_usuario cuando la llamada la origina un usuario (vacío en las llamadas del sistema); en las recomendaciones y sugerencias previas al guardado de la meta, id_meta puede estar vacío. Cuando después se elimina la cuenta, la meta o la evaluación (RF-ADM-010, RF-META-002c), el vínculo correspondiente queda vacío y el registro se conserva con su costo, tokens y latencia, de modo que las métricas del LLM no cambian (RF-ADM-011) **[Supuesto S-45]**. proveedor y modelo: RF-IA-009.


#### logro

**Atributos:** id_logro (PK); codigo (único); nombre; descripcion.

**Reglas y restricciones:** Catálogo de BR-020 (RF-LOGR-001).


#### usuario_logro (PK compuesta id_usuario + id_logro)

**Atributos:** id_usuario (FK a cliente); id_logro (FK a logro, ON DELETE RESTRICT); fecha_obtencion (DATETIME).

**Reglas y restricciones:** Garantiza el otorgamiento único (RF-LOGR-002).


#### cerrojo_sistema (técnica; sin RF propio)

**Atributos:** clave (PK, VARCHAR 30; único valor permitido: ultimo_super).

**Reglas y restricciones:** Tabla técnica de exclusión mutua, sin datos de negocio, sin llaves foráneas y con una sola fila, sembrada por el script. La toman las operaciones que bloquean, eliminan o degradan a un administrador super, de modo que dos operaciones simultáneas se serialicen y ninguna deje al sistema sin un super sin bloquear (BR-021, RF-ADM-017, RNF-014). La fila no se modifica ni se elimina. No tiene RF propio y no es un concepto del modelo de dominio.


## 3.4 Requisitos no funcionales (RNF)

Clasificados por ISO/IEC 25010. Cada RNF indica la métrica, el entorno de prueba y el método de medición en su criterio de aceptación. RNF-004 y RNF-008 se reformularon como metas verificables de un proyecto académico.

| ID | Atributo | Requisito (Enunciado) | Prioridad | Criterio de aceptación |
|---|---|---|---|---|
| RNF-001 | Seguridad (Autenticidad) | El sistema DEBE rechazar con HTTP 401 el 100 % de las peticiones a recursos protegidos que no presenten un token JWT válido. | Must | Una prueba automatizada recorre todos los endpoints protegidos del contrato de API sin token: el 100 % responde 401 y ninguno devuelve datos. Solo son públicos el registro, el inicio de sesión y la recuperación de contraseña y, como excepción técnica para el monitor externo de RNF-004, los endpoints de salud (/salud y /salud/listo), que no devuelven datos de usuarios ni de negocio. |
| RNF-002 | Fiabilidad (Integridad de datos) | El sistema DEBE actualizar en una misma transacción atómica el puntaje y el estado de una submeta. | Must | Tras inducir 3 fallos distintos (corte de conexión a BD, timeout del LLM, excepción de la aplicación) durante el cierre de una submeta, la BD no contiene escrituras parciales: puntaje y estado se persisten juntos o ninguno; el reintento no duplica puntos. |
| RNF-003 | Rendimiento (Comportamiento temporal) | El sistema DEBE responder las operaciones de consulta (inicio de sesión, agenda, perfil, ranking) con percentil 95 ≤ 2 s bajo 200 usuarios virtuales concurrentes. | Must | Entorno de prueba: 1 instancia de aplicación y 1 BD MariaDB 10.11 o posterior (2 vCPU, 4 GB RAM) con 10 000 usuarios y 100 000 submetas. Prueba de carga (k6, JMeter o Locust) con 1 min de subida y 5 min sostenidos: p95 ≤ 2 s y tasa de errores 5xx ≤ 1 %. |
| RNF-004 | Fiabilidad (Disponibilidad) | El sistema DEBE alcanzar una disponibilidad ≥ 99 % durante un periodo de observación de 7 días consecutivos en el entorno de demostración. La meta aspiracional de 99,9 % mensual no es exigible en esta versión. | Should | Un monitor externo consulta los endpoints de salud (públicos, excepción técnica de RNF-001) cada 5 min durante 7 días (2 016 comprobaciones): ≤ 20 comprobaciones fallidas (≥ 99 %). No se cuentan los mantenimientos anunciados con 24 h de antelación. |
| RNF-005 | Seguridad (Confidencialidad) | El sistema DEBE almacenar las contraseñas con bcrypt (factor de costo ≥ 12) o argon2id. | Must | Inspección de la BD: ninguna contraseña en texto plano; todos los hashes tienen prefijo $2b$ con costo ≥ 12 o $argon2id$; la verificación de acceso compara hashes. |
| RNF-006 | Seguridad (Confidencialidad) | El sistema DEBE servir todas las comunicaciones cliente-servidor sobre HTTPS con TLS 1.2 o superior. | Must | Un escáner TLS (testssl.sh o SSL Labs) no reporta protocolos inferiores a TLS 1.2; una petición HTTP recibe redirección 301 a HTTPS; el certificado es válido. |
| RNF-007 | Seguridad (Autenticidad) | El mecanismo de limitación de intentos fallidos de inicio de sesión DEBE resistir peticiones concurrentes sin permitir más de 5 intentos fallidos por cuenta antes del bloqueo. | Must | 20 intentos simultáneos con contraseña inválida contra la misma cuenta producen exactamente 1 bloqueo, contador final 5 (nunca mayor) y ningún intento exitoso posterior durante 15 min. |
| RNF-008 | Rendimiento (Capacidad / escalabilidad) | La API DEBE mantener la sesión del usuario fuera de la memoria del proceso, de modo que dos instancias detrás de un balanceador atiendan indistintamente peticiones de una misma sesión. La autoescalabilidad queda como meta aspiracional. | Could | Demostración con 2 instancias: un token obtenido en la instancia A permite 20 peticiones alternadas en A y B con HTTP 200 y sin errores 5xx. |
| RNF-009 | Usabilidad (Accesibilidad) | La interfaz DEBE cumplir las pautas WCAG 2.2 nivel AA. | Should | Auditoría con axe-core o WAVE sobre todas las pantallas: 0 violaciones críticas o serias. Verificación manual: los flujos CU-001, CU-002, CU-005, CU-013, CU-031 y CU-032 (calendario de actividad) se completan solo con teclado sin trampas de foco; contraste de texto ≥ 4,5:1; objetivos táctiles ≥ 24×24 px (criterio 2.5.8); checklist WCAG 2.2 AA firmado por pantalla. |
| RNF-010 | Portabilidad (Adaptabilidad) | La interfaz DEBE ser responsive y funcionar en las dos últimas versiones mayores de Chrome, Firefox, Edge y Safari de escritorio, y en Chrome Android y Safari iOS 16 o superior. | Should | Pruebas de visualización y de flujo en cada navegador: sin desbordamiento horizontal ni elementos inaccesibles desde 320 px de ancho; los flujos CU-001, CU-005, CU-009 y CU-013 se completan en cada navegador. Excepción (criterio 1.4.10 de WCAG 2.2, contenido bidimensional): la cuadrícula del calendario de actividad (RF-PER-003) puede desplazarse horizontalmente dentro de su propio contenedor, sin desplazar el resto de la página, siempre que desde 320 px la vista de tabla o lista (RF-PER-016) muestre la misma información sin desplazamiento horizontal. |
| RNF-011 | Fiabilidad (Integridad de datos) | El esquema de BD DEBE declarar restricciones CHECK para todo campo de catálogo y todo rango numérico del modelo de datos (sección 3.3). | Must | Inspección del script .sql: todo campo de 3.3 que sea de catálogo o de rango tiene CHECK, incluidos tipo, categoría, estado, formato, modo de inicio, modo de planificación, modo de desglose, rol, nivel de acceso, operación, dictamen (excelente, incoherente o invalida), estado de aceptación, resultado del uso del LLM, ventana (inicial o gracia), intento (1 o 2), porcentaje de tiempo transcurrido (0 a 110), tamaño, puntaje de 0 a 100, puntos de la evaluación (solo 0, 25, 50 o 100), límite de 24 h por día de la meta (BR-011), tiempo total mayor o igual que los días destinados y días destinados dentro del rango de fechas de la meta (BR-014), tokens, costo, latencia y duración de la submeta (horario_fin menos horario_inicio, múltiplo de 1 h y de 1 h o más); insertar por SQL un valor fuera de catálogo o de rango es rechazado, incluida una submeta de 90 minutos o de 0 h. El script se ejecuta sin errores y con las mismas restricciones en MariaDB 10.11 (versión mínima), 11.8 y 12.3. Estado de verificación (hecho verificado el 2026-11-01): el script se probó en MariaDB 10.11.19, 11.8.9, 12.3.3 y 13.0.2 con 500/500 pruebas SQL. |
| RNF-012 | Fiabilidad (Integridad de datos) | El esquema de BD DEBE declarar restricciones UNIQUE: máximo 2 evidencias por submeta, una evaluación por evidencia y una submeta por fecha de cada meta (BR-014); el uso del LLM se registra por llamada (RF-ADM-007). **[Supuesto S-35]** | Must | Insertar por SQL una tercera evidencia para una submeta o una segunda evaluación para una evidencia es rechazado; insertar dos registros de uso del LLM para la misma evaluación es aceptado (reintento); insertar dos submetas de la misma meta con la misma fecha es rechazado. |
| RNF-013 | Fiabilidad (Integridad de datos) | El esquema de BD DEBE declarar llaves foráneas con política ON DELETE y ON UPDATE explícita en toda relación entre tablas. | Should | Inspección del script .sql: el 100 % de las llaves foráneas declara su política; eliminar una meta elimina sus submetas, evidencias y evaluaciones; los vínculos de uso_llm con la cuenta, la meta y la evaluación y el vínculo submeta.id_administrador_cierre son anulables y declaran ON DELETE SET NULL, de modo que eliminar la cuenta, la meta, la evaluación o el administrador que cerró una submeta no elimina esos registros; el vínculo opcional sesion_pomodoro.id_submeta también declara ON DELETE SET NULL (eliminar una submeta conserva la sesión Pomodoro con el vínculo vacío) y usuario_logro.id_logro declara ON DELETE RESTRICT (no se elimina un logro del catálogo que algún cliente ya obtuvo); las llaves foráneas de los datos del cliente hacia cliente y de los datos de la cuenta hacia usuario declaran ON DELETE CASCADE (RF-ADM-010). |
| RNF-014 | Fiabilidad (Integridad de datos) | Las reglas que no puedan expresarse como CHECK DEBEN validarse también en la BD mediante triggers del script .sql, que es la fuente de verdad del esquema. Excepción: la suma de duraciones (BR-014) se valida en la transacción de creación del desglose. | Should | Las reglas son: regla del 80 % y coincidencia del porcentaje y la ventana de la evidencia con su instante de recepción (BR-001, RF-EVID-010), segundo envío solo tras un primer dictamen Incoherente o Inválida, tope de 90 con dos envíos, vigencia del código de recuperación de exactamente 10 min (600 s), coherencia rol-subtipo, cambio de rol solo mediante la operación de cambio de rol (BR-013) y solo en cuentas sin datos, permanencia de un administrador super sin bloquear (también con operaciones simultáneas, mediante la tabla técnica cerrojo_sistema), el nombre obligatorio de las submetas de un desglose manual y vínculos obligatorios de uso_llm al insertar (RF-ADM-007). Para cada una de estas reglas existe un trigger y una prueba que intenta violarla directamente por SQL y es rechazada. El límite de 24 h por día (BR-011), el tiempo total mayor o igual que los días destinados, los días destinados dentro del rango de fechas y los puntos de la evaluación (0, 25, 50 o 100) no son triggers: son restricciones CHECK (RNF-011). La suma de las duraciones de las submetas igual al tiempo total (BR-014) no se impone con un trigger, porque un trigger de fila no puede exigirla mientras las submetas se insertan una por una y MariaDB no tiene restricciones diferidas: la valida el procedimiento almacenado o la transacción que crea o regenera el desglose (RF-META-003, RF-META-027, RF-META-033, RF-META-034), que inserta todas las submetas de la meta en una sola transacción y la revierte, sin persistir ninguna submeta, si la suma difiere del tiempo total; la prueba ejecuta esa operación con una suma incorrecta y verifica el rechazo y la ausencia de submetas. La duración entera de 1 h o más de cada submeta es un CHECK (RNF-011). Las acciones referenciales de las llaves foráneas (ON DELETE CASCADE y SET NULL) no activan triggers en MariaDB: ninguna regla, limpieza ni auditoría puede depender de un trigger sobre filas eliminadas o modificadas por una cascada; el borrado de los archivos físicos (RF-EVID-017), la protección del último super (BR-021) y el cambio de rol (BR-013) se validan en operaciones directas sobre las tablas y en la aplicación. El SRS no fija el número de triggers; la lista vigente es la del script. |
| RNF-015 | Rendimiento (Comportamiento temporal) | El análisis por IA (desglose, sugerencia de fechas y evaluación de evidencia) DEBE completarse con percentil 95 ≤ 60 s medido desde la solicitud hasta el resultado persistido, con el proveedor operativo. El desglose por IA es una operación síncrona que el cliente inicia tras guardar la meta y cuya respuesta espera (hasta ~60 s); la evaluación de evidencia es asíncrona (RF-EVID-005). | Must | Con el proveedor real o un simulador con latencia de 5 a 20 s, 50 operaciones de cada tipo: p95 ≤ 60 s. Los casos con timeout o reintentos (RF-IA-003, RF-IA-004) se excluyen de esta medición. En la solicitud de desglose, el cliente y el proxy mantienen la espera abierta durante más de 100 s sin cortar la respuesta. |
| RNF-016 | Seguridad (Confidencialidad) | Los archivos de evidencia DEBEN almacenarse sin acceso público directo y ser accesibles solo a su propietario y a los administradores autenticados. | Must | Una solicitud anónima al archivo responde 401 **[Supuesto S-30]**; la solicitud de un usuario distinto del propietario responde 404; no existe URL pública permanente. |
| RNF-017 | Mantenibilidad (Capacidad de ser probado) | El código de las reglas de puntuación, ventanas de tiempo y planificación de metas DEBE tener una cobertura de pruebas unitarias ≥ 70 % de líneas. | Should | El informe de cobertura generado en integración continua o local muestra ≥ 70 % en esos módulos. |
| RNF-018 | Fiabilidad (Tolerancia a fallos) | El sistema DEBE mantener operativas las funciones que no dependen del LLM cuando el proveedor de LLM no está disponible. | Must | Con el LLM simulado caído, el inicio de sesión, la agenda, el perfil, el ranking, el Pomodoro, la creación de metas multidía con desglose manual (RF-META-033) y de metas de 1 día (de hasta 12 h con submeta única; de más de 12 h hasta 24 h guardadas sin recomendaciones, RF-META-030) y la administración responden con éxito en el 100 % de 20 pruebas. |
| RNF-019 | Usabilidad (Capacidad de aprendizaje) | Un usuario nuevo DEBE poder crear su primera meta de 1 día sin ayuda en 3 minutos o menos. | Should | Prueba con 5 personas no involucradas en el proyecto: al menos 4 completan la tarea en ≤ 3 min sin asistencia. |
| RNF-020 | Usabilidad (Localización) | La interfaz DEBE presentarse en español y mostrar fechas y horas en la zona horaria del usuario con formato día/mes/año y reloj de 24 horas. | Should | Inspección de todas las pantallas: textos en español. Una marca de tiempo de 13:00 UTC se muestra como 08:00 a un usuario con zona America/Bogota y como 10:00 a uno con zona America/Argentina/Buenos_Aires. |
| RNF-021 | Mantenibilidad (Analizabilidad) | El sistema DEBE registrar en un log, con marca de tiempo y un identificador de petición, todo error 5xx y toda llamada al LLM, y conservarlos al menos 30 días. | Could | Tras provocar un error 5xx y una llamada al LLM, ambos aparecen en el log con marca de tiempo e identificador de petición; la retención configurada es ≥ 30 días; el log no contiene nombre, correo ni contenido de evidencias (RF-IA-006), por lo que no requiere supresión al eliminar una cuenta. |
| RNF-022 | Seguridad (Integridad) | El sistema DEBE validar el tipo real de cada archivo de evidencia por su firma de contenido y rechazar los archivos cuyo contenido no corresponda a su extensión. | Should | Un ejecutable renombrado como .png responde HTTP 415 y no se persiste. |
| RNF-023 | Rendimiento (Comportamiento temporal) | El sistema DEBE entregar las notificaciones push al servicio de notificaciones en 60 segundos o menos desde el evento que las origina. | Could | En 20 eventos de prueba, el 95 % se entrega al servicio de notificaciones en ≤ 60 s medido en el log del sistema. |
| RNF-024 | Rendimiento (Comportamiento temporal) | El inicio automático de una submeta DEBE ocurrir entre 0 y 30 segundos después de su hora programada, en el 95 % de los casos, y nunca antes de ella. | Should | En 20 submetas automáticas programadas, ninguna inicia antes de su hora programada y al menos 19 (95 %) inician entre 0 y +30 s después, según el registro de hora de inicio real. |


## 3.5 Historias de Usuario (HU)

| ID | Actor | Descripción | RF relacionado | Prioridad | Criterios de Aceptación |
|---|---|---|---|---|---|
| HU-AUT-001 | Usuario (cliente) | Como usuario, quiero registrarme con nombre, correo y una contraseña que cumpla la política, y declarar que soy mayor de 18 años, para crear mi cuenta y guardar mi progreso. | RF-AUT-001, RF-AUT-002, RF-AUT-011, RF-AUT-013, RF-AUT-015, RF-AUT-017 | Must | Dado que no tengo cuenta, cuando registro datos válidos, entonces el sistema crea mi cuenta con rol cliente y me permite iniciar sesión.<br>Dado un correo ya registrado, cuando intento registrarme, entonces el sistema me lo rechaza (HTTP 409).<br>Dado una contraseña de 7 caracteres, cuando intento registrarme, entonces el sistema la rechaza (HTTP 422).<br>Dado que me registro desde un navegador configurado en America/Argentina/Buenos_Aires, cuando se crea mi cuenta, entonces mi zona horaria queda en esa zona sin que yo la escriba.<br>Dado que no marco la declaración 'Declaro ser mayor de 18 años', cuando intento registrarme, entonces el sistema me lo rechaza (HTTP 422) y no crea mi cuenta.<br>Dado que registro datos válidos y marco la declaración, cuando se crea mi cuenta, entonces queda guardado el momento en que declaré ser mayor de 18 años y el sistema no me pide fecha de nacimiento. |
| HU-AUT-002 | Usuario (cliente) | Como usuario, quiero iniciar sesión de forma segura, para acceder a mis metas y evidencias. | RF-AUT-003, RF-AUT-004 | Must | Dado un usuario registrado, cuando ingreso credenciales válidas, entonces el sistema emite un JWT y me lleva al inicio.<br>Dado un usuario registrado, cuando ingreso credenciales inválidas, entonces el sistema responde HTTP 401 sin token. |
| HU-AUT-003 | Usuario (cliente) | Como usuario, quiero recuperar mi contraseña olvidada, para volver a entrar a mi cuenta. | RF-AUT-006, RF-AUT-007, RF-AUT-008, RF-AUT-010 | Must | Dado que olvidé mi contraseña, cuando solicito recuperación con mi correo registrado, entonces el sistema envía un código a mi buzón.<br>Dado un código vigente, cuando lo ingreso con una nueva contraseña válida, entonces el sistema me permite iniciar sesión con ella.<br>Dado un código con más de 10 minutos, cuando lo uso, entonces el sistema lo rechaza (HTTP 422). |
| HU-AUT-004 | Usuario (cliente) | Como usuario, quiero cerrar sesión, para proteger mi cuenta en equipos compartidos. | RF-AUT-005 | Should | Dado que tengo sesión activa, cuando cierro sesión, entonces el token queda revocado y dejo de acceder a recursos protegidos. |
| HU-AUT-005 | Usuario (cliente) | Como usuario, quiero que mi cuenta se proteja temporalmente tras varios intentos fallidos y recibir un aviso por correo, para detectar accesos indebidos. | RF-AUT-009, RF-AUT-012, RF-AUT-014 | Must | Dado 5 intentos fallidos consecutivos, cuando intento un sexto inicio de sesión, entonces recibo HTTP 429 durante 15 minutos.<br>Dado el bloqueo temporal, cuando se activa, entonces recibo un correo informando el bloqueo.<br>Dado 3 intentos fallidos y un inicio exitoso, cuando consulto el contador, entonces vale 0. |
| HU-PER-001 | Usuario (cliente) | Como usuario, quiero ver mi perfil con mis puntos y días activos, para conocer mi progreso. | RF-PER-001 | Should | Dado mi perfil, cuando lo abro, entonces veo mi nombre, puntaje acumulado y conteo de días activos. |
| HU-PER-002 | Usuario (cliente) | Como usuario, quiero ver en un calendario de los últimos 12 meses, en verde, los días en que estuve activo, para visualizar mi constancia. | RF-PER-002, RF-PER-003 | Should | Dado un día en que inicié a mano una submeta, cuando veo mi calendario, entonces ese día aparece en verde.<br>Dado un día en que envié una evidencia, cuando veo mi calendario, entonces ese día aparece en el mismo tono de verde.<br>Dado un día en que solo inicié sesión, cuando veo mi calendario, entonces ese día no aparece en verde.<br>Dado un día anterior a los últimos 12 meses, cuando veo mi calendario, entonces ese día no se muestra.<br>Dado un día en que una submeta se inició sola a su hora programada y yo no actué, cuando veo mi calendario, entonces ese día no aparece en verde.<br>Dado un día en que mi submeta se cerró por vencimiento del tiempo sin que yo enviara evidencia, o la cerró un administrador, cuando veo mi calendario, entonces ese día no aparece en verde por ese cierre. |
| HU-PER-003 | Usuario (cliente) | Como usuario, quiero conocer mi posición en el ranking y entrar a él desde mi perfil, para medir mi competitividad. | RF-PER-004, RF-RANK-002 | Could | Dado mi perfil, cuando lo abro, entonces veo mi posición actual en el ranking.<br>Dado mi perfil, cuando selecciono ver ranking, entonces el sistema me muestra el ranking global. |
| HU-PER-004 | Usuario (cliente) | Como usuario, quiero ver a qué hora empecé a trabajar cada día y cuántas submetas inicié a mano, para entender mi ritmo diario. | RF-PER-005, RF-PER-006, RF-PER-010, RF-PER-011 | Should | Dado que hoy inicié a mano mi primera submeta a las 08:12, cuando abro mi perfil, entonces veo 'Primera actividad del día: 08:12'.<br>Dado que un día inicié a mano 3 submetas, cuando selecciono ese día en el calendario, entonces veo '3 submetas'. |
| HU-PER-005 | Usuario (cliente) | Como usuario, quiero ver mi racha actual, mi racha máxima y mi racha perfecta, para motivarme a mantener la constancia y la calidad de mis entregas. | RF-PER-007, RF-PER-009, RF-PER-012 | Should | Dado 3 días activos consecutivos hasta ayer, cuando abro mi perfil hoy antes de iniciar una submeta, entonces veo una racha de 3.<br>Dado que mi mejor racha fue de 5 días, cuando abro mi perfil, entonces veo una racha máxima de 5.<br>Dadas 3 submetas cerradas con acierto Excelente en el primer envío, cuando abro mi perfil, entonces veo una racha perfecta de 3; si la siguiente submeta cierra con 90 puntos, entonces mi racha perfecta vuelve a 0. |
| HU-PER-006 | Usuario (cliente) | Como usuario, quiero que mi zona horaria se detecte al registrarme y poder cambiarla en mi perfil, para que mis horarios y recordatorios coincidan con mi hora local. | RF-PER-008, RF-AUT-015, RF-PER-017, RF-AUT-016 | Must | Dado que me registro desde un navegador en America/Argentina/Buenos_Aires, cuando se crea mi cuenta, entonces mi zona horaria es esa.<br>Dado que elijo otra zona válida en mi perfil, cuando guardo, entonces mis horarios se muestran en esa zona.<br>Dado una zona inexistente, cuando intento guardar, entonces el sistema la rechaza.<br>Dado que cambio mi zona horaria, cuando guardo, entonces mis submetas pendientes conservan su fecha y hora locales y mis días activos anteriores no cambian. **[Supuesto S-52]**<br>Dado que un administrador creó mi cuenta, cuando inicio sesión por primera vez desde un navegador en America/Argentina/Buenos_Aires, entonces mi zona horaria pasa a esa zona. |
| HU-PER-007 | Usuario (cliente) | Como usuario que no distingue colores o que navega con teclado o lector de pantalla, quiero consultar mi calendario de actividad con etiquetas de texto, una tabla alternativa y navegación por teclado, para conocer mi constancia sin depender del color. | RF-PER-013, RF-PER-014, RF-PER-015, RF-PER-016, RF-PER-011 | Should | Dado mi calendario de actividad, cuando lo recorro con un lector de pantalla, entonces cada día se anuncia con su fecha y si fue activo.<br>Dado mi calendario, cuando lo recorro solo con el teclado, entonces veo el foco y puedo abrir el detalle de un día con su fecha y número de submetas, y cerrarlo con Escape.<br>Dado mi calendario, cuando elijo la vista de tabla, entonces veo la lista de mis días activos de los últimos 12 meses con su número de submetas. |
| HU-META-001 | Usuario (cliente) | Como usuario, quiero crear metas con mis fechas, horario y horas totales, para planificar mis objetivos. | RF-META-001, RF-META-029 | Must | Dado el formulario de creación, cuando completo los parámetros obligatorios, entonces el sistema guarda la meta y la muestra en la agenda.<br>Dado una fecha de trabajo anterior a hoy, cuando intento guardar, entonces el sistema la rechaza. |
| HU-META-002 | Usuario (cliente) | Como usuario, quiero que la IA desglose mis metas largas en submetas diarias con descripción y consejos, para no abrumarme. | RF-META-003, RF-META-005, RF-META-007, RF-META-011, RF-META-024, RF-META-027 | Must | Dada una meta de más de 1 día con desglose por IA, cuando la creo, entonces la IA genera una submeta por fecha con su horario y su descripción, cada una de horas enteras (mínimo 1 h), y la suma de sus duraciones es mi tiempo total.<br>Dada una meta de más de 1 día, cuando se genera el desglose, entonces veo consejos generales.<br>Dado que la IA no responde, cuando se agotan los reintentos, entonces mi meta se conserva y puedo reintentar el desglose o armarlo yo mismo con el desglose manual.<br>Dada una meta multidía con menos horas totales que días destinados (por ejemplo 2 h en 3 días), cuando intento guardarla, entonces el sistema la rechaza (HTTP 422) porque cada submeta dura al menos 1 h.<br>Dada una meta con más días destinados que días en su rango de fechas, cuando intento guardarla, entonces el sistema la rechaza (HTTP 422).<br>Dada una meta multidía guardada con desglose por IA, cuando solicito el desglose, entonces espero la respuesta en la misma pantalla (hasta ~60 s) y, si la IA falla, mi meta sigue guardada sin submetas y se me ofrece el desglose manual. |
| HU-META-003 | Usuario (cliente) | Como usuario, quiero recibir recomendaciones de la IA si mi meta exige más de 12 horas por día, para cumplirla sin saturarme. | RF-META-008, RF-META-009, RF-META-030 | Must | Dada una meta de 1 día con 18 h, o de 3 días con 42 h (14 h por día), cuando la creo, entonces la IA ofrece recomendaciones y puedo aceptarlas, modificarlas o rechazarlas.<br>Dada una meta de 3 días con 36 h (12 h por día), cuando la creo, entonces no se me ofrecen recomendaciones.<br>Dado que la IA no está disponible, cuando creo una meta de 1 día con 18 h, entonces puedo guardarla sin recomendaciones.<br>Dado que no he aceptado el servicio externo de IA, cuando creo una meta de 1 día con 18 h que no requiere evidencia, entonces no se me ofrecen recomendaciones y puedo guardarla sin ellas. |
| HU-META-004a | Usuario (cliente) | Como usuario, quiero editar mis metas, para corregir o ajustar mis planes. | RF-META-002b, RF-META-028, RF-META-037 | Should | Dada una meta sin submetas iniciadas, cuando la edito, entonces los cambios se guardan.<br>Dada una meta con una submeta iniciada, cuando intento cambiar su tiempo total, entonces el sistema me lo impide.<br>Dado que rechacé el aviso de IA, cuando edito una meta para que requiera evidencia, entonces el sistema me lo impide, me ofrece aceptar el aviso y mi meta no cambia.<br>Dada una meta con una submeta iniciada, cuando intento cambiar su modo de inicio o su requisito de evidencia, entonces el sistema me lo impide. **[Supuesto S-51]** |
| HU-META-004b | Usuario (cliente) | Como usuario, quiero eliminar mis metas, para descartar planes. | RF-META-002c | Must | Dada una meta existente, cuando la elimino y confirmo, entonces la meta y sus submetas quedan eliminadas y mi puntaje no cambia.<br>Dada una solicitud de eliminar una meta sin confirmación explícita, cuando se envía, entonces el sistema responde HTTP 422 y la meta no se elimina. |
| HU-META-005 | Usuario (cliente) | Como usuario, quiero iniciar mis submetas manualmente o que el sistema las inicie a la hora programada, para que el reloj corra según mi preferencia. | RF-META-012, RF-META-013, RF-META-025, RF-META-026 | Must | Dada una submeta en modo manual, cuando la inicio, entonces el reloj global empieza a contar desde ese momento.<br>Dada una submeta en modo automático, cuando llega su hora programada, entonces el reloj global inicia sin mi intervención.<br>Dada una submeta manual de una meta con evidencia que no inicié durante su fecha programada, cuando termina el día, entonces se cierra con 0 puntos.<br>Dada una submeta manual de una meta sin evidencia que no inicié durante su fecha programada, cuando termina el día, entonces se cierra sin calificación y no suma puntos.<br>Dada una submeta manual con horario de 14:00 a 15:00, cuando la inicio a cualquier hora de su fecha programada (por ejemplo a las 10:00), entonces el reloj empieza a contar desde ese momento.<br>Dada una submeta manual, cuando intento iniciarla antes de su fecha programada, entonces el sistema me lo rechaza (HTTP 409). |
| HU-META-006 | Usuario (cliente) | Como usuario, quiero consultar el detalle de una de mis metas, para revisar su plan y los consejos de la IA. | RF-META-002a | Should | Dada una meta propia, cuando la consulto, entonces veo sus datos, submetas y consejos.<br>Dada una meta de otro usuario, cuando intento consultarla, entonces el sistema responde que no existe. |
| HU-META-007 | Usuario (cliente) | Como usuario, quiero guardar rápido una meta corta de un día sin intervención de la IA, para no esperar por algo simple. | RF-META-004, RF-META-019, RF-META-031 | Must | Dada una meta de 1 día y 8 h, cuando la guardo, entonces no se invoca a la IA y se crea una submeta única.<br>Dada una meta de 1 día, 3 h y horario de 08:00 a 12:00, cuando la guardo, entonces mi submeta única va de 08:00 a 11:00 y su tiempo estipulado es de 3 h. |
| HU-META-008 | Usuario (cliente) | Como usuario, quiero que mis metas sin evidencia se cierren solas al terminar el tiempo, para no tener que justificarlas. | RF-META-006 | Should | Dada una meta sin evidencia, cuando termina el tiempo de su submeta, entonces la submeta se cierra 'sin calificación' y no suma puntos. |
| HU-META-009 | Usuario (cliente) | Como usuario, quiero que el sistema me impida planificar más de 24 horas por día, para que mis metas sean realizables. | RF-META-010, RF-META-020 | Must | Dado 25 h en 1 día, cuando intento guardar, entonces el sistema rechaza la meta.<br>Dado 24 h en 1 día con horario de 00:00 a 24:00, cuando guardo, entonces el sistema acepta la meta.<br>Dado 24 h en 1 día con horario de 00:00 a 23:59, cuando guardo, entonces el sistema me indica que el horario no alcanza.<br>Dado 250 h en 10 días, cuando guardo, entonces el sistema me indica que necesito al menos 11 días.<br>Dado 40 h en 8 días con horario de 2 h diarias, cuando guardo, entonces el sistema me indica que el horario no alcanza. |
| HU-META-010 | Usuario (cliente) | Como usuario, quiero indicar las horas totales de mi meta y elegir las fechas en que trabajaré, para controlar cuándo me dedico a ella. | RF-META-015, RF-META-016 | Must | Dado un tiempo total de 6 h y 3 fechas elegidas, cuando guardo la meta, entonces se crean 3 submetas en esas fechas que suman 6 h. |
| HU-META-011 | Usuario (cliente) | Como usuario, quiero indicar solo cuántos días necesito y que la IA me sugiera las fechas más convenientes según mi meta, para no planificar a ciegas. | RF-META-017, RF-META-018, RF-META-032 | Must | Dado un rango de 14 días, 5 días y una descripción, cuando pido sugerencia, entonces la IA propone 5 fechas dentro del rango.<br>Dadas las fechas sugeridas, cuando las acepto, modifico o rechazo, entonces la meta se guarda según mi decisión. |
| HU-META-012 | Usuario (cliente) | Como usuario, quiero describir mi meta, para que la IA entienda mi objetivo al planificar y evaluar. | RF-META-021, RF-META-022 | Should | Dada una descripción de la meta, cuando se desglosa o se evalúa una evidencia, entonces la IA recibe esa descripción como contexto.<br>Dado que pido fechas sugeridas sin descripción, cuando intento guardar, entonces el sistema me la exige. |
| HU-META-013 | Usuario (cliente) | Como usuario, quiero recibir recomendaciones de descanso cuando mi meta multidía exige más de 12 horas diarias, para cuidar mi salud. | RF-META-023 | Should | Dada una meta de 3 días y 42 h, cuando la creo, entonces la IA me ofrece recomendaciones que incluyen descanso y, si las acepto, las veo con los consejos de la meta. |
| HU-META-014 | Usuario (cliente) | Como usuario que prefiere no usar un servicio externo de IA, quiero armar yo mismo las submetas de una meta de varios días (nombre, fecha, horario y duración), para planificar mi trabajo sin enviar mis datos a un tercero. | RF-META-033, RF-META-034, RF-META-035 | Must | Dado que rechacé el aviso de IA, cuando creo una meta sin evidencia de 3 días y 6 h y defino una submeta de 2 h por cada fecha, entonces la meta se guarda con mis tres submetas, con su nombre, fecha y horario.<br>Dado un desglose cuyas duraciones suman 5 h para una meta de 6 h, cuando intento guardar, entonces el sistema me lo rechaza e indica que falta 1 h.<br>Dada una submeta que termina después de las 24:00 o fuera del horario diario de la meta, cuando intento guardar, entonces el sistema me indica el campo.<br>Dado que rechacé el aviso de IA, cuando intento crear la misma meta con evidencia o con desglose automático, entonces el sistema me lo impide y me ofrece aceptar el aviso.<br>Dada una submeta de 0 h o de 1,5 h, cuando intento guardar, entonces el sistema me indica que la duración debe ser en horas enteras, de 1 h o más. |
| HU-META-015 | Usuario (cliente) | Como usuario que aceptó el servicio de IA, quiero poder elegir el desglose manual en lugar del automático, para decidir yo mismo cómo distribuyo mi tiempo. | RF-META-036 | Should | Dado que acepté el servicio de IA, cuando creo una meta de varios días, entonces puedo elegir entre el desglose por IA y el desglose manual.<br>Dado que elijo el desglose manual en una meta con evidencia, cuando guardo la meta, entonces no se llama a la IA para desglosarla y mis evidencias se evalúan como las de cualquier otra meta. |
| HU-AGEN-001 | Usuario (cliente) | Como usuario, quiero ver mi agenda con metas y submetas por fecha con color por meta, para organizar mi día. | RF-AGEN-001, RF-AGEN-002 | Must | Dado mi calendario, cuando consulto la agenda, entonces veo metas y submetas agrupadas por fecha y las submetas de cada meta en el mismo color. |
| HU-AGEN-002 | Usuario (cliente) | Como usuario, quiero ver el estado de mis submetas y su ventana de tiempo, para saber qué me falta y cuánto tiempo queda. | RF-AGEN-003, RF-AGEN-006 | Should | Dada una submeta, cuando la veo en la agenda, entonces distingo su estado (pendiente, en curso, finalizada) por color y texto.<br>Dada una submeta en tiempo de gracia, cuando veo su detalle, entonces veo la cuenta regresiva del tiempo de gracia. |
| HU-AGEN-003 | Usuario (cliente) | Como usuario, quiero ver el detalle de una submeta desde la agenda, para consultar su puntaje, evidencias y evaluación. | RF-AGEN-004 | Should | Dada una submeta en la agenda, cuando la selecciono, entonces veo su horario, estado, puntaje, evidencias y estado de evaluación. |
| HU-AGEN-004 | Usuario (cliente) | Como usuario, quiero ver al entrar mi próxima submeta, mi puntaje y mi racha, para empezar rápido mi día. | RF-AGEN-005 | Could | Dado que inicio sesión, cuando se muestra el inicio, entonces veo mi próxima submeta de hoy, mi puntaje y mi racha. |
| HU-POM-001 | Usuario (cliente) | Como usuario, quiero usar un pomodoro flexible que pueda iniciar, pausar, reanudar, abandonar y finalizar, para concentrarme sin presión. | RF-POM-001, RF-POM-004, RF-POM-005, RF-POM-006, RF-POM-007 | Should | Dado el temporizador activo, cuando lo pauso y lo reanudo, entonces continúa desde donde quedó.<br>Dado el temporizador activo, cuando lo abandono, entonces el estado cambia y no se penaliza mi submeta.<br>Dado el temporizador activo, cuando lo uso, entonces corre en mi navegador y no se registra nada en el servidor hasta que lo finalizo o lo abandono. |
| HU-POM-002 | Usuario (cliente) | Como usuario, quiero que mis sesiones pomodoro queden guardadas y vinculadas a una submeta en curso, para llevar mi historial. | RF-POM-002, RF-POM-003 | Should | Dada una sesión pomodoro finalizada o abandonada, cuando se cierra, entonces el sistema la guarda con su duración efectiva y la submeta vinculada (si la elegí).<br>Dada una sesión pomodoro de menos de 1 minuto de duración efectiva, cuando termina, entonces el sistema no la guarda. |
| HU-EVID-001 | Usuario (cliente) | Como usuario, quiero subir mi evidencia solo cuando el sistema lo permita, para demostrar mi cumplimiento de forma justa. | RF-EVID-001, RF-EVID-002, RF-EVID-013 | Must | Dado el reloj por debajo del 80 %, cuando intento cargar, entonces el botón está deshabilitado y el backend rechaza (HTTP 409).<br>Dado el reloj en o por encima del 80 %, cuando cargo, entonces el sistema acepta la evidencia.<br>Dado que terminó el tiempo de gracia, cuando intento cargar, entonces el sistema rechaza (HTTP 409). |
| HU-EVID-002 | Usuario (cliente) | Como usuario, quiero subir evidencias en imagen, texto o Excel válidas y propias, para demostrar mi trabajo en mi formato preferido. | RF-EVID-003, RF-EVID-004, RF-EVID-014, RF-EVID-015, RF-IA-012 | Must | Dado un archivo de imagen, texto o Excel de hasta 25 MB, cuando lo subo, entonces el sistema lo acepta.<br>Dado un archivo .gif, .docx, .doc, .xlsx o .xls, cuando lo subo, entonces el sistema lo acepta y lo convierte antes de evaluarlo (el .gif a una imagen PNG; los documentos y hojas a texto).<br>Dado un archivo de otro formato o mayor a 25 MB, cuando lo subo, entonces el sistema lo rechaza.<br>Dado una meta que no requiere evidencia, cuando intento subir una, entonces el sistema la rechaza.<br>Dado un archivo vacío, corrupto o ilegible, cuando lo subo, entonces el sistema lo rechaza al instante, no consume mi envío y puedo subir otro archivo.<br>Dado un archivo de un tipo no soportado, cuando lo subo, entonces el sistema responde HTTP 415; dado un archivo admitido que no se puede convertir, responde HTTP 422; en ambos casos no consume mi envío. |
| HU-EVID-003 | Usuario (cliente) | Como usuario, quiero saber en qué estado está la evaluación de mi evidencia, para saber si fue aceptada. | RF-EVID-005, RF-EVID-006, RF-EVID-009 | Must | Dado el envío de una evidencia, cuando consulto su estado, entonces veo En evaluación, Evaluada con dictamen y justificación, o Error.<br>Dado un archivo legible sin relación con mi submeta, cuando se evalúa, entonces la evaluación queda con dictamen Inválida y 0 puntos y consume mi envío. |
| HU-EVID-004 | Usuario (cliente) | Como usuario, quiero poder enviar una segunda evidencia, una sola vez, si la primera sale Incoherente o Inválida, aun antes de terminar el tiempo, para corregir un error. | RF-EVID-007, RF-EVID-010, RF-EVID-012, RF-EVID-016 | Must | Dado un dictamen Incoherente o Inválida al 90 % del tiempo, cuando consulto mi submeta, entonces puedo enviar una nueva evidencia de inmediato.<br>Dado que ya envié dos evidencias, cuando intento un tercer envío, entonces el sistema lo rechaza (HTTP 409).<br>Dada una primera evidencia aún En evaluación o dictaminada Excelente, cuando intento un segundo envío, entonces el sistema lo rechaza (HTTP 409).<br>Dada una evidencia recibida al 98 % cuyo dictamen llega al 103 %, cuando se puntúa, entonces cuenta como enviada a tiempo. |
| HU-EVID-005 | Usuario (cliente) | Como usuario, quiero reintentar la evaluación cuando falla y que se complete aunque el plazo expire, para no perder mi esfuerzo por un fallo técnico. | RF-EVID-008, RF-EVID-011 | Must | Dada una evaluación en Error, cuando selecciono Reintentar, entonces se reevalúa la misma evidencia y no consumo un intento.<br>Dada una evidencia recibida en el último segundo de la gracia, cuando el dictamen llega después, entonces se puntúa igualmente.<br>Dada una submeta que un administrador cerró tras un Error persistente, cuando selecciono Reintentar, entonces el sistema me informa de que no es posible. |
| HU-EVID-006 | Usuario (cliente) | Como usuario, quiero que al eliminar una meta o mi cuenta se borren también los archivos de mis evidencias, para que no quede información mía almacenada. | RF-EVID-017, RF-EVID-018 | Must | Dada una meta con evidencias, cuando la elimino y confirmo, entonces los archivos de sus evidencias dejan de existir en el almacén.<br>Dado que el borrado de un archivo falló, cuando se ejecuta la limpieza programada, entonces el archivo se elimina sin afectar archivos que tengan registro. **[Supuesto S-53]** |
| HU-PUNT-001 | Usuario (cliente) | Como usuario, quiero ganar el 100 % de los puntos si entrego a tiempo y mi primera evidencia obtiene el dictamen Excelente, para ver mi disciplina recompensada. | RF-PUNT-001 | Must | Dado un primer envío a tiempo con dictamen Excelente, cuando se evalúa, entonces mi submeta cierra con 100 y se suma a mi perfil. |
| HU-PUNT-002 | Usuario (cliente) | Como usuario, quiero tener una segunda oportunidad si mi entrega fue Incoherente o Inválida o si no entregué, para recuperarme. | RF-PUNT-002, RF-PUNT-003, RF-PUNT-007 | Must | Dado un dictamen Incoherente a tiempo, cuando se evalúa, entonces obtengo 50 provisionales y mi submeta sigue abierta para enviar una segunda evidencia.<br>Dado que no envié a tiempo, cuando expira el tiempo inicial, entonces tengo 0 provisionales y se abre el tiempo de gracia (10 % del tiempo).<br>Dado que envío en el tiempo de gracia, cuando mi evidencia es Excelente, entonces obtengo 50 puntos (la mitad). |
| HU-PUNT-003 | Usuario (cliente) | Como usuario, quiero que los puntos de mi segundo envío valgan la mitad y se sumen a los del primero con un tope que premie el acierto en el primer envío, para que mi puntaje final refleje mi esfuerzo. | RF-PUNT-004, RF-PUNT-005, RF-PUNT-006, RF-PUNT-010 | Must | Dado un 50 previo (Incoherente), cuando mi segundo envío es Excelente, entonces suma 50 y mi puntaje final es 90 (tope).<br>Dado un 50 previo, cuando mi segundo envío es Incoherente, entonces suma 25 y mi puntaje final es 75.<br>Dado un 0 previo (Inválida), cuando mi segundo envío es Excelente, entonces mi puntaje final es 50, enviado en el periodo inicial o en el tiempo de gracia.<br>Dado un 50 previo, cuando mi segundo envío es Inválida, entonces mi puntaje final es 50.<br>Dado un 50 previo y ningún segundo envío, cuando termina la gracia, entonces mi submeta cierra con 50. |
| HU-PUNT-004 | Usuario (cliente) | Como usuario, quiero que mi puntaje se actualice de forma consistente, que la submeta cierre en cuanto no haya nada más por hacer y ver cuál puntaje es provisional, para confiar en mi ranking. | RF-PUNT-008, RF-PUNT-011, RF-PUNT-012, RF-PUNT-013, RF-PUNT-014 | Must | Dada una submeta abierta con 50, cuando la veo, entonces aparece 'Provisional: 50' y mi perfil no suma esos puntos todavía.<br>Dado el dictamen de mi segundo envío, cuando se conoce, entonces mi submeta cierra en ese instante y mi acumulado aumenta una sola vez en su puntaje final.<br>Dado un fallo durante el cierre, cuando se reintenta, entonces no se duplican ni se pierden puntos. |
| HU-RANK-001 | Usuario (cliente) | Como usuario, quiero ver el ranking global de usuarios, para compararme. | RF-RANK-001, RF-RANK-005 | Should | Dado el ranking, cuando lo consulto, entonces veo las cuentas ordenadas de mayor a menor puntaje, sin cuentas bloqueadas. |
| HU-RANK-002 | Usuario (cliente) | Como usuario, quiero que el ranking sea justo con los empates y no exponga datos personales, para participar con confianza. | RF-RANK-003, RF-RANK-004 | Must | Dados puntajes 300, 200, 200 y 100, cuando veo el ranking, entonces las posiciones son 1, 2, 2 y 4.<br>Dado el ranking, cuando lo veo, entonces solo aparecen nombre y puntaje. |
| HU-ADM-001 | Administrador | Como administrador, quiero crear, consultar, editar y eliminar cuentas, para gestionar la plataforma. | RF-ADM-001, RF-ADM-008, RF-ADM-009, RF-ADM-010, RF-ADM-020, RF-ADM-021, RF-AUT-018 | Must | Dado el panel de administración, cuando creo, consulto, edito o elimino una cuenta, entonces el cambio queda reflejado.<br>Dado que intento eliminar mi propia cuenta o al último administrador super, cuando confirmo, entonces el sistema lo rechaza.<br>Dado un administrador moderador, cuando intento crear una cuenta administrador, entonces el sistema responde HTTP 403.<br>Dado una cuenta cliente con metas, cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409).<br>Dado que elimino una cuenta cliente y confirmo, cuando termina la operación, entonces se borran en cascada todos sus datos y la cuenta sale del ranking.<br>Dado un administrador que cerró submetas, cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409).<br>Dado un cliente cuyo único dato es un día activo (inició una submeta y eliminó su meta), cuando intento cambiar su rol, entonces el sistema lo rechaza (HTTP 409). **[Supuesto S-54]**<br>Dada una cuenta sin datos, cuando el super cambia su rol, entonces se eliminan los datos del rol anterior y se crean los del nuevo con sus valores por defecto. **[Supuesto S-54]**<br>Dado que creo una cuenta cliente, cuando se guarda, entonces su zona horaria es America/Bogota hasta su primer inicio de sesión, en el que se detecta la de su navegador.<br>Dado que elimino una cuenta con evidencias, cuando termina la operación, entonces los archivos de sus evidencias también se eliminan.<br>Dado que creo una cuenta cliente, cuando su titular inicia sesión por primera vez, entonces debe declarar que es mayor de 18 años antes de usar las funciones de cliente. **[SUPUESTO S-R9]**<br>Dada una solicitud de eliminar una cuenta sin confirmación explícita, cuando se envía, entonces el sistema responde HTTP 422 y la cuenta no se elimina.<br>Dado un administrador moderador o soporte, cuando intento cambiar el nivel de acceso de un administrador o el rol de una cuenta, entonces el sistema responde HTTP 403 y no cambia nada. |
| HU-ADM-002 | Administrador | Como administrador, quiero bloquear y desbloquear cuentas, para controlar el acceso. | RF-ADM-004, RF-ADM-012, RF-ADM-013 | Must | Dada una cuenta bloqueada, cuando intenta iniciar sesión, entonces recibe HTTP 403.<br>Dada una cuenta desbloqueada, cuando inicia sesión, entonces accede.<br>Dada una sesión activa, cuando bloqueo la cuenta, entonces su token deja de ser válido.<br>Dado el único administrador super sin bloquear, cuando un super intenta bloquearlo (incluido a sí mismo), entonces el sistema lo rechaza (HTTP 409).<br>Dado un administrador de nivel moderador, cuando intento bloquear o desbloquear una cuenta administrador, entonces el sistema responde HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y no cambia la cuenta; con una cuenta cliente sí se permite. |
| HU-ADM-003 | Administrador | Como administrador, quiero ver métricas de la aplicación y del uso del LLM, para vigilar el rendimiento y el costo. | RF-ADM-002, RF-ADM-011 | Should | Dado el panel de métricas, cuando lo consulto, entonces veo usuarios, metas, evidencias evaluadas y, por operación, llamadas, tokens, costo y latencia del LLM. |
| HU-ADM-004 | Administrador | Como administrador, quiero consultar las evidencias de los usuarios, para dar soporte. | RF-ADM-003 | Should | Dado el panel, cuando consulto evidencias, entonces puedo ver las de cualquier usuario con su dictamen y estado. |
| HU-ADM-005 | Administrador | Como administrador, quiero ver el ranking global incluyendo cuentas bloqueadas, para dar soporte competitivo. | RF-ADM-005 | Should | Dado el panel de administración, cuando consulto el ranking, entonces veo la lista completa con la marca de las cuentas bloqueadas. |
| HU-ADM-006 | Administrador | Como administrador, quiero que mi rol sea excluyente del de cliente y que los clientes no accedan a administración, para separar supervisión de actividad personal. | RF-ADM-006, RF-ADM-016 | Must | Dada una sesión administrador, cuando intento crear una meta, entonces el sistema responde HTTP 403.<br>Dada una sesión cliente, cuando intento abrir una función de administración, entonces el sistema responde HTTP 403. |
| HU-ADM-007 | Administrador | Como administrador, quiero que cada llamada al LLM, incluidos los reintentos, quede registrada con su meta, evaluación y usuario, para auditar costos y errores. | RF-ADM-007, RF-IA-009 | Should | Dada una evaluación con un fallo y un reintento exitoso, cuando reviso los registros de uso, entonces existen dos registros vinculados a esa evaluación, cada uno con tokens, costo, latencia, proveedor, modelo y resultado. |
| HU-ADM-008 | Administrador | Como administrador, quiero conocer qué decisiones tomaron los usuarios sobre las recomendaciones de la IA, para analizar su efectividad. | RF-META-014 | Should | Dada una recomendación decidida, cuando consulto el registro, entonces veo la decisión y su fecha-hora. |
| HU-ADM-009 | Administrador | Como administrador, quiero asignar niveles de acceso a los administradores, para limitar lo que cada uno puede hacer. | RF-ADM-014, RF-ADM-015 | Must | Dado un administrador de nivel soporte, cuando intenta bloquear una cuenta, entonces el sistema responde HTTP 403.<br>Dado un administrador super, cuando cambia el nivel de otro administrador, entonces el cambio se guarda. |
| HU-IA-001 | Administrador | Como administrador, quiero poder cambiar el proveedor de IA sin modificar la lógica del sistema y con respuestas estructuradas y controladas, para reducir costo y dependencia. | RF-IA-001, RF-IA-002, RF-IA-003, RF-IA-004, RF-IA-005 | Must | Dada la configuración, cuando cambio de proveedor, entonces metas, evidencias y puntuación funcionan sin cambios.<br>Dada una respuesta fuera del esquema, cuando la recibo, entonces la operación pasa a Error sin persistir datos.<br>Dado un fallo transitorio, cuando se reintenta hasta 2 veces, entonces se persiste un único resultado. |
| HU-IA-002 | Usuario (cliente) | Como usuario, quiero saber y aceptar que mis evidencias se procesan con un servicio externo de IA y que no se envían mis datos personales, para proteger mi privacidad. | RF-IA-005, RF-IA-006, RF-IA-007 | Must | Dado que aún no acepté, cuando intento cargar mi primera evidencia o crear una meta que requiere IA, entonces el sistema me muestra el aviso y me pide aceptar.<br>Dada una evaluación, cuando se envía al proveedor, entonces no incluye mi nombre ni mi correo.<br>Dada una imagen con metadatos EXIF y un nombre de archivo con mi nombre, cuando se envía al proveedor, entonces se envía sin los metadatos EXIF y sin ese nombre de archivo. |
| HU-IA-003 | Usuario (cliente) | Como usuario, quiero que la IA evalúe mi evidencia con el contexto de mi meta y me explique su dictamen, para entender el resultado. | RF-IA-008 | Must | Dada una evidencia, cuando se evalúa, entonces la IA recibe el nombre y la descripción de la meta y devuelve dictamen y justificación que puedo leer. |
| HU-IA-004 | Usuario (cliente) | Como usuario que rechaza el uso de un servicio externo de IA, quiero seguir usando la aplicación con metas sin evidencia, de un día o de varios días con desglose manual, para proteger mi privacidad sin quedar fuera del producto. | RF-IA-010, RF-IA-011, RF-IA-007 | Must | Dado que rechacé el aviso de IA, cuando creo una meta de 1 día que no requiere evidencia, entonces se guarda con su submeta única.<br>Dado que rechacé el aviso de IA, cuando creo una meta de varios días sin evidencia con desglose manual, entonces se guarda con mis submetas.<br>Dado que rechacé el aviso de IA, cuando intento crear o editar una meta con evidencia, pedir desglose automático, recomendaciones o fechas sugeridas, o cargar una evidencia, entonces el sistema me lo impide y me ofrece aceptar el aviso.<br>Dado que acepto el aviso más tarde, cuando repito la operación, entonces el sistema la realiza. |
| HU-NOT-001 | Usuario (cliente) | Como usuario, quiero activar o desactivar las notificaciones push, para controlar los avisos que recibo. | RF-NOT-001, RF-NOT-002, RF-NOT-007 | Should | Dado que activo las notificaciones y concedo el permiso del navegador, cuando se produce un evento, entonces recibo el aviso.<br>Dado que las desactivo, cuando se produce un evento, entonces no recibo avisos. |
| HU-NOT-002 | Usuario (cliente) | Como usuario, quiero recibir avisos push de inicio de submeta, apertura de evidencia, tiempo de gracia, resultado y logros, para no perder los plazos. | RF-NOT-003, RF-NOT-004, RF-NOT-005, RF-NOT-006, RF-NOT-008 | Should | Dada una submeta programada a las 08:00, cuando son las 07:50, entonces recibo un recordatorio.<br>Dada una submeta de 60 min, cuando llega el minuto 48, entonces recibo el aviso de que puedo subir mi evidencia. |
| HU-LOGR-001 | Usuario (cliente) | Como usuario, quiero obtener logros automáticamente al cumplir hitos y ser avisado, para sentir reconocimiento. | RF-LOGR-001, RF-LOGR-002, RF-LOGR-004 | Should | Dado que inicio mi primera submeta (a mano o por inicio automático), cuando se registra, entonces obtengo 'Primer paso' una sola vez y veo un aviso.<br>Dado que cierro una submeta con acierto Excelente en el primer envío, cuando se cierra, entonces obtengo 'Impecable'; si el acierto fue en el segundo envío o en el tiempo de gracia, entonces no la obtengo.<br>Dado que ya vi el aviso de un logro, cuando la interfaz consulta de nuevo los logros desde el último instante visto, entonces el aviso no se repite. |
| HU-LOGR-002 | Usuario (cliente) | Como usuario, quiero ver mis logros obtenidos y los pendientes en mi perfil, para saber qué me falta. | RF-LOGR-003 | Should | Dado mi perfil, cuando lo abro, entonces veo los logros obtenidos con fecha y los demás como bloqueados. |
| HU-ADM-010 | Administrador | Como administrador, quiero que el despliegue cree una primera cuenta administrador de nivel super con variables de entorno, para poder gestionar la plataforma desde el primer día sin depender del autorregistro ni de una pantalla pública. | RF-ADM-017 | Must | Dada una base de datos sin ningún administrador super (aunque tenga un moderador), cuando el despliegue arranca con el correo y la contraseña iniciales en variables de entorno, entonces existe una cuenta administrador de nivel super que puede iniciar sesión.<br>Dada una base con un administrador super, cuando el despliegue arranca de nuevo, entonces no se crea otra cuenta (aunque exista un moderador).<br>Dado el sistema en ejecución, cuando busco una pantalla pública para crear el primer administrador, entonces no existe. |
| HU-ADM-011 | Administrador | Como administrador, quiero ver y cerrar las submetas cuya evaluación lleva 48 horas en Error, para que un usuario no quede bloqueado por un fallo técnico. | RF-ADM-018, RF-ADM-019 | Must | Dada una evaluación en Error desde hace 48 horas, cuando abro el listado, entonces la veo; si lleva 47 horas, no la veo.<br>Dada una submeta con 50 puntos provisionales y una evaluación en Error durante 48 horas, cuando la cierro, entonces queda finalizada con 50 y el acumulado del usuario aumenta en 50.<br>Dado un administrador de nivel soporte, cuando intento cerrar la submeta, entonces el sistema responde HTTP 403. |


## 3.6 Reglas de Negocio (BR)

Los RF, con su criterio de aceptación, son los requisitos verificables; las BR centralizan las reglas de negocio que varios RF aplican. Cuando un RF y una BR enuncian la misma regla, ambos DEBEN mantenerse sincronizados y todo cambio se aplica en los dos; la columna BR de la matriz 4.2 permite detectar esos cruces.

| ID | Nombre | Descripción |
|---|---|---|
| BR-001 | Regla del 80 % (mínimo de entrega) | La carga de toda evidencia de una submeta (primer o segundo envío) solo se habilita cuando ha transcurrido al menos el 80 % de su tiempo estipulado (BR-032); es una regla antifraude. Se aplica en el frontend y se valida de nuevo en el backend (HTTP 409). Es una única regla para ambos envíos: el segundo envío, que solo ocurre tras el dictamen del primero, queda siempre por encima del umbral, por lo que esta versión no define ninguna otra restricción de tiempo mínimo. El porcentaje de tiempo transcurrido y la ventana de la evidencia se calculan con el instante de recepción (fecha_carga), la hora de inicio real de la submeta y su tiempo estipulado T; si el porcentaje o la ventana registrados no coinciden con ese cálculo (tolerancia de 1 s de T), la evidencia se rechaza con HTTP 409. |
| BR-002 | Máximo de dos envíos y rectificación | (a) El máximo es de 2 envíos de evidencia por submeta; Reintentar una evaluación (BR-017) no cuenta como envío. (b) El primer envío solo puede hacerse tras el 80 % del tiempo estipulado (BR-001). (c) Si el primer envío es dictaminado Excelente, la submeta se cierra con ese puntaje y no admite otro envío. (d) Si el primer envío es dictaminado Incoherente o Inválida, el usuario puede enviar una única evidencia más, desde el dictamen y hasta el fin del tiempo de gracia, usando el tiempo restante del periodo inicial y el tiempo de gracia. (e) Un primer envío recibido en el tiempo de gracia (porque no se envió en el periodo inicial) se puntúa con la tabla de gracia y, si es Incoherente o Inválida, admite un segundo envío dentro de la gracia restante **[Supuesto S-37]**. (f) El segundo envío no se admite mientras el primero esté En evaluación o en Error. (g) El dictamen del segundo envío cierra la submeta (BR-018). (h) El segundo envío vale la mitad de la tabla del periodo inicial en cualquier ventana (BR-004). El tiempo de gracia es la ventana adicional del 10 % que sigue al tiempo estipulado. |
| BR-003 | Cálculo del tiempo de gracia | El tiempo de gracia equivale al 10 % del tiempo estipulado de la submeta (BR-032) y se cuenta desde la finalización del 100 % del tiempo inicial. |
| BR-004 | Matriz de puntuación por ventana y dictamen | Los puntos de una evidencia dependen de su número de envío, de la ventana en que se recibe y de su dictamen. Primer envío en el periodo inicial: Excelente = 100, Incoherente = 50, Inválida = 0. Primer envío en el tiempo de gracia (la mitad): Excelente = 50, Incoherente = 25, Inválida = 0. Segundo envío (la mitad, en cualquier ventana, incluido el periodo inicial): Excelente = 50, Incoherente = 25, Inválida = 0. Sin evidencia en el periodo inicial: 0 provisionales. El puntaje de la submeta es la suma de los puntos de sus evidencias: con un solo envío es ese valor (máximo 100); con dos envíos es la suma con tope de 90, de modo que quien necesitó dos envíos no iguala a quien acertó en el primero. Ejemplos oficiales: Incoherente (50) + Excelente (50) = 100, que por el tope da 90; Incoherente (50) + Incoherente (25) = 75; Inválida (0) + Excelente (50) = 50; Incoherente (50) + Inválida (0) = 50; Inválida + Inválida = 0; primer envío Excelente en el periodo inicial = 100 y cierra. La tabla completa de las 25 combinaciones está en 3.6.1. El puntaje acumulado del usuario es la suma de los puntajes finales de sus submetas cerradas con calificación, con 1 % = 1 punto (BR-030). |
| BR-005 | Dictámenes de evaluación | El LLM evalúa cada evidencia y retorna uno de tres dictámenes con una justificación. Inválida: la evidencia es legible pero no guarda relación con la submeta o es de otro tema (por ejemplo, una imagen en blanco o una captura de otra materia). Un archivo vacío, corrupto o ilegible al prepararlo, o de formato no soportado, no recibe dictamen: se rechaza al subirlo, sin llamar al LLM y sin consumir envío (RF-IA-012). Incoherente: la evidencia guarda relación con la submeta pero es insuficiente (por ejemplo, cubre una parte menor del trabajo declarado). Excelente: la evidencia corresponde a la submeta, es acorde y demuestra bien el trabajo realizado. **[Supuesto S-36]** Inválida es un dictamen que puntúa 0 y consume el envío; no es un Error. Error es solo un fallo técnico del servicio de IA (timeout tras los reintentos, error 5xx, cuota agotada o respuesta fuera del esquema) que no puntúa y admite Reintentar sin consumir envío. 'Sin envío' es la ausencia de evidencia dentro del tiempo estipulado inicial y no es un dictamen del LLM. |
| BR-006 | Inicio del reloj global | El reloj global de una submeta inicia a la hora programada de su fecha si el modo es automático; si el modo es manual, inicia cuando el usuario la inicia y su duración es el tiempo estipulado de la submeta (BR-032). El retraso en el inicio manual es responsabilidad del usuario (ver BR-027). |
| BR-007 | Pomodoro sin penalización | Las pausas, abandonos o la no utilización del Pomodoro no afectan la puntuación ni el reloj global de la submeta; solo rige el tiempo global de entrega. |
| BR-008 | Reglas aplicables a submetas | Las submetas diarias se rigen por las mismas reglas de evidencia, puntuación y tiempo de gracia, que se aplican a cada submeta de forma independiente. |
| BR-009 | Día activo | Se considera día activo el día calendario, en la zona horaria del usuario, en que el usuario actúa: inicia a mano una submeta de modo manual o envía una evidencia (el día es el de recepción de la evidencia por el servidor); se cuenta una sola vez por día. No activan ningún día: el inicio automático de una submeta; los cierres que provoca el sistema (fin del tiempo de gracia, vencimiento de una meta sin evidencia, submeta manual nunca iniciada, BR-027); el cierre administrativo (RF-ADM-019); una carga rechazada (RF-IA-012); ni la finalización por sí misma, que cuenta solo como consecuencia de una evidencia enviada ese día, la cual ya activa el día por el envío. En una meta sin evidencia solo el inicio manual activa el día; una submeta automática de una meta sin evidencia no activa ninguno. Efecto aceptado: una meta sin evidencia con inicio automático nunca activa un día ni suma a la racha, y el inicio automático sí cuenta para el logro 'Primer paso' (BR-020). Un día activo solo por el envío de una evidencia tiene 0 submetas iniciadas a mano. Es la única definición de día activo: la usan la racha (BR-019), el calendario de actividad (BR-034) y la vista de inicio (RF-AGEN-005). La aplicación calcula la fecha local del día activo (la del instante del evento en la zona horaria del usuario) y la entrega al registro; la base de datos no la deriva. |
| BR-010 | Metas sin evidencia | Las submetas de metas que no requieren evidencia no generan puntaje ni evaluación LLM; al finalizar el tiempo estipulado se cierran como finalizadas 'sin calificación' (puntaje vacío, no cero) y no suman puntos al perfil. |
| BR-011 | Límite de duración diaria (24 h por día) | Una meta DEBE cumplir tiempo total ÷ días destinados ≤ 24 horas (límite inclusivo). 24 h en 1 día es válido —con horario de 00:00 a 24:00, porque la hora de fin puede ser 24:00 (RF-META-005, RF-META-020)—; 25 h en 1 día no lo es; 250 h exigen al menos 11 días. Esta regla sustituye la formulación anterior 'mayor a 24 h' y la del script 'menor a 24'. El cociente es un promedio diario, no un tope por submeta (cada submeta, además, cabe en el horario diario de la meta, BR-014), y la duración de un horario se mide como la diferencia de las horas locales del reloj (fin menos inicio), sin ajustes por cambio de horario de verano. **[Supuesto S-49]** |
| BR-012 | Bloqueo temporal y bloqueo administrativo | Existen dos bloqueos independientes: (a) temporal, automático, de 15 min tras 5 intentos fallidos consecutivos (respuesta 429); (b) administrativo, indefinido, impuesto y retirado solo por un administrador (respuesta 403). Ningún evento ajeno (cierre de submeta, cambio de puntaje) puede levantar un bloqueo ni reiniciar el contador de intentos. |
| BR-013 | Roles excluyentes | Una cuenta tiene exactamente un rol: cliente o administrador. Las cuentas administrador no tienen metas, submetas, evidencias ni puntaje de ranking. Quien necesite ambas funciones usa dos cuentas con correos distintos. No se puede cambiar el rol de una cuenta que tenga datos: un cliente tiene datos si tiene al menos una meta, una sesión Pomodoro, un logro, un día activo o un puntaje mayor que 0, y un administrador tiene datos si cerró al menos una submeta (RF-ADM-019). La zona horaria, las preferencias de notificación, la aceptación de IA y las suscripciones push no cuentan como datos: se eliminan al pasar de cliente a administrador y, al pasar de administrador a cliente, se crean con valores por defecto, con zona America/Bogota hasta el primer inicio de sesión (RF-ADM-020, RF-AUT-016). **[Supuesto S-54]** Una cuenta con datos no cambia de rol: se elimina la cuenta o se crea una nueva. El rol solo cambia mediante la operación de cambio de rol (RF-ADM-009, RF-ADM-020; en el script, el procedimiento sp_cambiar_rol, que recibe el identificador del administrador que lo ejecuta y solo acepta a un super, BR-021); la base de datos rechaza la modificación directa del rol por cualquier otra vía. **[Supuesto S-48]** |
| BR-014 | Semántica de la planificación de la meta | (1) Tiempo total = horas totales dedicadas a la meta, entero ≥ 1. (2) Días destinados = número de fechas de trabajo (entero ≥ 1). (3) El usuario define las fechas de trabajo eligiéndolas, o indica solo el número de días (≥ 2) dentro de un rango y la IA propone las fechas según la descripción de la meta; el usuario confirma. (4) Cada fecha de trabajo origina exactamente una submeta. (5) La suma de los tiempos estipulados de las submetas (BR-032) es igual al tiempo total. (6) Cada submeta cabe en el horario diario de la meta, cuya hora de fin puede ser 24:00. (7) Tipo: un_dia si hay 1 día destinado, multidia si hay 2 o más. Los días destinados caben en el rango de fechas de la meta (de fecha_inicio a fecha_fin, ambos inclusive): no puede haber más días destinados que días en el rango (numeral 11). (8) Un selector de días de la semana en la interfaz es solo una ayuda para preseleccionar fechas; lo persistido son fechas concretas. (9) Con desglose manual, el usuario define para cada fecha de trabajo el nombre, la hora de inicio y la duración de su submeta, que cumple de (4) a (6); la duración de cada submeta es un número entero de horas, mínimo 1 h; no hay más de una submeta por fecha, tampoco en el desglose manual (RF-META-033 a RF-META-035). (10) La duración de cada submeta es un número entero de horas, mínimo 1 h, también cuando la genera el Agente IA: el LLM debe devolver horas enteras de 1 h o más y el sistema lo valida (RF-IA-002, RF-META-003); como cada submeta dura al menos 1 h, el tiempo total de una meta multidía debe ser mayor o igual que los días destinados y, si no lo es, la meta no admite un desglose válido y se rechaza con HTTP 422 al crearla o editarla, antes de guardarla (CU-005, CU-008a, CU-025). (11) Los días destinados no superan el número de días del rango de fechas de la meta; si lo superan, la meta se rechaza con HTTP 422 en el mismo momento. **[Supuestos S-04, S-05, S-33, S-34]** |
| BR-015 | Umbral de 12 horas por día para la recomendación de la IA | Se aplica por día de trabajo en toda meta, de 1 día o multidía: promedio diario = tiempo total ÷ días destinados. Hasta 12 h inclusive no se invoca la recomendación; más de 12 h y hasta 24 h activa la recomendación de la IA (RF-META-008), que el usuario puede aceptar, modificar o rechazar (RF-META-009) y que en metas multidía incluye descanso (RF-META-023); más de 24 h se rechaza y el usuario debe dedicar más días (BR-011). El umbral de 12 h es una recomendación de bienestar y nunca impide guardar una meta válida; sin aceptación del servicio externo de IA la recomendación no se obtiene (no se llama al LLM) y la meta se guarda igual (BR-035). El umbral es el promedio diario, no un tope por submeta, también en el desglose manual: allí cada fecha tiene una sola submeta, pero el umbral sigue siendo el promedio (tiempo total ÷ días destinados) y una submeta de más de 12 h no activa la recomendación por sí sola; el único límite duro es 24 h por día (BR-011). **[Supuesto S-49]** |
| BR-016 | Ventana de tiempo de una evidencia | Cada evidencia (primer o segundo envío) pertenece a la ventana (inicial o gracia) en la que el servidor la recibe. La evaluación de una evidencia recibida dentro del plazo se completa y puntúa aunque el plazo expire durante la evaluación. Pasado el fin del tiempo de gracia no se aceptan más evidencias. |
| BR-017 | Reintento de evaluación | Reintentar una evaluación en Error reevalúa la misma evidencia, no crea una evidencia nueva y no consume un intento de envío. La evidencia conserva la ventana en la que fue recibida (BR-016). Cada llamada al LLM del reintento genera su propio registro de uso (RF-ADM-007). |
| BR-018 | Cierre de submeta | Una submeta pasa a finalizada solo cuando: (a) su primer envío recibe dictamen Excelente (100 puntos en el periodo inicial, 50 en gracia); (b) su segundo envío recibe dictamen, en cuyo caso se cierra en ese instante sin esperar el fin de la gracia **[Supuesto S-40]**; (c) expira el tiempo de gracia sin segundo envío y sin evaluaciones pendientes ni en Error, con el puntaje del primer envío o 0 si no hubo envío; si el dictamen del primer envío (Incoherente o Inválida) llega cuando la gracia ya terminó, la submeta se cierra en el instante del dictamen con el puntaje de ese envío, porque no admite segundo envío; (d) vence el tiempo estipulado de una meta sin evidencia (BR-010); (e) vence sin iniciar una submeta manual (BR-027: 0 puntos si la meta requiere evidencia, sin calificación si no la requiere); o (f) un administrador la cierra después de 48 horas de una evaluación en Error, con su puntaje provisional (RF-ADM-019). Mientras tanto permanece en curso con puntaje provisional: la suma de los puntos de las evidencias ya evaluadas (con tope de 90 si hay dos evaluadas), contando 0 para las evidencias en evaluación o en Error. Al cerrarse, su puntaje final se suma al del perfil en la misma transacción (RF-PUNT-014). Una evaluación en Error mantiene abierta la submeta hasta que se resuelva con Reintentar o hasta el cierre administrativo de la letra (f) **[Supuesto S-22]**. |
| BR-019 | Cálculo de la racha de días | La racha actual es el número de días calendario consecutivos con día activo (BR-009, la misma definición que usa el calendario de actividad, BR-034) hasta hoy; si hoy aún no hay actividad, cuenta hasta ayer y no se reinicia hasta que termine el día de hoy sin actividad. La racha máxima es el mayor valor histórico de la racha actual. **[Supuesto S-14]** |
| BR-020 | Catálogo inicial de logros | **[Supuesto S-15]** (1) Primer paso: iniciar la primera submeta, a mano o por inicio automático; un inicio automático otorga el logro aunque no active el día (BR-009). (2) Constante: racha de 7 días. (3) Imparable: racha de 30 días. (4) Impecable: cerrar una submeta con acierto Excelente en el primer envío recibido en el periodo inicial (BR-033; 100 puntos). (5) Segunda oportunidad: cerrar una submeta en la que el segundo envío sumó puntos (más de 0). (6) Meta cumplida: finalizar todas las submetas de una meta multidía habiendo iniciado cada una; las cerradas por no inicio (BR-027) no cuentan. (7) Mil puntos: alcanzar 1 000 puntos acumulados. Los logros no otorgan puntos y no afectan el ranking **[Supuesto S-16]**. **[Supuesto S-38]** |
| BR-021 | Niveles de acceso del administrador | **[Supuesto S-17]** super: todas las funciones, incluida la creación y eliminación de administradores y la asignación de niveles. moderador: consultar cuentas, crear y editar cuentas cliente, bloquear y desbloquear cuentas cliente, consultar evidencias, ranking y métricas de uso de la aplicación, y listar y cerrar las submetas con evaluación en Error durante 48 horas (RF-ADM-018, RF-ADM-019) **[Supuesto S-43]**. soporte: solo lectura de cuentas, evidencias y ranking. Las métricas del LLM, la eliminación de cuentas, la creación o edición de cuentas administrador y el bloqueo y desbloqueo de cuentas administrador son exclusivas de super: el moderador que intenta bloquear o desbloquear una cuenta administrador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y no cambia nada. Siempre debe existir al menos un administrador super sin bloqueo administrativo: ninguna operación (eliminar, bloquear, cambiar el rol o cambiar el nivel) puede dejar al sistema sin él **[Supuesto S-47]**. Último super: el único administrador de nivel super sin bloqueo administrativo. Dos operaciones simultáneas que afecten a supers no pueden dejar al sistema sin él: una se completa y la otra responde HTTP 409. La única excepción es el arranque inicial, antes de que el despliegue cree el primer super con variables de entorno (RF-ADM-017), lo que ocurre solo si no existe ningún administrador super (pueden existir administradores de otros niveles, que no se modifican). Matriz por acción: consultar cuentas, evidencias y ranking —super, moderador y soporte—; métricas de uso de la aplicación, crear y editar cuentas cliente, bloquear y desbloquear cuentas cliente, y listar y cerrar evaluaciones en Error —super y moderador—; métricas del LLM, crear y editar cuentas administrador, bloquear y desbloquear cuentas administrador, asignar niveles, cambiar roles y eliminar cuentas —solo super—. El cambio de nivel de acceso y el cambio de rol los ejecuta siempre un actor identificado, que debe ser un administrador de nivel super: la operación recibe el identificador del administrador que la solicita y la rechaza (HTTP 403) si no existe o no es super. |
| BR-022 | Eventos y preferencias de notificación push | **[Supuesto S-19]** Eventos: recordatorio 10 min antes del inicio de una submeta, apertura de la carga de evidencia (80 %), apertura del tiempo de gracia, resultado de evaluación y logro obtenido. Solo se envía si la preferencia está activada y existe suscripción vigente. Los correos transaccionales (recuperación de contraseña, bloqueo temporal) se envían siempre, independientemente de esta preferencia. |
| BR-023 | Elegibilidad y desempate del ranking | El ranking de clientes incluye las cuentas con rol cliente no bloqueadas administrativamente. Empates: misma posición y orden alfabético por nombre. Se muestran solo nombre y puntaje. El ranking de administración (RF-ADM-005, CU-021) es distinto: incluye además las cuentas bloqueadas con su marca de estado. **[Supuestos S-18, S-20]** |
| BR-024 | Catálogo de categorías de meta | Las categorías permitidas son: estudio, bienestar, juegos, hábitos de vida, deporte, lectura, programación, idiomas, trabajo, proyecto personal y otro. |
| BR-025 | Edición y eliminación de metas | Los parámetros de planificación (días, tiempo total, fechas, horario) solo son editables mientras ninguna submeta de la meta haya sido iniciada; al editarlos se regeneran las submetas. Eliminar una meta elimina sus submetas, evidencias y evaluaciones, pero no revierte los puntos ya sumados al perfil ni elimina los días activos del usuario. **[Supuestos S-11, S-12]** **[Supuesto S-54]** |
| BR-026 | Datos enviados al proveedor de LLM | Al proveedor solo se envía el contenido estrictamente necesario: evidencia, nombre y descripción de la meta, descripción de la submeta y duración. No se envían nombre, correo ni identificadores del usuario ni el nombre original del archivo de la evidencia; las imágenes se envían sin metadatos EXIF (ubicación, fecha de captura y dispositivo) y con la resolución mínima útil para evaluarlas **[Supuesto S-R12]**. El usuario acepta explícitamente el uso de un servicio externo de IA antes de la primera llamada con sus datos, sea para desglose, recomendaciones, sugerencia de fechas o evaluación (RF-IA-007); si no acepta, se aplica BR-035. Los datos enviados no deben ser usados por el proveedor para entrenar modelos; esta condición se verifica al seleccionar el proveedor y se cumple con el plan de pago contratado. Con usuarios reales se usa solo un plan de pago del proveedor con límite de gasto configurado; la capa gratuita se usa únicamente con datos sintéticos de prueba y nunca con datos de usuarios reales. **[Supuesto S-25]** |
| BR-027 | Submeta manual no iniciada | Una submeta en modo manual puede iniciarse a cualquier hora de su fecha programada, de 00:00:00 a 23:59:59 en la zona horaria del usuario, también antes de su horario programado, que no limita el inicio; antes de su fecha programada no puede iniciarse (HTTP 409). Si no se inició durante su fecha, se cierra como finalizada, sin tiempo de gracia: con 0 puntos si la meta requiere evidencia y sin calificación (puntaje vacío, BR-010) si no la requiere. **[Supuesto S-09]** |
| BR-028 | Zona horaria | Todos los horarios de metas y submetas, el inicio automático, el día activo, el calendario de actividad y las notificaciones se interpretan en la zona horaria IANA del usuario, que se detecta del navegador al registrarse y se puede editar en el perfil; America/Bogota rige si el navegador no la informa y, hasta su primer inicio de sesión, en las cuentas cliente creadas por un administrador o convertidas desde administrador; en ese primer inicio se detecta la del navegador (RF-ADM-021, RF-AUT-016). La BD almacena marcas de tiempo absolutas para lo ocurrido (inicio real, cierre, evidencias) y fechas y horas locales para lo programado. Al cambiar la zona, las submetas pendientes conservan su fecha y hora locales y los días activos ya registrados no se recalculan (RF-PER-017). **[Supuesto S-27]** **[Supuesto S-52]** |
| BR-029 | Estados de submeta, evaluación y ventana | Submeta: pendiente → en curso (inicio manual o automático) → finalizada (BR-018); pendiente → finalizada (BR-027). Evaluación: en evaluación → evaluada \| error; error → en evaluación (reintento, BR-017). Ventana (derivada, no es un estado): inicial desde el inicio del reloj hasta el 100 %; gracia durante el 10 % siguiente; cerrada después. Una submeta se considera iniciada cuando su reloj llegó a correr (tiene hora de inicio real). Meta (derivada de sus submetas, no editable), evaluada en este orden de precedencia: (1) pendiente si no tiene submetas (desglose pendiente, RF-META-024); (2) finalizada si todas sus submetas están finalizadas, aunque ninguna se haya iniciado (por ejemplo, todas cerradas por BR-027); (3) en curso si alguna fue iniciada y alguna no está finalizada; (4) pendiente en los demás casos (ninguna iniciada y alguna no finalizada). Una meta nunca es a la vez pendiente y finalizada. El estado pendiente_evidencia no existe: la carga habilitada, el tiempo de gracia, la evaluación pendiente y el puntaje provisional se derivan del reloj y de las entidades evidencia y evaluacion, y no se almacenan como estado. |
| BR-030 | Equivalencia entre porcentaje y puntos | El puntaje de una submeta se expresa de 0 a 100 y 1 % equivale a 1 punto del puntaje acumulado del perfil, sin ponderar por duración. **[Supuesto S-29]** |
| BR-031 | Información no dependiente solo del color | Todo estado, resultado o ventana mostrado con color debe incluir además texto o ícono. (Soporte de RNF-009.) |
| BR-032 | Tiempo estipulado de la submeta | El tiempo estipulado T de una submeta es la duración de su propio horario: hora de fin menos hora de inicio de la submeta (la hora de fin puede ser 24:00). Es la base de la regla del 80 % (BR-001), del tiempo de gracia (BR-003) y de las ventanas de puntaje. La suma de los T de las submetas de una meta es igual al tiempo total (BR-014). En una meta de 1 día la submeta única empieza en la hora de inicio del horario de la meta y dura exactamente el tiempo total (RF-META-031): una meta de 3 h con horario 08:00 a 12:00 da una submeta de 08:00 a 11:00 con T = 3 h; el horario de la meta es la franja disponible y no la duración de la submeta. En modo manual el reloj dura T desde el inicio real (BR-006). **[Supuesto S-33]** |
| BR-033 | Acierto en el primer envío y racha perfecta | Acierto en el primer envío: la submeta se cerró porque su primer envío, recibido en el periodo inicial, fue dictaminado Excelente (100 puntos). El logro Impecable (BR-020) y la racha perfecta (número de submetas calificadas consecutivas, por orden de cierre, cerradas con acierto en el primer envío) solo cuentan con ese acierto: un primer envío Excelente recibido en el tiempo de gracia (50 puntos) no cuenta; tampoco una submeta cerrada por el segundo envío ni con cualquier otro resultado, y todas ellas reinician la racha perfecta a 0; una submeta sin calificación y una cerrada por un administrador tras un Error persistente (RF-ADM-019) no la alteran **[Supuesto S-44]**. La racha perfecta se alimenta solo del dictamen de las evidencias que envía el usuario; los cierres que provoca el sistema (fin de la gracia, BR-027) no son acciones del usuario ni activan el día (BR-009), pero, por ser calificados, reinician la racha perfecta como cualquier otro resultado. Los demás logros no otorgan puntos. **[Supuesto S-38]** |
| BR-034 | Calendario de actividad del perfil | El perfil muestra los últimos 12 meses móviles que terminan hoy (zona horaria del usuario; hasta 366 días) con una celda por día. Un día activo (BR-009, la misma definición que usa la racha, BR-019) se resalta con un único tono de verde, igual para todos los días activos, y un día no activo no se resalta. Ninguna información depende solo del color (BR-031): cada celda tiene etiqueta de texto y existe una alternativa textual equivalente (RF-PER-013). |
| BR-035 | Consentimiento de IA y funciones disponibles | Las funciones que envían datos al servicio externo de IA son el desglose automático (RF-META-003), las recomendaciones (RF-META-008), la sugerencia de fechas (RF-META-032) y la evaluación de evidencia (RF-EVID-005). Requieren la aceptación previa del usuario (RF-IA-007). Sin aceptación se permiten las metas que no requieren evidencia: de 1 día, o multidía con desglose manual (RF-META-033); se deniegan, con HTTP 403 y el aviso de consentimiento, las metas que requieren evidencia, el desglose automático, las fechas sugeridas, las recomendaciones y la carga de evidencia (RF-IA-011), tanto al crear como al editar una meta (RF-META-037). El aviso se muestra cada vez que el usuario intenta una de esas funciones y puede aceptarlo en cualquier momento. Las recomendaciones son informativas y nunca bloquean guardar una meta (BR-015): sin aceptación se deniega la solicitud de recomendaciones (HTTP 403, sin llamada al LLM), pero la meta que no requiere evidencia se guarda igual. El desglose manual está disponible también para quien aceptó la IA (RF-META-036). **[Supuesto S-46]** |
| BR-036 | Archivos de evidencia: eliminación y limpieza | El archivo físico de una evidencia vive y muere con su registro: se elimina del almacén cuando se elimina la evidencia, por la eliminación de su meta (RF-META-002c) o de su cuenta (RF-ADM-010), y el borrado cubre el 100 % de los archivos (RF-EVID-017). Si el borrado de un archivo falla, no se revierte la eliminación del registro: el fallo queda en el log y una limpieza programada, que se ejecuta al menos una vez cada 24 horas, elimina todo archivo del almacén que no tenga registro de evidencia (RF-EVID-018). Nunca se elimina un archivo que tenga registro ni uno sin registro con 1 hora o menos de antigüedad, porque puede ser una carga cuyo registro aún no se confirma. La antigüedad es el tiempo transcurrido desde que el archivo se escribió en el almacén, medido con el reloj del servidor, y no su fecha de modificación, que puede reiniciarse al copiarlo; el valor de 1 hora es el valor por defecto de un parámetro de configuración del despliegue, que puede aumentarse (por ejemplo a 24 horas) sin cambiar el modelo ni el procedimiento **[Supuesto S-55]**. **[Supuesto S-53]** |


### 3.6.1 Tablas de apoyo: tiempo y puntaje de una submeta

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


## 3.7 Casos de Uso (CU)

El modelado está en docs/02-design/: el diagrama de casos de uso docs/02-design/uml/use-cases/use-cases.puml (34 CU; actores humanos y técnicos; niveles de administrador por herencia soporte, moderador y super, sin generalización entre administrador y usuario; CU-025 y CU-032 como extensiones de CU-005 y CU-031 como extensión de CU-017); los 34 diagramas de actividades docs/02-design/uml/activities/CU-0NN-*.puml, uno por caso de uso; el modelo entidad-relación (docs/02-design/database/erd.puml), el modelo relacional (docs/02-design/database/relational.puml) y el modelo de dominio (docs/02-design/uml/domain-model/domain-model.puml); el diccionario de datos (docs/02-design/database/data-dictionary.xlsx); y el script SQL (database/schema.sql), fuente de verdad del esquema. *Diagrama vigente en docs/02-design/uml/use-cases/use-cases.puml.* En todo el documento los actores se nombran 'Usuario (cliente)' y 'Administrador'.


#### CU-001: Registrar Usuario

- **ID:** CU-001
- **Nombre:** Registrar Usuario
- **Actor(es):** Visitante
- **Precondiciones:** Conexión a internet y navegador; el correo no está registrado.
- **Flujo Básico:**
  1. El visitante accede a la vista de registro.
  2. El visitante ingresa nombre, correo electrónico y contraseña, y marca la declaración 'Declaro ser mayor de 18 años' (RF-AUT-017).
  3. El sistema valida el formato de los datos, la política de contraseña (RF-AUT-011) y que la declaración de mayoría de edad esté marcada (RF-AUT-017).
  4. El sistema valida que el correo no esté registrado (RF-AUT-002).
  5. El sistema asigna la zona horaria que informa el navegador, o America/Bogota si no la informa o no es válida (RF-AUT-015), y crea la cuenta con rol cliente, la contraseña cifrada y el sello de tiempo de la declaración de mayoría de edad (RF-AUT-001, RF-AUT-013, RF-AUT-017, RNF-005).
  6. El sistema confirma el registro y redirige al inicio de sesión.
- **Flujos Alternos:**
  - 2a. Datos incompletos, correo mal formado o contraseña que no cumple la política: el sistema responde HTTP 422 con el campo y no crea la cuenta.
  - 2b. Sin la declaración 'Declaro ser mayor de 18 años' (ausente o con valor falso): el sistema responde HTTP 422 con el motivo MAYORIA_EDAD_REQUERIDA y no crea la cuenta (RF-AUT-017).
  - 4a. El correo ya existe: el sistema responde HTTP 409 y no crea la cuenta.
  - 5a. El navegador no informa zona horaria o informa un valor que no es una zona IANA válida: se asigna America/Bogota.
- **Postcondiciones:** Existe una cuenta de rol cliente con preferencias por defecto y con el sello de tiempo de la declaración de mayoría de edad; el usuario puede iniciar sesión.
- **RF y HU relacionadas:** RF-AUT-001, RF-AUT-002, RF-AUT-011, RF-AUT-013, RF-AUT-015, RF-AUT-017 | HU-AUT-001, HU-PER-006


#### CU-002: Iniciar Sesión

- **ID:** CU-002
- **Nombre:** Iniciar Sesión
- **Actor(es):** Visitante
- **Precondiciones:** Cuenta registrada; navegador web.
- **Flujo Básico:**
  1. El visitante ingresa correo y contraseña.
  2. El sistema verifica que la cuenta no esté bloqueada (BR-012).
  3. El sistema valida las credenciales (RF-AUT-003).
  4. El sistema reinicia el contador de intentos fallidos (RF-AUT-012).
  5. El sistema emite un token JWT firmado con expiración de 60 min (RF-AUT-003).
  6. El sistema almacena el token en el cliente y muestra el inicio (CU-024) para clientes o el panel de administración para administradores.
  7. En cada petición posterior el sistema valida el token (RF-AUT-004).
- **Flujos Alternos:**
  - 3a. Credenciales inválidas: HTTP 401 sin token, el contador de intentos aumenta en 1.
  - 3b. Quinto intento fallido consecutivo: HTTP 401, el sistema bloquea la cuenta 15 min (RF-AUT-014) y envía un correo al titular (RF-AUT-009).
  - 2a. Bloqueo temporal vigente: HTTP 429 con Retry-After, sin validar credenciales.
  - 2b. Cuenta bloqueada por un administrador: HTTP 403 y aviso.
  - 5a. Primer inicio de sesión exitoso de una cuenta cliente creada por un administrador o convertida desde administrador: el sistema sustituye America/Bogota por la zona que informa el navegador, si es válida, y no la vuelve a sobrescribir en los inicios siguientes (RF-AUT-016).
  - 5b. Primer inicio de sesión exitoso de una cuenta cliente que aún no declaró ser mayor de 18 años (creada por un administrador o convertida desde administrador): el sistema informa que la declaración está pendiente; las funciones de cliente responden HTTP 403 con el motivo MAYORIA_EDAD_REQUERIDA hasta que el usuario declare 'Declaro ser mayor de 18 años' y el sistema guarde el sello de tiempo (RF-AUT-018); en los inicios siguientes no se vuelve a pedir **[SUPUESTO S-R9]**.
- **Postcondiciones:** El usuario tiene sesión activa; el token protege sus peticiones.
- **RF y HU relacionadas:** RF-AUT-003, RF-AUT-004, RF-AUT-009, RF-AUT-012, RF-AUT-014, RF-AUT-016, RF-AUT-018 | HU-AUT-002, HU-AUT-005, HU-PER-006, HU-ADM-001


#### CU-003: Recuperar Contraseña

- **ID:** CU-003
- **Nombre:** Recuperar Contraseña
- **Actor(es):** Visitante, Servicio de correo
- **Precondiciones:** Ninguna (no requiere sesión).
- **Flujo Básico:**
  1. El visitante solicita la recuperación ingresando su correo (RF-AUT-006).
  2. El sistema responde con un mensaje genérico idéntico para cualquier correo.
  3. Si el correo está registrado, el sistema genera un código de 6 dígitos con vigencia de 10 min y lo envía por correo (RF-AUT-007, RF-AUT-010).
  4. El visitante ingresa el código y una nueva contraseña.
  5. El sistema valida el código y la política de contraseña (RF-AUT-011) y actualiza la contraseña (RF-AUT-008).
  6. El sistema marca el código como usado y el visitante inicia sesión con la nueva contraseña.
- **Flujos Alternos:**
  - 3a. Correo inexistente: no se envía código; el mensaje al visitante es el mismo.
  - 5a. Código inválido, usado o expirado: HTTP 422 y se solicita uno nuevo.
  - 5b. Contraseña que no cumple la política: HTTP 422 sin cambios; el código sigue vigente.
- **Postcondiciones:** La contraseña queda actualizada y cifrada; el código queda inutilizable.
- **RF y HU relacionadas:** RF-AUT-006, RF-AUT-007, RF-AUT-008, RF-AUT-010, RF-AUT-011 | HU-AUT-003


#### CU-004: Cerrar Sesión

- **ID:** CU-004
- **Nombre:** Cerrar Sesión
- **Actor(es):** Usuario (cliente) o Administrador
- **Precondiciones:** Sesión activa con token vigente.
- **Flujo Básico:**
  1. El usuario solicita cerrar sesión.
  2. El sistema revoca el token (RF-AUT-005).
  3. El sistema redirige al inicio de sesión.
- **Flujos Alternos:**
  - 2a. El token ya expiró: el sistema trata la sesión como cerrada y redirige al inicio de sesión.
- **Postcondiciones:** Token revocado; peticiones posteriores con ese token reciben HTTP 401.
- **RF y HU relacionadas:** RF-AUT-005 | HU-AUT-004


#### CU-005: Crear Meta

- **ID:** CU-005
- **Nombre:** Crear Meta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa con rol cliente. **[Supuesto S-46]**
- **Flujo Básico:**
  1. El usuario accede a la creación de metas.
  2. El usuario captura nombre, categoría, tiempo total en horas, horario diario (la hora de fin puede ser 24:00), si requiere evidencia, modo de inicio y descripción opcional (RF-META-001, RF-META-015, RF-META-021).
  3. El usuario elige las fechas de trabajo (RF-META-016); en una meta de más de 1 día elige además el desglose por IA o el desglose manual (RF-META-033, RF-META-036).
  4. El sistema valida el horario (RF-META-005), fechas no pasadas (RF-META-029), el límite de 24 h por día (RF-META-010), la capacidad del horario (RF-META-020), que el tiempo total sea mayor o igual que los días destinados y que estos quepan en el rango de fechas (BR-014 (10) y (11), RF-META-003) y clasifica el tipo (RF-META-019).
  5. Si el tiempo total dividido entre los días destinados es mayor a 12 h, el flujo continúa en CU-007 (recomendaciones, RF-META-008) antes de guardar. La recomendación es informativa y nunca impide guardar la meta: si el usuario no ha aceptado el servicio externo de IA, no se invoca la IA y la meta se guarda igual (alterno 5b).
  6. El sistema guarda la meta. Si es de 1 día, crea su submeta única, que empieza en la hora de inicio del horario y dura el tiempo total (RF-META-004, RF-META-031); si es de más de 1 día con desglose por IA, continúa en CU-006, y con desglose manual guarda las submetas definidas en CU-032.
  7. El sistema muestra la meta en la agenda.
- **Flujos Alternos:**
  - 2a. El usuario indica solo el número de días y un rango de fechas: continúa en CU-025 (RF-META-017, RF-META-032).
  - 4a. Más de 24 h por día: HTTP 422 con el mínimo de días requerido (BR-011).
  - 4b. El horario diario no alcanza para el tiempo total: HTTP 422 con la capacidad y el horario mínimo (RF-META-020).
  - 4c. Fecha de trabajo anterior a hoy, hora de fin igual o anterior a la de inicio o posterior a 24:00, o parámetro obligatorio ausente: HTTP 422 indicando el campo.
  - 4d. Meta multidía con tiempo total menor que los días destinados (por ejemplo 2 h en 3 días, porque cada submeta dura al menos 1 h), o con más días destinados que días en el rango de fechas: HTTP 422 indicando el campo y el mínimo requerido; la meta se rechaza al crearla, antes de guardarla (BR-014 (10) y (11), RF-META-003).
  - 5a. La meta requiere evidencia o necesita la IA para el desglose (CU-006) o las fechas sugeridas (CU-025) y el usuario no ha aceptado el servicio externo de IA: el sistema muestra el aviso y registra la aceptación antes de continuar (RF-IA-007). Si el usuario lo rechaza se aplican RF-IA-010 y RF-IA-011 (BR-035): se guarda una meta que no requiere evidencia, de 1 día o multidía con desglose manual (CU-032), sin recomendaciones aunque supere 12 h por día; una meta que requiere evidencia, con desglose automático o con fechas sugeridas se rechaza con HTTP 403 y el aviso, y no se llama al LLM.
  - 5b. La meta no requiere evidencia, su promedio diario supera 12 h (CU-007) y el usuario no ha aceptado el servicio externo de IA: la recomendación es solo informativa y nunca bloquea guardar la meta (RF-META-008, BR-015). El sistema puede mostrar el aviso (RF-IA-007) para ofrecer las recomendaciones: si el usuario lo acepta, el flujo continúa en CU-007; si no lo acepta o lo rechaza, no se invoca la IA (la solicitud de recomendaciones responde HTTP 403 con el aviso de consentimiento y se registran 0 llamadas al LLM, RF-IA-011) y la meta se guarda igual, sin recomendaciones: de 1 día, con su submeta única, o multidía con desglose manual (CU-032).
  - 6a. Meta de más de 1 día con desglose por IA: tras guardar la meta, sin submetas, el cliente solicita el desglose y el flujo continúa en CU-006 (operación síncrona, RF-META-003).
  - 1a. Una cuenta con rol administrador intenta crear una meta: HTTP 403 (RF-ADM-006).
  - 6b. Meta de más de 1 día con desglose manual: antes de guardar, el sistema ejecuta CU-032 para definir y validar las submetas (RF-META-033 a RF-META-035).
- **Postcondiciones:** La meta queda persistida y visible en la agenda; las submetas existen o están pendientes de desglose.
- **RF y HU relacionadas:** RF-META-001, RF-META-003, RF-META-004, RF-META-005, RF-META-010, RF-META-015, RF-META-016, RF-META-019, RF-META-020, RF-META-021, RF-META-029, RF-META-031, RF-ADM-006, RF-IA-007, RF-IA-010, RF-META-033, RF-META-036, RF-IA-011 | HU-META-001, HU-META-002, HU-META-007, HU-META-009, HU-META-010, HU-META-012, HU-ADM-006, HU-IA-002, HU-IA-004, HU-META-014, HU-META-015


#### CU-006: Desglosar Meta con IA (duración mayor a 1 día)

- **ID:** CU-006
- **Nombre:** Desglosar Meta con IA (duración mayor a 1 día)
- **Actor(es):** Usuario (cliente), Motor LLM
- **Precondiciones:** Meta guardada con más de 1 día destinado y fechas de trabajo definidas; recomendaciones del CU-007 decididas, si aplicaban. El cliente solicita el desglose después de guardar la meta.
- **Flujo Básico:**
  1. El cliente solicita el desglose y espera la respuesta (operación síncrona, hasta ~60 s, RNF-015); el sistema verifica la aceptación del servicio externo de IA (RF-IA-007) e invoca al Agente IA a través de la interfaz de proveedor con la descripción, el tiempo total, las fechas y el horario (RF-META-003, RF-META-022, RF-IA-001).
  2. El Agente IA distribuye el tiempo total entre las fechas de trabajo en horas enteras, mínimo 1 h por submeta, y calcula el horario de cada submeta, que fija su tiempo estipulado (BR-032); la respuesta se valida contra el esquema, incluida la duración entera de 1 h o más (RF-IA-002), y contra el horario diario (RF-META-005).
  3. El Agente IA genera una descripción para cada submeta (RF-META-007) y consejos generales (RF-META-011); las recomendaciones de descanso aceptadas en CU-007 se conservan con los consejos (RF-META-023).
  4. El sistema guarda las submetas vinculadas a la meta (RF-META-005) y registra un uso del LLM por cada llamada, incluidos los reintentos (RF-ADM-007).
  5. El usuario visualiza las submetas y los consejos en su agenda.
- **Flujos Alternos:**
  - 2a. Timeout o error transitorio: el sistema reintenta hasta 2 veces (RF-IA-003, RF-IA-004).
  - 2b. Respuesta fuera del esquema, con una duración de 0 h, negativa o no entera, o con una suma de duraciones distinta del tiempo total: se trata como error.
  - 2c. Persisten los errores o la IA no está disponible: la meta, ya guardada, se conserva sin submetas, se informa al usuario en la misma respuesta y se le ofrece reintentar el desglose o armarlo manualmente (CU-032, RF-META-024, RF-META-033).
  - 1a. El usuario no ha aceptado o rechaza el servicio externo de IA: el sistema no invoca al Agente IA y no hay desglose automático (HTTP 403 con el aviso, RF-IA-011); si la meta no requiere evidencia se ofrece el desglose manual (CU-032, RF-META-033); si la requiere, no se guarda.
- **Postcondiciones:** Las submetas diarias existen con horario y descripción; los consejos quedan asociados a la meta.
- **RF y HU relacionadas:** RF-META-003, RF-META-005, RF-META-007, RF-META-011, RF-META-022, RF-META-023, RF-META-024, RF-IA-001, RF-IA-002, RF-IA-003, RF-IA-004, RF-IA-007, RF-ADM-007, RF-IA-010, RF-IA-011, RF-META-033 | HU-META-002, HU-META-012, HU-META-013, HU-IA-001, HU-IA-002, HU-ADM-007, HU-IA-004


#### CU-007: Obtener Recomendaciones IA (promedio diario mayor a 12 h)

- **ID:** CU-007
- **Nombre:** Obtener Recomendaciones IA (promedio diario mayor a 12 h)
- **Actor(es):** Usuario (cliente), Motor LLM
- **Precondiciones:** Meta configurada cuyo tiempo total dividido entre los días destinados es mayor a 12 h y menor o igual a 24 h (de 1 día o multidía); aún no persistida.
- **Flujo Básico:**
  1. El sistema verifica la aceptación del servicio externo de IA (RF-IA-007), detecta la condición (BR-015) e invoca al Agente IA (RF-META-008).
  2. El Agente IA entrega recomendaciones de hábitos saludables, descanso y una mejor división del tiempo (RF-META-023 en metas multidía).
  3. El sistema presenta las sugerencias al usuario.
  4. El usuario acepta, modifica o rechaza las sugerencias (RF-META-009).
  5. El sistema persiste la decisión con su fecha-hora (RF-META-014) y guarda la meta según la decisión del usuario: con su submeta única si es de 1 día (RF-META-031) o continuando en CU-006 (desglose por IA) o en CU-032 (desglose manual) si es multidía; las recomendaciones de descanso aceptadas se conservan con los consejos (RF-META-023).
- **Flujos Alternos:**
  - 4a. El usuario rechaza: la meta se guarda con sus parámetros originales y la decisión queda como rechazada.
  - 1a. El LLM no responde tras los reintentos: el sistema informa 'recomendaciones no disponibles' y permite guardar la meta de 1 día sin recomendaciones (RF-META-030); en una meta multidía el desglose por IA sigue RF-META-024 y se ofrece siempre el desglose manual (CU-032, RF-META-033).
  - 1b. El usuario no acepta el servicio externo de IA: una meta que no requiere evidencia se guarda sin recomendaciones aunque su promedio supere 12 h por día (de 1 día, o multidía con desglose manual, CU-032): la recomendación es informativa y nunca impide guardar la meta, y la solicitud de recomendaciones responde HTTP 403 con el aviso de consentimiento y no llama al LLM (RF-IA-011); una que requiere evidencia no se guarda (HTTP 403 con el aviso, RF-IA-010, RF-IA-011, BR-035).
- **Postcondiciones:** La meta queda configurada según la decisión del usuario (última palabra del usuario).
- **RF y HU relacionadas:** RF-META-008, RF-META-009, RF-META-014, RF-META-023, RF-META-030, RF-META-031, RF-IA-007, RF-IA-010, RF-IA-011, RF-META-033 | HU-META-003, HU-META-013, HU-ADM-008, HU-IA-002, HU-IA-004


#### CU-008a: Editar Meta

- **ID:** CU-008a
- **Nombre:** Editar Meta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Meta existente propia del usuario.
- **Flujo Básico:**
  1. El usuario selecciona editar una meta.
  2. El usuario modifica los parámetros.
  3. El sistema valida y guarda los cambios (RF-META-002b).
  4. Si cambian días, tiempo total, fechas u horario, el sistema regenera las submetas (RF-META-027) derivando a CU-006 o CU-007 si aplica, o a CU-032 si la meta tiene desglose manual (el usuario define las submetas nuevas en la misma edición).
- **Flujos Alternos:**
  - 3a. Datos inválidos: el sistema rechaza los cambios y muestra los errores de validación.
  - 3b. La meta tiene alguna submeta iniciada y se intenta modificar días, tiempo total, fechas u horario: HTTP 409 (RF-META-028).
  - 3c. Se intenta cambiar el modo de inicio o el requisito de evidencia de una meta con alguna submeta iniciada: HTTP 409 (RF-META-028) **[Supuesto S-51]**.
  - 3d. El usuario no ha aceptado el servicio externo de IA y la edición exigiría IA (activar el requisito de evidencia, pasar a multidía con desglose por IA, pedir recomendaciones o fechas sugeridas): HTTP 403 con el aviso de consentimiento, 0 llamadas al LLM y la meta no cambia (RF-META-037, RF-IA-011, BR-035) **[Supuesto S-51]**.
  - 4a. Meta con desglose manual cuyas submetas nuevas no cumplen la suma o el horario: HTTP 422 y la meta no cambia (RF-META-034, RF-META-035).
  - 3e. Se pasa la meta a multidía sin entregar un desglose manual válido ni pedir el de IA: HTTP 422 indicando el campo y la meta no cambia (RF-META-037).
- **Postcondiciones:** La meta queda actualizada; si aplica, sus submetas se regeneran.
- **RF y HU relacionadas:** RF-META-002b, RF-META-027, RF-META-028, RF-META-037, RF-META-034, RF-META-035 | HU-META-004a


#### CU-008b: Eliminar Meta

- **ID:** CU-008b
- **Nombre:** Eliminar Meta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Meta existente propia del usuario.
- **Flujo Básico:**
  1. El usuario selecciona eliminar una meta.
  2. El sistema solicita confirmación de eliminación.
  3. El usuario confirma la eliminación y el cliente envía la confirmación explícita (confirmar=true).
  4. El sistema elimina la meta, sus submetas, evidencias y evaluaciones y los archivos de las evidencias del almacén (RF-META-002c, RF-EVID-017); los registros de uso del LLM de la meta se conservan sin vínculo con ella **[Supuesto S-53]**.
- **Flujos Alternos:**
  - 3a. El usuario cancela: no se elimina nada.
  - 3b. La solicitud llega sin la confirmación explícita (confirmar=true): HTTP 422 y no se elimina nada (RF-META-002c).
  - 4a. El borrado de un archivo falla: la eliminación de la meta se completa, el fallo queda en el log y la limpieza programada (CU-033) elimina el archivo (RF-EVID-018) **[Supuesto S-53]**.
- **Postcondiciones:** La meta y sus dependientes quedan eliminadas; el puntaje del perfil no cambia.
- **RF y HU relacionadas:** RF-META-002c, RF-EVID-017, RF-EVID-018 | HU-META-004b, HU-EVID-006


#### CU-009: Iniciar Submeta (Reloj Global)

- **ID:** CU-009
- **Nombre:** Iniciar Submeta (Reloj Global)
- **Actor(es):** Usuario (cliente), Sistema (modo automático)
- **Precondiciones:** Submeta pendiente programada para la fecha.
- **Flujo Básico:**
  1. En modo manual: el usuario inicia la submeta; el sistema registra la hora real y arranca el reloj, que dura el tiempo estipulado de la submeta (RF-META-012, BR-032).
  2. En modo automático: el sistema inicia el reloj a la hora programada en la zona horaria del usuario (RF-META-013).
  3. El sistema cambia el estado de la submeta a en curso.
  4. Si el inicio fue manual, el sistema registra el día activo, la hora de la primera submeta iniciada a mano del día y el contador diario (RF-PER-002, RF-PER-005, RF-PER-006); el inicio automático no registra ningún día activo (BR-009).
  5. El sistema evalúa los logros aplicables (CU-026).
- **Flujos Alternos:**
  - 1a. Inicio manual a cualquier hora de su fecha programada, de 00:00:00 a 23:59:59, antes o después de su horario programado: el reloj corre desde el inicio real durante la duración programada (BR-006, BR-027).
  - 2a. El sistema estuvo caído a la hora programada: al recuperarse inicia la submeta con la hora programada como inicio si no venció su tiempo (RF-META-025).
  - 1b. La submeta manual no se inició durante su fecha programada (hasta las 23:59:59): el sistema la cierra como finalizada, sin gracia, con 0 puntos si la meta requiere evidencia o sin calificación si no la requiere (RF-META-026).
  - 1c. Una cuenta administrador intenta iniciar una submeta: HTTP 403 (RF-ADM-006).
  - 1d. El usuario intenta iniciar a mano una submeta antes de su fecha programada (en su zona horaria), o una submeta que ya está en curso o finalizada, incluida la cerrada por no inicio: HTTP 409 y la submeta no cambia (BR-027, RF-META-012).
- **Postcondiciones:** El reloj global está corriendo y la submeta está en curso, o la submeta vencida quedó finalizada con 0.
- **RF y HU relacionadas:** RF-META-012, RF-META-013, RF-META-025, RF-META-026, RF-PER-002, RF-PER-005, RF-PER-006 | HU-META-005, HU-PER-002, HU-PER-004


#### CU-010: Consultar Agenda

- **ID:** CU-010
- **Nombre:** Consultar Agenda
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El usuario consulta la agenda (RF-AGEN-001).
  2. El sistema muestra metas y submetas agrupadas por fecha en la zona horaria del usuario.
  3. Las submetas de una misma meta comparten color (RF-AGEN-002).
  4. Cada submeta muestra su estado con color y texto (RF-AGEN-003, BR-031).
- **Flujos Alternos:**
  - 1a. Sin datos en el rango: se muestra la agenda vacía.
- **Postcondiciones:** El usuario visualiza su agenda con colores por meta y por estado.
- **RF y HU relacionadas:** RF-AGEN-001, RF-AGEN-002, RF-AGEN-003 | HU-AGEN-001, HU-AGEN-002


#### CU-011: Consultar Detalle de Submeta

- **ID:** CU-011
- **Nombre:** Consultar Detalle de Submeta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Submeta existente propia.
- **Flujo Básico:**
  1. El usuario selecciona una submeta en la agenda.
  2. El sistema muestra horario, estado, puntaje, evidencias y estado de evaluación (RF-AGEN-004).
  3. Si la submeta está en curso, muestra la ventana vigente y su cuenta regresiva (RF-AGEN-006).
  4. Si la submeta está abierta, muestra el puntaje como provisional (RF-PUNT-012).
- **Flujos Alternos:**
  - 2a. Submeta sin puntaje: se muestra 'sin calificación' si la meta no requiere evidencia, o sin valor si aún no hay evidencias.
- **Postcondiciones:** El usuario ve el detalle de la submeta.
- **RF y HU relacionadas:** RF-AGEN-004, RF-AGEN-006, RF-PUNT-012 | HU-AGEN-002, HU-AGEN-003, HU-PUNT-004


#### CU-012: Usar Sesión Pomodoro

- **ID:** CU-012
- **Nombre:** Usar Sesión Pomodoro
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El usuario abre el temporizador Pomodoro.
  2. El usuario inicia la sesión en el temporizador del navegador (RF-POM-001), que no crea ningún registro en el servidor, y, si quiere, la vincula a una submeta en curso (RF-POM-003).
  3. El usuario pausa (RF-POM-004) y reanuda (RF-POM-005) libremente.
  4. El usuario finaliza la sesión (RF-POM-007).
  5. Al finalizar o abandonar, el cliente envía la sesión y el sistema la guarda con su duración efectiva (RF-POM-002), siempre que sea de al menos 1 minuto.
- **Flujos Alternos:**
  - 4a. El usuario abandona la sesión: se registra como abandonada, sin penalización (RF-POM-006, BR-007).
  - 4b. La sesión finalizada o abandonada dura menos de 1 minuto efectivo: no se guarda; el cliente no la envía y, si llega, el servidor responde HTTP 422 (RF-POM-002).
- **Postcondiciones:** La sesión Pomodoro queda persistida y la submeta vinculada no se ve afectada.
- **RF y HU relacionadas:** RF-POM-001, RF-POM-002, RF-POM-003, RF-POM-004, RF-POM-005, RF-POM-006, RF-POM-007 | HU-POM-001, HU-POM-002


#### CU-013: Cargar Evidencia (post-80 %, primer o segundo envío)

- **ID:** CU-013
- **Nombre:** Cargar Evidencia (post-80 %, primer o segundo envío)
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Submeta en curso de una meta que requiere evidencia; al menos el 80 % del tiempo estipulado transcurrido; menos de 2 envíos hechos; si existe un primer envío, con dictamen Incoherente o Inválida.
- **Flujo Básico:**
  1. El usuario intenta cargar la evidencia (primer o segundo envío).
  2. El frontend habilita la carga solo desde el 80 % del tiempo estipulado, en ambos envíos (RF-EVID-001, BR-001).
  3. Si el usuario aún no ha aceptado el servicio externo de IA, el sistema muestra el aviso y registra la aceptación (RF-IA-007).
  4. El backend valida propiedad, requerimiento de evidencia, 80 % del tiempo, ventana de tiempo, máximo de envíos, estado del primer envío cuando es el segundo, formato, tamaño y que el archivo no esté vacío, corrupto ni ilegible, y lo convierte cuando corresponde (RF-EVID-002, RF-EVID-003, RF-EVID-004, RF-EVID-012, RF-EVID-013, RF-EVID-014, RF-EVID-015, RF-EVID-016, RF-IA-005, RF-IA-012, RNF-022).
  5. El sistema calcula el porcentaje de tiempo transcurrido y la ventana con el instante de recepción, la hora de inicio real y el tiempo estipulado (RF-EVID-010, BR-001), persiste la evidencia con el número de envío y esa ventana, que son siempre los calculados por el servidor aunque el cliente haya declarado otros solo como dato informativo, registra el día activo (RF-PER-002, BR-009) y responde HTTP 202.
  6. El flujo continúa en CU-014.
- **Flujos Alternos:**
  - 4a. Por debajo del 80 %: HTTP 409, no persiste.
  - 4b. Formato no permitido o contenido que no coincide con la extensión: HTTP 415, no persiste y no consume envío (RF-EVID-003, RF-IA-012).
  - 4c. Archivo mayor a 25 MB (26 214 400 bytes): HTTP 413.
  - 4d. Tercer envío: HTTP 409.
  - 4e. Posterior al fin del tiempo de gracia: HTTP 409.
  - 4f. Meta que no requiere evidencia: HTTP 409.
  - 4g. Submeta ajena: HTTP 404.
  - 4h. Segundo envío con el primero En evaluación, en Error o dictaminado Excelente: HTTP 409 (RF-EVID-016).
  - 4i. Archivo vacío, corrupto o ilegible al prepararlo, o que no se puede convertir (.gif, .docx, .doc, .xlsx, .xls): HTTP 422, no persiste, no crea evaluación ni dictamen, no consume envío, no registra día activo y no llama al LLM; el usuario puede subir otro archivo (RF-IA-012).
  - 4j. El porcentaje de tiempo transcurrido o la ventana declarados por el cliente (solo informativos) no coinciden con los que calcula el servidor con el instante de recepción, la hora de inicio real y el tiempo estipulado (tolerancia de 1 s de T): HTTP 409 y no persiste (RF-EVID-010, BR-001).
  - 3a. El usuario rechaza el aviso: HTTP 403 con el aviso de consentimiento, la evidencia no se persiste, no se llama al LLM y el envío no se consume (RF-IA-011, BR-035); el usuario puede aceptar más tarde y cargar entonces la evidencia, y mientras tanto sigue usando la aplicación con metas sin evidencia (RF-IA-010).
- **Postcondiciones:** La evidencia queda registrada y pasa a evaluación (CU-014).
- **RF y HU relacionadas:** RF-EVID-001, RF-EVID-002, RF-EVID-003, RF-EVID-004, RF-EVID-010, RF-EVID-012, RF-EVID-013, RF-EVID-014, RF-EVID-015, RF-EVID-016, RF-IA-005, RF-IA-007, RF-IA-010, RF-IA-011, RF-IA-012, RF-PER-002 | HU-EVID-001, HU-EVID-002, HU-EVID-004, HU-IA-002, HU-IA-004, HU-PER-002


#### CU-014: Evaluar Evidencia con LLM (asíncrono)

- **ID:** CU-014
- **Nombre:** Evaluar Evidencia con LLM (asíncrono)
- **Actor(es):** Sistema, Motor LLM
- **Precondiciones:** Evidencia persistida, con el archivo ya validado y preparado de forma síncrona en la carga (CU-013, RF-IA-005, RF-IA-012).
- **Flujo Básico:**
  1. El sistema toma el contenido preparado en la carga según el formato, ya convertido cuando corresponde (RF-EVID-003, RF-IA-005, RF-IA-012), que no se persiste, y arma la solicitud con el contexto de la meta y sin datos personales: sin nombre, correo, id del usuario ni nombre original del archivo, y con las imágenes sin metadatos EXIF y con la resolución mínima útil (RF-IA-005, RF-IA-006, RF-IA-008).
  2. El sistema crea la evaluación en En evaluación y envía la solicitud de forma asíncrona (RF-EVID-005, RF-EVID-006).
  3. El Motor LLM responde dentro del timeout con dictamen Excelente, Incoherente o Inválida y justificación en el esquema acordado (RF-IA-002, RF-IA-003).
  4. El sistema registra la evaluación como Evaluada y guarda un registro de uso del LLM por cada llamada realizada, incluidos los reintentos, con proveedor, modelo y resultado (RF-EVID-006, RF-ADM-007, RF-IA-009).
  5. El sistema completa la evaluación aunque el plazo haya expirado durante el proceso (RF-EVID-011).
  6. El flujo continúa en CU-016.
- **Flujos Alternos:**
  - 3a. Timeout, error 5xx, cuota agotada o respuesta fuera del esquema: tras los reintentos automáticos (RF-IA-004) la evaluación pasa a Error y el usuario puede reintentar (CU-023); un Error es un fallo técnico y no puntúa.
  - 3b. El LLM dictamina Inválida (contenido legible sin relación con la submeta o de otro tema): la evaluación queda Evaluada con 0 puntos y el envío queda consumido; no es un Error y no admite Reintentar (RF-EVID-006, BR-005).
  - 1a. Un archivo vacío, corrupto, ilegible, que no se puede convertir o de formato no soportado no llega a este caso de uso: se rechaza en la carga, sin evaluación ni dictamen (CU-013, RF-IA-012).
- **Postcondiciones:** La evidencia tiene evaluación con dictamen, o queda en Error con opción de reintento; se notifica al usuario (CU-028).
- **RF y HU relacionadas:** RF-EVID-005, RF-EVID-006, RF-EVID-011, RF-IA-001, RF-IA-002, RF-IA-003, RF-IA-004, RF-IA-005, RF-IA-006, RF-IA-008, RF-IA-009, RF-ADM-007, RF-IA-012 | HU-EVID-003, HU-EVID-005, HU-IA-001, HU-IA-002, HU-IA-003, HU-ADM-007


#### CU-015: Rectificar Evidencia (segundo envío)

- **ID:** CU-015
- **Nombre:** Rectificar Evidencia (segundo envío)
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Primer envío con dictamen Incoherente o Inválida y fin del tiempo de gracia no alcanzado; segundo envío no usado.
- **Flujo Básico:**
  1. El sistema habilita el segundo envío desde el dictamen Incoherente o Inválida del primer envío, aunque no se haya llegado al 100 % del tiempo, y hasta el fin del tiempo de gracia (RF-EVID-007, BR-002).
  2. El tiempo de gracia equivale al 10 % del tiempo estipulado desde el fin del 100 % (RF-PUNT-007).
  3. El usuario envía la segunda evidencia (CU-013, segundo envío); el sistema registra la ventana de recepción (RF-EVID-010) y la puntúa con la mitad de la tabla del periodo inicial, sea cual sea la ventana (RF-PUNT-005).
  4. La evidencia pasa a evaluación (CU-014) y su dictamen cierra la submeta (CU-016, RF-PUNT-013).
- **Flujos Alternos:**
  - 3a. El usuario no envía antes de expirar el tiempo de gracia: la submeta cierra con lo acumulado (RF-PUNT-006).
  - 3b. El usuario intenta un tercer envío: HTTP 409 (RF-EVID-012).
  - 3c. El primer envío se hizo en el tiempo de gracia (primer envío tardío de CU-013): el segundo envío solo se admite dentro de la gracia restante y también vale la mitad (BR-002 e).
- **Postcondiciones:** La submeta queda con la rectificación evaluada o cerrada por expiración.
- **RF y HU relacionadas:** RF-EVID-007, RF-EVID-012, RF-EVID-016, RF-PUNT-005, RF-PUNT-007 | HU-EVID-004, HU-PUNT-002, HU-PUNT-003


#### CU-016: Asignar Puntuación y Cerrar Submeta

- **ID:** CU-016
- **Nombre:** Asignar Puntuación y Cerrar Submeta
- **Actor(es):** Sistema
- **Precondiciones:** Evaluación completada, tiempo de gracia expirado, tiempo estipulado vencido de una meta sin evidencia, submeta manual vencida sin iniciar, o cierre administrativo por Error persistente (CU-030).
- **Flujo Básico:**
  1. El sistema determina el número de envío (primero o segundo), la ventana de recepción y el dictamen de la evidencia evaluada (BR-004, BR-016).
  2. El sistema asigna los puntos de la evidencia según la tabla de 3.6.1 (primer envío según su ventana; segundo envío, la mitad de la tabla del periodo inicial; RF-PUNT-002, RF-PUNT-005) y calcula el puntaje de la submeta como la suma, con tope de 90 si hubo dos envíos (RF-PUNT-004, RF-PUNT-010).
  3. Si la submeta puede cerrarse (BR-018, RF-PUNT-013), la finaliza y, en la misma transacción, suma su puntaje final al acumulado del usuario (RF-PUNT-008, RF-PUNT-014, RNF-002).
  4. El sistema no registra ningún día activo en el cierre: el día activo lo registró el envío de la evidencia (CU-013, RF-PER-002, BR-009); evalúa los logros aplicables, incluidos Impecable y la racha perfecta (CU-026, BR-033).
- **Flujos Alternos:**
  - 1a. Primer envío Excelente en el periodo inicial: 100 puntos y cierre inmediato (RF-PUNT-001).
  - 1b. Primer envío Incoherente o Inválida: 50 o 0 puntos en el periodo inicial (25 o 0 en gracia); la submeta sigue abierta y se habilita CU-015 (RF-PUNT-002, RF-PUNT-011).
  - 1c. Sin evidencia en el tiempo inicial: 0 provisionales y se abre el tiempo de gracia (RF-PUNT-003).
  - 1d. Dictamen del segundo envío: la submeta se cierra en ese instante con la suma topada en 90 (RF-PUNT-013, RF-PUNT-004).
  - 1e. Expira el tiempo de gracia sin segundo envío y sin evaluaciones pendientes: cierre con lo acumulado (RF-PUNT-006).
  - 1f. Meta sin evidencia al vencer el tiempo: cierre sin calificación y sin puntos (RF-META-006, BR-010).
  - 1g. Submeta manual no iniciada durante su fecha programada (hasta las 23:59:59): cierre con 0 puntos si la meta requiere evidencia, o sin calificación si no la requiere (RF-META-026).
  - 3a. Fallo en la transacción: no se persiste ni el estado ni el puntaje y el cierre se reintenta sin duplicar puntos.
  - 3b. Evaluación en Error o pendiente: la submeta permanece abierta hasta resolverse (RF-PUNT-011).
  - 1h. El dictamen del primer envío (Incoherente o Inválida) llega cuando el tiempo de gracia ya terminó: la submeta se cierra en ese instante con el puntaje de ese envío (RF-PUNT-013, BR-018).
  - 3c. Evaluación en Error durante 48 horas: el cierre es administrativo y con el puntaje provisional (CU-030, RF-ADM-019).
  - 4a. Ningún cierre registra día activo: ni el provocado por el dictamen de una evidencia, ni el de fin de la gracia, el vencimiento de una meta sin evidencia o de una submeta manual no iniciada, ni el cierre administrativo (BR-009).
- **Postcondiciones:** Submeta finalizada con puntaje (o sin calificación); perfil y ranking actualizados.
- **RF y HU relacionadas:** RF-PUNT-001, RF-PUNT-002, RF-PUNT-003, RF-PUNT-004, RF-PUNT-005, RF-PUNT-006, RF-PUNT-008, RF-PUNT-010, RF-PUNT-011, RF-PUNT-013, RF-PUNT-014, RF-META-006, RF-META-026, RF-PER-002 | HU-PUNT-001, HU-PUNT-002, HU-PUNT-003, HU-PUNT-004, HU-META-005, HU-META-008, HU-PER-002


#### CU-017: Consultar Perfil, Racha y Logros

- **ID:** CU-017
- **Nombre:** Consultar Perfil, Racha y Logros
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El usuario abre su perfil.
  2. El sistema muestra nombre, puntaje acumulado, días activos y posición en el ranking (RF-PER-001, RF-PER-004).
  3. El sistema muestra el calendario de actividad de los últimos 12 meses, con los días activos en un único tono de verde (RF-PER-003); el detalle de cada día, su contador y la alternativa textual se consultan en CU-031, que extiende este caso.
  4. El sistema muestra la hora de la primera actividad del día (RF-PER-010), la racha actual, la racha máxima y la racha perfecta (RF-PER-007, RF-PER-009, RF-PER-012).
  5. El sistema muestra los logros obtenidos y los bloqueados (RF-LOGR-003).
  6. El usuario puede acceder al ranking global (RF-RANK-002).
- **Flujos Alternos:**
  - 1a. Sin actividad: calendario sin días verdes y racha 0.
- **Postcondiciones:** El usuario ve su perfil completo.
- **RF y HU relacionadas:** RF-PER-001, RF-PER-003, RF-PER-004, RF-PER-007, RF-PER-009, RF-PER-010, RF-PER-011, RF-PER-012, RF-LOGR-003, RF-RANK-002, RF-PER-013, RF-PER-014, RF-PER-015, RF-PER-016 | HU-PER-001, HU-PER-002, HU-PER-003, HU-PER-004, HU-PER-005, HU-LOGR-002, HU-PER-007


#### CU-018: Ver Ranking Global

- **ID:** CU-018
- **Nombre:** Ver Ranking Global
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El usuario accede al ranking desde su perfil (RF-RANK-002).
  2. El sistema muestra las cuentas elegibles, que son las cuentas con rol cliente no bloqueadas administrativamente (BR-023), ordenadas de mayor a menor puntaje (RF-RANK-001, RF-RANK-005).
  3. El sistema asigna igual posición a los empates y los ordena por nombre (RF-RANK-003).
  4. El sistema muestra solo nombre y puntaje (RF-RANK-004).
  5. El perfil muestra la posición del usuario (RF-PER-004).
- **Flujos Alternos:**
  - 1a. Acceso directo a la vista de ranking sin pasar por el perfil.
  - 2a. Una cuenta cliente bloqueada administrativamente no aparece en este ranking y reaparece al desbloquearse; el ranking de administración (CU-021) sí la lista, marcada (BR-023, RF-RANK-005, RF-ADM-005).
- **Postcondiciones:** El usuario visualiza el ranking global y su posición.
- **RF y HU relacionadas:** RF-RANK-001, RF-RANK-003, RF-RANK-004, RF-RANK-005, RF-PER-004 | HU-RANK-001, HU-RANK-002, HU-PER-003


#### CU-019: Administrar Usuarios

- **ID:** CU-019
- **Nombre:** Administrar Usuarios
- **Actor(es):** Administrador
- **Precondiciones:** Sesión con rol administrador y nivel de acceso suficiente (BR-021); existe al menos un administrador super (RF-ADM-017).
- **Flujo Básico:**
  1. El administrador accede al panel de administración.
  2. El administrador consulta el listado y el detalle de cuentas (RF-ADM-008).
  3. El administrador crea, edita o elimina cuentas según su nivel (BR-021): el moderador y el super crean (RF-ADM-001) y editan (RF-ADM-009) cuentas cliente, que nacen con zona America/Bogota hasta su primer inicio de sesión (RF-ADM-021, RF-AUT-016) y sin declaración de mayoría de edad, que hacen ellas mismas en ese primer inicio (RF-AUT-018) **[SUPUESTO S-R9]**; solo el super crea y edita cuentas administrador, cambia roles y elimina cuentas (RF-ADM-010); la eliminación exige confirmación explícita (confirmar=true; sin ella, HTTP 422) y borra en cascada los datos de la cuenta, incluidos los archivos de sus evidencias (RF-EVID-017).
  4. El administrador super, identificado como actor de la operación, asigna o cambia el nivel de acceso de un administrador (RF-ADM-014); el cambio de rol (RF-ADM-009) también lo ejecuta solo un super identificado (BR-021).
  5. El sistema valida permisos por nivel (RF-ADM-015) y persiste los cambios. Matriz de BR-021 para este caso de uso: consultar cuentas (paso 2) —super, moderador y soporte—; crear y editar cuentas cliente —super y moderador—; crear y editar cuentas administrador, asignar o cambiar niveles, cambiar roles y eliminar cuentas —solo super—; bloquear y desbloquear cuentas cliente (CU-020) —super y moderador—; bloquear y desbloquear cuentas administrador (CU-020) —solo super—.
- **Flujos Alternos:**
  - 2a. Cuenta con rol cliente accede al panel: HTTP 403 (RF-ADM-016).
  - 3a. Nivel insuficiente, incluidos un moderador que intenta crear o editar una cuenta administrador, cambiar un rol o eliminar una cuenta, y un soporte que intenta cualquier modificación: HTTP 403 (RF-ADM-015, BR-021).
  - 3b. Correo duplicado: HTTP 409.
  - 3c. El administrador intenta eliminar su propia cuenta o al último super, o cambiar el rol o el nivel del último super: HTTP 409 (RF-ADM-010, RF-ADM-009, BR-021).
  - 3d. Se intenta asignar un segundo rol a una cuenta: HTTP 422 (RF-ADM-006).
  - 3e. Se intenta cambiar el rol de una cuenta con datos (un cliente con metas, sesiones Pomodoro, logros, días activos o puntaje, o un administrador que cerró submetas): HTTP 409 (RF-ADM-009, BR-013); en una cuenta sin datos el cambio se acepta y, hacia administrador, exige el nivel de acceso; se eliminan los datos del rol anterior y se crean los del nuevo con valores por defecto (RF-ADM-020) **[Supuesto S-54]**.
  - 3f. Se elimina una cuenta administrador que cerró submetas: las submetas permanecen finalizadas con su fecha de cierre y el administrador vacío (RF-ADM-010).
  - 3g. El borrado de un archivo de evidencia falla: la eliminación de la cuenta se completa y la limpieza programada lo elimina después (CU-033, RF-EVID-018) **[Supuesto S-53]**.
  - 3h. La solicitud de eliminar una cuenta no lleva la confirmación explícita (confirmar=true): HTTP 422 y no se elimina nada (RF-ADM-010).
  - 3i. Un administrador que no es super, o una operación sin un administrador identificado como actor, intenta cambiar un nivel de acceso o un rol: HTTP 403 y no cambia nada (RF-ADM-014, RF-ADM-009, BR-021).
- **Postcondiciones:** Las cuentas quedan gestionadas en BD.
- **RF y HU relacionadas:** RF-ADM-001, RF-ADM-006, RF-ADM-008, RF-ADM-009, RF-ADM-010, RF-ADM-014, RF-ADM-015, RF-ADM-016, RF-ADM-020, RF-ADM-021, RF-AUT-016, RF-AUT-018, RF-EVID-017, RF-EVID-018 | HU-ADM-001, HU-ADM-006, HU-ADM-009, HU-EVID-006


#### CU-020: Bloquear/Desbloquear Usuario

- **ID:** CU-020
- **Nombre:** Bloquear/Desbloquear Usuario
- **Actor(es):** Administrador
- **Precondiciones:** Sesión administrador con nivel moderador o super; el moderador solo opera sobre cuentas cliente.
- **Flujo Básico:**
  1. El administrador selecciona una cuenta.
  2. El administrador la bloquea (RF-ADM-004) o la desbloquea (RF-ADM-012).
  3. Al bloquear, el sistema revoca las sesiones activas de la cuenta (RF-ADM-013).
  4. El sistema persiste el estado administrativo, independiente del bloqueo temporal (BR-012).
- **Flujos Alternos:**
  - 2a. Un usuario bloqueado intenta iniciar sesión: HTTP 403.
  - 2b. Nivel soporte: HTTP 403 (RF-ADM-015).
  - 2c. Un super intenta bloquear al único administrador super sin bloquear (incluido uno mismo): HTTP 409 (RF-ADM-004, BR-021).
  - 2d. Un administrador de nivel moderador intenta bloquear o desbloquear una cuenta administrador: HTTP 403 (NIVEL_ADMIN_INSUFICIENTE; solo el super bloquea y desbloquea cuentas administrador, RF-ADM-015, BR-021) y no cambia nada; esta comprobación de nivel precede a la del último super.
- **Postcondiciones:** El estado administrativo de la cuenta cambia y afecta su acceso y su presencia en el ranking.
- **RF y HU relacionadas:** RF-ADM-004, RF-ADM-012, RF-ADM-013 | HU-ADM-002


#### CU-021: Consultar Métricas, Evidencias y Ranking (Administrador)

- **ID:** CU-021
- **Nombre:** Consultar Métricas, Evidencias y Ranking (Administrador)
- **Actor(es):** Administrador
- **Precondiciones:** Sesión administrador; el nivel de acceso requerido depende de la consulta (BR-021).
- **Flujo Básico:**
  1. El administrador de nivel super o moderador consulta métricas de uso de la aplicación (RF-ADM-002).
  2. El administrador de nivel super consulta métricas de uso del LLM por operación (RF-ADM-011) basadas en la traza de llamadas (RF-ADM-007).
  3. El administrador de cualquier nivel (super, moderador o soporte) consulta evidencias de los usuarios con su dictamen y estado (RF-ADM-003).
  4. El administrador de cualquier nivel consulta el ranking global con las cuentas bloqueadas marcadas (RF-ADM-005); a diferencia del ranking de clientes (CU-018), que excluye a las bloqueadas, este las incluye con su marca (BR-023).
- **Flujos Alternos:**
  - 1a. Sin datos: las métricas se muestran en cero.
  - 2a. Nivel moderador o soporte consulta las métricas del LLM: HTTP 403 (BR-021).
  - 1b. Nivel soporte consulta las métricas de uso de la aplicación: HTTP 403 (BR-021).
- **Postcondiciones:** El administrador obtiene la información solicitada.
- **RF y HU relacionadas:** RF-ADM-002, RF-ADM-003, RF-ADM-005, RF-ADM-007, RF-ADM-011 | HU-ADM-003, HU-ADM-004, HU-ADM-005, HU-ADM-007


#### CU-022: Consultar Meta

- **ID:** CU-022
- **Nombre:** Consultar Meta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Meta existente propia.
- **Flujo Básico:**
  1. El usuario selecciona una meta.
  2. El sistema muestra sus datos, descripción, submetas y consejos generales (RF-META-002a, RF-META-011).
- **Flujos Alternos:**
  - 1a. Meta de otro usuario o inexistente: HTTP 404.
  - 2a. Meta con desglose pendiente: se muestra el aviso y la acción de reintentar (RF-META-024).
- **Postcondiciones:** El usuario ve el detalle de su meta.
- **RF y HU relacionadas:** RF-META-002a, RF-META-011 | HU-META-006


#### CU-023: Consultar Estado de Evaluación y Reintentar

- **ID:** CU-023
- **Nombre:** Consultar Estado de Evaluación y Reintentar
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Evidencia enviada.
- **Flujo Básico:**
  1. El usuario abre el estado de la evaluación de su evidencia (RF-EVID-009).
  2. El sistema muestra En evaluación, Evaluada con dictamen y justificación, o Error.
  3. Si está en Error, el usuario selecciona Reintentar y el sistema reevalúa la misma evidencia sin consumir intento y registrando un nuevo uso del LLM por cada llamada (RF-EVID-008, BR-017, RF-ADM-007).
  4. La evaluación continúa en CU-014.
- **Flujos Alternos:**
  - 3a. El plazo de gracia ya expiró: el reintento se acepta porque la evidencia conserva su ventana original (RF-EVID-011, BR-016).
  - 3b. La submeta fue cerrada por un administrador tras un Error persistente: Reintentar responde HTTP 409 (RF-EVID-008, RF-ADM-019).
  - 3c. El Reintentar vuelve a fallar: la evaluación regresa a Error y la cuenta de 48 h del listado administrativo comienza de nuevo (RF-ADM-018).
  - 3d. Como el contenido preparado no se persiste, al Reintentar el sistema lo vuelve a preparar a partir del archivo almacenado antes de llamar al LLM (RF-IA-012).
- **Postcondiciones:** El usuario conoce el estado; una evaluación en Error vuelve a En evaluación.
- **RF y HU relacionadas:** RF-EVID-008, RF-EVID-009, RF-EVID-011, RF-ADM-018, RF-ADM-019 | HU-EVID-003, HU-EVID-005


#### CU-024: Consultar Inicio

- **ID:** CU-024
- **Nombre:** Consultar Inicio
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El sistema muestra la próxima submeta de hoy, el puntaje acumulado y la racha (RF-AGEN-005).
- **Flujos Alternos:**
  - 1a. Sin submetas hoy: se muestra el mensaje de agenda libre.
- **Postcondiciones:** El usuario ve su resumen de inicio.
- **RF y HU relacionadas:** RF-AGEN-005 | HU-AGEN-004


#### CU-025: Sugerir Fechas de Trabajo con IA

- **ID:** CU-025
- **Nombre:** Sugerir Fechas de Trabajo con IA
- **Actor(es):** Usuario (cliente), Motor LLM
- **Precondiciones:** Formulario de meta con descripción, tiempo total, número de días (≥ 2) y rango de fechas; extiende CU-005.
- **Flujo Básico:**
  1. El usuario indica solo el número de días y el rango (RF-META-017).
  2. El sistema verifica la aceptación del servicio externo de IA (RF-IA-007) e invoca al Agente IA con la descripción como contexto (RF-META-032, RF-META-022).
  3. El Agente IA propone la cantidad pedida de fechas dentro del rango y no anteriores a hoy.
  4. El sistema valida la respuesta y la presenta al usuario.
  5. El usuario acepta, modifica o rechaza las fechas (RF-META-018).
  6. El flujo vuelve a CU-005 paso 4 con las fechas confirmadas.
- **Flujos Alternos:**
  - 2a. El usuario no acepta el servicio externo de IA: la sugerencia de fechas se deniega (HTTP 403 con el aviso, RF-IA-011, BR-035) y se ofrece la elección manual (RF-META-016); el usuario sigue usando la aplicación con metas sin evidencia (RF-IA-010).
  - 3a. La IA devuelve fechas fuera del rango o en cantidad distinta: la respuesta se descarta y se ofrece la elección manual (RF-META-016, RF-META-032).
  - 3b. La IA no responde tras los reintentos: se informa y se ofrece la elección manual.
  - 1a. El tiempo total es menor que el número de días indicado, o el número de días supera los días del rango: HTTP 422 sin invocar al Agente IA (BR-014 (10) y (11), RF-META-003).
  - 5a. El usuario rechaza: elige las fechas manualmente.
- **Postcondiciones:** Las fechas de trabajo quedan confirmadas por el usuario.
- **RF y HU relacionadas:** RF-META-003, RF-META-017, RF-META-018, RF-META-022, RF-META-032, RF-IA-007, RF-IA-010, RF-IA-011 | HU-META-002, HU-META-011, HU-META-012, HU-IA-002, HU-IA-004


#### CU-026: Otorgar Logro

- **ID:** CU-026
- **Nombre:** Otorgar Logro
- **Actor(es):** Sistema
- **Precondiciones:** Ocurre un evento evaluable (inicio de submeta, cierre de submeta, racha, puntaje acumulado).
- **Flujo Básico:**
  1. El sistema evalúa las condiciones del catálogo (RF-LOGR-001, BR-020); Impecable y la racha perfecta solo cuentan con acierto Excelente en el primer envío recibido en el periodo inicial (BR-033).
  2. Si se cumple una condición y el usuario no tiene el logro, el sistema lo otorga con su fecha (RF-LOGR-002).
  3. En el siguiente refresco, la interfaz consulta los logros obtenidos desde el último instante visto y muestra el aviso (RF-LOGR-004); el sistema dispara la notificación push (CU-028).
- **Flujos Alternos:**
  - 2a. El usuario ya tiene el logro: no se vuelve a otorgar.
- **Postcondiciones:** El logro queda registrado una sola vez para el usuario.
- **RF y HU relacionadas:** RF-LOGR-001, RF-LOGR-002, RF-LOGR-004 | HU-LOGR-001


#### CU-027: Configurar Preferencias de Cuenta

- **ID:** CU-027
- **Nombre:** Configurar Preferencias de Cuenta
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa.
- **Flujo Básico:**
  1. El usuario abre sus preferencias.
  2. El usuario consulta y modifica su zona horaria, asignada en el registro (RF-PER-008).
  3. El usuario activa o desactiva las notificaciones push (RF-NOT-001).
  4. Al activarlas, el navegador solicita permiso y el sistema registra la suscripción del dispositivo (RF-NOT-002).
  5. El sistema guarda las preferencias.
- **Flujos Alternos:**
  - 2a. Zona horaria inexistente: HTTP 422.
  - 4a. El usuario deniega el permiso del navegador: la preferencia queda desactivada con aviso.
  - 2b. El usuario cambia la zona con metas existentes: las submetas pendientes conservan su fecha y hora locales, lo ya ocurrido conserva su instante y los días activos no se recalculan (RF-PER-017) **[Supuesto S-52]**.
- **Postcondiciones:** Zona horaria y preferencia de notificaciones actualizadas.
- **RF y HU relacionadas:** RF-PER-008, RF-NOT-001, RF-NOT-002, RF-PER-017 | HU-PER-006, HU-NOT-001


#### CU-028: Enviar Notificaciones Push

- **ID:** CU-028
- **Nombre:** Enviar Notificaciones Push
- **Actor(es):** Sistema, Servicio de notificaciones push
- **Precondiciones:** Ocurre un evento notificable y el usuario tiene la preferencia activada con suscripción vigente.
- **Flujo Básico:**
  1. El sistema detecta el evento: 10 min antes del inicio (RF-NOT-003), 80 % del tiempo (RF-NOT-004), apertura de gracia (RF-NOT-005), evaluación terminada o en Error (RF-NOT-006) o logro (RF-NOT-008).
  2. El sistema verifica la preferencia y la suscripción (RF-NOT-007).
  3. El sistema envía la notificación al servicio de notificaciones push en ≤ 60 s (RNF-023).
- **Flujos Alternos:**
  - 2a. Preferencia desactivada o sin suscripción: no se envía nada.
  - 3a. El servicio de notificaciones rechaza la suscripción por vencida: el sistema la elimina.
- **Postcondiciones:** El usuario recibe el aviso en su dispositivo.
- **RF y HU relacionadas:** RF-NOT-003, RF-NOT-004, RF-NOT-005, RF-NOT-006, RF-NOT-007, RF-NOT-008 | HU-NOT-001, HU-NOT-002


#### CU-029: Inicializar el Primer Administrador Super

- **ID:** CU-029
- **Nombre:** Inicializar el Primer Administrador Super
- **Actor(es):** Responsable del despliegue, Sistema
- **Precondiciones:** Base de datos sin ninguna cuenta de nivel super (puede haber administradores moderador o soporte); el responsable del despliegue ha definido en variables de entorno el correo y la contraseña iniciales. **[Supuesto S-41]**
- **Flujo Básico:**
  1. El responsable define las variables de entorno con el correo y la contraseña iniciales y arranca el despliegue (RF-ADM-017).
  2. El sistema verifica en el arranque que no exista ningún administrador super, bloqueado o no.
  3. El sistema valida la política de contraseña (RF-AUT-011).
  4. El sistema crea la cuenta con rol administrador, nivel super (RF-ADM-014) y contraseña cifrada (RNF-005).
  5. El administrador inicia sesión (CU-002) y puede gestionar cuentas (CU-019).
- **Flujos Alternos:**
  - 2a. Ya existe algún administrador super, bloqueado o no: no se crea ninguna cuenta (el proceso se ejecuta una sola vez y es idempotente).
  - 2b. Existen administradores moderador o soporte pero ningún super: se crea el super y las demás cuentas no se modifican.
  - 1a. Variables ausentes: no se crea la cuenta, el arranque deja un aviso en el log y el sistema funciona sin administradores hasta que se definan las variables (excepción de BR-021 para el arranque inicial).
  - 3a. Contraseña que no cumple la política: no se crea la cuenta y el arranque deja un aviso en el log.
  - 3b. El correo de las variables ya pertenece a una cuenta: no se modifica esa cuenta ni se crea otra, y el arranque deja un aviso en el log (RF-ADM-017).
- **Postcondiciones:** Existe exactamente una cuenta administrador super inicial, creada solo si no había ningún super; BR-021 se cumple desde el primer día; el sistema no ofrece ninguna pantalla pública de configuración.
- **RF y HU relacionadas:** RF-ADM-017, RF-ADM-014, RF-AUT-011 | HU-ADM-010, HU-ADM-009


#### CU-030: Cerrar Submeta con Evaluación en Error Persistente (Administrador)

- **ID:** CU-030
- **Nombre:** Cerrar Submeta con Evaluación en Error Persistente (Administrador)
- **Actor(es):** Administrador
- **Precondiciones:** Sesión con rol administrador de nivel super o moderador; existe una evaluación en Error durante 48 horas o más cuya submeta sigue abierta.
- **Flujo Básico:**
  1. El administrador abre el listado de evaluaciones en Error persistente (RF-ADM-018).
  2. El administrador selecciona una evaluación y consulta su submeta, sus evidencias y su puntaje provisional.
  3. El administrador solicita el cierre y confirma.
  4. El sistema verifica que la evaluación lleva 48 horas o más en Error y que la submeta sigue abierta (RF-ADM-019).
  5. El sistema finaliza la submeta con su puntaje provisional como puntaje final, registra el administrador y la fecha del cierre y, en la misma transacción, suma el puntaje al acumulado del usuario (RF-PUNT-008, RF-PUNT-014).
  6. El sistema impide reintentar la evaluación de la submeta cerrada y no cuenta el cierre como acierto en el primer envío ni altera la racha perfecta (BR-033) ni activa el día activo (BR-009).
- **Flujos Alternos:**
  - 1a. Nivel soporte: HTTP 403 (BR-021).
  - 4a. La evaluación lleva menos de 48 horas en Error: HTTP 409 y no se cierra.
  - 4b. La evaluación se resolvió o la submeta se cerró mientras tanto: HTTP 409 sin cambios.
  - 5a. Fallo de la transacción: no se persiste ni el estado ni el puntaje y el cierre se reintenta sin duplicar puntos.
- **Postcondiciones:** La submeta queda finalizada con su puntaje provisional como final; el acumulado y el ranking del usuario se actualizan una sola vez.
- **RF y HU relacionadas:** RF-ADM-018, RF-ADM-019, RF-PUNT-008, RF-PUNT-011, RF-PUNT-014 | HU-ADM-011, HU-PUNT-004


#### CU-031: Consultar Calendario de Actividad (extiende CU-017)

- **ID:** CU-031
- **Nombre:** Consultar Calendario de Actividad (extiende CU-017)
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa; el usuario consulta su perfil (CU-017).
- **Flujo Básico:**
  1. El sistema calcula, con la zona horaria del usuario, los días de los últimos 12 meses y marca como activos los días en que el usuario inició a mano una submeta o envió una evidencia (BR-009, BR-034).
  2. El sistema muestra un calendario con una celda por día: los días activos en un único tono de verde y los demás sin resaltar (RF-PER-003).
  3. Cada celda expone como texto su fecha y su condición, activo o sin actividad; un día activo solo por el envío de una evidencia se anuncia con 0 submetas (RF-PER-013).
  4. El usuario recorre el calendario con el teclado o el puntero; al enfocar un día aparece un detalle accesible con su fecha y su número de submetas (RF-PER-011, RF-PER-014, RF-PER-015).
  5. El usuario puede cambiar a la vista de tabla o lista con los días activos y sus contadores (RF-PER-016).
- **Flujos Alternos:**
  - 1a. Sin actividad en los últimos 12 meses: calendario sin días verdes y tabla vacía con un aviso.
  - 4a. El usuario pulsa Escape: el detalle se cierra sin mover el foco.
- **Postcondiciones:** El usuario conoce su constancia sin depender del color.
- **RF y HU relacionadas:** RF-PER-002, RF-PER-003, RF-PER-011, RF-PER-013, RF-PER-014, RF-PER-006, RF-PER-015, RF-PER-016 | HU-PER-002, HU-PER-004, HU-PER-007


#### CU-032: Definir Desglose Manual de una Meta Multidía (extiende CU-005)

- **ID:** CU-032
- **Nombre:** Definir Desglose Manual de una Meta Multidía (extiende CU-005)
- **Actor(es):** Usuario (cliente)
- **Precondiciones:** Sesión activa con rol cliente; formulario de meta con 2 o más fechas de trabajo elegidas, tiempo total en horas y horario diario; extiende CU-005 y no exige la aceptación del servicio de IA.
- **Flujo Básico:**
  1. El sistema muestra una submeta por cada fecha de trabajo elegida, sin invocar al Agente IA (RF-META-033).
  2. El usuario captura para cada submeta su nombre, su hora de inicio y su duración en horas enteras, mínimo 1 h (RF-META-033, RF-META-035).
  3. El sistema calcula la hora de fin (inicio más duración) y la suma de las duraciones (BR-032).
  4. El sistema valida que la suma sea igual al tiempo total (RF-META-034) y que cada submeta tenga una fecha de trabajo distinta, quepa en el horario diario y termine a más tardar a las 24:00 (RF-META-035).
  5. El sistema guarda la meta con modo de desglose manual y sus submetas, sin registrar llamadas al LLM, y las muestra en la agenda (RF-META-005, RF-META-033).
- **Flujos Alternos:**
  - 4a. La suma de las duraciones es distinta del tiempo total: HTTP 422 con la diferencia ('faltan 1 h' o 'sobran 1 h') y no se guarda nada (RF-META-034, BR-014).
  - 4b. Una submeta queda fuera del horario diario, termina después de las 24:00, tiene una duración de 0 h, negativa o no entera, nombre vacío o de más de 150 caracteres, o repite o no pertenece a las fechas de trabajo: HTTP 422 indicando el campo (RF-META-035).
  - 1a. La meta requiere evidencia y el usuario no ha aceptado el servicio de IA: HTTP 403 con el aviso de consentimiento (RF-IA-011, BR-035).
  - 1b. El usuario aceptó el servicio de IA: puede elegir este desglose en lugar del automático, también en metas con evidencia (RF-META-036).
  - 1c. El desglose por IA falló o la IA no está disponible: la meta se conserva sin submetas y este desglose se ofrece siempre como alternativa (RF-META-024).
  - 4c. El usuario modifica las fechas o el tiempo total: el sistema vuelve a validar la suma y el horario (RF-META-034, RF-META-035).
- **Postcondiciones:** La meta multidía queda guardada con submetas definidas por el usuario cuya suma de duraciones es igual al tiempo total; no hubo llamadas al LLM.
- **RF y HU relacionadas:** RF-META-033, RF-META-034, RF-META-035, RF-META-036, RF-META-005, RF-IA-010, RF-IA-011 | HU-META-014, HU-META-015, HU-IA-004


#### CU-033: Limpiar Archivos de Evidencia sin Registro

- **ID:** CU-033
- **Nombre:** Limpiar Archivos de Evidencia sin Registro
- **Actor(es):** Sistema
- **Precondiciones:** El planificador del sistema está activo; el almacén de evidencias es accesible.
- **Flujo Básico:**
  1. El planificador inicia la limpieza al menos una vez cada 24 horas (RF-EVID-018).
  2. El sistema lista los archivos del almacén y los compara con los registros de evidencia (BR-036).
  3. El sistema elimina cada archivo que no tiene registro de evidencia y tiene más de 1 hora de antigüedad desde su escritura en el almacén, valor por defecto configurable (RF-EVID-017, RF-EVID-018, BR-036) **[Supuesto S-53]** **[Supuesto S-55]**.
  4. El sistema registra en el log los archivos eliminados.
- **Flujos Alternos:**
  - 3a. El borrado de un archivo vuelve a fallar: el sistema lo registra en el log y lo reintenta en la siguiente ejecución.
  - 3b. El archivo tiene registro de evidencia: el sistema no lo elimina nunca (BR-036).
  - 3c. El archivo no tiene registro pero tiene 1 hora o menos de antigüedad (carga en curso): el sistema no lo elimina y lo evalúa en la ejecución siguiente (BR-036).
  - 2a. El almacén no está disponible: la ejecución termina con un aviso en el log y se repite en la siguiente.
- **Postcondiciones:** El almacén no contiene archivos sin registro de evidencia con más de 1 hora de antigüedad; los archivos con registro permanecen intactos.
- **RF y HU relacionadas:** RF-EVID-018, RF-EVID-017 | HU-EVID-006


## 3.8 Casos de Prueba (CP)

El campo Resultado obtenido queda en Pendiente de ejecución para todos los casos. Los CP-068 a CP-080 verifican RNF. Cada fila de la tabla 3.6.1 tiene su caso de prueba (CP-010 a CP-013 y CP-081 a CP-100, según la columna CP de la tabla). Los CP que usan las ventanas de tiempo (CP-010 a CP-013, CP-081 a CP-100 y CP-112) requieren un reloj y un LLM simulados, porque la gracia de una submeta de 60 min dura 6 min y el timeout del LLM es de 30 s (RF-IA-003).


#### CP-001: Registro exitoso y rechazo de correo duplicado y de datos inválidos

- **ID:** CP-001
- **Nombre:** Registro exitoso y rechazo de correo duplicado y de datos inválidos
- **Descripción:** Verificar que un visitante se registre con datos válidos como cliente y que se rechacen el correo duplicado y los datos incompletos.
- **Datos de entrada:** nombre=Ana, correo=ana@test.com, contraseña=Clave1234; segundo intento con el mismo correo; tercer intento sin nombre; cuarto intento sin la declaración de mayoría de edad.
- **Pasos a ejecutar:**
  1. Acceder a la vista de registro.
  2. Enviar los datos válidos.
  3. Repetir el registro con el mismo correo (en mayúsculas).
  4. Enviar el registro sin nombre.
  5. Enviar el registro con datos válidos pero sin marcar la declaración 'Declaro ser mayor de 18 años'.
- **Resultado esperado:** 1. Se crea la cuenta con rol cliente y se redirige al inicio de sesión (HTTP 201). 2. El segundo intento responde HTTP 409 sin crear registro. 3. El tercero responde HTTP 422 indicando el campo nombre. 4. El cuarto responde HTTP 422 (MAYORIA_EDAD_REQUERIDA) y no crea la cuenta (RF-AUT-017).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-001, RF-AUT-002, RF-AUT-013, RF-AUT-017


#### CP-002: Autenticación y validación del token JWT

- **ID:** CP-002
- **Nombre:** Autenticación y validación del token JWT
- **Descripción:** Verificar que las credenciales válidas emitan un JWT de 60 min, que las inválidas se rechacen y que el token se valide en cada petición.
- **Datos de entrada:** correo válido + contraseña correcta; correo válido + contraseña incorrecta; token vencido; token alterado; token revocado; token de cliente en recurso de administración.
- **Pasos a ejecutar:**
  1. Iniciar sesión con credenciales válidas y decodificar la expiración.
  2. Iniciar sesión con contraseña incorrecta.
  3. Consultar un recurso protegido sin token, con token alterado, vencido y revocado.
  4. Con un token de cliente, solicitar un recurso de administración.
  5. Consultar /salud y /salud/listo sin token.
- **Resultado esperado:** Credenciales válidas: HTTP 200 con JWT cuya expiración es emisión + 60 min. Inválidas: HTTP 401 sin token. Recurso sin token, alterado, vencido o revocado: HTTP 401. Token de cliente en administración: HTTP 403. Los endpoints de salud responden sin token y sin datos de usuarios ni de negocio (excepción técnica de RNF-001).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-003, RF-AUT-004, RNF-001


#### CP-003: Recuperación de contraseña con código de 10 minutos

- **ID:** CP-003
- **Nombre:** Recuperación de contraseña con código de 10 minutos
- **Descripción:** Verificar el flujo de recuperación, la vigencia del código, su uso único y el mensaje genérico.
- **Datos de entrada:** correo registrado; correo inexistente; código correcto; código de 10 min 1 s; código ya usado; contraseña nueva 'Nueva1234'.
- **Pasos a ejecutar:**
  1. Solicitar recuperación con el correo registrado y con uno inexistente.
  2. Extraer el código del buzón.
  3. Enviar el código con 'Nueva1234'.
  4. Reutilizar el mismo código.
  5. Usar un código de 10 min 1 s de antigüedad.
- **Resultado esperado:** Ambas solicitudes responden HTTP 200 con el mismo mensaje y solo la registrada recibe correo. El código válido actualiza la contraseña. El código reutilizado y el vencido responden HTTP 422 sin cambios.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-006, RF-AUT-007, RF-AUT-008, RF-AUT-010


#### CP-004: Desglose automático de una meta de más de 1 día

- **ID:** CP-004
- **Nombre:** Desglose automático de una meta de más de 1 día
- **Descripción:** Verificar que una meta de más de 1 día se desglose en una submeta por fecha con descripción, consejos y duraciones que suman el tiempo total.
- **Datos de entrada:** meta de 3 fechas (lun, mié, vie), tiempo total 6 h, horario 08:00 a 10:00; LLM simulado con respuesta válida (2 h, 2 h y 2 h); segunda respuesta simulada con duraciones de 1,5 h, 2,5 h y 2 h (suma 6 h); meta de 3 fechas y 2 h totales.
- **Pasos a ejecutar:**
  1. Crear la meta con las 3 fechas elegidas.
  2. Esperar la respuesta del desglose (operación síncrona, hasta ~60 s) tras guardar la meta.
  3. Consultar la agenda y el detalle de la meta.
  4. Repetir con la segunda respuesta simulada (duraciones no enteras) y comprobar la meta.
  5. Intentar crear la meta de 3 fechas y 2 h totales.
- **Resultado esperado:** La meta se guarda sin submetas y, en la respuesta del desglose síncrono, se crean 3 submetas con fecha, horario dentro de 08:00 a 10:00, descripción no vacía, duración entera de 1 h o más cada una y duración total de 6 h; se muestran consejos generales; las submetas comparten el color de la meta; la respuesta con duraciones de 1,5 h y 2,5 h se trata como fuera del esquema (no se persiste ninguna submeta y la meta queda con el desglose pendiente); la meta de 3 fechas y 2 h responde HTTP 422 (BR-014 numeral 10).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-003, RF-META-005, RF-META-007, RF-META-011


#### CP-005: Recomendaciones de la IA cuando el promedio diario supera 12 horas

- **ID:** CP-005
- **Nombre:** Recomendaciones de la IA cuando el promedio diario supera 12 horas
- **Descripción:** Verificar que toda meta con más de 12 h por día reciba recomendaciones, que el usuario tenga la última palabra y que no se invoquen con 12 h por día o menos.
- **Datos de entrada:** (1 día, 18 h); (3 días, 42 h); (3 días, 36 h); (1 día, 12 h); (1 día, 24 h con horario 00:00 a 24:00).
- **Pasos a ejecutar:**
  1. Crear la meta de 1 día y 18 h y revisar las recomendaciones mostradas.
  2. Aceptar, modificar y, en otra ejecución, rechazar las sugerencias.
  3. Crear la meta de 3 días y 42 h (14 h por día) y repetir la decisión del usuario.
  4. Crear las metas de 3 días y 36 h (12 h por día) y de 1 día y 12 h.
  5. Crear la meta de 1 día y 24 h.
- **Resultado esperado:** Las metas de 1 día y 18 h, de 3 días y 42 h y de 1 día y 24 h muestran recomendaciones antes de guardarse y se guardan según la decisión del usuario en los tres casos; las de 3 días y 36 h y de 1 día y 12 h no invocan la recomendación del LLM.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-008, RF-META-009


#### CP-006: Validación del límite de 24 horas por día y de la hora de fin 24:00

- **ID:** CP-006
- **Nombre:** Validación del límite de 24 horas por día y de la hora de fin 24:00
- **Descripción:** Verificar el límite inclusivo de 24 h por día en los valores frontera, la aceptación de 24:00 como hora de fin, el mínimo de 1 h por día (tiempo total mayor o igual que los días destinados) y que los días destinados quepan en el rango de fechas.
- **Datos de entrada:** (1 día, 24 h, horario 00:00 a 24:00); (1 día, 24 h, horario 00:00 a 23:59); (1 día, 25 h); (10 días, 240 h, horario 00:00 a 24:00); (10 días, 250 h); (3 días, 0 h); (3 días, 2 h); (3 días, 3 h); (2 días destinados en un rango de 1 día); (3 días destinados en un rango de 3 días); (3 días, 2 h solicitando fechas sugeridas por la IA).
- **Pasos a ejecutar:**
  1. Intentar crear cada meta con el horario indicado (donde no se indica, con un horario suficiente).
  2. Para el caso de fechas sugeridas, solicitar la sugerencia (CU-025) y comprobar las llamadas al LLM simulado.
- **Resultado esperado:** (1 día, 24 h, 00:00 a 24:00): aceptada, con submeta de 00:00 a 24:00. (1 día, 24 h, 00:00 a 23:59): HTTP 422 por capacidad insuficiente. (1 día, 25 h): HTTP 422 con mínimo 2 días. (10 días, 240 h): aceptada. (10 días, 250 h): HTTP 422 con mínimo 11 días. (3 días, 0 h): HTTP 422 por tiempo total inválido. (3 días, 2 h): HTTP 422 porque el tiempo total es menor que los días destinados (cada submeta dura al menos 1 h), antes de guardar la meta y sin submetas. (3 días, 3 h): aceptada. (2 días destinados en un rango de 1 día): HTTP 422. (3 días destinados en un rango de 3 días): aceptada. (3 días, 2 h con fechas sugeridas): HTTP 422 sin llamadas al LLM simulado.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-010, RF-META-015, RF-META-020, RF-META-005, RF-META-003


#### CP-007: Bloqueo de carga de evidencia antes del 80 % (primer y segundo envío)

- **ID:** CP-007
- **Nombre:** Bloqueo de carga de evidencia antes del 80 % (primer y segundo envío)
- **Descripción:** Validar que la carga de evidencia esté bloqueada hasta que transcurra el 80 % del tiempo.
- **Datos de entrada:** submeta de 60 min iniciada; intentos de carga en el minuto 30, 47 y 48; segundo envío tras un primer dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta.
  2. Intentar cargar en el minuto 30.
  3. Intentar cargar en el minuto 47 (llamada directa a la API).
  4. Intentar cargar en el minuto 48.
  5. Tras el dictamen Incoherente del primer envío, enviar el segundo y verificar que la misma regla del 80 % (BR-001) lo admite sin una regla adicional de tiempo mínimo.
- **Resultado esperado:** En el minuto 30 y 47 el botón está deshabilitado y la API responde HTTP 409 sin persistir; en el minuto 48 la carga se habilita y se acepta; el segundo envío se acepta tras el dictamen del primero porque el tiempo transcurrido ya supera el 80 %.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-001, RF-EVID-002


#### CP-008: Aceptación de formatos y límite de tamaño

- **ID:** CP-008
- **Nombre:** Aceptación de formatos y límite de tamaño
- **Descripción:** Verificar los formatos permitidos con su conversión previa a la evaluación, el rechazo de otros formatos o de lo que no se puede convertir y el límite de 26 214 400 bytes.
- **Datos de entrada:** archivos válidos .png, .jpg, .jpeg, .webp, .gif (animado), .txt, .pdf, .docx, .doc, .xlsx y .xls; un .csv y un .exe; un .docx corrupto y un .doc que no se puede convertir; uno de 26 214 400 bytes y uno de 26 214 401 bytes.
- **Pasos a ejecutar:**
  1. Subir cada archivo como evidencia en una submeta habilitada.
  2. Para cada archivo aceptado, capturar el contenido que recibe el LLM simulado y, tras cada rechazo, consultar el número de envíos usados.
- **Resultado esperado:** Los once formatos válidos se aceptan; el .gif llega al LLM simulado como imagen PNG de su primer fotograma, los .docx, .doc, .xlsx y .xls como texto o Markdown, y los .png, .jpg, .jpeg, .webp, .pdf y .txt sin conversión; .csv y .exe: HTTP 415; el .docx corrupto y el .doc no convertible: HTTP 422; en los rechazos no se persiste la evidencia ni se consume el envío; 26 214 400 bytes aceptado; 26 214 401 bytes: HTTP 413.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-003, RF-EVID-004, RF-IA-005, RF-IA-012


#### CP-009: Ciclo de estados de la evaluación LLM

- **ID:** CP-009
- **Nombre:** Ciclo de estados de la evaluación LLM
- **Descripción:** Verificar que la evaluación pase por En evaluación y termine en Evaluada o Error.
- **Datos de entrada:** evidencia enviada; LLM simulado con respuesta válida (dictamen Excelente, Incoherente o Inválida); LLM simulado sin respuesta (timeout).
- **Pasos a ejecutar:**
  1. Enviar una evidencia.
  2. Consultar el estado inmediatamente.
  3. Esperar el dictamen.
  4. Repetir con el LLM simulado sin respuesta.
- **Resultado esperado:** La API responde HTTP 202 de inmediato; el estado es En evaluación y luego Evaluada con dictamen y justificación, o Error tras agotar los reintentos automáticos con la acción Reintentar visible.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-005, RF-EVID-006


#### CP-010: Primer envío Excelente a tiempo: 100 puntos y cierre (E-01)

- **ID:** CP-010
- **Nombre:** Primer envío Excelente a tiempo: 100 puntos y cierre (E-01)
- **Descripción:** Verificar que un primer envío con dictamen Excelente en el periodo inicial asigne 100 puntos, cierre la submeta sin aplicar el tope y sume al perfil.
- **Datos de entrada:** submeta de 60 min; evidencia con dictamen simulado Excelente enviada en el minuto 50 (entre el 80 % y el 100 % del tiempo).
- **Pasos a ejecutar:**
  1. Enviar la evidencia dentro del tiempo estipulado.
  2. Esperar el dictamen Excelente.
  3. Consultar el puntaje de la submeta y del perfil.
  4. Intentar un nuevo envío.
- **Resultado esperado:** La submeta cierra al dictamen con 100 puntos (sin tope), el perfil suma 100 una sola vez y el nuevo envío responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-001, RF-PUNT-002, RF-PUNT-013, RF-PUNT-014, RF-EVID-016


#### CP-011: Segundo envío antes del 100 %: Incoherente (50) + Excelente (50) = 100 con tope 90 (E-03)

- **ID:** CP-011
- **Nombre:** Segundo envío antes del 100 %: Incoherente (50) + Excelente (50) = 100 con tope 90 (E-03)
- **Descripción:** Verificar que tras un primer dictamen Incoherente se habilite de inmediato el segundo envío, aun antes del 100 % del tiempo, que el segundo envío valga la mitad y que la suma se limite a 90.
- **Datos de entrada:** submeta de 60 min; evidencia 1 Incoherente enviada en el minuto 50; evidencia 2 Excelente enviada en el minuto 55 (antes del 100 %).
- **Pasos a ejecutar:**
  1. Enviar la evidencia 1 en el minuto 50 y esperar el dictamen Incoherente.
  2. Verificar 50 provisionales, submeta abierta y segundo envío habilitado de inmediato.
  3. Enviar la evidencia 2 en el minuto 55.
  4. Esperar el dictamen Excelente.
  5. Consultar el puntaje de la submeta y del perfil.
- **Resultado esperado:** La evidencia 2, enviada en el periodo inicial, vale la mitad (50); la suma 100 se limita a 90: la submeta cierra al dictamen del segundo envío con 90 y el perfil suma 90 una sola vez. Antes del cierre el perfil no suma los 50 provisionales.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-004, RF-PUNT-005, RF-PUNT-010, RF-PUNT-013, RF-EVID-007


#### CP-012: Incoherente inicial (50) + Incoherente en gracia (25) = 75 (E-07)

- **ID:** CP-012
- **Nombre:** Incoherente inicial (50) + Incoherente en gracia (25) = 75 (E-07)
- **Descripción:** Verificar que el segundo envío Incoherente, enviado en la gracia, valga la mitad (25) y que la submeta cierre al dictamen.
- **Datos de entrada:** submeta de 60 min (gracia de 6 min, hasta el minuto 66); evidencia 1 Incoherente enviada en el minuto 50; evidencia 2 Incoherente enviada en el minuto 62.
- **Pasos a ejecutar:**
  1. Enviar la evidencia 1 en el minuto 50 y esperar el dictamen Incoherente.
  2. Dejar pasar el minuto 60 (se abre la gracia).
  3. Enviar la evidencia 2 en el minuto 62 y esperar el dictamen Incoherente.
  4. Consultar el puntaje y el instante de cierre.
- **Resultado esperado:** Evidencia 1: 50; evidencia 2 (segundo envío, la mitad): 25; suma 75 sin tope; la submeta cierra al dictamen del segundo envío (no en el minuto 66) y el perfil suma 75.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-004, RF-PUNT-005, RF-PUNT-007, RF-PUNT-013


#### CP-013: Sin segundo envío: cierre al fin de la gracia con 50 (E-02) y sin envío con 0 (E-25)

- **ID:** CP-013
- **Nombre:** Sin segundo envío: cierre al fin de la gracia con 50 (E-02) y sin envío con 0 (E-25)
- **Descripción:** Verificar que la submeta cierre al expirar la gracia conservando el puntaje del primer envío, o con 0 si no hubo envío.
- **Datos de entrada:** caso A: evidencia Incoherente en el minuto 50 (50 puntos) y sin segundo envío; caso B: ninguna evidencia.
- **Pasos a ejecutar:**
  1. Caso A: enviar la evidencia Incoherente y no enviar nada hasta terminar la gracia (minuto 66).
  2. Caso B: no enviar nada en ningún tiempo; verificar 0 provisionales en el minuto 60 y la gracia abierta.
- **Resultado esperado:** Caso A: cierra con 50 al expirar la gracia. Caso B: cierra con 0 al expirar la gracia y el acumulado no cambia.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-003, RF-PUNT-006


#### CP-014: Inicio automático del reloj de una submeta en modo automático

- **ID:** CP-014
- **Nombre:** Inicio automático del reloj de una submeta en modo automático
- **Descripción:** Verificar que una submeta automática inicie su reloj a la hora programada en la zona del usuario.
- **Datos de entrada:** 20 submetas automáticas programadas a las 08:00 America/Bogota.
- **Pasos a ejecutar:**
  1. Crear 20 metas en modo automático con zona America/Bogota, una submeta cada una a las 08:00.
  2. Esperar la hora programada.
  3. Consultar el estado y la hora de inicio real de cada submeta.
- **Resultado esperado:** Ninguna submeta inicia antes de las 08:00:00 y al menos 19 de las 20 inician entre las 08:00:00 y las 08:00:30, sin intervención del usuario.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-013, RNF-024


#### CP-015: Ordenamiento del ranking de mayor a menor puntaje

- **ID:** CP-015
- **Nombre:** Ordenamiento del ranking de mayor a menor puntaje
- **Descripción:** Verificar el ordenamiento del ranking global.
- **Datos de entrada:** cuentas cliente con puntajes 300, 120, 200 y 50.
- **Pasos a ejecutar:**
  1. Consultar el ranking como cliente.
- **Resultado esperado:** La lista aparece ordenada 300, 200, 120, 50 con las posiciones 1 a 4.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-RANK-001


#### CP-016: Bloqueo temporal y notificación tras 5 intentos fallidos

- **ID:** CP-016
- **Nombre:** Bloqueo temporal y notificación tras 5 intentos fallidos
- **Descripción:** Verificar el bloqueo de 15 min tras 5 intentos fallidos y el correo al titular.
- **Datos de entrada:** 5 contraseñas incorrectas; sexto intento con la contraseña correcta; espera de 15 min.
- **Pasos a ejecutar:**
  1. Intentar iniciar sesión 5 veces con contraseña incorrecta.
  2. Intentar una sexta vez con la contraseña correcta.
  3. Verificar el correo del titular.
  4. Esperar 15 min e iniciar sesión con la contraseña correcta.
- **Resultado esperado:** Intentos 1 a 5: HTTP 401; el quinto activa el bloqueo y envía un correo en ≤ 60 s; el sexto responde HTTP 429 con Retry-After; tras 15 min el inicio de sesión funciona.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-009, RF-AUT-014


#### CP-017: Registro del día activo por inicio manual o envío de evidencia

- **ID:** CP-017
- **Nombre:** Registro del día activo por inicio manual o envío de evidencia
- **Descripción:** Verificar que el día activo se registre solo cuando el usuario actúa (inicia a mano una submeta o envía una evidencia) y que el calendario lo muestre en verde; el inicio automático, los cierres del sistema o administrativos y el inicio de sesión no lo activan.
- **Datos de entrada:** submeta manual iniciada a mano hoy; submeta manual de 1 h (el 80 % se alcanza a los 48 min) iniciada a mano ayer a las 23:10, con evidencia enviada hoy a las 00:02 (al 87 % del tiempo y dentro del periodo inicial, que termina a las 00:10) y dictaminada hoy a las 00:40 (la evaluación en curso se completa aunque la gracia haya vencido); submeta automática que se inicia sola otro día sin intervención del usuario; submeta de una meta sin evidencia iniciada de forma automática; submeta manual nunca iniciada y cerrada por BR-027; otro día solo con inicio de sesión; reloj simulado.
- **Pasos a ejecutar:**
  1. Iniciar a mano una submeta hoy.
  2. Iniciar a mano ayer a las 23:10 una submeta de 1 h, enviar su evidencia hoy a las 00:02 (52 min después del inicio, 87 % del tiempo) y recibir el dictamen a las 00:40.
  3. Dejar que una submeta automática se inicie sola, sin ninguna otra acción del usuario ese día.
  4. Dejar que una submeta automática de una meta sin evidencia se inicie y venza sin intervención del usuario.
  5. Dejar sin iniciar una submeta manual hasta las 00:00 siguiente.
  6. Abrir el perfil y consultar el calendario y los días activos.
  7. Verificar un día en que solo se inició sesión.
- **Resultado esperado:** El día de hoy aparece en verde y cuenta una sola vez (por el inicio manual y por el envío de la evidencia); ayer aparece en verde por el inicio manual; el día del inicio automático, el de la meta sin evidencia iniciada automáticamente, el de la submeta cerrada sin haberse iniciado (BR-027) y el día con solo inicio de sesión no aparecen en verde; el día de la evidencia es el de su recepción (hoy, 00:02) y el dictamen de las 00:40 no activa por sí mismo ningún día.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-002, RF-PER-003


#### CP-018: Persistencia atómica de puntaje y estado

- **ID:** CP-018
- **Nombre:** Persistencia atómica de puntaje y estado
- **Descripción:** Verificar que puntaje y estado de la submeta se persistan en la misma transacción, incluso ante fallos.
- **Datos de entrada:** cierre de submeta con fallo inducido de conexión a BD, excepción de aplicación y timeout del LLM.
- **Pasos a ejecutar:**
  1. Inducir cada fallo durante la transacción de cierre.
  2. Revisar la BD.
  3. Reintentar el cierre.
- **Resultado esperado:** No hay escrituras parciales (estado y puntaje juntos o ninguno); el reintento no duplica ni pierde puntos.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-008, RNF-002


#### CP-019: Cierre de sesión y revocación del token

- **ID:** CP-019
- **Nombre:** Cierre de sesión y revocación del token
- **Descripción:** Verificar que cerrar sesión revoque el token.
- **Datos de entrada:** token vigente de un usuario.
- **Pasos a ejecutar:**
  1. Cerrar sesión.
  2. Usar el token revocado en un recurso protegido.
- **Resultado esperado:** La petición posterior con el token revocado responde HTTP 401.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-005


#### CP-020: Política de contraseña

- **ID:** CP-020
- **Nombre:** Política de contraseña
- **Descripción:** Verificar la política de contraseña en registro y restablecimiento.
- **Datos de entrada:** contraseñas 'Abc1234' (7), 'abcdefgh' (sin número), '12345678' (sin letra), 'Clave1234'.
- **Pasos a ejecutar:**
  1. Registrar con cada contraseña.
  2. Restablecer con cada contraseña usando un código válido.
- **Resultado esperado:** Las tres primeras responden HTTP 422 en ambos flujos; 'Clave1234' se acepta.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-011


#### CP-021: Reinicio del contador de intentos fallidos

- **ID:** CP-021
- **Nombre:** Reinicio del contador de intentos fallidos
- **Descripción:** Verificar que el contador se reinicie solo por inicio de sesión exitoso o fin del bloqueo y no por eventos ajenos.
- **Datos de entrada:** 3 intentos fallidos, luego inicio exitoso; 3 intentos fallidos y cierre de una submeta.
- **Pasos a ejecutar:**
  1. Provocar 3 fallos y luego iniciar sesión correctamente; leer el contador.
  2. Provocar 3 fallos y cerrar una submeta del usuario; leer el contador.
- **Resultado esperado:** Tras el inicio exitoso el contador es 0; tras cerrar la submeta el contador sigue en 3.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-012


#### CP-022: Consulta del perfil y acceso al ranking

- **ID:** CP-022
- **Nombre:** Consulta del perfil y acceso al ranking
- **Descripción:** Verificar los datos del perfil, la posición y el acceso al ranking.
- **Datos de entrada:** usuario con 240 puntos, 5 días activos, posición 12 de 300.
- **Pasos a ejecutar:**
  1. Abrir el perfil.
  2. Seleccionar el acceso al ranking.
- **Resultado esperado:** El perfil muestra nombre, 240 puntos, 5 días activos y 'Puesto #12 de 300'; la acción navega al ranking.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-001, RF-PER-004, RF-RANK-002


#### CP-023: Primera actividad del día y contador de submetas

- **ID:** CP-023
- **Nombre:** Primera actividad del día y contador de submetas
- **Descripción:** Verificar el registro y la visualización de la primera actividad y del contador diario.
- **Datos de entrada:** tres submetas iniciadas a mano hoy a las 08:12, 10:00 y 14:30; una submeta automática que se inició sola ayer.
- **Pasos a ejecutar:**
  1. Iniciar a mano las tres submetas.
  2. Abrir el perfil.
  3. Seleccionar el día de hoy en el calendario.
- **Resultado esperado:** El perfil muestra 'Primera actividad del día: 08:12' y el día muestra '3 submetas'; al día siguiente el contador inicia en 1; el inicio automático de ayer no suma al contador ni activa el día.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-005, RF-PER-006, RF-PER-010, RF-PER-011


#### CP-024: Cálculo de racha actual y máxima

- **ID:** CP-024
- **Nombre:** Cálculo de racha actual y máxima
- **Descripción:** Verificar la racha y su regla de no ruptura hasta terminar el día.
- **Datos de entrada:** días activos lun, mar y mié (inicios a mano o envíos de evidencia); jueves sin actividad del usuario, con solo un inicio automático; luego racha previa de 5 días.
- **Pasos a ejecutar:**
  1. Consultar la racha el jueves por la mañana.
  2. Cerrar el jueves sin actividad y consultar.
  3. Iniciar a mano una submeta el viernes y consultar.
  4. Consultar la racha máxima.
- **Resultado esperado:** Jueves por la mañana: 3. Tras el jueves sin actividad del usuario (el inicio automático no suma): 0. Viernes con actividad: 1. La racha máxima conserva 5 y no disminuye.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-007, RF-PER-009


#### CP-025: Zona horaria del usuario

- **ID:** CP-025
- **Nombre:** Zona horaria del usuario
- **Descripción:** Verificar la configuración de zona horaria y su efecto en el día activo y la hora de inicio. **[Supuesto S-52]**
- **Datos de entrada:** zona America/Argentina/Buenos_Aires; zona 'Mars/Olympus'.
- **Pasos a ejecutar:**
  1. Guardar la zona válida.
  2. Intentar guardar la zona inexistente.
  3. Iniciar a mano una submeta a las 23:30 hora local y consultar el día activo.
  4. Con una meta pendiente y días activos existentes, cambiar la zona y comprobar la regla de RF-PER-017 (detalle en CP-123).
- **Resultado esperado:** La zona válida se guarda y las horas se muestran en ella; la inexistente responde HTTP 422; el día activo corresponde a la fecha local; la zona asignada en el registro se verifica en CP-109.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-008, RF-PER-017


#### CP-026: Creación de meta con parámetros completos e incompletos

- **ID:** CP-026
- **Nombre:** Creación de meta con parámetros completos e incompletos
- **Descripción:** Verificar la creación de una meta y la validación de obligatorios y fechas.
- **Datos de entrada:** meta de 2 días con todos los campos; meta sin nombre; meta con fecha de ayer.
- **Pasos a ejecutar:**
  1. Crear la meta completa.
  2. Crear la meta sin nombre.
  3. Crear la meta con una fecha de trabajo de ayer.
  4. Crear la meta con la fecha de hoy.
- **Resultado esperado:** La completa responde HTTP 201 y aparece en la agenda; la incompleta y la de ayer responden HTTP 422 indicando el campo; la de hoy se acepta.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-001, RF-META-029


#### CP-027: Consulta, edición y eliminación de metas

- **ID:** CP-027
- **Nombre:** Consulta, edición y eliminación de metas
- **Descripción:** Verificar la consulta, edición con regeneración, restricción de edición y eliminación.
- **Datos de entrada:** meta A sin submetas iniciadas (6 h); meta B con una submeta en curso; meta de otro usuario.
- **Pasos a ejecutar:**
  1. Consultar la meta A y la ajena.
  2. Editar la meta A cambiando el tiempo total a 9 h.
  3. Editar el tiempo total de la meta B.
  4. Editar solo el nombre de la meta B.
  5. Intentar eliminar la meta A sin confirmación explícita y comprobar que sigue existiendo; luego eliminarla confirmando (confirmar=true); anotar el puntaje y los días activos antes y después.
  6. Verificar en el almacén que los archivos de las evidencias de la meta A dejaron de existir y que los registros de uso del LLM de esa meta se conservan sin vínculo con ella.
- **Resultado esperado:** La propia se muestra y la ajena responde HTTP 404; las submetas de A se regeneran sumando 9 h; cambiar el tiempo de B responde HTTP 409; cambiar el nombre de B se acepta; la eliminación sin confirmación explícita responde HTTP 422 y no elimina nada; al eliminar A confirmando desaparecen la meta y sus dependientes y el puntaje y los días activos del usuario no cambian **[Supuesto S-54]**; los archivos de sus evidencias no están en el almacén y sus registros de uso del LLM permanecen con la meta vacía.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-002a, RF-META-002b, RF-META-002c, RF-META-027, RF-META-028, RF-EVID-017


#### CP-028: Meta de un día de hasta 12 horas sin IA: submeta única con tiempo estipulado igual al tiempo total

- **ID:** CP-028
- **Nombre:** Meta de un día de hasta 12 horas sin IA: submeta única con tiempo estipulado igual al tiempo total
- **Descripción:** Verificar que una meta de 1 día y hasta 12 h se guarde sin IA con una submeta única cuyo tiempo estipulado es el tiempo total, aunque el horario de la meta sea más largo.
- **Datos de entrada:** meta de 1 día con 12 h; meta de 1 día con 3 h y horario 08:00 a 12:00; meta de 3 días.
- **Pasos a ejecutar:**
  1. Crear la meta de 1 día y 12 h con el registro de llamadas al LLM observable.
  2. Crear la meta de 1 día y 3 h con horario 08:00 a 12:00 y consultar su submeta.
  3. Crear la meta de 3 días.
  4. Consultar los tipos y la suma de los tiempos estipulados.
- **Resultado esperado:** La meta de 12 h no genera llamadas al LLM y tiene 1 submeta de tipo un_dia; la de 3 h tiene una submeta de 08:00 a 11:00 con tiempo estipulado de 3 h (la carga se habilita a las 10:24); la suma de los tiempos estipulados es igual al tiempo total; la de 3 días es multidia.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-004, RF-META-019, RF-META-031


#### CP-029: Cierre de submeta de una meta sin evidencia

- **ID:** CP-029
- **Nombre:** Cierre de submeta de una meta sin evidencia
- **Descripción:** Verificar el cierre sin calificación.
- **Datos de entrada:** meta que no requiere evidencia, submeta de 30 min.
- **Pasos a ejecutar:**
  1. Iniciar la submeta.
  2. Esperar 30 min (reloj simulado).
  3. Consultar la submeta y el perfil.
- **Resultado esperado:** La submeta queda finalizada 'sin calificación' (puntaje vacío), sin llamada al LLM y sin cambio en los puntos del perfil.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-006


#### CP-030: Tiempo total y fechas elegidas por el usuario

- **ID:** CP-030
- **Nombre:** Tiempo total y fechas elegidas por el usuario
- **Descripción:** Verificar la interpretación de las horas totales y la elección de fechas.
- **Datos de entrada:** tiempo total 6; fechas 5, 7, 12 y 20 del mes.
- **Pasos a ejecutar:**
  1. Crear la meta con 4 fechas no consecutivas.
  2. Consultar días destinados y submetas.
  3. Intentar tiempo total 0 y 2,5.
- **Resultado esperado:** Los días destinados valen 4 y existen 4 submetas en esas fechas con suma de 6 h; tiempo 0 y 2,5 responden HTTP 422.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-015, RF-META-016


#### CP-031: Sugerencia de fechas por IA con descripción

- **ID:** CP-031
- **Nombre:** Sugerencia de fechas por IA con descripción
- **Descripción:** Verificar la sugerencia de fechas, su validación y la decisión del usuario.
- **Datos de entrada:** rango de 14 días, 5 días, descripción 'Preparar examen de matemáticas'; LLM simulado con respuesta válida, con 4 fechas y con fechas fuera de rango; descripción vacía; descripción de 1001 caracteres.
- **Pasos a ejecutar:**
  1. Solicitar sugerencia con respuesta válida.
  2. Aceptar, modificar y rechazar en ejecuciones separadas.
  3. Repetir con las respuestas inválidas.
  4. Solicitar sin descripción y con 1001 caracteres.
- **Resultado esperado:** La IA propone 5 fechas distintas dentro del rango; las respuestas inválidas se descartan y se ofrece la elección manual; sin descripción o con 1001 caracteres responde HTTP 422; la solicitud al LLM contiene la descripción; ninguna meta se guarda sin confirmación.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-017, RF-META-018, RF-META-021, RF-META-022, RF-META-032


#### CP-032: Capacidad del horario diario (incluida la hora de fin 24:00)

- **ID:** CP-032
- **Nombre:** Capacidad del horario diario (incluida la hora de fin 24:00)
- **Descripción:** Verificar que el horario alcance para el tiempo total.
- **Datos de entrada:** (8 días, 40 h, 08:00 a 10:00); (3 días, 6 h, 08:00 a 10:00); (1 día, 24 h, 00:00 a 24:00); (1 día, 24 h, 00:00 a 23:59).
- **Pasos a ejecutar:**
  1. Intentar crear cada meta.
- **Resultado esperado:** La primera responde HTTP 422 indicando capacidad de 16 h y el horario mínimo requerido; la segunda se acepta; la tercera se acepta (capacidad de 24 h exactas); la cuarta responde HTTP 422 (capacidad de 23 h 59 min).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-020


#### CP-033: Recomendación de descanso en metas multidía con más de 12 h por día

- **ID:** CP-033
- **Nombre:** Recomendación de descanso en metas multidía con más de 12 h por día
- **Descripción:** Verificar el umbral de 12 h por día en metas multidía y la conservación de las recomendaciones aceptadas.
- **Datos de entrada:** (3 días, 42 h), (3 días, 36 h) y (3 días, 30 h); decisión del usuario: aceptar.
- **Pasos a ejecutar:**
  1. Crear las tres metas.
  2. Revisar las recomendaciones mostradas y aceptarlas.
  3. Consultar los consejos de cada meta.
- **Resultado esperado:** La meta de 42 h (14 h por día) muestra recomendaciones que incluyen descanso y, aceptadas, quedan con los consejos al consultar la meta; las de 36 h (12 h por día) y 30 h no muestran recomendaciones.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-023, RF-META-008


#### CP-034: Falla del desglose por IA y reintento manual

- **ID:** CP-034
- **Nombre:** Falla del desglose por IA y reintento manual
- **Descripción:** Verificar la conservación de la meta, el reintento y el desglose manual como alternativa.
- **Datos de entrada:** LLM simulado caído (3 fallos); luego disponible.
- **Pasos a ejecutar:**
  1. Crear una meta de 3 días con el LLM caído.
  2. Verificar la meta y el aviso.
  3. Restablecer el LLM y pulsar Reintentar desglose.
  4. Repetir la creación con el LLM caído, elegir 'Desglose manual' y definir tres submetas de 2 h; repetir con una meta con evidencia de un usuario que aceptó la IA.
- **Resultado esperado:** La meta, ya guardada antes de solicitar el desglose síncrono, existe sin submetas con el aviso 'desglose pendiente' en la respuesta tras 3 intentos; al reintentar se crean las submetas; con el LLM caído el aviso ofrece siempre 'Reintentar desglose' y 'Desglose manual' (también en la meta con evidencia); con el desglose manual la meta se guarda con sus tres submetas y 0 llamadas nuevas al LLM simulado.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-024, RF-META-033


#### CP-035: Persistencia de la decisión sobre la recomendación IA

- **ID:** CP-035
- **Nombre:** Persistencia de la decisión sobre la recomendación IA
- **Descripción:** Verificar el registro de decisión con fecha-hora y el historial.
- **Datos de entrada:** meta de 1 día y 18 h; decisión 'modificada'; edición posterior que genera una nueva recomendación.
- **Pasos a ejecutar:**
  1. Crear la meta y modificar las sugerencias.
  2. Consultar el registro de la decisión.
  3. Editar la meta para generar otra recomendación y consultar ambos registros.
- **Resultado esperado:** Existe un registro con estado 'modificada' y fecha-hora; la segunda recomendación no sobrescribe la primera.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-014


#### CP-036: Inicio manual y vencimiento de submeta no iniciada (con y sin evidencia)

- **ID:** CP-036
- **Nombre:** Inicio manual y vencimiento de submeta no iniciada (con y sin evidencia)
- **Descripción:** Verificar el inicio manual y el cierre por no inicio.
- **Datos de entrada:** submeta manual iniciada a las 09:20 con horario 09:00 a 10:00; otra submeta manual no iniciada de una meta con evidencia; otra no iniciada de una meta sin evidencia; meta manual con evidencia cuyas dos submetas vencen sin iniciarse; submetas manuales de otras metas, con horario 14:00 a 15:00 y fecha programada F, iniciadas a las 00:00:00 de F, a las 10:00 de F (mitad de la mañana, antes de su horario) y a las 23:59:59 de F; una submeta con fecha programada F cuyo inicio se intenta el día anterior (F menos 1 día, 23:59:59); otra cuyo inicio se intenta a las 00:00:00 del día siguiente a F; una submeta ya en curso.
- **Pasos a ejecutar:**
  1. Iniciar la primera submeta a las 09:20.
  2. Consultar la hora de inicio real y el fin del reloj.
  3. Dejar las otras dos sin iniciar hasta las 00:00 del día siguiente.
  4. Consultar el estado de la meta cuyas dos submetas manuales vencieron sin iniciarse, antes y después de la medianoche de su última fecha.
  5. Iniciar a mano las submetas de F a las 00:00:00, a las 10:00 y a las 23:59:59 (en la zona horaria del usuario) y consultar su estado, su hora de inicio real y el fin de su reloj.
  6. Intentar iniciar a mano una submeta de fecha F el día anterior, otra a las 00:00:00 del día siguiente a F y una ya en curso, y consultar su estado.
- **Resultado esperado:** La primera registra inicio real 09:20 y su reloj dura 60 min; la segunda queda finalizada con 0 puntos y sin tiempo de gracia; la tercera queda finalizada sin calificación (puntaje vacío), sin gracia y sin cambio en el perfil. La meta cuyas submetas vencieron todas sin iniciarse queda finalizada (nunca pendiente y finalizada a la vez, BR-029) y una meta con una submeta ya cerrada por no inicio y otra aún pendiente sigue pendiente. Los inicios de F a las 00:00:00, a las 10:00 y a las 23:59:59 se aceptan: la submeta pasa a en curso, registra esa hora como inicio real y su reloj dura 60 min desde ese instante, sin ajustarse a las 14:00 (BR-027, RF-META-012); el intento el día anterior a F responde HTTP 409 y la submeta sigue pendiente; el intento a las 00:00:00 del día siguiente responde HTTP 409 (la submeta ya fue cerrada por no inicio o su plazo venció) y no cambia; iniciar la submeta que ya está en curso responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-012, RF-META-026


#### CP-037: Inicio automático tras caída del sistema

- **ID:** CP-037
- **Nombre:** Inicio automático tras caída del sistema
- **Descripción:** Verificar la recuperación del inicio automático.
- **Datos de entrada:** sistema detenido de 07:55 a 08:10; submeta automática a las 08:00 de 60 min.
- **Pasos a ejecutar:**
  1. Detener el planificador a las 07:55.
  2. Reanudarlo a las 08:10.
  3. Consultar la submeta.
- **Resultado esperado:** La submeta pasa a en curso con inicio 08:00 y 50 min restantes; con reanudación posterior a las 09:00 queda vencida.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-025


#### CP-038: Meta de un día de más de 12 horas con IA no disponible

- **ID:** CP-038
- **Nombre:** Meta de un día de más de 12 horas con IA no disponible
- **Descripción:** Verificar que la meta pueda guardarse sin recomendaciones.
- **Datos de entrada:** meta de 1 día y 18 h; LLM simulado caído.
- **Pasos a ejecutar:**
  1. Crear la meta.
  2. Observar el aviso.
  3. Guardar.
- **Resultado esperado:** Se muestra 'recomendaciones no disponibles', la meta se guarda y no se crea registro de recomendación.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-030


#### CP-039: Agenda con colores por meta y por estado

- **ID:** CP-039
- **Nombre:** Agenda con colores por meta y por estado
- **Descripción:** Verificar la agrupación por fecha y los indicadores de color y texto.
- **Datos de entrada:** dos metas con submetas pendiente, en curso y finalizada (una sin calificación).
- **Pasos a ejecutar:**
  1. Consultar la agenda.
  2. Consultar sin parámetro de rango y con un rango de 94 días.
- **Resultado esperado:** Las submetas se agrupan por fecha; cada meta tiene un color propio; cada estado muestra color y texto; la finalizada sin calificación se distingue de las calificadas. Sin rango se muestra el mes en curso y el rango de 94 días responde HTTP 422.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AGEN-001, RF-AGEN-002, RF-AGEN-003


#### CP-040: Detalle de submeta con ventana y puntaje provisional

- **ID:** CP-040
- **Nombre:** Detalle de submeta con ventana y puntaje provisional
- **Descripción:** Verificar el detalle y la cuenta regresiva de la ventana.
- **Datos de entrada:** submeta en tiempo inicial; submeta en gracia con 50 provisionales.
- **Pasos a ejecutar:**
  1. Abrir el detalle de cada submeta.
- **Resultado esperado:** Se muestran horario, estado, evidencias y estado de evaluación; el tiempo inicial muestra 'Tiempo estipulado' con cuenta regresiva y la gracia 'Tiempo de gracia'; los 50 se muestran como 'Provisional'.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AGEN-004, RF-AGEN-006, RF-PUNT-012


#### CP-041: Vista de inicio

- **ID:** CP-041
- **Nombre:** Vista de inicio
- **Descripción:** Verificar el contenido de la vista de inicio.
- **Datos de entrada:** usuario con una submeta pendiente hoy, 120 puntos, días activos ayer y anteayer (racha 2) y un día previo con solo un inicio automático; usuario sin submetas hoy.
- **Pasos a ejecutar:**
  1. Iniciar sesión con cada usuario.
- **Resultado esperado:** El primero ve su próxima submeta, 120 puntos y racha 2 (el día con solo inicio automático no suma); el segundo ve el mensaje de agenda libre.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AGEN-005


#### CP-042: Ciclo del temporizador Pomodoro

- **ID:** CP-042
- **Nombre:** Ciclo del temporizador Pomodoro
- **Descripción:** Verificar iniciar, pausar, reanudar, abandonar y finalizar.
- **Datos de entrada:** sesión de 25 min; pausa de 5 min; otra sesión abandonada; la primera sesión consultada mientras corre.
- **Pasos a ejecutar:**
  1. Iniciar la sesión.
  2. Pausar a los 10 min por 5 min y reanudar.
  3. Finalizar.
  4. Iniciar otra sesión y abandonarla.
  5. Con una sesión activa y con otra en pausa, consultar el historial de sesiones en el servidor antes de terminarlas.
- **Resultado esperado:** La primera termina con duración efectiva sin contar la pausa; la segunda queda abandonada; ninguna altera el estado, el reloj ni el puntaje de la submeta vinculada; mientras las sesiones están activas o en pausa el servidor no tiene ningún registro de ellas.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-POM-001, RF-POM-004, RF-POM-005, RF-POM-006, RF-POM-007


#### CP-043: Persistencia y vínculo de la sesión Pomodoro

- **ID:** CP-043
- **Nombre:** Persistencia y vínculo de la sesión Pomodoro
- **Descripción:** Verificar el guardado y el vínculo con submetas en curso.
- **Datos de entrada:** sesión vinculada a una submeta en curso; intento de vincular una submeta pendiente y una ajena; sesión de 30 s de duración efectiva.
- **Pasos a ejecutar:**
  1. Iniciar y finalizar una sesión vinculada.
  2. Consultar el registro.
  3. Intentar vincular la submeta pendiente y la ajena.
  4. Finalizar una sesión de 30 s de duración efectiva e intentar guardarla.
- **Resultado esperado:** El registro contiene fecha-hora, minutos efectivos, submeta y estado; solo se ofrecen submetas en curso del usuario; la ajena responde HTTP 404; la sesión de 30 s no se guarda (si el cliente la envía, el servidor responde HTTP 422).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-POM-002, RF-POM-003


#### CP-044: Segundo envío único, máximo de 2 evidencias y cierre del plazo

- **ID:** CP-044
- **Nombre:** Segundo envío único, máximo de 2 evidencias y cierre del plazo
- **Descripción:** Verificar el segundo intento, el rechazo del tercero y el rechazo posterior a la gracia.
- **Datos de entrada:** submeta de 60 min; evidencia 1 Inválida; evidencia 2; tercera evidencia; carga 1 s después de la gracia en otra submeta.
- **Pasos a ejecutar:**
  1. Enviar la evidencia 1 y esperar el dictamen Inválida.
  2. Verificar que la carga se habilita de inmediato.
  3. Enviar la evidencia 2 y luego una tercera.
  4. En otra submeta, cargar 1 s después de terminar la gracia.
- **Resultado esperado:** El segundo intento se acepta; la tercera responde HTTP 409; la carga posterior a la gracia responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-007, RF-EVID-012, RF-EVID-013


#### CP-045: Reintento de evaluación sin consumir intento

- **ID:** CP-045
- **Nombre:** Reintento de evaluación sin consumir intento
- **Descripción:** Verificar el reintento sobre la misma evidencia.
- **Datos de entrada:** evaluación en Error; luego LLM disponible.
- **Pasos a ejecutar:**
  1. Provocar una evaluación en Error.
  2. Consultar el estado.
  3. Pulsar Reintentar.
  4. Verificar el número de evidencias e intentos.
  5. Pulsar Reintentar con el LLM de nuevo caído y comprobar el estado y el instante del Error.
  6. Con la submeta cerrada por un administrador (CP-111), pulsar Reintentar.
- **Resultado esperado:** El estado muestra Error con Reintentar; al reintentar pasa a En evaluación y luego a Evaluada sobre la misma evidencia; no se crea una evidencia nueva y el contador de intentos no cambia. Si el Reintentar vuelve a fallar, la evaluación regresa a Error y la cuenta de 48 h comienza de nuevo; tras el cierre administrativo de la submeta Reintentar responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-008, RF-EVID-009, RF-ADM-018, RF-ADM-019


#### CP-046: Ventana por instante de recepción y evaluación que cruza el plazo

- **ID:** CP-046
- **Nombre:** Ventana por instante de recepción y evaluación que cruza el plazo
- **Descripción:** Verificar la asignación de ventana y la finalización de una evaluación en curso.
- **Datos de entrada:** evidencia recibida al 98 % con dictamen al 103 %; evidencia recibida en el último segundo de la gracia con dictamen 40 s después; evidencia que declara 85 % cuando su instante de recepción corresponde al 8 %; evidencia que declara la ventana gracia cuando su instante de recepción corresponde al periodo inicial; evidencia cuyo porcentaje declarado difiere del real en 1 s de T o menos (control de tolerancia).
- **Pasos a ejecutar:**
  1. Enviar la primera evidencia al 98 % con el LLM simulado lento.
  2. Esperar el dictamen en la gracia.
  3. Enviar otra evidencia en el último segundo de la gracia.
  4. Esperar el dictamen tras el vencimiento.
  5. En otra submeta de 60 min, enviar las evidencias cuyo porcentaje o ventana no corresponden a su instante de recepción y la de tolerancia.
- **Resultado esperado:** La primera se puntúa como enviada a tiempo; la segunda, recibida en el último segundo de la gracia, se evalúa aunque el plazo haya vencido, queda registrada con ventana de gracia, se puntúa (como segundo envío vale la mitad de la tabla del periodo inicial) y cierra la submeta. La evidencia con 85 % declarado al 8 % real y la que declara la ventana gracia en el periodo inicial se rechazan con HTTP 409 y no se persisten (BR-001, RF-EVID-010); la evidencia cuyo porcentaje difiere del real en 1 s de T o menos se acepta; una evidencia sin porcentaje ni ventana declarados se acepta, y en todos los casos el servidor guarda su propio porcentaje y su propia ventana.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-010, RF-EVID-011


#### CP-047: Evidencia no permitida: meta sin evidencia y submeta ajena

- **ID:** CP-047
- **Nombre:** Evidencia no permitida: meta sin evidencia y submeta ajena
- **Descripción:** Verificar el rechazo de cargas no válidas por contexto.
- **Datos de entrada:** submeta de meta sin evidencia; submeta de otro usuario.
- **Pasos a ejecutar:**
  1. Intentar cargar evidencia en cada caso.
- **Resultado esperado:** La primera responde HTTP 409; la segunda HTTP 404; no se persiste ninguna evidencia.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-014, RF-EVID-015


#### CP-048: Cierre diferido, tope de puntaje y puntaje provisional

- **ID:** CP-048
- **Nombre:** Cierre diferido, tope de puntaje y puntaje provisional
- **Descripción:** Verificar que la submeta no cierre antes de tiempo y el tope de 100.
- **Datos de entrada:** primer envío Incoherente al 90 % (50 puntos); evaluación pendiente al expirar la gracia; dos envíos cuya suma supera 90.
- **Pasos a ejecutar:**
  1. Obtener Incoherente al 90 % y consultar el estado y el perfil.
  2. Dejar una evaluación pendiente al expirar la gracia.
  3. Enviar un segundo envío Excelente y verificar el puntaje final.
- **Resultado esperado:** La submeta sigue en curso con 'Provisional: 50' y el perfil no suma esos puntos; no cierra mientras haya evaluación pendiente; con dos envíos el puntaje nunca excede 90 y con un solo envío nunca excede 100.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-004, RF-PUNT-010, RF-PUNT-011, RF-PUNT-012


#### CP-049: Empates, privacidad y exclusión de bloqueados en el ranking

- **ID:** CP-049
- **Nombre:** Empates, privacidad y exclusión de bloqueados en el ranking
- **Descripción:** Verificar, según BR-023, posiciones por empate, ausencia de correo y exclusión de bloqueadas en el ranking de clientes; el ranking de administración, que sí incluye a las bloqueadas marcadas, se verifica en CP-056.
- **Datos de entrada:** puntajes 300, 200, 200, 100; una cuenta bloqueada con 250.
- **Pasos a ejecutar:**
  1. Consultar el ranking como cliente.
  2. Inspeccionar la respuesta.
  3. Desbloquear la cuenta y consultar de nuevo.
- **Resultado esperado:** Posiciones 1, 2, 2, 4 con orden alfabético en el empate; no hay campo de correo; la cuenta bloqueada no aparece y reaparece al desbloquearse (BR-023, RF-RANK-005); las cuentas administrador no aparecen.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-RANK-003, RF-RANK-004, RF-RANK-005


#### CP-050: Administrador crea cuentas según su nivel

- **ID:** CP-050
- **Nombre:** Administrador crea cuentas según su nivel
- **Descripción:** Verificar la creación de cuentas por el administrador.
- **Datos de entrada:** administrador super y moderador; datos de cuenta cliente y de cuenta administrador; correo duplicado.
- **Pasos a ejecutar:**
  1. Con el super, crear una cuenta cliente y una cuenta administrador con nivel soporte.
  2. Con el moderador, crear una cuenta cliente y luego una cuenta administrador.
  3. Repetir con correo duplicado.
- **Resultado esperado:** El super crea ambas cuentas; el moderador crea la cuenta cliente y recibe HTTP 403 al intentar crear un administrador; el nivel de acceso es obligatorio para las cuentas administrador; el correo duplicado responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-001


#### CP-051: Administrador consulta, edita y elimina cuentas

- **ID:** CP-051
- **Nombre:** Administrador consulta, edita y elimina cuentas
- **Descripción:** Verificar el listado, la edición y la eliminación con restricciones.
- **Datos de entrada:** cuenta cliente con metas; la propia cuenta del administrador; el último super (cambio de rol y de nivel).
- **Pasos a ejecutar:**
  1. Listar y abrir el detalle.
  2. Editar nombre, correo y rol.
  3. Eliminar la cuenta cliente: primero sin confirmación explícita y luego confirmando (confirmar=true).
  4. Intentar eliminar la propia cuenta y al último super.
  5. Intentar cambiar el rol y el nivel del último super.
  6. Con un administrador moderador, intentar cambiar el nivel de acceso de un administrador y el rol de una cuenta sin datos.
- **Resultado esperado:** Se listan con paginación; los cambios válidos se guardan y el correo repetido responde HTTP 409; la eliminación sin confirmación explícita responde HTTP 422 y no borra nada; la eliminación confirmada borra la cuenta y sus datos; la propia cuenta y el último super responden HTTP 409 al eliminar; cambiar el rol o el nivel del último super responde HTTP 409; el moderador recibe HTTP 403 en el cambio de nivel y en el de rol y no cambia nada (BR-021).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-008, RF-ADM-009, RF-ADM-010, RF-ADM-014


#### CP-052: Bloqueo y desbloqueo administrativo

- **ID:** CP-052
- **Nombre:** Bloqueo y desbloqueo administrativo
- **Descripción:** Verificar el bloqueo persistente, la revocación de sesiones y que eventos ajenos no lo levanten, y que el moderador solo bloquee y desbloquee cuentas cliente.
- **Datos de entrada:** cliente con sesión activa; cierre de una submeta del cliente bloqueado; administrador moderador y soporte; un único administrador super sin bloquear; una cuenta administrador de nivel soporte.
- **Pasos a ejecutar:**
  1. Bloquear la cuenta con el administrador moderador.
  2. Usar el token previo del cliente.
  3. Intentar iniciar sesión.
  4. Cerrar una submeta del cliente y consultar su estado.
  5. Desbloquear.
  6. Intentar bloquear con el nivel soporte.
  7. Con el super, intentar bloquear al único administrador super sin bloquear (a sí mismo).
  8. Con el moderador, intentar bloquear la cuenta administrador de nivel soporte y la del único super.
  9. Con el super, bloquear la cuenta administrador de nivel soporte; con el moderador, intentar desbloquearla; con el super, desbloquearla.
- **Resultado esperado:** El token previo responde HTTP 401; el inicio de sesión responde HTTP 403; el bloqueo persiste tras el cierre de la submeta; tras desbloquear inicia sesión; el nivel soporte recibe HTTP 403; bloquear al único super sin bloquear, con el super, responde HTTP 409 y la cuenta no cambia; el moderador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) al bloquear o desbloquear una cuenta administrador y esta no cambia; el super sí la bloquea y la desbloquea.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-004, RF-ADM-012, RF-ADM-013


#### CP-053: Métricas de uso de la aplicación

- **ID:** CP-053
- **Nombre:** Métricas de uso de la aplicación
- **Descripción:** Verificar las métricas de la aplicación.
- **Datos de entrada:** datos con 10 usuarios, 25 metas y 40 evidencias evaluadas; base vacía.
- **Pasos a ejecutar:**
  1. Abrir las métricas con cada base.
- **Resultado esperado:** Se muestran 10, 25 y 40; con base vacía se muestran ceros.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-002


#### CP-054: Métricas y traza del uso del LLM: un registro por llamada

- **ID:** CP-054
- **Nombre:** Métricas y traza del uso del LLM: un registro por llamada
- **Descripción:** Verificar que cada llamada al LLM, incluidos reintentos automáticos y manuales, genere su registro de uso y que las métricas por operación coincidan. **[Supuesto S-35]**
- **Datos de entrada:** un desglose que falla dos veces y acierta a la tercera; una evaluación con una llamada fallida y un Reintentar exitoso; una llamada del sistema sin usuario.
- **Pasos a ejecutar:**
  1. Ejecutar el desglose y la evaluación con el LLM simulado configurado para fallar según los datos.
  2. Consultar los registros de uso.
  3. Abrir las métricas del LLM.
- **Resultado esperado:** El desglose deja 3 registros con el mismo id de meta (2 fallidos y 1 exitoso); la evaluación deja 2 registros con el mismo id de evaluación; la llamada del sistema tiene usuario vacío; cada registro tiene tokens, costo, latencia, proveedor, modelo y resultado; las métricas por operación (número de llamadas incluidas las fallidas, tokens, costo y latencia promedio) coinciden con los registros.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-007, RF-ADM-011, RF-IA-004, RF-EVID-008


#### CP-055: Consulta de evidencias por el administrador

- **ID:** CP-055
- **Nombre:** Consulta de evidencias por el administrador
- **Descripción:** Verificar el listado de evidencias de cualquier usuario.
- **Datos de entrada:** evidencias de dos usuarios con dictamen Excelente e Incoherente.
- **Pasos a ejecutar:**
  1. Listar evidencias como administrador.
  2. Abrir una evidencia.
- **Resultado esperado:** Se listan y visualizan las evidencias de ambos usuarios con dictamen y estado.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-003


#### CP-056: Ranking en administración

- **ID:** CP-056
- **Nombre:** Ranking en administración
- **Descripción:** Verificar el ranking completo con marca de bloqueo.
- **Datos de entrada:** cuentas con puntajes distintos y una bloqueada.
- **Pasos a ejecutar:**
  1. Abrir el ranking como administrador.
- **Resultado esperado:** Aparecen todas las cuentas cliente con puntaje y posición; la bloqueada tiene marca 'bloqueada'.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-005


#### CP-057: Roles excluyentes y acceso a administración

- **ID:** CP-057
- **Nombre:** Roles excluyentes y acceso a administración
- **Descripción:** Verificar la exclusión de roles y la denegación de acceso.
- **Datos de entrada:** sesión administrador; sesión cliente.
- **Pasos a ejecutar:**
  1. Con el administrador crear una meta, iniciar una submeta y cargar una evidencia.
  2. Con el cliente abrir una función de administración.
  3. Intentar asignar a una cuenta un segundo rol.
- **Resultado esperado:** Todas las acciones del administrador sobre funciones de cliente responden HTTP 403; el cliente recibe HTTP 403 en administración; el segundo rol responde HTTP 422.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-006, RF-ADM-016


#### CP-058: Niveles de acceso del administrador

- **ID:** CP-058
- **Nombre:** Niveles de acceso del administrador
- **Descripción:** Verificar la asignación de nivel y la matriz de permisos.
- **Datos de entrada:** administradores super, moderador y soporte; una cuenta cliente y una cuenta administrador.
- **Pasos a ejecutar:**
  1. Asignar niveles como super y como moderador.
  2. Con cada nivel intentar bloquear, eliminar una cuenta y ver métricas del LLM.
  3. Con el moderador y con el super, bloquear y desbloquear la cuenta cliente y la cuenta administrador.
- **Resultado esperado:** Solo super asigna niveles; soporte no bloquea; moderador no elimina ni ve métricas del LLM; super puede todo, incluido bloquear y desbloquear cuentas administrador; el moderador bloquea y desbloquea la cuenta cliente, pero con la cuenta administrador recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE) y no cambia nada; un nivel inválido responde HTTP 422.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-014, RF-ADM-015


#### CP-059: Interfaz de proveedor intercambiable y salida estructurada

- **ID:** CP-059
- **Nombre:** Interfaz de proveedor intercambiable y salida estructurada
- **Descripción:** Verificar el cambio de proveedor por configuración y el rechazo de respuestas fuera de esquema.
- **Datos de entrada:** proveedor simulado A y B; respuesta fuera del esquema; respuesta con un dictamen distinto de Excelente, Incoherente o Inválida; respuesta de desglose con una submeta de 1,5 h y otra con una submeta de 0 h.
- **Pasos a ejecutar:**
  1. Ejecutar un desglose con el proveedor A.
  2. Cambiar la configuración al proveedor B y repetir.
  3. Responder con un JSON fuera del esquema, con un dictamen no permitido y, en un desglose, con una duración de 1,5 h o de 0 h.
- **Resultado esperado:** Ambos proveedores funcionan sin cambios en el código de negocio; las respuestas fuera del esquema, incluidos un dictamen no permitido y una duración de submeta de 0 h o no entera, dejan la operación en Error y no persiste datos.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-001, RF-IA-002


#### CP-060: Timeout y reintentos automáticos del LLM

- **ID:** CP-060
- **Nombre:** Timeout y reintentos automáticos del LLM
- **Descripción:** Verificar el timeout de 30 s, los 2 reintentos y la ausencia de duplicados.
- **Datos de entrada:** LLM simulado que responde a los 31 s; falla 2 veces y acierta a la tercera; falla 3 veces.
- **Pasos a ejecutar:**
  1. Invocar la operación con cada comportamiento simulado.
- **Resultado esperado:** El caso de 31 s se corta por timeout; el de 2 fallas termina con éxito y un solo resultado persistido; el de 3 fallas termina en error.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-003, RF-IA-004


#### CP-061: Preparación del contenido por formato

- **ID:** CP-061
- **Nombre:** Preparación del contenido por formato
- **Descripción:** Verificar la extracción según formato.
- **Datos de entrada:** archivos .pdf, .txt, .docx, .doc, .xlsx, .xls, .png, .jpg, .webp y .gif animado; un .docx con una imagen incrustada.
- **Pasos a ejecutar:**
  1. Enviar cada evidencia a evaluación y capturar la solicitud al LLM.
  2. Comparar el contenido recibido por el LLM simulado del .gif con su primer fotograma y el del .docx con el texto del documento.
- **Resultado esperado:** El .pdf se envía como PDF y el .txt como texto; el .docx y el .doc, como texto o Markdown extraído; el .xlsx y el .xls, como contenido tabular en Markdown; el .png, .jpg y .webp, como imagen y el .gif como imagen PNG de su primer fotograma; la imagen incrustada del .docx no llega al LLM (límite conocido de la conversión); ningún formato aceptado queda sin tratamiento ni se rechaza por 'formato no soportado por el proveedor'.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-005, RF-EVID-003


#### CP-062: Privacidad y consentimiento de IA externa: aceptación, rechazo y minimización de datos

- **ID:** CP-062
- **Nombre:** Privacidad y consentimiento de IA externa: aceptación, rechazo y minimización de datos
- **Descripción:** Verificar la minimización de datos, la aceptación previa y el efecto del rechazo en las operaciones de IA.
- **Datos de entrada:** usuario sin decisión; usuario con nombre 'Ana' y correo ana@test.com; operaciones: creación de una meta con evidencia, desglose automático de una meta de 3 días, fechas sugeridas, carga de evidencia y meta de 1 día de 8 h sin evidencia.
- **Pasos a ejecutar:**
  1. Crear una meta de 1 día y 8 h sin evidencia sin decisión previa.
  2. Intentar crear una meta con evidencia y rechazar el aviso.
  3. Intentar el desglose automático de una meta de 3 días y la carga de evidencia sin aceptación.
  4. Aceptar el aviso, repetir las operaciones y capturar la solicitud enviada al LLM simulado.
- **Resultado esperado:** La meta de 1 día de 8 h sin evidencia se guarda sin pedir aceptación; con el aviso rechazado, la meta con evidencia, el desglose automático y la carga responden HTTP 403 con el aviso y sin llamadas al LLM; tras aceptar queda registrada la fecha, no se vuelve a pedir en ninguna operación y las operaciones se realizan; la solicitud no contiene 'Ana', el correo ni el id del usuario.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-006, RF-IA-007, RF-IA-010, RF-IA-011


#### CP-063: Contexto, dictamen y registro del proveedor en la evaluación

- **ID:** CP-063
- **Nombre:** Contexto, dictamen y registro del proveedor en la evaluación
- **Descripción:** Verificar el contexto enviado y lo guardado.
- **Datos de entrada:** meta 'Estudiar cálculo' con descripción; evidencia cualquiera.
- **Pasos a ejecutar:**
  1. Evaluar una evidencia.
  2. Capturar la solicitud.
  3. Consultar la evaluación y el registro de uso.
- **Resultado esperado:** La solicitud contiene nombre y descripción de la meta; se guardan dictamen y justificación; el registro de uso tiene proveedor y modelo.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-008, RF-IA-009


#### CP-064: Preferencias de notificaciones push

- **ID:** CP-064
- **Nombre:** Preferencias de notificaciones push
- **Descripción:** Verificar la activación, el permiso y el respeto de la preferencia.
- **Datos de entrada:** cuenta nueva; permiso concedido; permiso denegado; preferencia desactivada.
- **Pasos a ejecutar:**
  1. Consultar la preferencia en una cuenta nueva.
  2. Desactivarla, reactivarla y conceder el permiso.
  3. Reactivarla denegando el permiso.
  4. Generar un evento con la preferencia desactivada.
- **Resultado esperado:** La cuenta nueva la tiene activada; con permiso se registra la suscripción; con permiso denegado queda desactivada con aviso; con la preferencia desactivada no se envía ninguna notificación.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-NOT-001, RF-NOT-002, RF-NOT-007


#### CP-065: Eventos de notificación push

- **ID:** CP-065
- **Nombre:** Eventos de notificación push
- **Descripción:** Verificar los cuatro eventos temporales y de evaluación.
- **Datos de entrada:** submeta 08:00 de 60 min; evaluación terminada; evaluación en Error; primer envío Excelente aún en evaluación al expirar el tiempo inicial.
- **Pasos a ejecutar:**
  1. Esperar 07:50.
  2. Esperar el minuto 48 de la submeta.
  3. Dejar expirar el tiempo inicial sin envío (o con primer envío Incoherente o Inválida).
  4. Terminar una evaluación y provocar otra en Error.
  5. Dejar expirar el tiempo inicial con un primer envío Excelente aún en evaluación.
- **Resultado esperado:** Se entregan: recordatorio entre 07:49:30 y 07:50:30, aviso de evidencia en el minuto 48, aviso de gracia con 6 min y avisos de resultado y de Error; no se envía aviso de gracia si el primer envío en evaluación resulta Excelente.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-NOT-003, RF-NOT-004, RF-NOT-005, RF-NOT-006


#### CP-066: Logros: otorgamiento único, Impecable, aviso y notificación

- **ID:** CP-066
- **Nombre:** Logros: otorgamiento único, Impecable, aviso y notificación
- **Descripción:** Verificar el otorgamiento automático de logros del catálogo.
- **Datos de entrada:** primera submeta del usuario (iniciada a mano); primera submeta de un segundo usuario, de una meta sin evidencia en modo automático que se inicia sola; segunda submeta; racha de 7 días; 1 000 puntos; una submeta cerrada con Excelente en el primer envío del periodo inicial; otra cerrada por un segundo envío Excelente (90 puntos); otra con primer envío Excelente recibido en gracia (50 puntos) en un usuario sin 'Impecable'.
- **Pasos a ejecutar:**
  1. Iniciar a mano la primera submeta de un usuario y dejar que se inicie sola la primera submeta del segundo usuario, sin otra acción de este en el día.
  2. Iniciar la segunda.
  3. Completar 7 días activos.
  4. Acumular 1 000 puntos.
  5. Cerrar una submeta con acierto en el primer envío del periodo inicial, otra con acierto en el segundo envío y otra, en un usuario sin 'Impecable', cuyo primer envío Excelente se recibe en el tiempo de gracia (50 puntos) **[F1f-003]**.
- **Resultado esperado:** 'Primer paso' se otorga una vez con aviso y notificación push, también al usuario cuya primera submeta se inició sola, cuyo día no queda activo (BR-009); 'Constante' al 7.º día; 'Mil puntos' al alcanzar 1 000; 'Impecable' solo con la submeta de acierto en el primer envío del periodo inicial y no con la de 90 puntos ni con la de gracia (50); no se repiten; los logros no cambian el puntaje; el aviso aparece al consultar los logros desde el último instante visto y no se repite al consultar de nuevo con el instante actualizado (RF-LOGR-004).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-LOGR-001, RF-LOGR-002, RF-LOGR-004, RF-NOT-008


#### CP-067: Logros en el perfil

- **ID:** CP-067
- **Nombre:** Logros en el perfil
- **Descripción:** Verificar la presentación de logros obtenidos y bloqueados.
- **Datos de entrada:** usuario con 2 logros.
- **Pasos a ejecutar:**
  1. Abrir el perfil.
- **Resultado esperado:** Se listan todos los logros del catálogo; los 2 obtenidos muestran fecha y los demás aparecen bloqueados.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-LOGR-003


#### CP-068: Prueba de carga de consultas

- **ID:** CP-068
- **Nombre:** Prueba de carga de consultas
- **Descripción:** Verificar el rendimiento de consultas con 200 usuarios virtuales.
- **Datos de entrada:** k6 con 200 VUs, 1 min de subida y 5 min sostenidos sobre inicio de sesión, agenda, perfil y ranking; dataset de 10 000 usuarios y 100 000 submetas; 1 instancia.
- **Pasos a ejecutar:**
  1. Preparar el entorno y los datos.
  2. Ejecutar el script de carga.
  3. Exportar las métricas.
- **Resultado esperado:** p95 ≤ 2 s en cada consulta y errores 5xx ≤ 1 %.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-003


#### CP-069: Sesión sin estado con dos instancias

- **ID:** CP-069
- **Nombre:** Sesión sin estado con dos instancias
- **Descripción:** Verificar que dos instancias atiendan una misma sesión.
- **Datos de entrada:** 2 instancias detrás de un balanceador; un token obtenido en la instancia A.
- **Pasos a ejecutar:**
  1. Autenticarse en la instancia A.
  2. Enviar 20 peticiones alternadas a A y B.
- **Resultado esperado:** Las 20 peticiones responden HTTP 200 y no hay errores 5xx.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-008


#### CP-070: Tiempo de análisis por IA

- **ID:** CP-070
- **Nombre:** Tiempo de análisis por IA
- **Descripción:** Verificar el tiempo de las operaciones de IA.
- **Datos de entrada:** 50 desgloses, 50 sugerencias de fechas y 50 evaluaciones con latencia simulada de 5 a 20 s.
- **Pasos a ejecutar:**
  1. Ejecutar las operaciones.
  2. Calcular el percentil 95 del tiempo hasta el resultado persistido.
- **Resultado esperado:** p95 ≤ 60 s en los tres tipos de operación; el desglose se mide como una solicitud síncrona completa, sin que el cliente ni el proxy corten la espera antes de 100 s.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-015


#### CP-071: Observación de disponibilidad de 7 días

- **ID:** CP-071
- **Nombre:** Observación de disponibilidad de 7 días
- **Descripción:** Verificar la meta de disponibilidad en el entorno de demostración.
- **Datos de entrada:** monitor externo cada 5 min durante 7 días.
- **Pasos a ejecutar:**
  1. Configurar el monitor sobre el endpoint de salud.
  2. Recolectar 2 016 comprobaciones.
  3. Descontar mantenimientos anunciados.
- **Resultado esperado:** No más de 20 comprobaciones fallidas (disponibilidad ≥ 99 %).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-004


#### CP-072: Auditoría de accesibilidad WCAG 2.2 AA

- **ID:** CP-072
- **Nombre:** Auditoría de accesibilidad WCAG 2.2 AA
- **Descripción:** Verificar el cumplimiento de accesibilidad.
- **Datos de entrada:** todas las pantallas; flujos CU-001, CU-002, CU-005, CU-013, CU-031 (calendario de actividad) y CU-032 (desglose manual).
- **Pasos a ejecutar:**
  1. Ejecutar axe-core o WAVE en cada pantalla.
  2. Recorrer los 6 flujos solo con teclado.
  3. Medir contraste y tamaño de objetivos táctiles.
  4. Verificar que ningún estado dependa solo del color.
- **Resultado esperado:** 0 violaciones críticas o serias; los flujos se completan sin trampas de foco; contraste de texto ≥ 4,5:1; objetivos ≥ 24×24 px; checklist por pantalla firmado.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-009


#### CP-073: Compatibilidad de navegadores y responsividad

- **ID:** CP-073
- **Nombre:** Compatibilidad de navegadores y responsividad
- **Descripción:** Verificar el funcionamiento en navegadores y desde 320 px.
- **Datos de entrada:** Chrome, Firefox, Edge, Safari (escritorio), Chrome Android y Safari iOS 16; anchos de 320, 375, 768 y 1440 px.
- **Pasos a ejecutar:**
  1. Ejecutar los flujos CU-001, CU-005, CU-009 y CU-013 en cada navegador y ancho.
  2. A 320 px de ancho, abrir el perfil con el calendario de actividad y la vista de tabla o lista.
- **Resultado esperado:** Sin desbordamiento horizontal ni elementos inaccesibles; los flujos se completan en todos. A 320 px el calendario de actividad se desplaza solo dentro de su contenedor y la vista de tabla o lista muestra la misma información sin desplazamiento horizontal.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-010


#### CP-074: Integridad declarativa y por triggers en la BD

- **ID:** CP-074
- **Nombre:** Integridad declarativa y por triggers en la BD
- **Descripción:** Verificar CHECK, UNIQUE, FK y triggers directamente por SQL.
- **Datos de entrada:** inserciones por SQL: categoría fuera de catálogo, tercera evidencia, segunda evaluación para una evidencia, dictamen distinto de excelente, incoherente o invalida, estado pendiente_evidencia en una submeta, horario_fin 24:00 y horario_fin posterior a 24:00, dos submetas de la misma meta con la misma fecha, una submeta de 90 minutos y otra de 0 h, dos registros de uso para la misma evaluación, borrado de una meta, carga al 79 %, segunda evidencia con la primera Excelente o En evaluación, puntaje 91 con dos envíos, cambio de rol de un cliente con metas, cambio de rol por UPDATE directo de una cuenta sin datos, bloqueo del único super sin bloquear, meta de 1 día con 25 h, meta de 3 días con 2 h, meta de 3 días destinados en un rango de 2 fechas, evaluación evaluada con 30 puntos, códigos de recuperación con vigencia de 9 min y de 11 min (y uno de 10 min), modo de desglose fuera de catálogo, eliminación de una cuenta con registros de uso del LLM y de un administrador que cerró una submeta; además, la creación del desglose de una meta de 6 h con submetas que suman 5 h mediante el procedimiento o la transacción de creación (RF-META-034).
- **Pasos a ejecutar:**
  1. Ejecutar cada sentencia contra el esquema del script .sql.
  2. Ejecutar la creación del desglose de la meta de 6 h con submetas que suman 5 h mediante el procedimiento o la transacción que crea el desglose, y consultar las submetas de la meta.
- **Resultado esperado:** Todas las inserciones y cambios inválidos son rechazados, incluidos el estado pendiente_evidencia, la hora de fin posterior a 24:00, el segundo envío con el primero Excelente o En evaluación, el puntaje superior a 90 con dos envíos, el cambio de rol con datos y el bloqueo del único super; horario_fin = 24:00 se acepta; dos registros de uso para la misma evaluación se aceptan; el borrado de la meta elimina sus dependientes; cada regla de BR-001, BR-013, BR-021, RF-EVID-016 y RF-AUT-010 tiene un trigger que la rechaza: el código de 9 min y el de 11 min se rechazan (solo el de 10 min = 600 s se acepta), el cambio de rol por UPDATE directo se rechaza y el bloqueo del único super se rechaza también con dos operaciones simultáneas. El límite de 24 h por día (BR-011), la meta de 3 días con 2 h, la meta con más días destinados que días en el rango y la evaluación con 30 puntos las rechaza un CHECK (RNF-011), no un trigger. Dos submetas de la misma meta con la misma fecha son rechazadas por SQL; una submeta de 90 minutos o de 0 h es rechazada por CHECK (RNF-011); la creación del desglose con una suma de duraciones distinta del tiempo total es rechazada por la transacción de creación, sin dejar ninguna submeta persistida (no hay trigger para esta regla, RNF-014); un modo de desglose fuera de catálogo es rechazado; al eliminar una cuenta por SQL no se espera que un trigger actúe sobre las filas borradas en cascada (las acciones referenciales de MariaDB no activan triggers); al eliminar la cuenta, la meta, la evaluación o el administrador que cerró una submeta, los registros de uso del LLM y la submeta se conservan con el vínculo vacío (ON DELETE SET NULL).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-011, RNF-012, RNF-013, RNF-014, RF-EVID-016, RF-PUNT-004, RF-ADM-009, RF-ADM-004


#### CP-075: Inspección de contraseñas, TLS y archivos

- **ID:** CP-075
- **Nombre:** Inspección de contraseñas, TLS y archivos
- **Descripción:** Verificar el cifrado de contraseñas, TLS, acceso a archivos y tipo real de archivo.
- **Datos de entrada:** volcado de la tabla de usuarios; escáner TLS; solicitud anónima y ajena a un archivo; ejecutable renombrado como .png.
- **Pasos a ejecutar:**
  1. Revisar los hashes.
  2. Ejecutar el escáner TLS y una petición HTTP.
  3. Solicitar el archivo de evidencia sin sesión y con otro usuario.
  4. Subir el ejecutable renombrado.
- **Resultado esperado:** Hashes bcrypt costo ≥ 12 o argon2id; sin protocolos < TLS 1.2 y con redirección 301; archivo anónimo 401 y ajeno 404; el ejecutable responde HTTP 415.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-005, RNF-006, RNF-016, RNF-022


#### CP-076: Resistencia a intentos concurrentes de inicio de sesión

- **ID:** CP-076
- **Nombre:** Resistencia a intentos concurrentes de inicio de sesión
- **Descripción:** Verificar el bloqueo bajo concurrencia.
- **Datos de entrada:** 20 solicitudes simultáneas con contraseña inválida a la misma cuenta.
- **Pasos a ejecutar:**
  1. Lanzar las 20 solicitudes en paralelo.
  2. Leer el contador y el estado.
- **Resultado esperado:** Exactamente 1 bloqueo; contador final 5; sin inicio de sesión exitoso en 15 min.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-007


#### CP-077: Operación con el LLM caído

- **ID:** CP-077
- **Nombre:** Operación con el LLM caído
- **Descripción:** Verificar la degradación controlada.
- **Datos de entrada:** LLM simulado caído; 20 ejecuciones.
- **Pasos a ejecutar:**
  1. Probar inicio de sesión, agenda, perfil, ranking, Pomodoro, meta de 1 día de hasta 12 h, meta de 1 día de 18 h guardada sin recomendaciones, meta multidía con desglose manual y administración.
- **Resultado esperado:** El 100 % de las 20 ejecuciones responde con éxito; solo las funciones de IA reportan error.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-018, RF-META-030, RF-META-033


#### CP-078: Prueba de usabilidad de la primera meta

- **ID:** CP-078
- **Nombre:** Prueba de usabilidad de la primera meta
- **Descripción:** Verificar el tiempo de la primera meta.
- **Datos de entrada:** 5 personas nuevas, sin asistencia.
- **Pasos a ejecutar:**
  1. Pedir a cada persona crear una meta de 1 día.
  2. Cronometrar.
- **Resultado esperado:** Al menos 4 de 5 completan la tarea en ≤ 3 min.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-019


#### CP-079: Cobertura de pruebas y registros

- **ID:** CP-079
- **Nombre:** Cobertura de pruebas y registros
- **Descripción:** Verificar la cobertura, la localización y los registros.
- **Datos de entrada:** informe de cobertura; pantallas; log tras un error 5xx y una llamada al LLM.
- **Pasos a ejecutar:**
  1. Generar el informe de cobertura.
  2. Revisar textos y formatos de fecha en dos zonas.
  3. Provocar un error 5xx y una llamada al LLM y revisar el log.
- **Resultado esperado:** Cobertura ≥ 70 % en puntuación, ventanas y planificación; interfaz en español y 13:00 UTC mostrado 08:00 en Bogotá y 10:00 en Buenos Aires; ambos eventos en el log con marca de tiempo e identificador y retención ≥ 30 días. El log no contiene nombre, correo ni contenido de evidencias.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-017, RNF-020, RNF-021


#### CP-080: Tiempos de entrega de notificaciones push

- **ID:** CP-080
- **Nombre:** Tiempos de entrega de notificaciones push
- **Descripción:** Verificar el plazo de entrega de notificaciones.
- **Datos de entrada:** 20 eventos de prueba.
- **Pasos a ejecutar:**
  1. Generar los eventos.
  2. Medir el tiempo entre el evento y la entrega al servicio de notificaciones.
- **Resultado esperado:** Al menos el 95 % se entrega en ≤ 60 s.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RNF-023


#### CP-081: Puntaje E-04: Incoherente inicial (50) + Incoherente inicial (25) = 75

- **ID:** CP-081
- **Nombre:** Puntaje E-04: Incoherente inicial (50) + Incoherente inicial (25) = 75
- **Descripción:** Verificar la fila E-04 de la tabla de puntaje (3.6.1): Incoherente inicial (50) + Incoherente inicial (25) = 75.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Incoherente; 2.º envío en el periodo inicial (minuto 55) con dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 50 puntos provisionales ('Provisional: 50'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 55 (antes del fin del tiempo estipulado) con dictamen simulado Incoherente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 50; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en el periodo inicial): 25; suma 75; puntaje final 75; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 75 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012


#### CP-082: Puntaje E-05: Incoherente inicial (50) + Inválida inicial (0) = 50

- **ID:** CP-082
- **Nombre:** Puntaje E-05: Incoherente inicial (50) + Inválida inicial (0) = 50
- **Descripción:** Verificar la fila E-05 de la tabla de puntaje (3.6.1): Incoherente inicial (50) + Inválida inicial (0) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Incoherente; 2.º envío en el periodo inicial (minuto 55) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 50 puntos provisionales ('Provisional: 50'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 55 (antes del fin del tiempo estipulado) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 50; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en el periodo inicial): 0; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012


#### CP-083: Puntaje E-06: Incoherente inicial (50) + Excelente en gracia (50) = 90 (suma 100, tope 90)

- **ID:** CP-083
- **Nombre:** Puntaje E-06: Incoherente inicial (50) + Excelente en gracia (50) = 90 (suma 100, tope 90)
- **Descripción:** Verificar la fila E-06 de la tabla de puntaje (3.6.1): Incoherente inicial (50) + Excelente en gracia (50) = 90 (suma 100, tope 90).
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Incoherente; 2.º envío en la gracia (minuto 62) con dictamen Excelente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 50 puntos provisionales ('Provisional: 50'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 62 (tiempo de gracia) con dictamen simulado Excelente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 50; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 50; suma 100; puntaje final 90 (tope de 90); cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 90 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-084: Puntaje E-08: Incoherente inicial (50) + Inválida en gracia (0) = 50

- **ID:** CP-084
- **Nombre:** Puntaje E-08: Incoherente inicial (50) + Inválida en gracia (0) = 50
- **Descripción:** Verificar la fila E-08 de la tabla de puntaje (3.6.1): Incoherente inicial (50) + Inválida en gracia (0) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Incoherente; 2.º envío en la gracia (minuto 62) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 50 puntos provisionales ('Provisional: 50'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 62 (tiempo de gracia) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 50; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 0; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-085: Puntaje E-09: Inválida inicial (0), sin 2.º envío = 0

- **ID:** CP-085
- **Nombre:** Puntaje E-09: Inválida inicial (0), sin 2.º envío = 0
- **Descripción:** Verificar la fila E-09 de la tabla de puntaje (3.6.1): Inválida inicial (0), sin 2.º envío = 0.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; sin 2.º envío.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. No enviar más evidencias y avanzar hasta el minuto 66 (fin de la gracia).
  5. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntaje final: 0; cierre al expirar la gracia (minuto 66); sin 2.º envío; el acumulado del perfil aumenta en 0.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-006


#### CP-086: Puntaje E-10: Inválida inicial (0) + Excelente inicial (50) = 50

- **ID:** CP-086
- **Nombre:** Puntaje E-10: Inválida inicial (0) + Excelente inicial (50) = 50
- **Descripción:** Verificar la fila E-10 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Excelente inicial (50) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en el periodo inicial (minuto 55) con dictamen Excelente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 55 (antes del fin del tiempo estipulado) con dictamen simulado Excelente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en el periodo inicial): 50; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012


#### CP-087: Puntaje E-11: Inválida inicial (0) + Incoherente inicial (25) = 25

- **ID:** CP-087
- **Nombre:** Puntaje E-11: Inválida inicial (0) + Incoherente inicial (25) = 25
- **Descripción:** Verificar la fila E-11 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Incoherente inicial (25) = 25.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en el periodo inicial (minuto 55) con dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 55 (antes del fin del tiempo estipulado) con dictamen simulado Incoherente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en el periodo inicial): 25; suma 25; puntaje final 25; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 25 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012


#### CP-088: Puntaje E-12: Inválida inicial (0) + Inválida inicial (0) = 0

- **ID:** CP-088
- **Nombre:** Puntaje E-12: Inválida inicial (0) + Inválida inicial (0) = 0
- **Descripción:** Verificar la fila E-12 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Inválida inicial (0) = 0.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en el periodo inicial (minuto 55) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 55 (antes del fin del tiempo estipulado) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en el periodo inicial): 0; suma 0; puntaje final 0; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 0 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012


#### CP-089: Puntaje E-13: Inválida inicial (0) + Excelente en gracia (50) = 50

- **ID:** CP-089
- **Nombre:** Puntaje E-13: Inválida inicial (0) + Excelente en gracia (50) = 50
- **Descripción:** Verificar la fila E-13 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Excelente en gracia (50) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en la gracia (minuto 62) con dictamen Excelente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 62 (tiempo de gracia) con dictamen simulado Excelente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 50; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-090: Puntaje E-14: Inválida inicial (0) + Incoherente en gracia (25) = 25

- **ID:** CP-090
- **Nombre:** Puntaje E-14: Inválida inicial (0) + Incoherente en gracia (25) = 25
- **Descripción:** Verificar la fila E-14 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Incoherente en gracia (25) = 25.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en la gracia (minuto 62) con dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 62 (tiempo de gracia) con dictamen simulado Incoherente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 25; suma 25; puntaje final 25; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 25 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-091: Puntaje E-15: Inválida inicial (0) + Inválida en gracia (0) = 0

- **ID:** CP-091
- **Nombre:** Puntaje E-15: Inválida inicial (0) + Inválida en gracia (0) = 0
- **Descripción:** Verificar la fila E-15 de la tabla de puntaje (3.6.1): Inválida inicial (0) + Inválida en gracia (0) = 0.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en el periodo inicial (minuto 50) con dictamen Inválida; 2.º envío en la gracia (minuto 62) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Avanzar al minuto 50 (periodo inicial, tras el umbral del minuto 48) y enviar la 1.ª evidencia con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 62 (tiempo de gracia) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 0; suma 0; puntaje final 0; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 0 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-092: Puntaje E-16: Excelente en gracia (50) = 50 y cierra

- **ID:** CP-092
- **Nombre:** Puntaje E-16: Excelente en gracia (50) = 50 y cierra
- **Descripción:** Verificar la fila E-16 de la tabla de puntaje (3.6.1): Excelente en gracia (50) = 50 y cierra.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Excelente; sin 2.º envío.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Excelente.
  3. Esperar el dictamen y verificar que la submeta pasa a finalizada en ese instante con 50 puntos.
  4. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 50; puntaje final: 50; cierre al dictamen del 1.er envío; el acumulado del perfil aumenta en 50.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-013, RF-EVID-010, RF-PUNT-007


#### CP-093: Puntaje E-17: Incoherente en gracia (25), sin 2.º envío = 25

- **ID:** CP-093
- **Nombre:** Puntaje E-17: Incoherente en gracia (25), sin 2.º envío = 25
- **Descripción:** Verificar la fila E-17 de la tabla de puntaje (3.6.1): Incoherente en gracia (25), sin 2.º envío = 25.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Incoherente; sin 2.º envío.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 25 puntos provisionales ('Provisional: 25'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. No enviar más evidencias y avanzar hasta el minuto 66 (fin de la gracia).
  5. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 25; puntaje final: 25; cierre al expirar la gracia (minuto 66); sin 2.º envío; el acumulado del perfil aumenta en 25.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-006, RF-PUNT-007, RF-EVID-010


#### CP-094: Puntaje E-18: Incoherente en gracia (25) + Excelente en gracia (50) = 75

- **ID:** CP-094
- **Nombre:** Puntaje E-18: Incoherente en gracia (25) + Excelente en gracia (50) = 75
- **Descripción:** Verificar la fila E-18 de la tabla de puntaje (3.6.1): Incoherente en gracia (25) + Excelente en gracia (50) = 75.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Incoherente; 2.º envío en la gracia (minuto 64) con dictamen Excelente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 25 puntos provisionales ('Provisional: 25'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Excelente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 25; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 50; suma 75; puntaje final 75; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 75 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-095: Puntaje E-19: Incoherente en gracia (25) + Incoherente en gracia (25) = 50

- **ID:** CP-095
- **Nombre:** Puntaje E-19: Incoherente en gracia (25) + Incoherente en gracia (25) = 50
- **Descripción:** Verificar la fila E-19 de la tabla de puntaje (3.6.1): Incoherente en gracia (25) + Incoherente en gracia (25) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Incoherente; 2.º envío en la gracia (minuto 64) con dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 25 puntos provisionales ('Provisional: 25'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Incoherente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 25; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 25; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-096: Puntaje E-20: Incoherente en gracia (25) + Inválida en gracia (0) = 25

- **ID:** CP-096
- **Nombre:** Puntaje E-20: Incoherente en gracia (25) + Inválida en gracia (0) = 25
- **Descripción:** Verificar la fila E-20 de la tabla de puntaje (3.6.1): Incoherente en gracia (25) + Inválida en gracia (0) = 25.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Incoherente; 2.º envío en la gracia (minuto 64) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Incoherente.
  3. Esperar el dictamen y verificar 25 puntos provisionales ('Provisional: 25'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 25; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 0; suma 25; puntaje final 25; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 25 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-097: Puntaje E-21: Inválida en gracia (0), sin 2.º envío = 0

- **ID:** CP-097
- **Nombre:** Puntaje E-21: Inválida en gracia (0), sin 2.º envío = 0
- **Descripción:** Verificar la fila E-21 de la tabla de puntaje (3.6.1): Inválida en gracia (0), sin 2.º envío = 0.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Inválida; sin 2.º envío.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. No enviar más evidencias y avanzar hasta el minuto 66 (fin de la gracia).
  5. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntaje final: 0; cierre al expirar la gracia (minuto 66); sin 2.º envío; el acumulado del perfil aumenta en 0.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-006, RF-PUNT-007, RF-EVID-010


#### CP-098: Puntaje E-22: Inválida en gracia (0) + Excelente en gracia (50) = 50

- **ID:** CP-098
- **Nombre:** Puntaje E-22: Inválida en gracia (0) + Excelente en gracia (50) = 50
- **Descripción:** Verificar la fila E-22 de la tabla de puntaje (3.6.1): Inválida en gracia (0) + Excelente en gracia (50) = 50.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Inválida; 2.º envío en la gracia (minuto 64) con dictamen Excelente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Excelente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 50; suma 50; puntaje final 50; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 50 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-099: Puntaje E-23: Inválida en gracia (0) + Incoherente en gracia (25) = 25

- **ID:** CP-099
- **Nombre:** Puntaje E-23: Inválida en gracia (0) + Incoherente en gracia (25) = 25
- **Descripción:** Verificar la fila E-23 de la tabla de puntaje (3.6.1): Inválida en gracia (0) + Incoherente en gracia (25) = 25.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Inválida; 2.º envío en la gracia (minuto 64) con dictamen Incoherente.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Incoherente.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 25; suma 25; puntaje final 25; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 25 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-100: Puntaje E-24: Inválida en gracia (0) + Inválida en gracia (0) = 0

- **ID:** CP-100
- **Nombre:** Puntaje E-24: Inválida en gracia (0) + Inválida en gracia (0) = 0
- **Descripción:** Verificar la fila E-24 de la tabla de puntaje (3.6.1): Inválida en gracia (0) + Inválida en gracia (0) = 0.
- **Datos de entrada:** Submeta de 60 min con evidencia requerida (inicio del reloj en el minuto 0, umbral de carga en el minuto 48, fin del tiempo estipulado en el minuto 60, fin de la gracia en el minuto 66); reloj y LLM simulados. 1.er envío en la gracia (minuto 62) con dictamen Inválida; 2.º envío en la gracia (minuto 64) con dictamen Inválida.
- **Pasos a ejecutar:**
  1. Iniciar la submeta en el minuto 0.
  2. Dejar pasar el minuto 60 sin enviar nada (se abre la gracia de 6 min) y enviar la 1.ª evidencia en el minuto 62 con dictamen simulado Inválida.
  3. Esperar el dictamen y verificar 0 puntos provisionales ('Provisional: 0'), la submeta abierta y el segundo envío habilitado de inmediato.
  4. Enviar la 2.ª evidencia en el minuto 64 (dentro de la gracia restante) con dictamen simulado Inválida.
  5. Esperar el dictamen y verificar que la submeta cierra en ese instante, sin esperar el minuto 66.
  6. Verificar el puntaje final de la submeta, el acumulado del perfil (que aumenta una sola vez) y que un envío adicional responde HTTP 409.
- **Resultado esperado:** Puntos del 1.er envío: 0; puntos del 2.º envío (la mitad de la tabla del periodo inicial, enviado en la gracia): 0; suma 0; puntaje final 0; cierre al dictamen del 2.º envío; el acumulado del perfil aumenta en 0 una sola vez.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-002, RF-PUNT-010, RF-PUNT-014, RF-PUNT-004, RF-PUNT-005, RF-PUNT-013, RF-EVID-007, RF-EVID-012, RF-PUNT-007, RF-EVID-010


#### CP-101: Impecable y racha perfecta solo con acierto en el primer envío del periodo inicial

- **ID:** CP-101
- **Nombre:** Impecable y racha perfecta solo con acierto en el primer envío del periodo inicial
- **Descripción:** Verificar que la racha perfecta y el logro Impecable cuenten únicamente los cierres por acierto Excelente en el primer envío recibido en el periodo inicial.
- **Datos de entrada:** usuario A: tres submetas cerradas con primer envío Excelente en el periodo inicial (100), una submeta de una meta sin evidencia, una cerrada por un segundo envío Excelente (90) y otra con primer envío Excelente en el periodo inicial; usuario B: una submeta cuyo primer envío Excelente se recibe en gracia (50 puntos).
- **Pasos a ejecutar:**
  1. Usuario A: cerrar las tres primeras submetas con acierto en el primer envío y consultar la racha perfecta y los logros.
  2. Usuario A: cerrar una submeta de una meta sin evidencia y consultar la racha perfecta.
  3. Usuario A: cerrar una submeta con segundo envío Excelente (90) y consultar la racha perfecta.
  4. Usuario A: cerrar otra submeta con acierto en el primer envío y consultar la racha perfecta.
  5. Usuario B: cerrar una submeta con primer envío Excelente recibido en la gracia (50) y consultar sus logros y su racha perfecta.
- **Resultado esperado:** Usuario A: la racha perfecta pasa por 1, 2 y 3; la submeta sin calificación no la altera (sigue en 3); la de 90 puntos la reinicia a 0; la siguiente con acierto la lleva a 1; 'Impecable' se otorga una sola vez con el primer acierto y nunca por la submeta de 90; usuario B: no obtiene 'Impecable' y su racha perfecta es 0; ningún logro suma puntos.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-012, RF-LOGR-002, RF-LOGR-001


#### CP-102: Alta del primer administrador super por variables de entorno y protección del último super

- **ID:** CP-102
- **Nombre:** Alta del primer administrador super por variables de entorno y protección del último super
- **Descripción:** Verificar la creación única del primer administrador super con variables de entorno, la ausencia de pantalla pública de configuración y que el último super no pueda eliminarse, bloquearse ni degradarse. **[Supuesto S-47]**
- **Datos de entrada:** BD sin ningún administrador super; otra BD con solo un administrador moderador y sin super; variables de entorno con correo y contraseña inicial 'Inicial1234'; segundo arranque, con y sin variables; intentos de eliminar, bloquear, cambiar el rol y cambiar el nivel del último super; dos supers que se bloquean a la vez; correo de las variables ya registrado como cliente.
- **Pasos a ejecutar:**
  1. Arrancar el despliegue con las variables sobre la BD vacía e iniciar sesión.
  2. Buscar en las rutas y en la interfaz una pantalla o endpoint público de configuración inicial.
  3. Arrancar de nuevo, con y sin variables.
  4. Con ese super, intentar eliminar su cuenta, bloquearla, cambiar su rol y cambiar su nivel.
  5. Crear un segundo super y repetir los cambios sobre el primero.
  6. Con dos supers, bloquear a uno e intentar bloquear al otro.
  7. Con un super bloqueado administrativamente y otro sin bloquear, intentar eliminar, bloquear o degradar al que no está bloqueado.
  8. Con dos supers, bloquearse mutuamente a la vez desde dos sesiones.
  9. Arrancar con las variables cuyo correo ya pertenece a una cuenta cliente.
  10. Arrancar con las variables sobre la BD que solo tiene un administrador moderador, y arrancar de nuevo.
- **Resultado esperado:** El primer arranque crea exactamente una cuenta super que inicia sesión, con la contraseña cifrada; no existe ninguna pantalla ni endpoint público de configuración; los arranques siguientes no crean ni modifican cuentas; con un único super las cuatro operaciones responden HTTP 409; con dos supers el cambio sobre uno de ellos se permite, pero no el bloqueo del último super sin bloquear. Con un super bloqueado y otro sin bloquear, eliminar, bloquear o degradar al segundo responde HTTP 409. Con dos bloqueos simultáneos exactamente uno se completa y el otro responde HTTP 409, y siempre queda un super sin bloquear; con el correo ya registrado no se modifica esa cuenta, no se crea otra y el arranque deja un aviso en el log. Sobre la BD con solo un moderador el primer arranque crea un super que inicia sesión y no modifica al moderador, y el segundo arranque no crea ninguna cuenta.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-017, RF-ADM-009, RF-ADM-010, RF-ADM-014, RF-ADM-004


#### CP-103: Segundo envío rechazado si el primero no tiene dictamen Incoherente o Inválida

- **ID:** CP-103
- **Nombre:** Segundo envío rechazado si el primero no tiene dictamen Incoherente o Inválida
- **Descripción:** Verificar que el segundo envío solo se admita tras un primer dictamen Incoherente o Inválida.
- **Datos de entrada:** submeta de 60 min; primer envío En evaluación; primer envío en Error; primer envío Excelente; primer envío Incoherente.
- **Pasos a ejecutar:**
  1. Enviar la evidencia 1 y, sin esperar el dictamen, intentar el segundo envío.
  2. Provocar un Error en la evaluación e intentar el segundo envío.
  3. En otra submeta, obtener Excelente e intentar el segundo envío.
  4. En otra submeta, obtener Incoherente y enviar el segundo envío.
- **Resultado esperado:** Con el primero En evaluación, en Error o Excelente el segundo envío responde HTTP 409 y no se persiste; con el primero Incoherente se acepta.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-016, RF-EVID-007


#### CP-104: Meta de 24 horas en un día con horario hasta 24:00

- **ID:** CP-104
- **Nombre:** Meta de 24 horas en un día con horario hasta 24:00
- **Descripción:** Verificar que una submeta pueda terminar a las 24:00 y que la regla del 80 % y la gracia se calculen sobre su tiempo estipulado.
- **Datos de entrada:** meta de 1 día, 24 h, horario 00:00 a 24:00; submeta con hora de fin 00:00 o 24:01.
- **Pasos a ejecutar:**
  1. Crear la meta de 24 h en un día con horario 00:00 a 24:00.
  2. Consultar la submeta, el umbral de carga y la gracia.
  3. Intentar crear una submeta con hora de fin 00:00 o 24:01.
- **Resultado esperado:** La meta se acepta con una submeta de 00:00 a 24:00 y tiempo estipulado de 24 h; la carga se habilita a las 19:12 y la gracia dura 2 h 24 min; una hora de fin de 00:00 o 24:01 responde HTTP 422.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-005, RF-META-010, RF-META-020, RF-META-031, RF-PUNT-007


#### CP-105: Puntaje acumulado del usuario y ranking

- **ID:** CP-105
- **Nombre:** Puntaje acumulado del usuario y ranking
- **Descripción:** Verificar que el acumulado sea la suma de los puntajes finales de las submetas cerradas con calificación y que el ranking lo use.
- **Datos de entrada:** tres submetas cerradas con 100, 90 y 50; una submeta abierta con 50 provisionales; una submeta sin calificación; dos usuarios con acumulados 240 y 200.
- **Pasos a ejecutar:**
  1. Cerrar las tres submetas y consultar el acumulado.
  2. Consultar el acumulado con la submeta abierta y con la sin calificación.
  3. Eliminar la meta de una de las submetas cerradas y consultar el acumulado.
  4. Consultar el ranking.
- **Resultado esperado:** El acumulado es 240; la submeta abierta, la sin calificación y la eliminación de la meta no lo alteran; el ranking ordena 240 antes que 200.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-014, RF-PUNT-008, RF-RANK-001


#### CP-106: Rechazo del consentimiento de IA: uso solo con metas sin evidencia

- **ID:** CP-106
- **Nombre:** Rechazo del consentimiento de IA: uso solo con metas sin evidencia
- **Descripción:** Verificar que el usuario que rechaza el servicio externo de IA pueda usar la aplicación con metas sin evidencia, incluidas las multidía con desglose manual, y que toda función dependiente de la IA quede denegada. **[Supuesto S-46]**
- **Datos de entrada:** usuario nuevo que rechaza el aviso; metas: 1 día de 8 h sin evidencia, 1 día de 18 h sin evidencia, 1 día de 8 h con evidencia, 3 días sin evidencia con desglose manual, 3 días con desglose automático; solicitud de fechas sugeridas; LLM simulado con registro de llamadas.
- **Pasos a ejecutar:**
  1. Registrar al usuario y rechazar el aviso de IA cuando aparezca.
  2. Crear la meta de 1 día de 8 h sin evidencia y la de 1 día de 18 h sin evidencia.
  3. Crear la meta de 3 días sin evidencia con desglose manual (detalle en CP-116).
  4. Intentar crear la meta de 1 día con evidencia, la meta de 3 días con desglose automático y la solicitud de fechas sugeridas.
  5. Iniciar la submeta de la meta de 8 h y usar la agenda, el Pomodoro, el perfil y el ranking.
  6. Aceptar el aviso y repetir la creación de la meta con evidencia.
- **Resultado esperado:** Las dos metas de 1 día sin evidencia se guardan con su submeta única y sin recomendaciones, y la meta de 3 días con desglose manual se guarda con sus submetas, todas con 0 llamadas al LLM simulado; la meta con evidencia, la de 3 días con desglose automático y las fechas sugeridas responden HTTP 403 con el aviso de consentimiento y 0 llamadas al LLM; agenda, Pomodoro, perfil y ranking funcionan; tras aceptar, la meta con evidencia se guarda.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-010, RF-IA-007, RF-META-030, RF-IA-011, RF-META-033


#### CP-107: Calendario de actividad de 12 meses con un solo tono de verde

- **ID:** CP-107
- **Nombre:** Calendario de actividad de 12 meses con un solo tono de verde
- **Descripción:** Verificar que el perfil muestre los últimos 12 meses y que todo día activo, y solo ese, aparezca en el mismo tono de verde.
- **Datos de entrada:** usuario con días activos hace 11 meses, hace 13 meses, el mes pasado (1 submeta), y hoy (4 submetas); un día con solo inicio de sesión; un día con solo un inicio automático de una submeta; usuario sin actividad.
- **Pasos a ejecutar:**
  1. Abrir el perfil del usuario con actividad y medir el rango de fechas del calendario.
  2. Comparar el color de los días con 1 y con 4 submetas.
  3. Revisar el día con solo inicio de sesión y el día de hace 13 meses.
  4. Abrir el perfil del usuario sin actividad.
- **Resultado esperado:** El calendario cubre los 12 meses móviles que terminan hoy (BR-034); los días activos de hace 11 meses, del mes pasado y de hoy aparecen en el mismo tono de verde, sin gradaciones por número de submetas; el día con solo inicio de sesión, el del inicio automático y el de hace 13 meses no aparecen en verde; el usuario sin actividad ve el calendario completo sin días verdes.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-003, RF-PER-002


#### CP-108: Accesibilidad del calendario de actividad

- **ID:** CP-108
- **Nombre:** Accesibilidad del calendario de actividad
- **Descripción:** Verificar que el calendario de actividad no dependa solo del color y se pueda usar con teclado y lector de pantalla.
- **Datos de entrada:** calendario de un usuario con 5 días activos; lector de pantalla (NVDA o VoiceOver); simulación de daltonismo; solo teclado.
- **Pasos a ejecutar:**
  1. Recorrer el calendario con un lector de pantalla.
  2. Aplicar la simulación de daltonismo y revisar si se distingue el día activo.
  3. Recorrer el calendario solo con el teclado, abrir el detalle de un día y cerrarlo con Escape.
  4. Cambiar a la vista de tabla.
  5. Medir el contraste de la celda activa, de la no activa y del foco.
  6. Revisar un día activo solo por el envío de una evidencia (sin submetas iniciadas a mano ese día).
- **Resultado esperado:** El lector anuncia cada celda como 'fecha, activo, N submetas' o 'fecha, sin actividad'; con la simulación de daltonismo los días activos se identifican por texto o forma; el recorrido con el teclado no tiene trampas de foco y el detalle muestra la fecha y '3 submetas' (por ejemplo) y se cierra con Escape; la tabla lista los 5 días activos con sus contadores; los contrastes son ≥ 3:1. Un día activo solo por el envío de una evidencia se anuncia 'fecha, activo, 0 submetas' y aparece en la tabla con 0 submetas.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-013, RF-PER-014, RF-PER-015, RF-PER-016, RF-PER-011


#### CP-109: Detección de la zona horaria en el registro

- **ID:** CP-109
- **Nombre:** Detección de la zona horaria en el registro
- **Descripción:** Verificar que la cuenta nueva reciba la zona horaria del navegador y que se use America/Bogota solo si no se detecta.
- **Datos de entrada:** navegador en America/Argentina/Buenos_Aires; navegador que no informa zona; navegador que informa 'Mars/Olympus'.
- **Pasos a ejecutar:**
  1. Registrar una cuenta desde el navegador en America/Argentina/Buenos_Aires y consultar la zona del perfil.
  2. Registrar otra cuenta con un navegador que no informa zona.
  3. Registrar otra cuenta con la zona 'Mars/Olympus'.
  4. Cambiar la zona de la primera cuenta a America/Bogota.
- **Resultado esperado:** La primera cuenta queda con America/Argentina/Buenos_Aires sin que el visitante la escriba; la segunda y la tercera quedan con America/Bogota; la zona se puede modificar en el perfil y los horarios se muestran en la nueva zona.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-015, RF-PER-008


#### CP-110: Listado de evaluaciones en Error persistente (48 h)

- **ID:** CP-110
- **Nombre:** Listado de evaluaciones en Error persistente (48 h)
- **Descripción:** Verificar que el listado del administrador muestre las evaluaciones en Error desde hace 48 horas o más y solo ellas.
- **Datos de entrada:** evaluaciones en Error desde hace 47 h 59 min, 48 h y 60 h; una evaluación reintentada con éxito; una cuyo Reintentar la devolvió a Error hace 1 h; administradores super, moderador y soporte; reloj simulado.
- **Pasos a ejecutar:**
  1. Abrir el listado como super.
  2. Avanzar el reloj 1 minuto y consultar de nuevo.
  3. Consultar el listado como soporte.
  4. Revisar la evaluación reintentada con éxito y la devuelta a Error hace 1 h.
- **Resultado esperado:** A las 47 h 59 min la evaluación no aparece y al cumplirse 48 h aparece; la de 60 h aparece; la reintentada con éxito no aparece; la devuelta a Error hace 1 h no aparece (la cuenta comenzó de nuevo); el soporte recibe HTTP 403; cada fila muestra submeta, usuario e instante del Error.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-018


#### CP-111: Cierre administrativo con puntaje provisional

- **ID:** CP-111
- **Nombre:** Cierre administrativo con puntaje provisional
- **Descripción:** Verificar que el administrador cierre una submeta con evaluación en Error persistente asignándole su puntaje provisional.
- **Datos de entrada:** submeta A con primer envío Incoherente (50) y segundo envío en Error desde hace 48 h; submeta B con único envío en Error desde hace 48 h; submeta C con Error desde hace 47 h; administradores moderador y soporte.
- **Pasos a ejecutar:**
  1. Con el moderador, cerrar la submeta A y consultar el acumulado del usuario.
  2. Cerrar la submeta B.
  3. Intentar cerrar la submeta C.
  4. Con soporte, intentar cerrar otra submeta con 48 h de Error.
  5. Pulsar Reintentar sobre la evaluación de la submeta A como usuario.
- **Resultado esperado:** La submeta A queda finalizada con 50 puntos y el acumulado sube 50 una sola vez, con el administrador y la fecha registrados; la B queda finalizada con 0; la C responde HTTP 409; el soporte recibe HTTP 403; Reintentar tras el cierre responde HTTP 409; la racha perfecta del usuario no cambia. El cierre administrativo no activa el día activo del usuario.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-019, RF-PUNT-011, RF-PUNT-008, RF-PUNT-014, RF-EVID-008, RF-PER-002


#### CP-112: Dictamen tardío del primer envío: cierre al llegar el dictamen

- **ID:** CP-112
- **Nombre:** Dictamen tardío del primer envío: cierre al llegar el dictamen
- **Descripción:** Verificar que, si el dictamen del primer envío llega cuando la gracia ya terminó, la submeta cierre en ese instante con el puntaje de ese envío.
- **Datos de entrada:** submeta de 60 min; primer envío Incoherente recibido en el minuto 58; LLM simulado que dictamina en el minuto 70; reloj simulado.
- **Pasos a ejecutar:**
  1. Enviar la evidencia en el minuto 58.
  2. Avanzar hasta el minuto 66 sin dictamen y verificar la submeta abierta.
  3. Hacer llegar el dictamen Incoherente en el minuto 70.
  4. Intentar un segundo envío y consultar el puntaje y el acumulado.
- **Resultado esperado:** En el minuto 66 la submeta sigue abierta por la evaluación pendiente; al llegar el dictamen en el minuto 70 se cierra en ese instante con 50 puntos y el acumulado sube 50; el segundo envío responde HTTP 409.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PUNT-013, RF-PUNT-006, RF-PUNT-011


#### CP-113: Cambio de rol solo en cuentas sin datos

- **ID:** CP-113
- **Nombre:** Cambio de rol solo en cuentas sin datos
- **Descripción:** Verificar que el cambio de rol se acepte en cuentas sin datos y se rechace en cuentas con datos. **[Supuesto S-48]**
- **Datos de entrada:** cuenta cliente sin metas ni puntaje; cuenta cliente con una meta; cuenta cliente con 100 puntos; cuenta cliente que inició a mano una submeta y eliminó su meta (puntaje 0, con un día activo); administradores super y moderador; administrador que cerró una submeta. **[Supuesto S-54]**
- **Pasos a ejecutar:**
  1. Con el super, cambiar a administrador (nivel soporte) la cuenta sin datos.
  2. Con el super, intentar cambiar el rol de la cuenta con una meta y el de la cuenta con 100 puntos.
  3. Con el moderador, intentar cambiar el rol de la cuenta sin datos.
  4. Intentar cambiar a administrador sin indicar el nivel.
  5. Con el super, intentar cambiar a cliente al administrador que cerró una submeta.
  6. Con el super, intentar cambiar el rol del cliente que solo conserva un día activo.
- **Resultado esperado:** La cuenta sin datos pasa a administrador con nivel soporte; las cuentas con una meta o con puntos responden HTTP 409 y no cambian; el moderador recibe HTTP 403; sin nivel de acceso responde HTTP 422. El administrador que cerró una submeta responde HTTP 409 y no cambia; el cliente con un día activo responde HTTP 409 y no cambia.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-009


#### CP-114: Eliminación de cuenta en cascada

- **ID:** CP-114
- **Nombre:** Eliminación de cuenta en cascada
- **Descripción:** Verificar que eliminar una cuenta borre todos sus datos asociados y que la propia cuenta y el último super no se puedan eliminar. **[Supuesto S-45]**
- **Datos de entrada:** cuenta cliente con metas, submetas, evidencias, evaluaciones, sesiones Pomodoro, logros, suscripción push y 300 puntos en el ranking; registros de uso del LLM de esa cuenta; el administrador super único; administrador que cerró una submeta de otro usuario; archivos físicos de las evidencias en el almacén.
- **Pasos a ejecutar:**
  1. Eliminar la cuenta cliente confirmando.
  2. Consultar por SQL cada tabla dependiente y el ranking.
  3. Consultar las métricas del LLM.
  4. Intentar eliminar la propia cuenta y al único super.
  5. Eliminar al administrador que cerró una submeta y consultar esa submeta.
  6. Inspeccionar el almacén de archivos de la cuenta eliminada **[Supuesto S-53]**.
- **Resultado esperado:** La cuenta y todos sus datos dejan de existir y desaparece del ranking; los registros de uso del LLM permanecen sin vínculo con la cuenta y las métricas del LLM no cambian; eliminar la propia cuenta o al único super responde HTTP 409. La submeta cerrada por el administrador eliminado permanece finalizada con su fecha de cierre y el administrador vacío; el almacén no conserva ningún archivo de la cuenta eliminada; los registros de uso del LLM conservan costo, tokens y latencia con los vínculos vacíos.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-010, RF-ADM-011, RF-EVID-017


#### CP-115: Dictamen Inválida frente a Error y rechazo de archivos inválidos en la carga

- **ID:** CP-115
- **Nombre:** Dictamen Inválida frente a Error y rechazo de archivos inválidos en la carga
- **Descripción:** Verificar que un archivo vacío, corrupto, ilegible o de formato no soportado se rechace al subirlo sin consumir envío ni generar dictamen, que un contenido legible sin relación dictamine Inválida (0 puntos, consume el envío) y que un Error técnico no puntúe ni consuma envío.
- **Datos de entrada:** archivo de 0 bytes; PDF truncado; .xlsx sin hojas con datos; imagen no decodificable; ejecutable renombrado como .png; imagen en blanco y evidencia de otro tema (legibles); LLM simulado que responde Inválida; LLM simulado que no responde (Error); LLM simulado que responde 429 por cuota; submeta de 60 min con el 80 % transcurrido.
- **Pasos a ejecutar:**
  1. Subir el archivo de 0 bytes, el PDF truncado, el .xlsx sin hojas y la imagen no decodificable, y consultar la respuesta, la lista de evidencias, el número de envíos usados y las llamadas al LLM simulado.
  2. Subir el ejecutable renombrado como .png.
  3. Subir una imagen en blanco con el LLM simulado respondiendo Inválida; consultar el estado, los puntos y la acción disponible.
  4. En otra submeta, enviar una evidencia con el LLM sin respuesta hasta agotar los reintentos.
  5. Repetir con el LLM simulado respondiendo 429 en todos los reintentos.
  6. Consultar el estado, los puntos y la acción disponible; pulsar Reintentar con el LLM disponible.
  7. Tras un rechazo, subir un archivo válido en la misma submeta.
- **Resultado esperado:** Los cuatro archivos inválidos responden HTTP 422 con el motivo 'archivo vacío, corrupto o ilegible', no se persisten, no crean evaluación ni dictamen, no consumen envío, no activan el día activo y registran 0 llamadas al LLM simulado; el ejecutable renombrado responde HTTP 415 con los mismos efectos; el archivo válido posterior se acepta como primer envío; la imagen en blanco queda Evaluada con dictamen Inválida y 0 puntos, no ofrece Reintentar y consume el envío (queda el segundo envío); las evidencias sin respuesta o con cuota agotada quedan en Error, sin puntos y con la acción Reintentar; al reintentar se reevalúa la misma evidencia sin consumir envío y el contenido se prepara de nuevo a partir del archivo almacenado, porque no se persiste (RF-IA-012).
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-006, RF-EVID-008, RF-IA-008, RF-IA-012, RF-EVID-003


#### CP-116: Desglose manual de una meta multidía sin consentimiento de IA

- **ID:** CP-116
- **Nombre:** Desglose manual de una meta multidía sin consentimiento de IA
- **Descripción:** Verificar que el usuario que rechaza el servicio de IA cree una meta multidía sin evidencia armando sus submetas, y que se validen la suma, el horario y el consentimiento.
- **Datos de entrada:** usuario que rechazó el aviso de IA; meta de 3 días (10, 11 y 12 de diciembre), 6 h, horario 08:00 a 12:00; submetas 'Leer capítulo 1' 08:00 2 h, 'Resumir' 09:00 2 h, 'Ejercicios' 10:00 2 h; variantes: 2 h, 2 h y 1 h; 2 h, 2 h y 3 h; una submeta de 1,5 h; una submeta de 0 h; tres submetas de 1 h, 1 h y 4 h (suma 6 h); una submeta de 07:00 a 09:00; horario 00:00 a 24:00 con submetas que terminan a las 24:00 y a las 25:00; dos submetas en la misma fecha; la misma meta con evidencia; LLM simulado con registro de llamadas.
- **Pasos a ejecutar:**
  1. Crear la meta sin evidencia con las tres submetas indicadas.
  2. Intentar las variantes de suma (1 h de menos y 1 h de más) y la submeta de 07:00 a 09:00.
  3. Con horario 00:00 a 24:00, probar una submeta de 22:00 con duración 2 h y otra con duración 3 h; probar dos submetas en la misma fecha y una duración de 0; probar las duraciones de 1,5 h y de 1 h.
  4. Intentar crear la misma meta con evidencia y con desglose por IA.
  5. Consultar la agenda y el registro de llamadas al LLM simulado.
- **Resultado esperado:** La meta con las tres submetas se guarda (HTTP 201) con modo de desglose manual, nombre, fecha y horario de cada submeta, y 0 llamadas al LLM simulado; 2 h, 2 h y 1 h responden HTTP 422 'faltan 1 h' y 2 h, 2 h y 3 h responden HTTP 422 'sobran 1 h'; la submeta de 07:00 a 09:00 responde HTTP 422 indicando el campo; la de 22:00 con 2 h se acepta y la de 3 h se rechaza; la duración 0, la de 1,5 h (no entera) y las dos submetas en la misma fecha responden HTTP 422; la duración de 1 h se acepta (mínimo 1 h); la meta con evidencia y el desglose por IA responden HTTP 403 con el aviso de consentimiento y 0 llamadas; las submetas aparecen en la agenda.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-033, RF-META-034, RF-META-035, RF-IA-010, RF-IA-011, RF-META-005


#### CP-117: Desglose manual como alternativa para el usuario que aceptó la IA

- **ID:** CP-117
- **Nombre:** Desglose manual como alternativa para el usuario que aceptó la IA
- **Descripción:** Verificar que el usuario con aceptación registrada pueda elegir entre el desglose por IA y el manual, también en metas con evidencia.
- **Datos de entrada:** usuario con aceptación de IA registrada; meta de 3 días y 42 h (14 h por día) con evidencia y desglose manual; meta de 3 días y 6 h con desglose por IA; LLM simulado con registro de llamadas.
- **Pasos a ejecutar:**
  1. Abrir la creación de una meta de 3 días y comprobar las opciones de desglose.
  2. Crear la meta de 42 h con evidencia y elegir el desglose manual con tres submetas de 14 h.
  3. Revisar las recomendaciones y las llamadas registradas.
  4. Crear la meta de 6 h con desglose por IA.
  5. Cargar una evidencia en una submeta manual al superar el 80 % de su tiempo.
- **Resultado esperado:** Aparecen las opciones 'Desglose por IA' y 'Desglose manual'; con el manual se muestran las recomendaciones de RF-META-008 antes de guardar (14 h por día), no se registra ninguna llamada de desglose y la meta con evidencia se guarda con sus tres submetas; la meta con desglose por IA registra la llamada de desglose; la evidencia de la submeta manual se evalúa y puntúa como la de cualquier otra.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-036, RF-META-008, RF-META-003, RF-META-033


#### CP-118: Edición de metas y consentimiento de IA

- **ID:** CP-118
- **Nombre:** Edición de metas y consentimiento de IA
- **Descripción:** Verificar que la edición no eluda el consentimiento de IA y que las metas con desglose manual y las submetas iniciadas se editen según las reglas. **[Supuesto S-51]**
- **Datos de entrada:** usuario que rechazó el aviso de IA con una meta de 1 día sin evidencia (8 h) y una meta de 3 días con desglose manual sin submetas iniciadas; una meta con una submeta en curso; usuario con aceptación de IA; LLM simulado con registro de llamadas.
- **Pasos a ejecutar:**
  1. Editar la meta de 1 día para activar el requisito de evidencia.
  2. Editar la meta de 1 día para convertirla en multidía sin entregar desglose, pidiendo el desglose por IA y luego entregando un desglose manual válido.
  3. En la meta manual, cambiar el tiempo total sin entregar submetas nuevas y entregándolas con una suma incorrecta y con una suma correcta.
  4. En la meta con una submeta en curso, cambiar el modo de inicio y el requisito de evidencia; cambiar solo el nombre.
  5. Con el usuario que aceptó la IA, activar el requisito de evidencia en la primera meta.
- **Resultado esperado:** Activar la evidencia sin aceptación responde HTTP 403 con el aviso, 0 llamadas al LLM y la meta no cambia; convertirla en multidía sin entregar un desglose manual válido responde HTTP 422 con el campo faltante y la meta sin cambios (403 solo si se pide el desglose por IA sin aceptación), y con un desglose manual válido se acepta; cambiar el tiempo total de la meta manual sin submetas nuevas o con suma incorrecta responde HTTP 422 y no cambia, y con suma correcta se sustituyen las submetas; cambiar el modo de inicio o la evidencia con una submeta en curso responde HTTP 409 y el nombre se acepta; con aceptación registrada la activación de la evidencia se acepta.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-037, RF-META-027, RF-META-028, RF-IA-011


#### CP-119: Eliminación de los archivos físicos de las evidencias

- **ID:** CP-119
- **Nombre:** Eliminación de los archivos físicos de las evidencias
- **Descripción:** Verificar que eliminar una meta o una cuenta elimine también los archivos de sus evidencias del almacén. **[Supuesto S-53]**
- **Datos de entrada:** meta A con 2 evidencias; cuenta B con evidencias en 3 metas; cuenta C con 1 evidencia que no se elimina; acceso de inspección al almacén.
- **Pasos a ejecutar:**
  1. Anotar los archivos del almacén de la meta A, de la cuenta B y de la cuenta C.
  2. Eliminar la meta A confirmando y consultar el almacén y las rutas de sus archivos.
  3. Eliminar la cuenta B con un administrador super confirmando y consultar el almacén.
  4. Comprobar los archivos de la cuenta C.
- **Resultado esperado:** Tras eliminar la meta A, sus 2 archivos no existen en el almacén y una solicitud a su ruta responde 404; tras eliminar la cuenta B no queda ningún archivo suyo; el archivo de la cuenta C permanece intacto.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-017, RF-META-002c, RF-ADM-010


#### CP-120: Fallo del borrado de un archivo y limpieza programada con antigüedad mínima

- **ID:** CP-120
- **Nombre:** Fallo del borrado de un archivo y limpieza programada con antigüedad mínima
- **Descripción:** Verificar que un fallo al borrar un archivo no revierta la eliminación, que la limpieza programada lo complete sin tocar archivos con registro y que no borre un archivo sin registro con 1 hora o menos de antigüedad. **[Supuesto S-53]** **[Supuesto S-55]**
- **Datos de entrada:** meta con 2 evidencias; almacén simulado que falla al borrar uno de los archivos; archivo con registro de una meta vigente; archivo sin registro escrito hace 59 min (carga en curso; la antigüedad se mide desde su escritura en el almacén y el mínimo de 1 hora es el valor por defecto de un parámetro configurable); reloj simulado; ejecución de la limpieza.
- **Pasos a ejecutar:**
  1. Eliminar la meta con el almacén fallando en un archivo.
  2. Consultar el log y el almacén.
  3. Restablecer el almacén y ejecutar la limpieza programada con el archivo fallido ya de más de 1 hora de antigüedad.
  4. Escribir un archivo sin registro y ejecutar la limpieza a los 59 min; ejecutarla de nuevo a los 61 min sin que se confirme su registro.
  5. Avanzar el reloj 24 h y comprobar que se vuelve a ejecutar la limpieza.
  6. Verificar el archivo con registro de la meta vigente.
- **Resultado esperado:** La eliminación de la meta se completa (HTTP 200) y no se revierte; el fallo queda en el log con la ruta del archivo y el archivo permanece sin registro; al ejecutar la limpieza el archivo se elimina; el archivo sin registro de 59 min se conserva y el de 61 min se elimina; la limpieza se ejecuta de nuevo dentro de las 24 h siguientes; el archivo con registro no se elimina.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-EVID-018, RF-EVID-017, RF-META-002c


#### CP-121: Día activo: inicio manual, envío de evidencia y cierres del sistema o administrativos

- **ID:** CP-121
- **Nombre:** Día activo: inicio manual, envío de evidencia y cierres del sistema o administrativos
- **Descripción:** Verificar que solo el inicio manual de una submeta y el envío de una evidencia activen el día, y que el inicio automático, los cierres del sistema o administrativos y la finalización por sí misma no lo activen, incluida la meta sin evidencia.
- **Datos de entrada:** submeta de 22:00 a 24:00 de una meta sin evidencia en modo automático que cierra a las 00:00; submeta de 22:00 a 24:00 de una meta sin evidencia en modo manual iniciada a mano; submeta de 23:00 a 24:00 con primer envío Incoherente a las 23:50 y fin de la gracia a las 00:06 sin segundo envío; submeta cerrada por un administrador 49 h después de un Error; submeta manual de 23:00 a 24:00 (el 80 % se alcanza a las 23:48) iniciada a mano a las 23:00, con evidencia recibida a las 23:50 (83 % del tiempo) y dictaminada a las 00:40 del día siguiente (la evaluación en curso se completa aunque la gracia haya vencido); submeta automática con evidencia recibida un día en que el usuario no hizo nada más; reloj simulado.
- **Pasos a ejecutar:**
  1. Dejar vencer la submeta automática de la meta sin evidencia a las 00:00 sin intervención del usuario.
  2. Iniciar a mano la submeta de la meta sin evidencia y dejarla vencer.
  3. Enviar el primer envío Incoherente a las 23:50 y dejar que expire la gracia a las 00:06 sin segundo envío.
  4. Cerrar con un administrador la submeta con Error persistente.
  5. Iniciar a mano a las 23:00 la submeta de 23:00 a 24:00, enviar la evidencia a las 23:50 y recibir el dictamen Excelente a las 00:40 del día siguiente.
  6. En la submeta automática, enviar la evidencia en un día sin otra acción del usuario.
  7. Consultar el calendario de actividad y el detalle de cada día.
- **Resultado esperado:** El día de la submeta automática de la meta sin evidencia no queda activo; el día de la submeta iniciada a mano de la meta sin evidencia sí queda activo; el día siguiente al fin de la gracia no queda activo por ese cierre (el día del envío sí, por la evidencia enviada); el día del cierre administrativo no queda activo por ese cierre; en la submeta de 23:00 a 24:00 queda activo el día del inicio manual y del envío (el de la recepción a las 23:50), y el día del dictamen (00:40 del día siguiente) no queda activo salvo que el usuario actúe; el día del envío de la evidencia de la submeta automática queda activo; un día activo solo por el envío de una evidencia se anuncia 'fecha, activo, 0 submetas'.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-002, RF-ADM-019, RF-PER-013, RF-PUNT-006


#### CP-122: Cambio de rol, valores por defecto y zona horaria de las cuentas creadas por un administrador

- **ID:** CP-122
- **Nombre:** Cambio de rol, valores por defecto y zona horaria de las cuentas creadas por un administrador
- **Descripción:** Verificar los efectos del cambio de rol en cuentas sin datos, el rechazo en administradores con submetas cerradas y la zona horaria de las cuentas cliente creadas por un administrador o convertidas, que se detecta en su primer inicio de sesión. **[Supuesto S-54]**
- **Datos de entrada:** cuenta cliente sin datos con aceptación de IA y una suscripción push; cuenta administrador sin submetas cerradas; administrador que cerró una submeta; cuenta cliente creada por un administrador; navegadores en America/Argentina/Buenos_Aires, sin zona informada y con 'Mars/Olympus'; administrador super.
- **Pasos a ejecutar:**
  1. Con el super, cambiar la cuenta cliente sin datos a administrador de nivel soporte y consultar sus datos.
  2. Con el super, cambiar la cuenta administrador sin submetas cerradas a cliente y consultar la zona, las preferencias y la aceptación de IA.
  3. Intentar cambiar a cliente al administrador que cerró una submeta.
  4. Crear una cuenta cliente desde administración y consultar su zona horaria antes de su primer inicio de sesión.
  5. Iniciar sesión con una contraseña incorrecta y luego, por primera vez correctamente, desde un navegador en America/Argentina/Buenos_Aires; consultar la zona; iniciar sesión de nuevo desde un navegador en otra zona.
  6. Repetir el primer inicio de sesión con la cuenta convertida desde administrador usando un navegador que no informa zona y otro que informa 'Mars/Olympus'.
- **Resultado esperado:** La cuenta pasa a administrador sin zona, preferencias, aceptación de IA ni suscripciones push; la cuenta administrador pasa a cliente con zona America/Bogota (pendiente de detección), notificaciones push activadas, sin aceptación de IA y puntaje 0, y conserva identificador, nombre y correo; el administrador con una submeta cerrada responde HTTP 409 y no cambia; la cuenta creada por un administrador tiene America/Bogota antes de su primer inicio de sesión; el intento fallido no cuenta como primer inicio; en el primer inicio exitoso su zona pasa a America/Argentina/Buenos_Aires y el inicio siguiente desde otra zona no la sobrescribe; con un navegador sin zona o con zona no válida la cuenta conserva America/Bogota; el usuario puede cambiar la zona en su perfil.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-ADM-020, RF-ADM-021, RF-ADM-009, RF-AUT-016


#### CP-123: Cambio de zona horaria con metas y días activos existentes

- **ID:** CP-123
- **Nombre:** Cambio de zona horaria con metas y días activos existentes
- **Descripción:** Verificar que al cambiar la zona horaria se conserve la hora local de lo programado y el instante de lo ocurrido, sin recalcular los días activos. **[Supuesto S-52]**
- **Datos de entrada:** usuario en America/Bogota con una submeta automática pendiente el 10/12 a las 08:00, una submeta finalizada con inicio real a las 14:00 hora de Bogotá y 3 días activos registrados; cambio a America/Argentina/Buenos_Aires; reloj simulado.
- **Pasos a ejecutar:**
  1. Cambiar la zona del perfil a America/Argentina/Buenos_Aires.
  2. Consultar la agenda y el detalle de las submetas.
  3. Avanzar el reloj hasta el 10/12 a las 08:00 de Buenos Aires.
  4. Consultar el calendario de actividad.
- **Resultado esperado:** La submeta pendiente sigue programada el 10/12 a las 08:00 en la nueva zona y su inicio automático ocurre a esa hora local; la submeta finalizada muestra su inicio real convertido a la nueva zona (16:00) con el mismo instante; los 3 días activos no cambian en el calendario.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-PER-017, RF-PER-008, RF-META-013


#### CP-124: Declaración de mayoría de edad en el registro

- **ID:** CP-124
- **Nombre:** Declaración de mayoría de edad en el registro
- **Descripción:** Verificar que el registro exija la declaración 'Declaro ser mayor de 18 años', que guarde su sello de tiempo y que no pida ni guarde la fecha de nacimiento.
- **Datos de entrada:** registro con nombre=Luis, correo=luis@test.com, contraseña=Clave1234 y la declaración marcada; registro con la declaración ausente; registro con la declaración en falso; reloj del servidor conocido.
- **Pasos a ejecutar:**
  1. Registrar la cuenta con la declaración marcada y anotar el instante de envío.
  2. Consultar el sello de tiempo de la declaración guardado en la cuenta (inspección de la BD).
  3. Intentar el registro sin el campo de declaración.
  4. Intentar el registro con la declaración en falso.
  5. Revisar el formulario, las respuestas de la API y las columnas de la BD en busca de un campo de fecha de nacimiento.
- **Resultado esperado:** 1. HTTP 201 y la cuenta de rol cliente existe. 2. El sello de la declaración no es nulo y difiere del instante de envío en 5 s o menos. 3 y 4. HTTP 422 con el motivo MAYORIA_EDAD_REQUERIDA, sin crear la cuenta ni ninguna fila. 5. No existe ningún campo de fecha de nacimiento en el formulario, la API ni la BD.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-017, RF-AUT-001


#### CP-125: Declaración de mayoría de edad en el primer inicio de sesión de una cuenta creada por un administrador

- **ID:** CP-125
- **Nombre:** Declaración de mayoría de edad en el primer inicio de sesión de una cuenta creada por un administrador
- **Descripción:** Verificar que la cuenta cliente creada por un administrador o convertida desde administrador declare ser mayor de 18 años en su primer inicio de sesión exitoso y que hasta entonces no use las funciones de cliente. **[SUPUESTO S-R9]**
- **Datos de entrada:** cuenta cliente creada por un administrador; cuenta administrador sin datos convertida a cliente por el super; cuenta de autorregistro con declaración; una contraseña incorrecta.
- **Pasos a ejecutar:**
  1. Crear la cuenta cliente desde administración y consultar que no tiene sello de declaración.
  2. Iniciar sesión con una contraseña incorrecta.
  3. Iniciar sesión correctamente por primera vez y llamar a una función de cliente (por ejemplo, crear una meta).
  4. Declarar 'Declaro ser mayor de 18 años' y repetir la llamada.
  5. Cerrar sesión, iniciar de nuevo y llamar a la función.
  6. Convertir la cuenta administrador a cliente y repetir los pasos 3 a 5.
  7. Iniciar sesión con la cuenta de autorregistro y llamar a la función.
- **Resultado esperado:** La cuenta creada nace sin sello; el intento fallido responde HTTP 401 y no cuenta como primer inicio; en el primer inicio exitoso (HTTP 200) se informa que la declaración está pendiente y la función de cliente responde HTTP 403 con el motivo MAYORIA_EDAD_REQUERIDA; tras declarar queda guardado el sello de tiempo y la función se permite; en el inicio siguiente no se vuelve a pedir; la cuenta convertida se comporta igual; la cuenta de autorregistro no recibe el aviso ni el 403.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-AUT-018


#### CP-126: Recomendación de la IA sin consentimiento: la meta se guarda igual

- **ID:** CP-126
- **Nombre:** Recomendación de la IA sin consentimiento: la meta se guarda igual
- **Descripción:** Verificar que, cuando el usuario no ha aceptado el servicio externo de IA y solo falta la recomendación por superar 12 h por día, no se invoque la IA, la solicitud de recomendaciones se deniegue y la meta que no requiere evidencia se guarde igual.
- **Datos de entrada:** usuario que aún no ha aceptado el aviso de IA; metas sin evidencia: 1 día de 18 h, 3 días de 42 h (14 h por día) con desglose manual y 1 día de 8 h; LLM simulado con registro de llamadas.
- **Pasos a ejecutar:**
  1. Con el usuario que aún no aceptó el aviso, configurar la meta de 1 día de 18 h sin evidencia y solicitar las recomendaciones.
  2. No aceptar el aviso y guardar la meta.
  3. Repetir los pasos 1 y 2 con la meta de 3 días y 42 h con desglose manual.
  4. Crear la meta de 1 día de 8 h sin evidencia.
  5. Aceptar el aviso, solicitar las recomendaciones de una meta nueva de 1 día y 18 h y guardarla con la decisión del usuario.
- **Resultado esperado:** Las dos solicitudes de recomendaciones sin aceptación responden HTTP 403 con el aviso de consentimiento y registran 0 llamadas al LLM; ambas metas se guardan, la de 1 día con su submeta única y la de 3 días con sus submetas manuales, sin recomendaciones ni decisión de IA registrada; la meta de 8 h se guarda sin mostrar el aviso; tras aceptar, las recomendaciones se ofrecen y la decisión queda registrada.
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-META-008, RF-IA-007, RF-IA-011


#### CP-127: Minimización de datos enviados al proveedor de IA: sin EXIF ni identificadores del usuario

- **ID:** CP-127
- **Nombre:** Minimización de datos enviados al proveedor de IA: sin EXIF ni identificadores del usuario
- **Descripción:** Verificar que, antes de enviar una evidencia al proveedor de IA, se eliminen los metadatos EXIF de la imagen y se limite su resolución, que no se envíen el nombre, el correo, el id del usuario ni el nombre original del archivo, y que la evaluación siga funcionando. **[Supuesto S-R12]**
- **Datos de entrada:** usuario 'Ana' con correo ana@test.com y un id conocido, con el aviso de IA ya aceptado; archivo 'Ana_ana@test.com_evidencia.jpg' (JPEG de 6000 x 4000 px con EXIF de orientación 6, coordenadas GPS, fecha de captura, marca y modelo de cámara); archivo 'foto_ana.png' (PNG de 800 x 600 px con metadatos de texto de autor 'Ana'); LLM simulado que captura el cuerpo, las cabeceras y los nombres de archivo de cada solicitud y responde con el dictamen Excelente; resolución máxima configurada en el entorno de prueba (por ejemplo, 2048 px de lado mayor, valor de prueba que no fija el SRS). **[SUPUESTO S-R12]**
- **Pasos a ejecutar:**
  1. Con la evidencia habilitada, cargar 'Ana_ana@test.com_evidencia.jpg' en una submeta y registrar el hash SHA-256 del archivo guardado.
  2. Esperar la evaluación y capturar la solicitud recibida por el LLM simulado.
  3. Extraer la imagen recibida, examinar sus metadatos con una herramienta (por ejemplo, exiftool), medir sus dimensiones y comprobar su orientación visual; buscar en todo el contenido de la solicitud 'Ana', 'ana@test.com', el id del usuario y 'evidencia.jpg'.
  4. Repetir los pasos 1 a 3 con 'foto_ana.png' en otra submeta.
  5. Consultar el archivo guardado de la evidencia del paso 1 y comparar su hash con el registrado.
- **Resultado esperado:** La imagen recibida del .jpg no contiene bloque EXIF ni etiquetas de ubicación, fecha de captura, marca o modelo; su lado mayor mide como máximo el valor configurado (2048 px), no supera las dimensiones originales y se ve derecha (la rotación de la orientación 6 ya está aplicada); la imagen del .png no contiene metadatos de texto y conserva 800 x 600 px (no se amplía); en ninguna de las dos solicitudes aparecen 'Ana', el correo, el id del usuario ni el nombre original del archivo, ni en el cuerpo ni en las cabeceras ni en el nombre del archivo adjunto; ambas evaluaciones terminan Evaluada con dictamen y se registra el uso del LLM; el hash del archivo guardado coincide con el del paso 1. **[SUPUESTO S-R12]**
- **Resultado obtenido:** Pendiente de ejecución.
- **RF Asociado:** RF-IA-005, RF-IA-006


# 4. Verificación y trazabilidad


## 4.1 Estrategia de verificación

Cada RF y cada RNF queda asociado a al menos uno de los siguientes métodos y a al menos un caso de prueba (CP) de la sección 3.8. La matriz de 4.2 enumera, para cada requisito, su método, sus HU, CU, CP y las reglas de negocio (BR) que aplica.

| Método | Definición | Uso típico |
|---|---|---|
| Inspección | Revisión del documento, diseño, configuración o script. | Hashing, HTTPS, restricciones de BD, localización, rutas del despliegue. |
| Demostración | Mostrar la funcionalidad en ejecución, sin instrumentación detallada. | Flujos de interfaz, calendario, colores, vistas. |
| Prueba | Caso de prueba reproducible (CP). | Reglas de negocio, puntuación, validaciones, seguridad, accesibilidad. |
| Análisis | Medición o cálculo. | Rendimiento, disponibilidad, cobertura. |

Cobertura de la versión 0.1: 168 RF, 24 RNF, 65 HU, 36 BR, 34 CU y 127 CP. El 100 % de los RF tiene al menos una HU, un CU y un CP, y el 100 % de los RNF tiene al menos un CP. Todos los CP están en estado Pendiente de ejecución. Los CP de ventanas de tiempo (tabla 3.6.1) y de timeout del LLM se ejecutan con reloj y LLM simulados.


## 4.2 Matriz de trazabilidad

Matriz RF y RNF contra método de verificación, HU, CU, CP y reglas de negocio (BR). La matriz completa, con entidades, pantallas y endpoints, está en docs/01-analysis/traceability-matrix.xlsx.

| ID Requisito | Método | HU | CU | CP | BR |
|---|---|---|---|---|---|
| RF-AUT-001 | Prueba | HU-AUT-001 | CU-001 | CP-001, CP-124 | — |
| RF-AUT-002 | Prueba | HU-AUT-001 | CU-001 | CP-001 | — |
| RF-AUT-003 | Prueba | HU-AUT-002 | CU-002 | CP-002 | — |
| RF-AUT-004 | Prueba | HU-AUT-002 | CU-002 | CP-002 | — |
| RF-AUT-005 | Prueba | HU-AUT-004 | CU-004 | CP-019 | — |
| RF-AUT-006 | Prueba | HU-AUT-003 | CU-003 | CP-003 | — |
| RF-AUT-007 | Prueba | HU-AUT-003 | CU-003 | CP-003 | — |
| RF-AUT-008 | Prueba | HU-AUT-003 | CU-003 | CP-003 | — |
| RF-AUT-009 | Prueba | HU-AUT-005 | CU-002 | CP-016 | — |
| RF-AUT-010 | Prueba | HU-AUT-003 | CU-003 | CP-003 | — |
| RF-AUT-011 | Prueba | HU-AUT-001 | CU-001, CU-003, CU-029 | CP-020 | — |
| RF-AUT-012 | Prueba | HU-AUT-005 | CU-002 | CP-021 | BR-012 |
| RF-AUT-013 | Prueba | HU-AUT-001 | CU-001 | CP-001 | BR-013 |
| RF-AUT-014 | Prueba | HU-AUT-005 | CU-002 | CP-016 | BR-012 |
| RF-AUT-015 | Prueba | HU-AUT-001, HU-PER-006 | CU-001 | CP-109 | BR-028 |
| RF-AUT-016 | Prueba | HU-PER-006 | CU-002, CU-019 | CP-122 | BR-028 |
| RF-AUT-017 | Prueba | HU-AUT-001 | CU-001 | CP-001, CP-124 | — |
| RF-AUT-018 | Prueba | HU-ADM-001 | CU-002, CU-019 | CP-125 | — |
| RF-PER-001 | Prueba | HU-PER-001 | CU-017 | CP-022 | — |
| RF-PER-002 | Prueba | HU-PER-002 | CU-009, CU-013, CU-016, CU-031 | CP-017, CP-107, CP-111, CP-121 | BR-009, BR-027 |
| RF-PER-003 | Prueba y demostración | HU-PER-002 | CU-017, CU-031 | CP-017, CP-107 | BR-009, BR-034 |
| RF-PER-004 | Prueba y demostración | HU-PER-003 | CU-017, CU-018 | CP-022 | — |
| RF-PER-005 | Prueba | HU-PER-004 | CU-009 | CP-023 | — |
| RF-PER-006 | Prueba | HU-PER-004 | CU-009, CU-031 | CP-023 | — |
| RF-PER-007 | Prueba y demostración | HU-PER-005 | CU-017 | CP-024 | BR-019 |
| RF-PER-008 | Prueba | HU-PER-006 | CU-027 | CP-025, CP-109, CP-123 | BR-028 |
| RF-PER-009 | Prueba | HU-PER-005 | CU-017 | CP-024 | BR-019 |
| RF-PER-010 | Prueba y demostración | HU-PER-004 | CU-017 | CP-023 | — |
| RF-PER-011 | Prueba y demostración | HU-PER-004, HU-PER-007 | CU-017, CU-031 | CP-023, CP-108 | BR-034 |
| RF-PER-012 | Prueba y demostración | HU-PER-005 | CU-017 | CP-101 | BR-033 |
| RF-PER-013 | Inspección y prueba | HU-PER-007 | CU-017, CU-031 | CP-108, CP-121 | BR-034 |
| RF-PER-014 | Inspección y prueba | HU-PER-007 | CU-017, CU-031 | CP-108 | BR-034 |
| RF-PER-015 | Inspección y prueba | HU-PER-007 | CU-017, CU-031 | CP-108 | BR-034 |
| RF-PER-016 | Inspección y prueba | HU-PER-007 | CU-017, CU-031 | CP-108 | BR-034 |
| RF-PER-017 | Prueba | HU-PER-006 | CU-027 | CP-025, CP-123 | BR-028 |
| RF-META-001 | Prueba | HU-META-001 | CU-005 | CP-026 | BR-024 |
| RF-META-002a | Prueba | HU-META-006 | CU-022 | CP-027 | — |
| RF-META-002b | Prueba | HU-META-004a | CU-008a | CP-027 | — |
| RF-META-002c | Prueba | HU-META-004b | CU-008b | CP-027, CP-119, CP-120 | BR-025, BR-036 |
| RF-META-003 | Prueba | HU-META-002 | CU-005, CU-006, CU-025 | CP-004, CP-006, CP-117 | BR-014 |
| RF-META-004 | Prueba | HU-META-007 | CU-005 | CP-028 | BR-015 |
| RF-META-005 | Prueba | HU-META-002 | CU-005, CU-006, CU-032 | CP-004, CP-006, CP-104, CP-116 | BR-008 |
| RF-META-006 | Prueba | HU-META-008 | CU-016 | CP-029 | BR-010 |
| RF-META-007 | Prueba | HU-META-002 | CU-006 | CP-004 | — |
| RF-META-008 | Prueba | HU-META-003 | CU-007 | CP-005, CP-033, CP-117, CP-126 | BR-011, BR-015 |
| RF-META-009 | Prueba | HU-META-003 | CU-007 | CP-005 | — |
| RF-META-010 | Prueba | HU-META-009 | CU-005 | CP-006, CP-104 | BR-011 |
| RF-META-011 | Prueba | HU-META-002 | CU-006, CU-022 | CP-004 | — |
| RF-META-012 | Prueba | HU-META-005 | CU-009 | CP-036 | BR-006 |
| RF-META-013 | Prueba | HU-META-005 | CU-009 | CP-014, CP-123 | BR-006, BR-028 |
| RF-META-014 | Prueba | HU-ADM-008 | CU-007 | CP-035 | — |
| RF-META-015 | Prueba | HU-META-010 | CU-005 | CP-006, CP-030 | BR-014 |
| RF-META-016 | Prueba | HU-META-010 | CU-005 | CP-030 | BR-014 |
| RF-META-017 | Prueba | HU-META-011 | CU-025 | CP-031 | BR-014 |
| RF-META-018 | Prueba | HU-META-011 | CU-025 | CP-031 | — |
| RF-META-019 | Prueba | HU-META-007 | CU-005 | CP-028 | BR-014 |
| RF-META-020 | Prueba | HU-META-009 | CU-005 | CP-006, CP-032, CP-104 | BR-014 |
| RF-META-021 | Prueba | HU-META-012 | CU-005 | CP-031 | — |
| RF-META-022 | Prueba | HU-META-012 | CU-006, CU-025 | CP-031 | — |
| RF-META-023 | Prueba | HU-META-013 | CU-006, CU-007 | CP-033 | BR-015 |
| RF-META-024 | Prueba | HU-META-002 | CU-006 | CP-034 | BR-029 |
| RF-META-025 | Prueba | HU-META-005 | CU-009 | CP-037 | — |
| RF-META-026 | Prueba | HU-META-005 | CU-009, CU-016 | CP-036 | BR-010, BR-027, BR-029 |
| RF-META-027 | Prueba | HU-META-002 | CU-008a | CP-027, CP-118 | BR-025, BR-035 |
| RF-META-028 | Prueba | HU-META-004a | CU-008a | CP-027, CP-118 | BR-025 |
| RF-META-029 | Prueba | HU-META-001 | CU-005 | CP-026 | — |
| RF-META-030 | Prueba | HU-META-003 | CU-007 | CP-038, CP-077, CP-106 | BR-015, BR-035 |
| RF-META-031 | Prueba | HU-META-007 | CU-005, CU-007 | CP-028, CP-104 | BR-014, BR-032 |
| RF-META-032 | Prueba | HU-META-011 | CU-025 | CP-031 | — |
| RF-META-033 | Prueba | HU-META-014 | CU-005, CU-006, CU-007, CU-032 | CP-034, CP-077, CP-106, CP-116, CP-117 | BR-014, BR-032, BR-035 |
| RF-META-034 | Prueba | HU-META-014 | CU-008a, CU-032 | CP-116 | BR-014 |
| RF-META-035 | Prueba | HU-META-014 | CU-008a, CU-032 | CP-116 | BR-011, BR-014 |
| RF-META-036 | Prueba | HU-META-015 | CU-005, CU-032 | CP-117 | BR-014, BR-035 |
| RF-META-037 | Prueba | HU-META-004a | CU-008a | CP-118 | BR-025, BR-035 |
| RF-AGEN-001 | Prueba | HU-AGEN-001 | CU-010 | CP-039 | — |
| RF-AGEN-002 | Prueba y demostración | HU-AGEN-001 | CU-010 | CP-039 | — |
| RF-AGEN-003 | Prueba y demostración | HU-AGEN-002 | CU-010 | CP-039 | BR-010, BR-029, BR-031 |
| RF-AGEN-004 | Prueba | HU-AGEN-003 | CU-011 | CP-040 | — |
| RF-AGEN-005 | Prueba y demostración | HU-AGEN-004 | CU-024 | CP-041 | BR-019 |
| RF-AGEN-006 | Prueba y demostración | HU-AGEN-002 | CU-011 | CP-040 | — |
| RF-POM-001 | Prueba | HU-POM-001 | CU-012 | CP-042 | — |
| RF-POM-002 | Prueba | HU-POM-002 | CU-012 | CP-043 | — |
| RF-POM-003 | Prueba | HU-POM-002 | CU-012 | CP-043 | — |
| RF-POM-004 | Prueba | HU-POM-001 | CU-012 | CP-042 | — |
| RF-POM-005 | Prueba | HU-POM-001 | CU-012 | CP-042 | — |
| RF-POM-006 | Prueba | HU-POM-001 | CU-012 | CP-042 | BR-007 |
| RF-POM-007 | Prueba | HU-POM-001 | CU-012 | CP-042 | — |
| RF-EVID-001 | Prueba | HU-EVID-001 | CU-013 | CP-007 | BR-001, BR-032 |
| RF-EVID-002 | Prueba | HU-EVID-001 | CU-013 | CP-007 | BR-001 |
| RF-EVID-003 | Prueba | HU-EVID-002 | CU-013 | CP-008, CP-061, CP-115 | — |
| RF-EVID-004 | Prueba | HU-EVID-002 | CU-013 | CP-008 | — |
| RF-EVID-005 | Prueba | HU-EVID-003 | CU-014 | CP-009 | — |
| RF-EVID-006 | Prueba | HU-EVID-003 | CU-014 | CP-009, CP-115 | BR-005 |
| RF-EVID-007 | Prueba | HU-EVID-004 | CU-015 | CP-011, CP-044, CP-081, CP-082, CP-083, CP-084, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-094, CP-095, CP-096, CP-098, CP-099, CP-100, CP-103 | BR-002 |
| RF-EVID-008 | Prueba | HU-EVID-005 | CU-023 | CP-045, CP-054, CP-111, CP-115 | BR-017 |
| RF-EVID-009 | Prueba | HU-EVID-003 | CU-023 | CP-045 | — |
| RF-EVID-010 | Prueba | HU-EVID-004 | CU-013 | CP-046, CP-083, CP-084, CP-089, CP-090, CP-091, CP-092, CP-093, CP-094, CP-095, CP-096, CP-097, CP-098, CP-099, CP-100 | BR-016 |
| RF-EVID-011 | Prueba | HU-EVID-005 | CU-014, CU-023 | CP-046 | BR-016 |
| RF-EVID-012 | Prueba | HU-EVID-004 | CU-013, CU-015 | CP-044, CP-081, CP-082, CP-083, CP-084, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-094, CP-095, CP-096, CP-098, CP-099, CP-100 | BR-002 |
| RF-EVID-013 | Prueba | HU-EVID-001 | CU-013 | CP-044 | BR-016 |
| RF-EVID-014 | Prueba | HU-EVID-002 | CU-013 | CP-047 | — |
| RF-EVID-015 | Prueba | HU-EVID-002 | CU-013 | CP-047 | — |
| RF-EVID-016 | Prueba | HU-EVID-004 | CU-013, CU-015 | CP-010, CP-074, CP-103 | BR-002 |
| RF-EVID-017 | Prueba e inspección | HU-EVID-006 | CU-008b, CU-019, CU-033 | CP-027, CP-114, CP-119, CP-120 | BR-036 |
| RF-EVID-018 | Prueba e inspección | HU-EVID-006 | CU-008b, CU-019, CU-033 | CP-120 | BR-036 |
| RF-PUNT-001 | Prueba | HU-PUNT-001 | CU-016 | CP-010 | BR-004 |
| RF-PUNT-002 | Prueba | HU-PUNT-002 | CU-016 | CP-010, CP-011, CP-012, CP-013, CP-081, CP-082, CP-083, CP-084, CP-085, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-092, CP-093, CP-094, CP-095, CP-096, CP-097, CP-098, CP-099, CP-100 | BR-004 |
| RF-PUNT-003 | Prueba | HU-PUNT-002 | CU-016 | CP-013 | BR-004 |
| RF-PUNT-004 | Prueba | HU-PUNT-003 | CU-016 | CP-011, CP-012, CP-048, CP-074, CP-081, CP-082, CP-083, CP-084, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-094, CP-095, CP-096, CP-098, CP-099, CP-100 | BR-004 |
| RF-PUNT-005 | Prueba | HU-PUNT-003 | CU-015, CU-016 | CP-011, CP-012, CP-081, CP-082, CP-083, CP-084, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-094, CP-095, CP-096, CP-098, CP-099, CP-100 | BR-002, BR-004 |
| RF-PUNT-006 | Prueba | HU-PUNT-003 | CU-016 | CP-013, CP-085, CP-093, CP-097, CP-112, CP-121 | BR-004, BR-018 |
| RF-PUNT-007 | Prueba | HU-PUNT-002 | CU-015 | CP-012, CP-083, CP-084, CP-089, CP-090, CP-091, CP-092, CP-093, CP-094, CP-095, CP-096, CP-097, CP-098, CP-099, CP-100, CP-104 | BR-003, BR-032 |
| RF-PUNT-008 | Prueba | HU-PUNT-004 | CU-016, CU-030 | CP-018, CP-105, CP-111 | BR-018, BR-030 |
| RF-PUNT-010 | Prueba | HU-PUNT-003 | CU-016 | CP-011, CP-048, CP-081, CP-082, CP-083, CP-084, CP-085, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-092, CP-093, CP-094, CP-095, CP-096, CP-097, CP-098, CP-099, CP-100 | BR-004, BR-008 |
| RF-PUNT-011 | Prueba | HU-PUNT-004 | CU-016, CU-030 | CP-048, CP-111, CP-112 | BR-018, BR-029 |
| RF-PUNT-012 | Prueba | HU-PUNT-004 | CU-011 | CP-040, CP-048 | — |
| RF-PUNT-013 | Prueba | HU-PUNT-004 | CU-016 | CP-010, CP-011, CP-012, CP-081, CP-082, CP-083, CP-084, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-092, CP-094, CP-095, CP-096, CP-098, CP-099, CP-100, CP-112 | BR-018 |
| RF-PUNT-014 | Prueba | HU-PUNT-004 | CU-016, CU-030 | CP-010, CP-081, CP-082, CP-083, CP-084, CP-085, CP-086, CP-087, CP-088, CP-089, CP-090, CP-091, CP-092, CP-093, CP-094, CP-095, CP-096, CP-097, CP-098, CP-099, CP-100, CP-105, CP-111 | BR-004, BR-030 |
| RF-RANK-001 | Prueba | HU-RANK-001 | CU-018 | CP-015, CP-105 | — |
| RF-RANK-002 | Prueba y demostración | HU-PER-003 | CU-017 | CP-022 | — |
| RF-RANK-003 | Prueba | HU-RANK-002 | CU-018 | CP-049 | BR-023 |
| RF-RANK-004 | Prueba | HU-RANK-002 | CU-018 | CP-049 | BR-023 |
| RF-RANK-005 | Prueba | HU-RANK-001 | CU-018 | CP-049 | BR-023 |
| RF-ADM-001 | Prueba | HU-ADM-001 | CU-019 | CP-050 | BR-021 |
| RF-ADM-002 | Prueba | HU-ADM-003 | CU-021 | CP-053 | — |
| RF-ADM-003 | Prueba | HU-ADM-004 | CU-021 | CP-055 | — |
| RF-ADM-004 | Prueba | HU-ADM-002 | CU-020 | CP-052, CP-074, CP-102 | BR-012, BR-021 |
| RF-ADM-005 | Prueba | HU-ADM-005 | CU-021 | CP-056 | — |
| RF-ADM-006 | Prueba | HU-ADM-006 | CU-005, CU-019 | CP-057 | BR-013 |
| RF-ADM-007 | Prueba | HU-ADM-007 | CU-006, CU-014, CU-021 | CP-054 | — |
| RF-ADM-008 | Prueba | HU-ADM-001 | CU-019 | CP-051 | — |
| RF-ADM-009 | Prueba | HU-ADM-001 | CU-019 | CP-051, CP-074, CP-102, CP-113, CP-122 | BR-013, BR-021 |
| RF-ADM-010 | Prueba | HU-ADM-001 | CU-019 | CP-051, CP-102, CP-114, CP-119 | BR-021, BR-036 |
| RF-ADM-011 | Prueba | HU-ADM-003 | CU-021 | CP-054, CP-114 | — |
| RF-ADM-012 | Prueba | HU-ADM-002 | CU-020 | CP-052 | — |
| RF-ADM-013 | Prueba | HU-ADM-002 | CU-020 | CP-052 | — |
| RF-ADM-014 | Prueba | HU-ADM-009 | CU-019, CU-029 | CP-051, CP-058, CP-102 | BR-021 |
| RF-ADM-015 | Prueba | HU-ADM-009 | CU-019 | CP-058 | BR-021 |
| RF-ADM-016 | Prueba | HU-ADM-006 | CU-019 | CP-057 | — |
| RF-ADM-017 | Prueba e inspección | HU-ADM-010 | CU-029 | CP-102 | BR-021 |
| RF-ADM-018 | Prueba | HU-ADM-011 | CU-023, CU-030 | CP-045, CP-110 | BR-021 |
| RF-ADM-019 | Prueba | HU-ADM-011 | CU-023, CU-030 | CP-045, CP-111, CP-121 | BR-009, BR-018, BR-021 |
| RF-ADM-020 | Prueba | HU-ADM-001 | CU-019 | CP-122 | BR-013 |
| RF-ADM-021 | Prueba | HU-ADM-001 | CU-019 | CP-122 | BR-028 |
| RF-IA-001 | Prueba e inspección | HU-IA-001 | CU-006, CU-014 | CP-059 | — |
| RF-IA-002 | Prueba | HU-IA-001 | CU-006, CU-014 | CP-059 | — |
| RF-IA-003 | Prueba | HU-IA-001 | CU-006, CU-014 | CP-060 | — |
| RF-IA-004 | Prueba | HU-IA-001 | CU-006, CU-014 | CP-054, CP-060 | — |
| RF-IA-005 | Prueba | HU-IA-001, HU-IA-002 | CU-013, CU-014 | CP-008, CP-061, CP-127 | BR-026 |
| RF-IA-006 | Prueba | HU-IA-002 | CU-014 | CP-062, CP-127 | BR-026 |
| RF-IA-007 | Prueba | HU-IA-002, HU-IA-004 | CU-005, CU-006, CU-007, CU-013, CU-025 | CP-062, CP-106, CP-126 | BR-026, BR-035 |
| RF-IA-008 | Prueba | HU-IA-003 | CU-014 | CP-063, CP-115 | BR-005 |
| RF-IA-009 | Prueba | HU-ADM-007 | CU-014 | CP-063 | — |
| RF-IA-010 | Prueba | HU-IA-004 | CU-005, CU-006, CU-007, CU-013, CU-025, CU-032 | CP-062, CP-106, CP-116 | BR-026, BR-035 |
| RF-IA-011 | Prueba | HU-IA-004 | CU-005, CU-006, CU-007, CU-013, CU-025, CU-032 | CP-062, CP-106, CP-116, CP-118, CP-126 | BR-035 |
| RF-IA-012 | Prueba | HU-EVID-002 | CU-013, CU-014 | CP-008, CP-115 | BR-005 |
| RF-NOT-001 | Prueba | HU-NOT-001 | CU-027 | CP-064 | BR-022 |
| RF-NOT-002 | Prueba | HU-NOT-001 | CU-027 | CP-064 | — |
| RF-NOT-003 | Prueba | HU-NOT-002 | CU-028 | CP-065 | BR-022 |
| RF-NOT-004 | Prueba | HU-NOT-002 | CU-028 | CP-065 | BR-022 |
| RF-NOT-005 | Prueba | HU-NOT-002 | CU-028 | CP-065 | BR-022 |
| RF-NOT-006 | Prueba | HU-NOT-002 | CU-028 | CP-065 | BR-022 |
| RF-NOT-007 | Prueba | HU-NOT-001 | CU-028 | CP-064 | BR-022 |
| RF-NOT-008 | Prueba | HU-NOT-002 | CU-028 | CP-066 | BR-022 |
| RF-LOGR-001 | Prueba | HU-LOGR-001 | CU-026 | CP-066, CP-101 | BR-020 |
| RF-LOGR-002 | Prueba | HU-LOGR-001 | CU-026 | CP-066, CP-101 | BR-020, BR-033 |
| RF-LOGR-003 | Prueba y demostración | HU-LOGR-002 | CU-017 | CP-067 | — |
| RF-LOGR-004 | Prueba y demostración | HU-LOGR-001 | CU-026 | CP-066 | — |
| RNF-001 | Prueba | — | — | CP-002 | — |
| RNF-002 | Prueba y análisis | — | — | CP-018 | — |
| RNF-003 | Análisis | — | — | CP-068 | — |
| RNF-004 | Análisis | — | — | CP-071 | — |
| RNF-005 | Inspección | — | — | CP-075 | — |
| RNF-006 | Inspección y análisis | — | — | CP-075 | — |
| RNF-007 | Prueba | — | — | CP-076 | — |
| RNF-008 | Demostración | — | — | CP-069 | — |
| RNF-009 | Inspección y prueba | — | — | CP-072 | — |
| RNF-010 | Prueba | — | — | CP-073 | — |
| RNF-011 | Inspección y prueba | — | — | CP-074 | — |
| RNF-012 | Prueba | — | — | CP-074 | BR-014 |
| RNF-013 | Inspección | — | — | CP-074 | — |
| RNF-014 | Inspección y prueba | — | — | CP-074 | BR-013, BR-014, BR-021 |
| RNF-015 | Análisis | — | — | CP-070 | — |
| RNF-016 | Prueba | — | — | CP-075 | — |
| RNF-017 | Análisis | — | — | CP-079 | — |
| RNF-018 | Prueba | — | — | CP-077 | — |
| RNF-019 | Prueba | — | — | CP-078 | — |
| RNF-020 | Inspección | — | — | CP-079 | — |
| RNF-021 | Inspección | — | — | CP-079 | — |
| RNF-022 | Prueba | — | — | CP-075 | — |
| RNF-023 | Análisis | — | — | CP-080 | — |
| RNF-024 | Análisis | — | — | CP-014 | — |


# Anexo A. Supuestos

Los supuestos son valores propuestos por el analista. Los adoptados por defecto se etiquetan [SUPUESTO S-nn] en cada requisito donde se aplican y están en el Anexo A.1; los confirmados se etiquetan [Supuesto S-nn] y están en el Anexo A.2.


## A.1 Supuestos adoptados por defecto

Los supuestos siguientes no bloquean el avance; el usuario puede revocarlos o confirmarlos. Se etiquetan [SUPUESTO S-nn] en cada requisito donde se aplican.

| ID | Supuesto | Requisitos afectados |
|---|---|---|
| S-R1 | La vigencia de 600 s del código de recuperación sigue siendo un trigger, como lo implementa el script; podría pasar a CHECK. | RNF-014, 3.3 (codigo_recuperacion), CP-074 |
| S-R2 | 'Existe un super' incluye al super bloqueado administrativamente. | RF-ADM-017, BR-021, CU-029, CP-102 |
| S-R3 | El nivel soporte no consulta las métricas de uso de la aplicación (HTTP 403). | BR-021, CU-021 |
| S-R4 | El moderador edita, bloquea y desbloquea cuentas cliente; eliminar cuentas, cambiar roles y todo lo relativo a cuentas administrador, incluido bloquearlas y desbloquearlas, es solo del super (lectura literal de BR-021). | BR-021, RF-ADM-004, RF-ADM-009, RF-ADM-010, RF-ADM-012, RF-ADM-015, CU-019, CU-020 |
| S-R5 | El intento de inicio manual en el día siguiente a la fecha programada responde HTTP 409 tanto si la submeta ya se cerró por no inicio como si el cierre aún no corrió. | BR-027, RF-META-012, RF-META-026, CU-009, CP-036 |
| S-R6 | La tolerancia de 1 s de T de BR-001 equivale a 1 s de T expresado en puntos porcentuales más el redondeo a 2 decimales. | BR-001, RF-EVID-010, CP-046 |
| S-R7 | Las entidades de cada RF en docs/01-analysis/traceability-matrix.xlsx son una deducción del analista sobre el SQL y el diccionario de datos. | docs/01-analysis/traceability-matrix.xlsx |
| S-R8 | La columna fecha_confirmacion_mayoria_edad está en cliente y no en usuario, porque solo los clientes declaran; es nula únicamente en las cuentas creadas por un administrador o convertidas desde administrador hasta su primer inicio de sesión. | 3.3 (cliente), RF-AUT-017, RF-AUT-018 |
| S-R9 | Las cuentas cliente creadas por un administrador o convertidas desde administrador hacen la declaración de mayoría de edad en su primer inicio de sesión exitoso; hasta entonces sus funciones de cliente responden HTTP 403 (MAYORIA_EDAD_REQUERIDA). La declaración no se retira ni se vuelve a pedir. | RF-AUT-018, RF-ADM-001, RF-ADM-020, CU-002, CU-019, HU-ADM-001, CP-125 |
| S-R10 | El límite de 26 214 400 bytes se aplica al archivo original, antes de convertirlo; un .gif se convierte por su primer fotograma aunque sea animado; los documentos y hojas se convierten sin sus imágenes incrustadas (límite conocido). | RF-EVID-003, RF-EVID-004, RF-IA-005, CP-008, CP-061 |
| S-R11 | El límite de gasto del plan de pago del motor de IA lo configura el responsable del despliegue; el SRS no fija cifras ni precios porque cambian. | IEXT-001, BR-026, 2.5 |
| S-R12 | Al proveedor de IA no se envían nombre, correo ni id del usuario ni el nombre original del archivo (RF-IA-006, BR-026), y las imágenes de evidencia se envían sin metadatos EXIF (ubicación, fecha de captura y dispositivo) y con la resolución mínima útil para evaluarlas (RF-IA-005). Es criterio de aceptación de RF-IA-005 y RF-IA-006 y se verifica con CP-127. Alcance **[SUPUESTO]**: (a) la eliminación y la reducción se aplican a la copia que se envía, y el archivo guardado del usuario no se modifica; (b) la resolución mínima útil es un parámetro de implementación sin cifra en este SRS, y lo verificable es que la imagen enviada no supere las dimensiones originales ni el máximo configurado y que la evaluación siga produciendo dictamen; (c) la rotación indicada por la orientación se aplica antes de eliminar el EXIF; (d) la medida cubre las imágenes, y los metadatos internos de un PDF enviado como PDF (autor, producto) no se eliminan, límite conocido, porque el texto convertido de documentos y hojas no los incluye. | IEXT-001, BR-026, RF-IA-005, RF-IA-006, CP-127 |
| S-API-01 | El desglose por IA es síncrono (hasta ~60 s), porque el esquema no tiene tabla de tareas; guardar la meta con desglose por IA la deja sin submetas hasta que el cliente solicita el desglose. | RF-META-003, RF-META-024, RNF-015, CU-005, CU-006 |
| S-API-02 | Las recomendaciones y las fechas sugeridas son operaciones sin estado: no se guardan hasta que se guarda la meta con las decisiones del usuario. | CU-007, CU-025, RF-META-014 |
| S-API-03 | El aviso de logro se resuelve con el último instante visto que guarda el cliente (parámetro desde); no se añade la columna 'visto'. | RF-LOGR-004, CU-026 |
| S-API-04 | El temporizador Pomodoro es del cliente; solo se registran las sesiones finalizadas o abandonadas de al menos 1 minuto. | RF-POM-001, RF-POM-002, RF-POM-004, RF-POM-005, CU-012 |
| S-API-05 | El .doc se acepta con conversión a texto en el servidor; si no es viable, se retira de RF-EVID-003 y responde HTTP 415. | RF-EVID-003, RF-IA-005 |
| S-API-06 | El cliente puede enviar el porcentaje y la ventana declarados solo como dato informativo; el servidor usa siempre los suyos y responde HTTP 409 si no coinciden. | RF-EVID-010, CU-013 |
| S-API-07 | Eliminar una meta o una cuenta exige la confirmación explícita (confirmar=true); sin ella, HTTP 422. | RF-META-002c, RF-ADM-010, CU-008b, CU-019 |
| S-API-08 | Bloquear y desbloquear una cuenta son idempotentes: responden HTTP 200 si la cuenta ya estaba en ese estado. | RF-ADM-004, RF-ADM-012, CU-020 |
| S-API-09 | El inicio manual de una submeta de una meta en modo automático responde HTTP 409 (SUBMETA_MODO_AUTOMATICO). | RF-META-012, BR-027, CU-009 |
| S-API-10 | Los endpoints de salud (/salud y /salud/listo) son públicos: excepción técnica a RNF-001 para el monitor externo de RNF-004. | RNF-001, RNF-004 |
| S-API-11 | El HTTP 403 MAYORIA_EDAD_REQUERIDA (RF-AUT-018, S-R9) se aplica a toda operación de cliente salvo cerrar sesión, consultar la sesión y declarar la mayoría de edad; la consulta y la descarga de una evidencia lo aplican solo cuando quien llama es un cliente. La declaración es idempotente: si ya existía, devuelve el sello original. La sesión lleva la declaración y se reemite al declarar. | RF-AUT-018, CU-002, CP-125 |
| S-API-12 | Al cambiar el nivel de acceso, una cuenta que no es administrador responde HTTP 404 (la cuenta no existe o no es administrador), como el mensaje del procedimiento de la BD. | RF-ADM-014, CU-019 |
| S-API-13 | Las confirmaciones explícitas (confirmar=true al eliminar una meta o una cuenta y al cerrar administrativamente una submeta; confirma_mayoria_edad al registrarse y al declarar) las valida el servicio, no el esquema del contrato: sin ellas responde HTTP 422 (CONFIRMACION_REQUERIDA o MAYORIA_EDAD_REQUERIDA) y no cambia nada, en lugar del HTTP 400 de un validador de esquema. | RF-META-002c, RF-ADM-010, RF-AUT-017, RF-AUT-018, CU-008b, CU-019, CU-030 |
| S-API-14 | El registro de una sesión Pomodoro con fecha_hora_inicio futura (tolerancia de 60 s) o anterior al registro de la cuenta se rechaza con HTTP 422; es regla del servicio, porque el trigger de la BD solo valida que la submeta sea del usuario. | RF-POM-002, CU-012 |
| S-API-15 | Las operaciones de IA síncronas comparten una cadena de tiempos: 30 s por intento, 2 reintentos con espera de 2 s y 6 s, plazo de la operación de 110 s, servidor de 120 s, proxy de 130 s y cliente de 140 s o más; la subida de evidencia (conversión de 30 s, proxy de 60 s) tiene la suya. Los valores son configuración; RNF-015 exige un p95 de 60 s o menos y una espera abierta de más de 100 s. | RF-IA-003, RF-IA-004, RF-META-003, RNF-015, CU-006 |
| S-API-16 | Bloquear o desbloquear una cuenta administrador es exclusivo del super; el moderador solo bloquea y desbloquea cuentas cliente y recibe HTTP 403 (NIVEL_ADMIN_INSUFICIENTE, nivel requerido super) si lo intenta con una cuenta administrador. Complementa S-R4 y BR-021. | RF-ADM-004, RF-ADM-012, RF-ADM-015, BR-021, CU-020, CP-052, CP-058 |
| S-API-17 | El saneado de la copia de la evidencia que se envía al proveedor de IA (metadatos EXIF fuera con la rotación aplicada antes, resolución reducida sin ampliar, sin el nombre original del archivo y sin identificadores del usuario) se hace en el servidor sobre esa copia y no cambia ningún endpoint, esquema ni código de respuesta del contrato; la resolución máxima es un valor de configuración (LLM_IMAGE_MAX_PX). Complementa S-R12; se verifica con CP-127. | RF-IA-005, RF-IA-006, BR-026, CU-014, CP-127 |


## A.2 Supuestos confirmados

Supuestos confirmados; se etiquetan [Supuesto S-nn] en cada requisito donde se aplican. Un identificador sin efecto en la línea base queda reservado.

| ID | Supuesto | Requisitos donde se aplica |
|---|---|---|
| S-01 | El token JWT expira a los 60 minutos y no hay renovación. | RF-AUT-003 |
| S-02 | Política de contraseña: mínimo 8 caracteres, con al menos una letra y un número. | RF-AUT-011 |
| S-03 | El código de recuperación tiene 6 dígitos numéricos y es de un solo uso. | RF-AUT-007, RF-AUT-008 |
| S-04 | El tiempo total se expresa en horas enteras; la granularidad en minutos queda como trabajo futuro. | RF-META-015 |
| S-05 | En la sugerencia de fechas por IA, el usuario aporta un rango (fecha de inicio y fecha límite), un mínimo de 2 días y una descripción obligatoria; para 1 día la fecha la elige el usuario. | RF-META-017, RF-META-021 |
| S-06 | El horario de fin puede ser 24:00 para que 24 h por día sea alcanzable. La regla de capacidad del horario es S-34. | RF-META-005, RF-META-010, RF-META-020, BR-011, CP-006 |
| S-07 | El umbral de 12 h por día se aplica por día en toda meta, de 1 día o multidía. | RF-META-004, RF-META-008, RF-META-023, BR-015 |
| S-08 | Si el desglose por IA falla tras 2 reintentos, la meta se conserva sin submetas y el usuario puede reintentar; siempre se ofrece el desglose manual (CU-032) como alternativa cuando el desglose por IA falla o la IA no está disponible. | RF-META-024, RF-META-030, CU-006, CU-007, 2.6 |
| S-09 | Una submeta manual puede iniciarse de 00:00:00 a 23:59:59 de su fecha programada, a cualquier hora y no antes de ella; después se cierra sin tiempo de gracia, con 0 puntos si la meta requiere evidencia y sin calificación si no la requiere. | RF-META-026, BR-027 |
| S-10 | Tras una caída del sistema, la submeta automática se inicia al recuperarse con la hora programada como inicio, si no venció su tiempo. | RF-META-025 |
| S-11 | No se pueden modificar días, tiempo total, fechas ni horario de una meta con alguna submeta iniciada. | RF-META-028, BR-025 |
| S-12 | Eliminar una meta no revierte los puntos ya sumados al perfil. | RF-META-002c, BR-025 |
| S-13 | Las recomendaciones de IA son 1:N con la meta (historial de decisiones). | RF-META-014 |
| S-14 | Racha actual: días activos consecutivos hasta hoy; si hoy aún no hay actividad cuenta hasta ayer y solo se reinicia al terminar el día sin actividad. Racha máxima: mayor valor histórico. | RF-PER-007, RF-PER-009, BR-019 |
| S-15 | Catálogo inicial de 7 logros: Primer paso, Constante (racha 7), Imparable (racha 30), Impecable (acierto Excelente en el primer envío), Segunda oportunidad (el segundo envío sumó puntos), Meta cumplida (meta multidía con todas sus submetas iniciadas y finalizadas) y Mil puntos. | RF-LOGR-001, BR-020 |
| S-16 | Los logros no otorgan puntos ni afectan el ranking. | BR-020 |
| S-17 | Niveles de administrador super, moderador y soporte con la matriz de permisos de BR-021 (valores tomados del script SQL). | RF-ADM-014, RF-ADM-015, BR-021 |
| S-18 | Las cuentas administrador no aparecen en el ranking; las cuentas bloqueadas administrativamente se excluyen del ranking de clientes y se marcan en el de administración. | RF-RANK-005, RF-ADM-005, BR-023 |
| S-19 | Eventos push: recordatorio 10 min antes del inicio, apertura de evidencia (80 %), apertura de gracia, resultado de evaluación y logro; preferencia inicial activada. | RF-NOT-001 a 008, BR-022 |
| S-20 | Empates en el ranking: misma posición y orden alfabético por nombre. | RF-RANK-003 |
| S-21 | Reglas de evidencia: máximo 2 evidencias, reenvío solo tras Incoherente y el dictamen de la rectificación cierra; la tabla de puntaje, el tope de 90 y el segundo envío a la mitad son los de BR-002, BR-004 y 3.6.1. | BR-002, BR-004, BR-018, RF-EVID-007, RF-PUNT-001 a RF-PUNT-006 |
| S-22 | Una evaluación en Error persistente mantiene abierta la submeta; tras 48 horas el administrador puede cerrarla con el puntaje provisional (RF-ADM-018, RF-ADM-019); el reintento manual no tiene límite de plazo ni de número. | BR-018, RF-PUNT-011 |
| S-23 | Timeout de 30 s por llamada al LLM y hasta 2 reintentos automáticos con espera creciente. | RF-IA-003, RF-IA-004 |
| S-24 | La eliminación de una cuenta es un borrado en cascada de sus datos (RF-ADM-010), exige confirmación y no se permite eliminar la propia cuenta ni al último administrador super. | RF-ADM-010 |
| S-25 | El usuario acepta explícitamente el uso de un servicio externo de IA antes del primer uso, y el proveedor no debe usar los datos para entrenar modelos. | RF-IA-007, BR-026 |
| S-26 | La vista de inicio muestra la próxima submeta del día, el puntaje acumulado y la racha. | RF-AGEN-005 |
| S-27 | La zona horaria se detecta del navegador al registrarse y es editable en el perfil; America/Bogota solo si no se detecta (RF-AUT-015, RF-PER-008). Las cuentas cliente creadas por un administrador o convertidas desde administrador la detectan en su primer inicio de sesión (RF-AUT-016), con America/Bogota hasta entonces. | RF-PER-008, RF-AUT-015, RF-AUT-016, RF-ADM-020, RF-ADM-021, BR-028 |
| S-28 | El Pomodoro solo se vincula a submetas en curso del usuario y registra la duración efectiva (sin pausas). | RF-POM-002, RF-POM-003 |
| S-29 | 1 % de puntaje equivale a 1 punto del perfil, sin ponderar por duración de la submeta. | BR-030 |
| S-30 | Códigos HTTP unificados: 200, 201 y 202 para éxito, creación y aceptación; 401 credenciales o token inválidos y acceso anónimo; 403 sin permiso o cuenta bloqueada por administrador; 404 recurso ajeno o inexistente; 409 conflicto de estado, incluidos los envíos fuera de ventana o por encima del máximo; 413 archivo demasiado grande; 415 formato no soportado; 422 datos inválidos, incluido el código de recuperación inválido, usado o expirado; 429 bloqueo temporal. | RF-AUT-008, RF-AUT-010, RF-EVID-002, RF-EVID-013, RNF-016 y los demás RF con códigos HTTP |
| S-31 | Conversión de prioridades: Alta = Must, Media = Should, Baja = Could; la prioridad de cada requisito la asigna el analista. | Todos |
| S-32 | Se aplican como buena práctica los principios de la Ley 1581 de 2012 (Colombia); sin normativa formal exigida. | Sección 2.5 |
| S-33 | Tiempo estipulado de la submeta: es la duración de su propio horario (fin menos inicio). En una meta de 1 día la submeta empieza en la hora de inicio del horario de la meta y dura exactamente el tiempo total; el horario de la meta es la franja disponible. No se exige que el horario sea igual al tiempo total ni se relaja la suma de BR-014(5). | RF-META-031, BR-014, BR-032, RF-PUNT-007 |
| S-34 | El horario diario de ejecución limita el tiempo diario: tiempo total ≤ días × (hora de fin − hora de inicio), con hora de fin hasta 24:00. | RF-META-020, BR-014 |
| S-35 | El registro de uso del LLM es uno por llamada (no uno por evaluación): los reintentos automáticos y el Reintentar manual generan registros adicionales. | RF-ADM-007, RF-ADM-011, RNF-012, CP-054 |
| S-36 | Dictámenes: Inválida, Incoherente y Excelente (BR-005). Los nombres Coherente y Mal no se usan. | BR-005, RF-IA-008, RF-EVID-006 |
| S-37 | Un primer envío recibido en el tiempo de gracia (porque no hubo envío en el periodo inicial) se puntúa con la tabla de gracia y, si es Incoherente o Inválida, admite un segundo envío dentro de la gracia restante, que vale la mitad. | BR-002, RF-EVID-007, casos E-18 a E-20 y E-22 a E-24 |
| S-38 | Racha perfecta: submetas calificadas consecutivas (por orden de cierre) cerradas con acierto Excelente en el primer envío; cualquier otro cierre calificado la reinicia y una submeta sin calificación no la altera. El logro 'Impecable' y la racha perfecta solo cuentan con Excelente en el primer envío del periodo inicial. | BR-020, BR-033, RF-PER-012, RF-LOGR-002 |
| S-39 | Agenda: el rango consultado por defecto es el mes calendario en curso y el máximo es de 93 días por consulta. | RF-AGEN-001 |
| S-40 | La submeta se cierra en el instante del dictamen del segundo envío (no se espera al fin de la gracia), porque no admite más acciones. | BR-018, RF-PUNT-013 |
| S-41 | El primer administrador super lo crea el despliegue con variables de entorno, una sola vez; no hay pantalla pública de configuración. | RF-ADM-017, CU-029 |
| S-42 | Día activo: el usuario actúa, es decir, inicia a mano una submeta o envía una evidencia; el inicio automático y los cierres del sistema o de un administrador no activan el día, y una finalización cuenta solo como consecuencia de una evidencia enviada ese día (que ya cuenta por el envío). | RF-PER-002, BR-009 |
| S-43 | Cierre administrativo por Error persistente: las 48 horas se cuentan desde el instante en que la evaluación pasó a Error (un Reintentar que vuelve a fallar reinicia la cuenta) y el listado y el cierre corresponden a los administradores de nivel super y moderador, no al de soporte. | RF-ADM-018, RF-ADM-019, BR-021 |
| S-44 | Efectos del cierre administrativo: el puntaje provisional es la suma de los puntos de las evidencias ya evaluadas (0 para la que está en Error), con tope de 90 si hay dos evaluadas; la evidencia en Error no admite Reintentar; el cierre no cuenta como acierto del primer envío ni altera la racha perfecta. | RF-ADM-019, BR-033 |
| S-45 | Eliminación de cuentas en cascada: los registros de uso del LLM de la cuenta se conservan sin vínculo con la cuenta, la meta ni la evaluación, para no alterar el costo histórico de las métricas. | RF-ADM-010, RF-ADM-011, RF-META-002c, CP-114 |
| S-46 | Consentimiento de IA rechazado: el usuario puede crear metas multidía sin evidencia con desglose manual de submetas; siguen inaccesibles el desglose automático, las recomendaciones, las fechas sugeridas y toda meta con evidencia (RF-META-033 a RF-META-037, RF-IA-010, RF-IA-011, BR-035). El desglose manual también está disponible para quien aceptó la IA. El aviso se muestra de nuevo cada vez que el usuario intenta una función de IA y puede aceptarlo en cualquier momento. | RF-IA-010, RF-IA-011, BR-035, CU-005, CP-106 |
| S-47 | Último administrador super: es el único administrador super sin bloqueo administrativo; ninguna operación (eliminar, bloquear, cambiar el rol o cambiar el nivel) puede dejar al sistema sin al menos uno. | BR-021, RF-ADM-004, CP-102 |
| S-48 | Cuenta con datos: un cliente con al menos una meta, una sesión Pomodoro, un logro o un puntaje acumulado mayor que 0; el rol solo se cambia en cuentas sin datos y, al pasar a administrador, se exige el nivel de acceso. S-54 amplía la definición (día activo como dato y administrador con datos). | RF-ADM-009, BR-013, CP-113 |
| S-49 | Umbral de 12 h por día y límite de 24 h por día: son promedios diarios (tiempo total ÷ días destinados), no topes por submeta, y la duración de un horario se mide como diferencia de horas locales, sin ajustes por cambio de horario de verano. Rige también en el desglose manual (BR-015); el umbral de 12 h es una recomendación de bienestar que nunca impide guardar la meta y el único límite duro es 24 h por día. | BR-011, BR-015, RF-META-008 |
| S-50 | Identificador reservado; sin efecto en la línea base. El día activo es el de S-42 y BR-009. | RF-PER-002, BR-009, CP-121 |
| S-51 | Edición de metas: con alguna submeta iniciada tampoco se pueden cambiar el modo de inicio ni el requisito de evidencia (HTTP 409), además de los días, el tiempo total, las fechas y el horario (S-11); antes de iniciar cualquier submeta, activar el requisito de evidencia exige la aceptación de IA. | RF-META-028, RF-META-037, CU-008a, HU-META-004a, CP-118 |
| S-52 | Cambio de zona horaria: las submetas pendientes conservan su fecha y hora locales (se reinterpretan en la zona nueva); lo ya ocurrido (inicio real, cierre, evidencias) conserva su instante y se muestra en la zona nueva; los días activos ya registrados no se recalculan. | RF-PER-017, BR-028, CU-027, HU-PER-006, CP-025, CP-123 |
| S-53 | Archivos de evidencia: si falla el borrado de un archivo no se revierte la eliminación de la meta o la cuenta; una limpieza programada, al menos cada 24 horas, elimina del almacén todo archivo sin registro de evidencia. La antigüedad mínima de los archivos que se eliminan es la de S-55. | RF-META-002c, RF-EVID-017, RF-EVID-018, RF-ADM-010, HU-EVID-006, CU-008b, CU-019, CU-033, BR-036, CP-114, CP-119, CP-120 |
| S-54 | Cuenta con datos y conversión de rol (complementa S-48 y la parte de administrador de BR-013): (a) un cliente tiene además datos si tiene algún día activo; (b) un administrador tiene datos si cerró al menos una submeta (RF-ADM-019); (c) al cambiar el rol de una cuenta sin datos se eliminan los datos propios del rol anterior (cliente: zona horaria, preferencias de notificación, aceptación de IA y suscripciones push; administrador: nivel de acceso) y se crean los del nuevo con valores por defecto (cliente: zona America/Bogota hasta su primer inicio de sesión, notificaciones push activadas, sin aceptación de IA y puntaje 0; administrador: el nivel indicado), y la cuenta conserva identificador, nombre, correo y registros de uso del LLM; (d) eliminar una meta no elimina los días activos del usuario (como el puntaje, S-12). | RF-ADM-009, RF-ADM-020, BR-013, BR-025, RF-META-002c, HU-ADM-001, CU-019, CP-027, CP-113, CP-122, 1.3 (Cuenta con datos), 3.3 dia_activo |
| S-55 | Limpieza de archivos de evidencia (complementa S-53): la limpieza programada solo elimina los archivos sin registro con más de 1 hora de antigüedad, para no borrar una carga cuyo registro aún no se confirma; un archivo huérfano de 1 hora o menos se evalúa en la ejecución siguiente. La antigüedad se mide desde que el archivo se escribió en el almacén, con el reloj del servidor (no por su fecha de modificación); el valor de 1 hora es el valor por defecto de un parámetro de configuración del despliegue y puede aumentarse (por ejemplo a 24 horas) sin cambiar el modelo. | RF-EVID-018, BR-036, CU-033, CP-120, 1.3 (Limpieza programada), 3.3 evidencia |


# Anexo B. Preguntas y criterios adoptados

Cada pregunta con 'Criterio adoptado' está resuelta con ese criterio. OQ-04 es la única con estado Pendiente.

| ID | Pregunta y criterio | Ubicación |
|---|---|---|
| OQ-01 | ¿La submeta o la meta tienen un estado de espera de evidencia? Criterio adoptado: la submeta y la meta no tienen estado de espera de evidencia; esa situación se deriva del reloj y de las entidades evidencia y evaluacion (BR-029). | BR-029 |
| OQ-02 | ¿A qué se aplica el umbral de 12 h? Criterio adoptado: se aplica por día en toda meta. | BR-015 |
| OQ-03 | ¿Puede el horario terminar a las 24:00? Criterio adoptado: se permite horario_fin = 24:00. | RF-META-020, RF-META-010 |
| OQ-04 | Estado: Pendiente. Verificar, para el proveedor inicial definido en el documento de decisiones de arquitectura, el soporte de formatos (imagen, pdf, docx, xlsx), la política de no entrenamiento con los datos enviados y el costo. Este SRS no nombra al proveedor. Verificada técnicamente el 2026-11-01 (fuentes oficiales del proveedor consultadas ese día, que cambian con rapidez). Hechos clave: con el plan de pago el proveedor declara no usar los datos enviados para entrenar o mejorar sus productos y con el plan gratuito sí; el proveedor conserva un registro de abuso por un tiempo limitado cuya duración no está publicada y que no se puede desactivar por esa vía; el registro del proyecto retiene hasta 55 días y se puede configurar a 7; los archivos subidos por el mecanismo de archivos del proveedor se conservan 48 h; el límite de una solicitud en línea es de 20 MB; no hay selección de región de procesamiento; los formatos nativos son PNG, JPEG, WEBP, HEIC, HEIF y PDF, y el resto se convierte antes de evaluar. Queda pendiente por acciones que no son de diseño y que corresponden al usuario o al responsable del despliegue: habilitar el nivel de pago (Tier 1) con presupuesto; limitar el registro del proyecto en el panel del proveedor; revisión jurídica de la transferencia internacional de datos y de la política de tratamiento frente a la Ley 1581 de 2012, porque este SRS no afirma cumplimiento legal; y releer las políticas del proveedor el día de la puesta en producción. Este SRS no fija precios. Véase también S-R12 (Anexo A.1). | Módulo IA |
| OQ-05 | ¿Qué reglas rigen la racha, los logros, los niveles de administrador y los eventos push? Criterio adoptado: los supuestos S-14 a S-19. | Módulos PER, LOGR, ADM, NOT |
| OQ-06 | ¿Qué ocurre con una submeta cuya evaluación permanece en Error? Criterio adoptado: tras 48 horas el administrador puede cerrarla. | BR-018 |
| OQ-07 | ¿Cómo se eliminan las cuentas? Criterio adoptado: borrado en cascada. | RF-ADM-010 |
| OQ-08 | ¿Hay preferencia de notificación por correo? Criterio adoptado: la entidad cliente no tiene el campo notificaciones_email; solo existe notificaciones_push. | 3.3 cliente |
| OQ-09 | ¿Se desean incorporar página de aterrizaje, vista 'Progreso', eventos manuales en la agenda, rango o handle? Criterio adoptado: fuera de alcance de la versión 0.1. | 1.2.1 |
| OQ-10 | ¿Qué granularidad tiene el tiempo total? Criterio adoptado (S-04): horas enteras; los minutos y las cuotas de costo del LLM por usuario son trabajo futuro (1.2.1). | RF-META-015 |
| OQ-11 | ¿Cuánto suma Incoherente + Incoherente? Criterio adoptado: 75 (caso E-04). | 3.6.1, caso E-04 |
| OQ-12 | ¿Qué dictámenes existen? Criterio adoptado: Inválida, Incoherente y Excelente. | BR-005 |
| OQ-13 | ¿Admite segundo envío el primer envío recibido en gracia? Criterio adoptado (S-37): sí, dentro de la gracia restante. | BR-002, casos E-18 a E-20 y E-22 a E-24 |
| OQ-14 | ¿Cómo se definen el tiempo estipulado de la submeta, el registro de uso del LLM y el cierre tras el segundo envío? Criterio adoptado (S-33, S-35, S-40). | RF-ADM-007, RF-META-031, BR-018 |
| OQ-15 | ¿Cómo se define la racha perfecta? Criterio adoptado (S-38). | BR-020, BR-033 |
| OQ-16 | ¿Qué puede hacer el usuario que rechaza la IA? Criterio adoptado: puede crear metas multidía sin evidencia con desglose manual (S-46). | BR-035, RF-IA-010 |
| OQ-17 | ¿Se fija un tope de horas por submeta? Criterio adoptado (S-49): 12 h y 24 h por día son promedios y no se fija un tope por submeta. | BR-011, BR-015 |
| OQ-18 | ¿Qué es un día activo? Criterio adoptado (S-42); su precisión sobre los cierres del sistema o de un administrador es OQ-21. | BR-009, BR-034 |
| OQ-19 | ¿Cómo se cierra la submeta con Error persistente? Criterio adoptado (S-43, S-44). | RF-ADM-018, RF-ADM-019 |
| OQ-20 | ¿Qué efectos tiene eliminar una cuenta y qué es una cuenta con datos? Criterio adoptado (S-45, S-47, S-48). | RF-ADM-010, BR-021, BR-013 |
| OQ-21 | ¿Activan el día los cierres del sistema o de un administrador? Criterio adoptado: día activo = el usuario actúa; el inicio automático y los cierres del sistema o administrativos no lo activan (S-42, BR-009). El identificador S-50 queda reservado. | BR-009, RF-PER-002 |
| OQ-22 | ¿Qué se puede editar con una submeta iniciada? Criterio adoptado (S-51): no se cambian el modo de inicio ni el requisito de evidencia, y activar la evidencia al editar exige la aceptación de IA. | RF-META-028, RF-META-037 |
| OQ-23 | ¿Qué ocurre al cambiar la zona horaria? Criterio adoptado (S-52): las submetas pendientes conservan su hora local y los días activos no se recalculan. | RF-PER-017, BR-028 |
| OQ-24 | ¿Cómo se eliminan los archivos sin registro? Criterio adoptado (S-53): limpieza programada al menos cada 24 horas. | RF-EVID-018, BR-036 |
| OQ-25 | ¿Cómo se aplica el umbral de 12 h en el desglose manual? Criterio adoptado (S-49): es el promedio diario (tiempo total ÷ días destinados), una recomendación de bienestar que nunca impide guardar la meta; el único límite duro es 24 h por día. | BR-015, RF-META-008 |
| OQ-26 | ¿Qué es una cuenta con datos y qué efectos tiene el cambio de rol? Criterio adoptado (S-54): el día activo cuenta como dato del cliente; un administrador con datos es el que cerró alguna submeta; se definen los efectos del cambio de rol; los días activos se conservan al eliminar una meta. | RF-ADM-009, RF-ADM-020, BR-013, BR-025 |
| OQ-27 | ¿Qué antigüedad tienen los archivos huérfanos que se eliminan? Criterio adoptado (S-55): más de una antigüedad mínima, 1 hora por defecto, parámetro configurable, medida desde la escritura del archivo en el almacén. | RF-EVID-018, BR-036 |


# Anexo C. Identificadores reservados

| Identificador | Estado |
|---|---|
| RF-PUNT-009 | Reservado, sin efecto en la línea base |
| S-50 | Reservado, sin efecto en la línea base |
