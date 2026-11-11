-- ============================================================================
-- Focus Strike — Modelo físico MariaDB (DDL + triggers + funciones + procedimientos + vistas)
-- ----------------------------------------------------------------------------
-- | Versión | Fecha      | Autor              | Cambio      |
-- |---------|------------|--------------------|-------------|
-- | 0.1     | 2026-11-11 | Equipo FocusStrike | Línea base  |
-- ----------------------------------------------------------------------------
-- PROPÓSITO
--   Esquema físico de la base de datos db_focus_strike: 17 tablas, 26 triggers, 3 funciones, 20 procedimientos
--   y 5 vistas. Las reglas críticas del negocio (BR-xxx) viven aquí; la aplicación no las duplica.
--   Cubre los requisitos del SRS (docs/01-analysis/SRS.md): metas y submetas, evidencia y evaluación, puntaje,
--   rachas y logros, administración de usuarios y registro de uso del LLM.
--
-- MOTOR Y VERSIONES
--   MariaDB 10.11 como mínimo; producción en 11.8 LTS o 12.3 LTS. Usa JSON_TABLE, CHECK, funciones de ventana
--   y SKIP LOCKED (el backend).
--   El GRANT de la cuenta de respaldo (fs_backup) sobre las rutinas depende de la versión del motor.
--
-- USO
--   * Ejecutar sobre una instancia vacía:  mariadb -u <usuario> -p < database/schema.sql
--   * CARGARLO CON LA CUENTA PROPIETARIA fs_owner (según la política de cuentas de la base de datos), no como root: las
--     rutinas, los triggers y las vistas quedan con DEFINER = la cuenta que carga el script y con SQL SECURITY
--     DEFINER (declarado de forma explícita en cada rutina y vista). Este script no escribe DEFINER= con host fijo.
--     Crear las cuentas de la base de datos antes de cargar el esquema.
--   * Convención de tiempo: toda marca de tiempo DATETIME es UTC (inicio real, cierre, evidencias, evaluaciones);
--     fechas y horas programadas (fecha_programada, horario_*) son locales del usuario (BR-028). Configurar el
--     servidor con time_zone = '+00:00'.
--   * Este script NO contiene credenciales ni datos de prueba. Solo el catálogo de logros (BR-020) y la fila
--     técnica de `cerrojo_sistema`.
--
-- PRIMER ADMINISTRADOR SUPER (RF-ADM-017, CU-029) — sin credenciales en el script
--   El despliegue lee del entorno el correo y la contraseña iniciales (por ejemplo
--   FOCUSSTRIKE_ADMIN_EMAIL y FOCUSSTRIKE_ADMIN_PASSWORD), calcula el hash con bcrypt (costo >= 12)
--   o argon2id (RNF-005) en el proceso de arranque y llama, una sola vez por arranque:
--       CALL sp_inicializar_primer_super(<correo>, <nombre>, <hash>, @resultado);
--   El procedimiento es idempotente: si ya existe un administrador de nivel SUPER (bloqueado o no),
--   o el correo ya pertenece a una cuenta, no crea ni modifica nada y devuelve 'omitido_ya_existe_super' u
--   'omitido_correo_existente' (el arranque debe registrar el aviso en el log). Si existen solo
--   administradores moderador o soporte, SI crea el super y no toca a los demás. La contraseña en
--   texto plano nunca llega a la base de datos. No hay otra vía de creación del primer super.
--
-- DISEÑO — reglas que el lector debe conocer
--   * Cierre de submeta: evaluacion NO toca a submeta. El cierre y el puntaje los decide
--     sp_cerrar_submeta (BR-018, tabla 3.6.1), que el servicio llama tras cada dictamen
--     (sp_registrar_dictamen) y desde un barrido periódico (sp_cerrar_submetas_vencidas).
--     El puntaje del perfil se suma en el trigger submeta_au al pasar a finalizada con puntaje
--     (RF-PUNT-008, RF-PUNT-014): una sola vía, atómica con el UPDATE de la submeta.
--   * Suma de duraciones (BR-014 num. 5): NO hay trigger (RNF-014). La valida la transacción de
--     creación del desglose: sp_crear_desglose / sp_validar_suma_desglose.
--   * Las acciones referenciales (ON DELETE CASCADE / SET NULL) no activan triggers en MariaDB:
--     ninguna regla depende de un trigger sobre filas borradas en cascada (RNF-014).
--   * Límite de 24 h por día (BR-011): CHECK chk_meta_24h_dia, sin trigger.
--   * Inicio manual (BR-027): vale durante la fecha programada de la submeta (00:00:00 a 23:59:59, zona del
--     usuario), a cualquier hora; no se adapta a horario_inicio; lo valida sp_iniciar_submeta (la hora actual no
--     se puede expresar como CHECK).
--   * Formato del hash: sp_inicializar_primer_super acepta bcrypt (prefijo $2b$, costo >= 12) o
--     argon2id. Un envoltorio con otro prefijo (p. ej. bcrypt_sha256$) exige ampliar esa validación.
--   * Cierre por no inicio (BR-018 e, BR-027): el barrido sp_cerrar_submetas_vencidas SOLO cierra
--     submetas en_curso. Las submetas manuales pendientes cuya fecha local ya pasó las cierra
--     sp_cerrar_submeta_no_iniciada(id, fecha-hora LOCAL del usuario), que la APLICACIÓN debe programar
--     (necesita la zona de cliente.zona_horaria).
--   * Cambio de rol: solo lo hace sp_cambiar_rol; un UPDATE directo de usuario.rol se rechaza.
--     sp_cambiar_rol(p_id_actor, ...) y sp_cambiar_nivel_acceso(p_id_actor, ...) exigen un administrador
--     identificado de nivel super (403 si no). El UPDATE directo de administrador.nivel_acceso lo impide el
--     PRIVILEGIO (fs_app no lo tiene, según la política de cuentas de la base de datos): no hay trigger, porque el propietario del
--     esquema (y las pruebas) sí lo usan para preparar datos.
--   * Mayoría de edad: cliente.fecha_confirmacion_mayoria_edad (UTC). El registro (RF-AUT-017) la guarda al
--     insertar la fila de cliente (la aplicación rechaza con 422 sin la declaración); las cuentas creadas por un
--     administrador o convertidas nacen con NULL y la declaran en el primer inicio de sesión con
--     sp_confirmar_mayoria_edad (RF-AUT-018). La respuesta 403 MAYORIA_EDAD_REQUERIDA mientras sea NULL la aplica
--     la APLICACIÓN (sin trigger a propósito).
--   * Errores: todo SIGNAL de negocio termina en "(NNN)" con el código HTTP que el backend debe responder
--     (403/404/409/422; 500 = invariante que la API no debe provocar). Excepciones: dos fallos de arranque de
--     sp_inicializar_primer_super (hash débil, bloqueo), que no son HTTP.
--   * Día activo por evidencia: la aplicación calcula la fecha local y llama sp_registrar_dia_activo.
--   * Contenido preparado de la evidencia: no se persiste; se recalcula al Reintentar.
-- ============================================================================

SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `db_focus_strike` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_focus_strike`;

-- ============================================================================
-- 1. TABLAS (17 entidades: las 16 del SRS, sección 3.3, más la técnica cerrojo_sistema)
-- ============================================================================

-- usuario: base de la herencia JOINED (incluye al administrador) ---------------------------------
CREATE TABLE `usuario` (
    `id_usuario`        INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la cuenta',
    `nombre`            VARCHAR(100)  NOT NULL COMMENT 'Nombre visible',
    `correo`            VARCHAR(150)  NOT NULL COMMENT 'Correo único para el inicio de sesión',
    `contrasena_hash`   VARCHAR(255)  NOT NULL COMMENT 'Hash bcrypt (costo >= 12) o argon2id (RNF-005); nunca texto plano',
    `puntaje_acumulado` INT           NOT NULL DEFAULT 0 COMMENT 'Suma de los puntajes finales de las submetas cerradas con calificación (RF-PUNT-014)',
    `estado_bloqueo`    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'Bloqueo ADMINISTRATIVO indefinido (BR-012a); independiente de bloqueado_hasta',
    `rol`               VARCHAR(20)   NOT NULL DEFAULT 'cliente' COMMENT 'cliente | administrador (excluyentes, BR-013)',
    `intentos_fallidos` INT           NOT NULL DEFAULT 0 COMMENT 'Intentos fallidos consecutivos de inicio de sesión',
    `bloqueado_hasta`   DATETIME      NULL COMMENT 'Bloqueo TEMPORAL automático (15 min tras 5 fallos, BR-012b); UTC',
    `fecha_registro`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Alta de la cuenta (UTC)',
    PRIMARY KEY (`id_usuario`),
    UNIQUE KEY `uk_usuario_correo` (`correo`),
    KEY `idx_usuario_rol` (`rol`),
    KEY `idx_usuario_puntaje` (`puntaje_acumulado`),
    KEY `idx_usuario_bloqueado_hasta` (`bloqueado_hasta`),
    CONSTRAINT `chk_usuario_rol` CHECK (`rol` IN ('cliente','administrador')),
    CONSTRAINT `chk_usuario_puntaje` CHECK (`puntaje_acumulado` >= 0),
    CONSTRAINT `chk_usuario_intentos` CHECK (`intentos_fallidos` >= 0),
    CONSTRAINT `chk_usuario_bloqueo` CHECK (`estado_bloqueo` IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cuentas (herencia JOINED: administrador | cliente)';

-- administrador (PK = FK a usuario) --------------------------------------------------------------
CREATE TABLE `administrador` (
    `id_usuario`       INT          NOT NULL COMMENT 'PK y FK a usuario',
    `nivel_acceso`     VARCHAR(20)  NOT NULL COMMENT 'super | moderador | soporte (BR-021); obligatorio, sin valor por defecto',
    `fecha_asignacion` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Asignación del rol (UTC)',
    PRIMARY KEY (`id_usuario`),
    KEY `idx_admin_nivel` (`nivel_acceso`),
    CONSTRAINT `fk_administrador_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_admin_nivel` CHECK (`nivel_acceso` IN ('super','moderador','soporte'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Subtipo administrador';

-- cliente (PK = FK a usuario) --------------------------------------------------------------------
CREATE TABLE `cliente` (
    `id_usuario`                INT          NOT NULL COMMENT 'PK y FK a usuario',
    `zona_horaria`              VARCHAR(64)  NOT NULL DEFAULT 'America/Bogota' COMMENT 'Zona IANA del usuario (BR-028); admite 3 segmentos',
    `notificaciones_push`       TINYINT(1)   NOT NULL DEFAULT 1 COMMENT 'Preferencia de notificaciones push (RF-NOT-001)',
    `fecha_aceptacion_ia`       DATETIME     NULL COMMENT 'Consentimiento de uso de IA externa (RF-IA-007, BR-035); NULL = no aceptado',
    `zona_pendiente_deteccion`  TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1 = cuenta creada/convertida por un administrador hasta su primer inicio de sesión',
    `fecha_confirmacion_mayoria_edad` DATETIME NULL COMMENT 'Instante (UTC) en que el usuario declaró ser mayor de 18 años (RF-AUT-017, RF-AUT-018); NULL = aún sin declarar (cuenta creada o convertida por un administrador); sin fecha de nacimiento',
    PRIMARY KEY (`id_usuario`),
    CONSTRAINT `fk_cliente_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_cliente_zona` CHECK (`zona_horaria` REGEXP '^(UTC|[A-Za-z]+(/[A-Za-z0-9_+-]+){1,2})$'),
    CONSTRAINT `chk_cliente_push` CHECK (`notificaciones_push` IN (0,1)),
    CONSTRAINT `chk_cliente_zona_pend` CHECK (`zona_pendiente_deteccion` IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Subtipo cliente';

-- suscripcion_push -----------------------------------------------------------------------
CREATE TABLE `suscripcion_push` (
    `id_suscripcion` INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la suscripción',
    `id_usuario`     INT           NOT NULL COMMENT 'Cliente propietario',
    `endpoint`       VARCHAR(512)  NOT NULL COMMENT 'URL del servicio push del dispositivo (RF-NOT-002)',
    `clave_p256dh`   VARCHAR(255)  NOT NULL COMMENT 'Clave pública de la suscripción',
    `clave_auth`     VARCHAR(255)  NOT NULL COMMENT 'Secreto de autenticación de la suscripción',
    `fecha_creacion` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Registro (UTC)',
    `vigente`        TINYINT(1)    NOT NULL DEFAULT 1 COMMENT '0 = revocada o expirada',
    PRIMARY KEY (`id_suscripcion`),
    UNIQUE KEY `uk_push_usuario_endpoint` (`id_usuario`, `endpoint`),
    CONSTRAINT `fk_push_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_push_vigente` CHECK (`vigente` IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Suscripciones push por dispositivo (RF-NOT-002)';

-- token_sesion -----------------------------------------------------------------------------------
CREATE TABLE `token_sesion` (
    `id_token`         INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la sesión',
    `token_hash`       VARCHAR(255)  NOT NULL COMMENT 'Hash del token (único)',
    `fecha_emision`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Emisión (UTC)',
    `fecha_expiracion` DATETIME      NOT NULL COMMENT 'Expiración (UTC)',
    `revocado`         TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = cerrada o revocada (RF-AUT-005, RF-ADM-013)',
    `id_usuario`       INT           NOT NULL COMMENT 'Dueño de la sesión',
    PRIMARY KEY (`id_token`),
    UNIQUE KEY `uk_token_hash` (`token_hash`),
    KEY `idx_token_usuario` (`id_usuario`),
    KEY `idx_token_expiracion` (`fecha_expiracion`),
    CONSTRAINT `fk_token_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_token_vigencia` CHECK (`fecha_expiracion` > `fecha_emision`),
    CONSTRAINT `chk_token_hash` CHECK (CHAR_LENGTH(`token_hash`) > 0),
    CONSTRAINT `chk_token_revocado` CHECK (`revocado` IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sesiones (JWT) del usuario';

-- codigo_recuperacion ----------------------------------------------------------------------------
CREATE TABLE `codigo_recuperacion` (
    `id_codigo`        INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador del código',
    `codigo_hash`      VARCHAR(255)  NOT NULL COMMENT 'Hash del código (único); bcrypt o argon2id',
    `fecha_generacion` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Generación (UTC)',
    `fecha_expiracion` DATETIME      NOT NULL COMMENT 'Expiración: exactamente 10 min tras la generación (trigger)',
    `usado`            TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = ya utilizado',
    `id_usuario`       INT           NOT NULL COMMENT 'Dueño del código',
    PRIMARY KEY (`id_codigo`),
    UNIQUE KEY `uk_codigo_hash` (`codigo_hash`),
    KEY `idx_codigo_usuario` (`id_usuario`),
    KEY `idx_codigo_expiracion` (`fecha_expiracion`),
    CONSTRAINT `fk_codigo_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_codigo_hash` CHECK (CHAR_LENGTH(`codigo_hash`) > 0),
    CONSTRAINT `chk_codigo_usado` CHECK (`usado` IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Códigos de recuperación de contraseña (RF-AUT-007)';

-- dia_activo: PK compuesta (BR-009) --------------------------------------------------------
CREATE TABLE `dia_activo` (
    `id_usuario`               INT       NOT NULL COMMENT 'Cliente',
    `fecha`                    DATE      NOT NULL COMMENT 'Día calendario en la zona del usuario',
    `primera_submeta_inicio`   DATETIME  NULL COMMENT 'Primer inicio MANUAL de una submeta ese día (UTC); NULL si solo hubo envío de evidencia',
    `total_submetas_iniciadas` INT       NOT NULL DEFAULT 0 COMMENT 'Submetas iniciadas a mano ese día; 0 si el día se activó solo por una evidencia',
    PRIMARY KEY (`id_usuario`, `fecha`),
    CONSTRAINT `fk_dia_activo_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_dia_activo_total` CHECK (`total_submetas_iniciadas` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Días activos: base de la racha y del calendario de actividad (BR-009, BR-019, BR-034)';

-- meta -------------------------------------------------------------------------------------------
CREATE TABLE `meta` (
    `id_meta`             INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la meta',
    `id_usuario`          INT           NOT NULL COMMENT 'Cliente propietario',
    `nombre`              VARCHAR(150)  NOT NULL COMMENT 'Nombre de la meta',
    `descripcion`         TEXT          NULL COMMENT 'Descripción opcional, hasta 1000 caracteres (base de la IA)',
    `categoria`           VARCHAR(30)   NOT NULL COMMENT 'Catálogo BR-024',
    `tipo`                VARCHAR(10)   NOT NULL COMMENT 'un_dia | multidia, derivado de dias_destinados',
    `dias_destinados`     INT           NOT NULL COMMENT 'Número de fechas de trabajo (>= 1)',
    `tiempo_total`        INT           NOT NULL COMMENT 'Horas totales dedicadas a la meta (entero >= 1)',
    `fecha_inicio`        DATE          NOT NULL COMMENT 'Primera fecha del rango',
    `fecha_fin`           DATE          NOT NULL COMMENT 'Última fecha del rango',
    `horario_inicio`      TIME          NOT NULL COMMENT 'Inicio de la franja diaria (hora local)',
    `horario_fin`         TIME          NOT NULL COMMENT 'Fin de la franja diaria; admite 24:00:00',
    `requiere_evidencia`  TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = las submetas exigen evidencia',
    `modo_inicio`         VARCHAR(10)   NOT NULL DEFAULT 'manual' COMMENT 'manual | automatico',
    `modo_planificacion`  VARCHAR(20)   NOT NULL DEFAULT 'fechas_usuario' COMMENT 'fechas_usuario | sugerida_ia (BR-014)',
    `modo_desglose`       VARCHAR(10)   NULL COMMENT 'ia | manual; NULL en una meta de 1 día o con el desglose aún sin elegir',
    `consejos_ia`         TEXT          NULL COMMENT 'Consejos generales de la IA (RF-META-011)',
    `estado`              VARCHAR(20)   NOT NULL DEFAULT 'pendiente' COMMENT 'DERIVADO de las submetas (BR-029); mantenido por trigger, no editable',
    `fecha_creacion`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creación (UTC)',
    PRIMARY KEY (`id_meta`),
    KEY `idx_meta_usuario_estado` (`id_usuario`, `estado`),
    KEY `idx_meta_fechas` (`fecha_inicio`, `fecha_fin`),
    CONSTRAINT `fk_meta_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_meta_categoria` CHECK (`categoria` IN ('estudio','bienestar','juegos','habitos_vida','deporte','lectura','programacion','idiomas','trabajo','proyecto_personal','otro')),
    CONSTRAINT `chk_meta_tipo` CHECK (`tipo` IN ('un_dia','multidia')),
    CONSTRAINT `chk_meta_tipo_dias` CHECK ((`tipo` = 'un_dia' AND `dias_destinados` = 1) OR (`tipo` = 'multidia' AND `dias_destinados` >= 2)),
    CONSTRAINT `chk_meta_dias` CHECK (`dias_destinados` >= 1),
    CONSTRAINT `chk_meta_tiempo` CHECK (`tiempo_total` >= 1),
    -- BR-011: 24 h por día, inclusivo. Es regla de fila: CHECK, no trigger.
    CONSTRAINT `chk_meta_24h_dia` CHECK (`tiempo_total` <= 24 * `dias_destinados`),
    -- cada submeta dura >= 1 h, luego tiempo_total >= dias_destinados (si no, HTTP 422)
    CONSTRAINT `chk_meta_horas_ge_dias` CHECK (`tiempo_total` >= `dias_destinados`),
    CONSTRAINT `chk_meta_fechas` CHECK (`fecha_fin` >= `fecha_inicio`),
    CONSTRAINT `chk_meta_un_dia_fecha` CHECK (`tipo` <> 'un_dia' OR `fecha_fin` = `fecha_inicio`),
    CONSTRAINT `chk_meta_dias_en_rango` CHECK (DATEDIFF(`fecha_fin`, `fecha_inicio`) + 1 >= `dias_destinados`),
    -- RF-META-005: horario_fin > horario_inicio y horario_fin <= 24:00
    CONSTRAINT `chk_meta_horario` CHECK (`horario_fin` > `horario_inicio` AND `horario_fin` <= '24:00:00'),
    -- capacidad de la franja
    CONSTRAINT `chk_meta_capacidad` CHECK (`tiempo_total` * 3600 <= `dias_destinados` * (TIME_TO_SEC(`horario_fin`) - TIME_TO_SEC(`horario_inicio`))),
    CONSTRAINT `chk_meta_descripcion` CHECK (`descripcion` IS NULL OR CHAR_LENGTH(`descripcion`) <= 1000),
    CONSTRAINT `chk_meta_evidencia` CHECK (`requiere_evidencia` IN (0,1)),
    CONSTRAINT `chk_meta_modo_inicio` CHECK (`modo_inicio` IN ('manual','automatico')),
    CONSTRAINT `chk_meta_modo_plan` CHECK (`modo_planificacion` IN ('fechas_usuario','sugerida_ia')),
    CONSTRAINT `chk_meta_modo_desglose` CHECK (`modo_desglose` IS NULL OR `modo_desglose` IN ('ia','manual')),
    CONSTRAINT `chk_meta_un_dia_desglose` CHECK (`tipo` <> 'un_dia' OR `modo_desglose` IS NULL),
    CONSTRAINT `chk_meta_estado` CHECK (`estado` IN ('pendiente','en_curso','finalizada'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Metas con planificación y desglose';

-- submeta ----------------------------------------------------------------------------------------
CREATE TABLE `submeta` (
    `id_submeta`                 INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la submeta',
    `id_meta`                    INT           NOT NULL COMMENT 'Meta padre',
    `fecha_programada`           DATE          NOT NULL COMMENT 'Fecha de trabajo (local); una submeta por fecha',
    `horario_inicio`             TIME          NOT NULL COMMENT 'Inicio programado (local)',
    `horario_fin`                TIME          NOT NULL COMMENT 'Fin programado (local); admite 24:00:00; fin - inicio = tiempo estipulado T (BR-032)',
    `hora_inicio_real`           DATETIME      NULL COMMENT 'Instante en que corrió el reloj (UTC); NULL = no iniciada',
    `hora_fin_real`              DATETIME      NULL COMMENT 'Instante de cierre (UTC)',
    `estado`                     VARCHAR(20)   NOT NULL DEFAULT 'pendiente' COMMENT 'pendiente | en_curso | finalizada (BR-029)',
    `puntaje_obtenido`           INT           NULL COMMENT 'Puntaje final 0-100 al cerrar; NULL = abierta o sin calificación (BR-010)',
    `nombre`                     VARCHAR(150)  NULL COMMENT 'Obligatorio en el desglose manual (trigger)',
    `descripcion_ia`             TEXT          NULL COMMENT 'Descripción generada por la IA',
    `cerrada_por_administrador`  TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '1 = cierre administrativo por Error persistente (RF-ADM-019)',
    `id_administrador_cierre`    INT           NULL COMMENT 'Administrador que cerró; NULL si fue eliminado (ON DELETE SET NULL)',
    `fecha_cierre_administrativo` DATETIME     NULL COMMENT 'Instante del cierre administrativo (UTC)',
    PRIMARY KEY (`id_submeta`),
    UNIQUE KEY `uk_submeta_meta_fecha` (`id_meta`, `fecha_programada`),
    KEY `idx_submeta_estado_inicio` (`estado`, `hora_inicio_real`),
    KEY `idx_submeta_admin_cierre` (`id_administrador_cierre`),
    CONSTRAINT `fk_submeta_meta` FOREIGN KEY (`id_meta`) REFERENCES `meta` (`id_meta`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_submeta_admin_cierre` FOREIGN KEY (`id_administrador_cierre`) REFERENCES `administrador` (`id_usuario`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_submeta_estado` CHECK (`estado` IN ('pendiente','en_curso','finalizada')),
    CONSTRAINT `chk_submeta_horario` CHECK (`horario_fin` > `horario_inicio` AND `horario_fin` <= '24:00:00'),
    -- RNF-011: duración entera de horas, mínimo 1 h
    CONSTRAINT `chk_submeta_duracion` CHECK ((TIME_TO_SEC(`horario_fin`) - TIME_TO_SEC(`horario_inicio`)) >= 3600
                                             AND MOD(TIME_TO_SEC(`horario_fin`) - TIME_TO_SEC(`horario_inicio`), 3600) = 0),
    CONSTRAINT `chk_submeta_puntaje` CHECK (`puntaje_obtenido` IS NULL OR (`puntaje_obtenido` BETWEEN 0 AND 100)),
    CONSTRAINT `chk_submeta_puntaje_estado` CHECK (`puntaje_obtenido` IS NULL OR `estado` = 'finalizada'),
    CONSTRAINT `chk_submeta_pendiente` CHECK (`estado` <> 'pendiente' OR (`hora_inicio_real` IS NULL AND `hora_fin_real` IS NULL)),
    CONSTRAINT `chk_submeta_en_curso` CHECK (`estado` <> 'en_curso' OR (`hora_inicio_real` IS NOT NULL AND `hora_fin_real` IS NULL)),
    CONSTRAINT `chk_submeta_reloj` CHECK (`hora_inicio_real` IS NULL OR `hora_fin_real` IS NULL OR `hora_fin_real` > `hora_inicio_real`),
    -- MariaDB no admite en un CHECK la columna con ON DELETE SET NULL (error 1901): la regla
    -- "id_administrador_cierre solo si cerrada_por_administrador = 1" va en los triggers submeta_bi/bu.
    CONSTRAINT `chk_submeta_cierre_admin` CHECK ((`cerrada_por_administrador` = 0 AND `fecha_cierre_administrativo` IS NULL)
                                                 OR (`cerrada_por_administrador` = 1 AND `fecha_cierre_administrativo` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Submetas: una por fecha de trabajo de la meta';

-- recomendacion_ia: relación 1:N con meta (historial de decisiones) -------------------
CREATE TABLE `recomendacion_ia` (
    `id_recomendacion`  INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `id_meta`           INT           NOT NULL COMMENT 'Meta recomendada',
    `sugerencia_habito` TEXT          NOT NULL COMMENT 'Sugerencia de hábitos/descanso',
    `propuesta_horario` VARCHAR(100)  NOT NULL COMMENT 'Propuesta de reparto de horas',
    `estado_aceptacion` VARCHAR(10)   NULL COMMENT 'aceptada | modificada | rechazada; NULL = sin decisión',
    `fecha_decision`    DATETIME      NULL COMMENT 'Instante de la decisión (UTC)',
    PRIMARY KEY (`id_recomendacion`),
    KEY `idx_recomendacion_meta` (`id_meta`),
    CONSTRAINT `fk_recomendacion_meta` FOREIGN KEY (`id_meta`) REFERENCES `meta` (`id_meta`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_recomendacion_estado` CHECK (`estado_aceptacion` IS NULL OR `estado_aceptacion` IN ('aceptada','modificada','rechazada'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Recomendaciones de la IA y decisión del usuario';

-- sesion_pomodoro --------------------------------------------------------------------------------
CREATE TABLE `sesion_pomodoro` (
    `id_sesion`         INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `fecha_hora_inicio` DATETIME     NOT NULL COMMENT 'Inicio (UTC)',
    `duracion_minutos`  INT          NOT NULL COMMENT 'Duración efectiva (> 0)',
    `estado`            VARCHAR(15)  NOT NULL COMMENT 'finalizada | abandonada',
    `id_usuario`        INT          NOT NULL COMMENT 'Cliente',
    `id_submeta`        INT          NULL COMMENT 'Submeta vinculada (opcional)',
    PRIMARY KEY (`id_sesion`),
    KEY `idx_pomodoro_usuario_fecha` (`id_usuario`, `fecha_hora_inicio`),
    KEY `idx_pomodoro_submeta` (`id_submeta`),
    CONSTRAINT `fk_pomodoro_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_pomodoro_submeta` FOREIGN KEY (`id_submeta`) REFERENCES `submeta` (`id_submeta`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_pomodoro_estado` CHECK (`estado` IN ('finalizada','abandonada')),
    CONSTRAINT `chk_pomodoro_duracion` CHECK (`duracion_minutos` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sesiones Pomodoro';

-- evidencia -------------------------------------------------------------------
CREATE TABLE `evidencia` (
    `id_evidencia`                   INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `id_submeta`                     INT           NOT NULL COMMENT 'Submeta acreditada',
    `id_usuario`                     INT           NOT NULL COMMENT 'Cliente que envía (debe ser el dueño de la submeta; trigger)',
    `archivo`                        VARCHAR(255)  NOT NULL COMMENT 'Ruta del archivo físico en el almacén (RF-EVID-017)',
    `formato`                        VARCHAR(10)   NOT NULL COMMENT 'imagen | texto | excel',
    `tamano`                         INT           NOT NULL COMMENT 'Bytes: 1 a 26 214 400 (25 MB)',
    `porcentaje_tiempo_transcurrido` DECIMAL(5,2)  NOT NULL COMMENT '% del tiempo estipulado al recibirse: 0-100 inicial, 100-110 gracia',
    `intento`                        TINYINT       NOT NULL COMMENT 'Número de envío: 1 o 2',
    `ventana`                        VARCHAR(10)   NOT NULL COMMENT 'inicial | gracia, fijada por el instante de recepción (RF-EVID-010)',
    `fecha_carga`                    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Recepción por el servidor (UTC)',
    PRIMARY KEY (`id_evidencia`),
    UNIQUE KEY `uk_evidencia_submeta_intento` (`id_submeta`, `intento`),
    KEY `idx_evidencia_usuario` (`id_usuario`),
    CONSTRAINT `fk_evidencia_submeta` FOREIGN KEY (`id_submeta`) REFERENCES `submeta` (`id_submeta`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_evidencia_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_evidencia_formato` CHECK (`formato` IN ('imagen','texto','excel')),
    CONSTRAINT `chk_evidencia_tamano` CHECK (`tamano` BETWEEN 1 AND 26214400),
    CONSTRAINT `chk_evidencia_porcentaje` CHECK (`porcentaje_tiempo_transcurrido` BETWEEN 0 AND 110),
    CONSTRAINT `chk_evidencia_intento` CHECK (`intento` IN (1,2)),
    CONSTRAINT `chk_evidencia_ventana` CHECK (`ventana` IN ('inicial','gracia')),
    -- coherencia ventana/porcentaje (100 exacto pertenece a ambas fronteras)
    CONSTRAINT `chk_evidencia_ventana_pct` CHECK ((`ventana` = 'inicial' AND `porcentaje_tiempo_transcurrido` <= 100)
                                                  OR (`ventana` = 'gracia' AND `porcentaje_tiempo_transcurrido` >= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Evidencias: máximo 2 por submeta';

-- evaluacion -------------------------------------------------------------------------------------
CREATE TABLE `evaluacion` (
    `id_evaluacion`      INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `id_evidencia`       INT           NOT NULL COMMENT 'Evidencia evaluada (1:1)',
    `estado`             VARCHAR(15)   NOT NULL DEFAULT 'en_evaluacion' COMMENT 'en_evaluacion | evaluada | error (BR-029)',
    `dictamen`           VARCHAR(15)   NULL COMMENT 'excelente | incoherente | invalida; NULL mientras no esté evaluada',
    `puntos_otorgados`   INT           NULL COMMENT 'Puntos de ESTA evidencia según BR-004 (se asignan por trigger)',
    `justificacion`      TEXT          NULL COMMENT 'Justificación del LLM',
    `fecha_evaluacion`   DATETIME      NULL COMMENT 'Instante del dictamen (UTC)',
    `fecha_ultimo_error` DATETIME      NULL COMMENT 'Última entrada a Error (UTC); base de las 48 h de RF-ADM-018',
    PRIMARY KEY (`id_evaluacion`),
    UNIQUE KEY `uk_evaluacion_evidencia` (`id_evidencia`),
    KEY `idx_evaluacion_estado_error` (`estado`, `fecha_ultimo_error`),
    CONSTRAINT `fk_evaluacion_evidencia` FOREIGN KEY (`id_evidencia`) REFERENCES `evidencia` (`id_evidencia`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_evaluacion_estado` CHECK (`estado` IN ('en_evaluacion','evaluada','error')),
    CONSTRAINT `chk_evaluacion_dictamen` CHECK (`dictamen` IS NULL OR `dictamen` IN ('excelente','incoherente','invalida')),
    CONSTRAINT `chk_evaluacion_puntos` CHECK (`puntos_otorgados` IS NULL OR `puntos_otorgados` IN (0,25,50,100)),
    CONSTRAINT `chk_evaluacion_coherencia` CHECK ((`estado` = 'evaluada' AND `dictamen` IS NOT NULL AND `puntos_otorgados` IS NOT NULL)
                                                  OR (`estado` <> 'evaluada' AND `dictamen` IS NULL AND `puntos_otorgados` IS NULL)),
    CONSTRAINT `chk_evaluacion_error` CHECK (`estado` <> 'error' OR `fecha_ultimo_error` IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Evaluación asíncrona del LLM (una por evidencia; el reintento reutiliza la fila, BR-017)';

-- uso_llm: un registro por llamada; sin UNIQUE por evaluación (RNF-012) ---------------
CREATE TABLE `uso_llm` (
    `id_uso`            INT            NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `fecha`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Instante de la llamada (UTC)',
    `operacion`         VARCHAR(20)    NOT NULL COMMENT 'desglose | sugerencia_fechas | recomendacion | evaluacion',
    `tokens_consumidos` INT            NOT NULL DEFAULT 0 COMMENT 'Tokens (0 si falló)',
    `costo`             DECIMAL(10,4)  NOT NULL DEFAULT 0.0000 COMMENT 'Costo monetario',
    `latencia_ms`       INT            NOT NULL DEFAULT 0 COMMENT 'Latencia en ms',
    `proveedor`         VARCHAR(50)    NOT NULL COMMENT 'Proveedor del LLM (RF-IA-009)',
    `modelo`            VARCHAR(100)   NOT NULL COMMENT 'Modelo usado (RF-IA-009)',
    `resultado`         VARCHAR(10)    NOT NULL COMMENT 'exitosa | fallida',
    `id_usuario`        INT            NULL COMMENT 'Origen (NULL = llamada del sistema o cuenta eliminada)',
    `id_meta`           INT            NULL COMMENT 'Meta (obligatoria al insertar si operacion = desglose; trigger)',
    `id_evaluacion`     INT            NULL COMMENT 'Evaluación (obligatoria al insertar si operacion = evaluacion; trigger)',
    PRIMARY KEY (`id_uso`),
    KEY `idx_uso_fecha_operacion` (`fecha`, `operacion`),
    KEY `idx_uso_usuario` (`id_usuario`),
    KEY `idx_uso_meta` (`id_meta`),
    KEY `idx_uso_evaluacion` (`id_evaluacion`),
    CONSTRAINT `fk_uso_llm_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_uso_llm_meta` FOREIGN KEY (`id_meta`) REFERENCES `meta` (`id_meta`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_uso_llm_evaluacion` FOREIGN KEY (`id_evaluacion`) REFERENCES `evaluacion` (`id_evaluacion`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_uso_operacion` CHECK (`operacion` IN ('desglose','sugerencia_fechas','recomendacion','evaluacion')),
    CONSTRAINT `chk_uso_resultado` CHECK (`resultado` IN ('exitosa','fallida')),
    CONSTRAINT `chk_uso_tokens` CHECK (`tokens_consumidos` >= 0),
    CONSTRAINT `chk_uso_costo` CHECK (`costo` >= 0),
    CONSTRAINT `chk_uso_latencia` CHECK (`latencia_ms` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Trazabilidad de llamadas al LLM (RF-ADM-007, RF-ADM-011)';

-- logro ----------------------------------------------------------------------------------
CREATE TABLE `logro` (
    `id_logro`    INT           NOT NULL AUTO_INCREMENT COMMENT 'Identificador',
    `codigo`      VARCHAR(40)   NOT NULL COMMENT 'Código estable del logro',
    `nombre`      VARCHAR(100)  NOT NULL COMMENT 'Nombre visible',
    `descripcion` VARCHAR(255)  NOT NULL COMMENT 'Condición de obtención',
    PRIMARY KEY (`id_logro`),
    UNIQUE KEY `uk_logro_codigo` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de logros (BR-020, RF-LOGR-001)';

-- usuario_logro: PK compuesta garantiza el otorgamiento único (RF-LOGR-002) --------------
CREATE TABLE `usuario_logro` (
    `id_usuario`      INT       NOT NULL COMMENT 'Cliente',
    `id_logro`        INT       NOT NULL COMMENT 'Logro obtenido',
    `fecha_obtencion` DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Obtención (UTC)',
    PRIMARY KEY (`id_usuario`, `id_logro`),
    KEY `idx_usuario_logro_logro` (`id_logro`),
    CONSTRAINT `fk_usuario_logro_cliente` FOREIGN KEY (`id_usuario`) REFERENCES `cliente` (`id_usuario`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_usuario_logro_logro` FOREIGN KEY (`id_logro`) REFERENCES `logro` (`id_logro`)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Logros obtenidos por cliente';

-- cerrojo_sistema (entidad 17): tabla TÉCNICA sin datos de negocio. Su única fila es el cerrojo de
-- exclusión mutua que toma sp_validar_no_ultimo_super (BR-021). No la modifica la aplicación.
CREATE TABLE `cerrojo_sistema` (
    `clave` VARCHAR(30) NOT NULL COMMENT 'Nombre del cerrojo; hoy solo ultimo_super',
    PRIMARY KEY (`clave`),
    CONSTRAINT `chk_cerrojo_clave` CHECK (`clave` IN ('ultimo_super'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla técnica: cerrojo de exclusión mutua del último super (BR-021)';
INSERT INTO `cerrojo_sistema` (`clave`) VALUES ('ultimo_super');

-- Catálogo inicial de logros (BR-020). Datos de referencia, no de prueba.
INSERT INTO `logro` (`codigo`, `nombre`, `descripcion`) VALUES
 ('primer_paso',         'Primer paso',         'Iniciar tu primera submeta, a mano o por inicio automático.'),
 ('constante',           'Constante',           'Alcanzar una racha de 7 días.'),
 ('imparable',           'Imparable',           'Alcanzar una racha de 30 días.'),
 ('impecable',           'Impecable',           'Cerrar una submeta con dictamen Excelente en el primer envío recibido en el periodo inicial (100 puntos).'),
 ('segunda_oportunidad', 'Segunda oportunidad', 'Cerrar una submeta en la que el segundo envío sumó puntos.'),
 ('meta_cumplida',       'Meta cumplida',       'Finalizar todas las submetas de una meta multidía habiendo iniciado cada una.'),
 ('mil_puntos',          'Mil puntos',          'Alcanzar 1 000 puntos acumulados.');

-- ============================================================================
-- 2. FUNCIONES Y PROCEDIMIENTOS DE APOYO (usados por los triggers)
-- ============================================================================

DELIMITER $$

-- Puntos de UNA evidencia según BR-004 / tabla 3.6.1:
--   primer envío en periodo inicial 100/50/0; primer envío en gracia 50/25/0; segundo envío 50/25/0.
CREATE FUNCTION `fn_puntos_evidencia`(p_intento INT, p_ventana VARCHAR(10), p_dictamen VARCHAR(15))
RETURNS INT DETERMINISTIC SQL SECURITY DEFINER
BEGIN
    IF p_dictamen IS NULL THEN RETURN NULL; END IF;
    RETURN CASE p_dictamen
        WHEN 'excelente'   THEN IF(p_intento = 1 AND p_ventana = 'inicial', 100, 50)
        WHEN 'incoherente' THEN IF(p_intento = 1 AND p_ventana = 'inicial', 50, 25)
        ELSE 0
    END;
END$$

-- Puntaje provisional (RF-PUNT-012): suma de las evidencias evaluadas; tope 90 si hay dos evaluadas.
CREATE FUNCTION `fn_puntaje_provisional`(p_id_submeta INT)
RETURNS INT READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE v_suma INT DEFAULT 0;
    DECLARE v_n    INT DEFAULT 0;
    SELECT COALESCE(SUM(ev.`puntos_otorgados`), 0), COUNT(*)
      INTO v_suma, v_n
      FROM `evidencia` e
      JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`
     WHERE e.`id_submeta` = p_id_submeta AND ev.`estado` = 'evaluada';
    RETURN IF(v_n >= 2, LEAST(v_suma, 90), v_suma);
END$$

-- Estado derivado de la meta con la precedencia de BR-029.
CREATE FUNCTION `fn_estado_meta`(p_id_meta INT)
RETURNS VARCHAR(20) READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE v_n  INT DEFAULT 0;
    DECLARE v_nf INT DEFAULT 0;
    DECLARE v_ni INT DEFAULT 0;
    SELECT COUNT(*), COALESCE(SUM(`estado` = 'finalizada'), 0), COALESCE(SUM(`hora_inicio_real` IS NOT NULL), 0)
      INTO v_n, v_nf, v_ni
      FROM `submeta` WHERE `id_meta` = p_id_meta;
    IF v_n = 0 THEN RETURN 'pendiente'; END IF;          -- (1) sin submetas
    IF v_nf = v_n THEN RETURN 'finalizada'; END IF;      -- (2) todas finalizadas
    IF v_ni > 0 THEN RETURN 'en_curso'; END IF;          -- (3) alguna iniciada y alguna sin finalizar
    RETURN 'pendiente';                                  -- (4) los demás casos
END$$

CREATE PROCEDURE `sp_recalcular_estado_meta`(IN p_id_meta INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_estado VARCHAR(20);
    SET v_estado = `fn_estado_meta`(p_id_meta);
    UPDATE `meta` SET `estado` = v_estado WHERE `id_meta` = p_id_meta AND `estado` <> v_estado;
END$$

-- BR-021: ninguna operación puede dejar al sistema sin un administrador super sin bloquear.
-- Se llama ANTES de eliminar, bloquear, cambiar de rol o de nivel a una cuenta.
-- Concurrencia: MariaDB prohíbe una lectura con bloqueo (FOR UPDATE) sobre la tabla que el trigger está
-- modificando (error 1442), por lo que la exclusión mutua se toma sobre la fila de la tabla técnica
-- `cerrojo_sistema` (siempre sembrada): toda transacción que bloquea, elimina o degrada a un super espera a la anterior y
-- cuenta los supers DESPUÉS, con lo que "una se completa y la otra responde 409" (BR-021). El bloqueo
-- se mantiene hasta el COMMIT/ROLLBACK de quien llama. Con aislamiento REPEATABLE READ, la transacción
-- no debe haber leído antes `usuario`/`administrador` (los procedimientos del script cumplen esto).
CREATE PROCEDURE `sp_validar_no_ultimo_super`(IN p_id_usuario INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_es    INT DEFAULT 0;
    DECLARE v_otros INT DEFAULT 0;
    DECLARE v_mutex VARCHAR(30) DEFAULT NULL;
    SELECT `clave` INTO v_mutex FROM `cerrojo_sistema` WHERE `clave` = 'ultimo_super' FOR UPDATE;
    IF v_mutex IS NULL THEN
        -- la fila falta (p. ej. TRUNCATE, que no activa triggers): se resiembra y se vuelve a bloquear
        INSERT IGNORE INTO `cerrojo_sistema` (`clave`) VALUES ('ultimo_super');
        SELECT `clave` INTO v_mutex FROM `cerrojo_sistema` WHERE `clave` = 'ultimo_super' FOR UPDATE;
    END IF;
    SELECT COUNT(*) INTO v_es
      FROM `administrador` a JOIN `usuario` u ON u.`id_usuario` = a.`id_usuario`
     WHERE a.`id_usuario` = p_id_usuario AND a.`nivel_acceso` = 'super'
       AND u.`estado_bloqueo` = 0 AND u.`rol` = 'administrador';
    IF v_es = 1 THEN
        SELECT COUNT(*) INTO v_otros
          FROM `administrador` a JOIN `usuario` u ON u.`id_usuario` = a.`id_usuario`
         WHERE a.`nivel_acceso` = 'super' AND u.`estado_bloqueo` = 0 AND u.`rol` = 'administrador'
           AND a.`id_usuario` <> p_id_usuario;
        IF v_otros = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-021: debe existir siempre un administrador super sin bloquear (409)';
        END IF;
    END IF;
END$$

-- Suma de duraciones = tiempo_total y número de submetas = dias_destinados (BR-014 num. 4 y 5).
-- NO es un trigger (RNF-014): se invoca desde la transacción de creación/regeneración del desglose.
CREATE PROCEDURE `sp_validar_suma_desglose`(IN p_id_meta INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_total INT; DECLARE v_dias INT;
    DECLARE v_n INT DEFAULT 0; DECLARE v_seg INT DEFAULT 0;
    SELECT `tiempo_total`, `dias_destinados` INTO v_total, v_dias FROM `meta` WHERE `id_meta` = p_id_meta;
    IF v_total IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La meta no existe (404)';
    END IF;
    SELECT COUNT(*), COALESCE(SUM(TIME_TO_SEC(`horario_fin`) - TIME_TO_SEC(`horario_inicio`)), 0)
      INTO v_n, v_seg FROM `submeta` WHERE `id_meta` = p_id_meta;
    IF v_n <> v_dias THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-014: el número de submetas debe ser igual a dias_destinados (422)';
    END IF;
    IF v_seg <> v_total * 3600 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-014: la suma de duraciones de las submetas debe ser igual a tiempo_total (422)';
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- 3. TRIGGERS (reglas que no se expresan como CHECK, RNF-014)
-- ============================================================================

DELIMITER $$

-- ---- usuario ---------------------------------------------------------------
CREATE TRIGGER `usuario_bi` BEFORE INSERT ON `usuario`
FOR EACH ROW
BEGIN
    IF NEW.`correo` NOT REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo inválido (422)';
    END IF;
    -- estado_bloqueo (administrativo) y bloqueado_hasta (temporal) son independientes (BR-012):
    -- el trigger NUNCA deriva uno del otro.
END$$

CREATE TRIGGER `usuario_bu` BEFORE UPDATE ON `usuario`
FOR EACH ROW
BEGIN
    IF NEW.`correo` <> OLD.`correo` AND NEW.`correo` NOT REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo inválido (422)';
    END IF;
    -- BR-013: el rol solo cambia en cuentas sin datos
    IF NEW.`rol` <> OLD.`rol` THEN
        IF OLD.`rol` = 'cliente' THEN
            IF OLD.`puntaje_acumulado` > 0 OR NEW.`puntaje_acumulado` > 0
               OR EXISTS (SELECT 1 FROM `meta` WHERE `id_usuario` = OLD.`id_usuario`)
               OR EXISTS (SELECT 1 FROM `sesion_pomodoro` WHERE `id_usuario` = OLD.`id_usuario`)
               OR EXISTS (SELECT 1 FROM `usuario_logro` WHERE `id_usuario` = OLD.`id_usuario`)
               OR EXISTS (SELECT 1 FROM `dia_activo` WHERE `id_usuario` = OLD.`id_usuario`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-013: no se puede cambiar el rol de una cuenta con datos (409)';
            END IF;
        ELSEIF EXISTS (SELECT 1 FROM `submeta` WHERE `id_administrador_cierre` = OLD.`id_usuario`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-013: un administrador que cerró submetas tiene datos (409)';
        END IF;
        -- BR-013 / RNF-014: el rol solo cambia dentro de sp_cambiar_rol, que fija @fs_rol_autorizado
        -- con el id de la cuenta y lo limpia al terminar; así la cuenta nunca queda sin su fila de subtipo ni con
        -- la del subtipo equivocado. (Un rol fuera de catálogo cae en chk_usuario_rol.) Limitación: es una
        -- variable de sesión; quien tiene acceso SQL libre podría fijarla a mano. La mitigación es de despliegue:
        -- la cuenta de la aplicación no debe tener UPDATE directo sobre usuario.rol (solo EXECUTE de sp_cambiar_rol).
        IF NEW.`rol` IN ('cliente','administrador') AND NOT (@fs_rol_autorizado <=> OLD.`id_usuario`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-013: el rol solo se cambia con sp_cambiar_rol (409)';
        END IF;
        CALL `sp_validar_no_ultimo_super`(OLD.`id_usuario`);
    END IF;
    -- BR-021: bloquear (administrativamente) al último super sin bloquear
    IF OLD.`estado_bloqueo` = 0 AND NEW.`estado_bloqueo` = 1 THEN
        CALL `sp_validar_no_ultimo_super`(OLD.`id_usuario`);
    END IF;
    -- sin rama que restablezca estado_bloqueo ni intentos_fallidos. Cerrar una submeta o sumar
    -- puntaje (UPDATE de puntaje_acumulado) no puede levantar un bloqueo (BR-012, RF-AUT-012).
END$$

CREATE TRIGGER `usuario_bd` BEFORE DELETE ON `usuario`
FOR EACH ROW
BEGIN
    CALL `sp_validar_no_ultimo_super`(OLD.`id_usuario`);   -- RF-ADM-010 / BR-021
END$$

-- ---- administrador / cliente: coherencia rol-subtipo (BR-013) ----------
CREATE TRIGGER `administrador_bi` BEFORE INSERT ON `administrador`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `usuario` WHERE `id_usuario` = NEW.`id_usuario` AND `rol` = 'administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario debe existir y tener rol administrador (500)';
    END IF;
    IF EXISTS (SELECT 1 FROM `cliente` WHERE `id_usuario` = NEW.`id_usuario`) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-013: una cuenta no puede ser administrador y cliente a la vez (500)';
    END IF;
END$$

CREATE TRIGGER `administrador_bu` BEFORE UPDATE ON `administrador`
FOR EACH ROW
BEGIN
    IF NEW.`id_usuario` <> OLD.`id_usuario` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la cuenta del administrador (500)';
    END IF;
    IF OLD.`nivel_acceso` = 'super' AND NEW.`nivel_acceso` <> 'super' THEN
        CALL `sp_validar_no_ultimo_super`(OLD.`id_usuario`);    -- BR-021
    END IF;
END$$

CREATE TRIGGER `administrador_bd` BEFORE DELETE ON `administrador`
FOR EACH ROW
BEGIN
    CALL `sp_validar_no_ultimo_super`(OLD.`id_usuario`);        -- BR-021
END$$

CREATE TRIGGER `cliente_bi` BEFORE INSERT ON `cliente`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `usuario` WHERE `id_usuario` = NEW.`id_usuario` AND `rol` = 'cliente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario debe existir y tener rol cliente (500)';
    END IF;
    IF EXISTS (SELECT 1 FROM `administrador` WHERE `id_usuario` = NEW.`id_usuario`) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-013: una cuenta no puede ser administrador y cliente a la vez (500)';
    END IF;
END$$

-- ---- cerrojo_sistema: la fila única no se borra ni se modifica (BR-021, RNF-014) --------------
CREATE TRIGGER `cerrojo_sistema_bu` BEFORE UPDATE ON `cerrojo_sistema`
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-021: la fila de cerrojo_sistema no se modifica (tabla técnica) (500)';
END$$

CREATE TRIGGER `cerrojo_sistema_bd` BEFORE DELETE ON `cerrojo_sistema`
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-021: la fila de cerrojo_sistema no se elimina (tabla técnica) (500)';
END$$

-- ---- codigo_recuperacion: vigencia exacta de 10 min (RF-AUT-007/010, RNF-014) -------------
CREATE TRIGGER `codigo_recuperacion_bi` BEFORE INSERT ON `codigo_recuperacion`
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(SECOND, NEW.`fecha_generacion`, NEW.`fecha_expiracion`) <> 600 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La vigencia del código de recuperación debe ser de exactamente 10 minutos (500)';
    END IF;
END$$

-- ---- meta -------------------------------------------------------------------
CREATE TRIGGER `meta_bi` BEFORE INSERT ON `meta`
FOR EACH ROW
BEGIN
    DECLARE v_acepta DATETIME;
    IF NEW.`estado` <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: una meta nueva (sin submetas) nace pendiente; el estado es derivado (409)';
    END IF;
    -- BR-035: sin consentimiento de IA solo metas sin evidencia, de 1 día o con desglose manual
    IF NEW.`requiere_evidencia` = 1 OR NEW.`modo_desglose` = 'ia' OR NEW.`modo_planificacion` = 'sugerida_ia' THEN
        SELECT `fecha_aceptacion_ia` INTO v_acepta FROM `cliente` WHERE `id_usuario` = NEW.`id_usuario`;
        IF v_acepta IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-035: requiere aceptar el uso de IA (403)';
        END IF;
    END IF;
END$$

CREATE TRIGGER `meta_bu` BEFORE UPDATE ON `meta`
FOR EACH ROW
BEGIN
    DECLARE v_acepta DATETIME;
    IF NEW.`id_usuario` <> OLD.`id_usuario` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar el propietario de la meta (500)';
    END IF;
    -- BR-029: el estado es derivado y no editable directamente
    IF NEW.`estado` <> `fn_estado_meta`(OLD.`id_meta`) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: el estado de la meta es derivado de sus submetas y no es editable (409)';
    END IF;
    -- BR-025 / RF-META-028: con una submeta iniciada no se editan los parámetros de planificación
    IF (NEW.`dias_destinados` <> OLD.`dias_destinados` OR NEW.`tiempo_total` <> OLD.`tiempo_total`
        OR NEW.`fecha_inicio` <> OLD.`fecha_inicio` OR NEW.`fecha_fin` <> OLD.`fecha_fin`
        OR NEW.`horario_inicio` <> OLD.`horario_inicio` OR NEW.`horario_fin` <> OLD.`horario_fin`
        OR NEW.`modo_inicio` <> OLD.`modo_inicio` OR NEW.`requiere_evidencia` <> OLD.`requiere_evidencia`)
       AND EXISTS (SELECT 1 FROM `submeta` WHERE `id_meta` = OLD.`id_meta` AND `hora_inicio_real` IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-META-028: la meta tiene submetas iniciadas; no se pueden editar sus parámetros (409)';
    END IF;
    IF NEW.`requiere_evidencia` = 1 OR NEW.`modo_desglose` = 'ia' OR NEW.`modo_planificacion` = 'sugerida_ia' THEN
        SELECT `fecha_aceptacion_ia` INTO v_acepta FROM `cliente` WHERE `id_usuario` = NEW.`id_usuario`;
        IF v_acepta IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-035: requiere aceptar el uso de IA (403)';
        END IF;
    END IF;
END$$

-- ---- submeta ------------------------------------------------------------------
CREATE TRIGGER `submeta_bi` BEFORE INSERT ON `submeta`
FOR EACH ROW
BEGIN
    DECLARE v_fi DATE; DECLARE v_ff DATE; DECLARE v_hi TIME; DECLARE v_hf TIME; DECLARE v_modo VARCHAR(10);
    SELECT `fecha_inicio`, `fecha_fin`, `horario_inicio`, `horario_fin`, `modo_desglose`
      INTO v_fi, v_ff, v_hi, v_hf, v_modo FROM `meta` WHERE `id_meta` = NEW.`id_meta`;
    IF v_fi IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La meta de la submeta no existe (404)';
    END IF;
    -- BR-014 num. 6: la submeta cabe en el horario diario de la meta y su fecha en el rango
    IF NEW.`fecha_programada` < v_fi OR NEW.`fecha_programada` > v_ff THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-014: la fecha de la submeta está fuera del rango de la meta (422)';
    END IF;
    IF NEW.`horario_inicio` < v_hi OR NEW.`horario_fin` > v_hf THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-014: la submeta debe caber en el horario diario de la meta (422)';
    END IF;
    -- RNF-014: nombre obligatorio en el desglose manual
    IF v_modo = 'manual' AND (NEW.`nombre` IS NULL OR TRIM(NEW.`nombre`) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-META-035: el desglose manual exige nombre en cada submeta (422)';
    END IF;
    IF NEW.`cerrada_por_administrador` = 0 AND NEW.`id_administrador_cierre` IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'id_administrador_cierre solo se informa en un cierre administrativo (500)';
    END IF;
END$$

CREATE TRIGGER `submeta_bu` BEFORE UPDATE ON `submeta`
FOR EACH ROW
BEGIN
    DECLARE v_fi DATE; DECLARE v_ff DATE; DECLARE v_hi TIME; DECLARE v_hf TIME; DECLARE v_modo VARCHAR(10);
    DECLARE v_n_evid INT DEFAULT 0;
    IF NEW.`id_meta` <> OLD.`id_meta` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la meta padre de la submeta (500)';
    END IF;
    -- Una submeta finalizada es inmutable (estado, puntaje, cierre)
    IF OLD.`estado` = 'finalizada' AND (NEW.`estado` <> 'finalizada' OR NOT (NEW.`puntaje_obtenido` <=> OLD.`puntaje_obtenido`)
       OR NOT (NEW.`hora_fin_real` <=> OLD.`hora_fin_real`)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La submeta ya está finalizada; el cierre es definitivo (409)';
    END IF;
    IF OLD.`estado` = 'en_curso' AND NEW.`estado` = 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: una submeta en curso no vuelve a pendiente (409)';
    END IF;
    -- hora_inicio_real solo pasa de NULL a un valor (al iniciar la submeta); fijada, no cambia ni se borra,
    -- porque de ella se derivan el porcentaje y la ventana de la evidencia (BR-001, BR-003)
    IF OLD.`hora_inicio_real` IS NOT NULL AND NOT (NEW.`hora_inicio_real` <=> OLD.`hora_inicio_real`) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-001: hora_inicio_real no se puede modificar una vez fijada (500)';
    END IF;
    IF NEW.`fecha_programada` <> OLD.`fecha_programada` OR NEW.`horario_inicio` <> OLD.`horario_inicio`
       OR NEW.`horario_fin` <> OLD.`horario_fin` THEN
        SELECT `fecha_inicio`, `fecha_fin`, `horario_inicio`, `horario_fin`
          INTO v_fi, v_ff, v_hi, v_hf FROM `meta` WHERE `id_meta` = NEW.`id_meta`;
        IF NEW.`fecha_programada` < v_fi OR NEW.`fecha_programada` > v_ff
           OR NEW.`horario_inicio` < v_hi OR NEW.`horario_fin` > v_hf THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-014: la submeta debe caber en la fecha y el horario de la meta (422)';
        END IF;
    END IF;
    SELECT `modo_desglose` INTO v_modo FROM `meta` WHERE `id_meta` = NEW.`id_meta`;
    IF v_modo = 'manual' AND (NEW.`nombre` IS NULL OR TRIM(NEW.`nombre`) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-META-035: el desglose manual exige nombre en cada submeta (422)';
    END IF;
    IF NEW.`cerrada_por_administrador` = 0 AND NEW.`id_administrador_cierre` IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'id_administrador_cierre solo se informa en un cierre administrativo (500)';
    END IF;
    -- RF-PUNT-004: con dos envíos el puntaje no supera 90
    IF NEW.`puntaje_obtenido` IS NOT NULL AND NEW.`puntaje_obtenido` > 90 THEN
        SELECT COUNT(*) INTO v_n_evid FROM `evidencia` WHERE `id_submeta` = NEW.`id_submeta`;
        IF v_n_evid >= 2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-PUNT-004: con dos envíos el puntaje máximo es 90 (500)';
        END IF;
    END IF;
END$$

CREATE TRIGGER `submeta_ai` AFTER INSERT ON `submeta`
FOR EACH ROW
BEGIN
    CALL `sp_recalcular_estado_meta`(NEW.`id_meta`);
END$$

CREATE TRIGGER `submeta_au` AFTER UPDATE ON `submeta`
FOR EACH ROW
BEGIN
    -- RF-PUNT-008 / RF-PUNT-014: el puntaje final se suma al perfil UNA vez, al pasar a finalizada con calificación
    IF OLD.`estado` <> 'finalizada' AND NEW.`estado` = 'finalizada' AND NEW.`puntaje_obtenido` IS NOT NULL THEN
        UPDATE `usuario`
           SET `puntaje_acumulado` = `puntaje_acumulado` + NEW.`puntaje_obtenido`
         WHERE `id_usuario` = (SELECT `id_usuario` FROM `meta` WHERE `id_meta` = NEW.`id_meta`);
    END IF;
    IF NEW.`estado` <> OLD.`estado` OR NOT (NEW.`hora_inicio_real` <=> OLD.`hora_inicio_real`) THEN
        CALL `sp_recalcular_estado_meta`(NEW.`id_meta`);
    END IF;
END$$

CREATE TRIGGER `submeta_ad` AFTER DELETE ON `submeta`
FOR EACH ROW
BEGIN
    CALL `sp_recalcular_estado_meta`(OLD.`id_meta`);
END$$

-- ---- sesion_pomodoro -------------------------------------------------------------
CREATE TRIGGER `sesion_pomodoro_bi` BEFORE INSERT ON `sesion_pomodoro`
FOR EACH ROW
BEGIN
    IF NEW.`id_submeta` IS NOT NULL AND NOT EXISTS (
           SELECT 1 FROM `submeta` s JOIN `meta` m ON m.`id_meta` = s.`id_meta`
            WHERE s.`id_submeta` = NEW.`id_submeta` AND m.`id_usuario` = NEW.`id_usuario`) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La submeta no pertenece al usuario de la sesión Pomodoro (404)';
    END IF;
END$$

-- ---- recomendacion_ia ----------------------------------------------------------
CREATE TRIGGER `recomendacion_ia_bu` BEFORE UPDATE ON `recomendacion_ia`
FOR EACH ROW
BEGIN
    IF NEW.`id_meta` <> OLD.`id_meta` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la meta de la recomendación (500)';
    END IF;
END$$

-- ---- evidencia: reglas del 80 %, segundo envío y propiedad (BR-001, BR-002, RF-EVID-014/015/016) ----
CREATE TRIGGER `evidencia_bi` BEFORE INSERT ON `evidencia`
FOR EACH ROW
BEGIN
    DECLARE v_estado_sub VARCHAR(20); DECLARE v_propietario INT; DECLARE v_req TINYINT;
    DECLARE v_e1 VARCHAR(15); DECLARE v_d1 VARCHAR(15);
    DECLARE v_inicio DATETIME; DECLARE v_t INT; DECLARE v_seg INT; DECLARE v_pct DECIMAL(9,4);
    SELECT s.`estado`, m.`id_usuario`, m.`requiere_evidencia`, s.`hora_inicio_real`,
           TIME_TO_SEC(s.`horario_fin`) - TIME_TO_SEC(s.`horario_inicio`)
      INTO v_estado_sub, v_propietario, v_req, v_inicio, v_t
      FROM `submeta` s JOIN `meta` m ON m.`id_meta` = s.`id_meta`
     WHERE s.`id_submeta` = NEW.`id_submeta`;
    IF v_propietario IS NULL OR v_propietario <> NEW.`id_usuario` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-015: la submeta no existe o no pertenece al usuario (404)';
    END IF;
    IF v_req = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-014: la meta no requiere evidencia (409)';
    END IF;
    IF v_estado_sub <> 'en_curso' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se recibe evidencia de una submeta en curso (409)';
    END IF;
    -- BR-001 / BR-003 / RF-EVID-010: el porcentaje y la ventana se DERIVAN de fecha_carga (UTC), de
    -- hora_inicio_real y del tiempo estipulado T de la submeta, y lo declarado se contrasta con lo derivado.
    SET v_seg = TIMESTAMPDIFF(SECOND, v_inicio, NEW.`fecha_carga`);
    IF v_seg < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-010: fecha_carga es anterior al inicio real de la submeta (409)';
    END IF;
    IF v_seg > v_t + v_t DIV 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-003: fecha_carga es posterior al fin del periodo de gracia, 1,1 T (409)';
    END IF;
    SET v_pct = v_seg * 100 / v_t;
    -- BR-001: regla del 80 %, para el primer y el segundo envío, sobre el porcentaje derivado y sobre el declarado
    IF v_pct < 80 OR NEW.`porcentaje_tiempo_transcurrido` < 80 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-001: no se admite evidencia antes del 80 % del tiempo estipulado (409)';
    END IF;
    -- tolerancia: 1 segundo de T expresado en puntos porcentuales, más el redondeo a 2 decimales
    IF ABS(NEW.`porcentaje_tiempo_transcurrido` - v_pct) > 100 / v_t + 0.01 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-010: porcentaje_tiempo_transcurrido no coincide con fecha_carga, hora_inicio_real y T (409)';
    END IF;
    -- ventana: inicial hasta T, gracia después (en T exacto vale cualquiera)
    IF (NEW.`ventana` = 'inicial' AND v_seg > v_t) OR (NEW.`ventana` = 'gracia' AND v_seg < v_t) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-010: ventana no coincide con fecha_carga (inicial hasta T, gracia hasta 1,1 T) (409)';
    END IF;
    -- RF-EVID-016: el segundo envío exige primer dictamen Incoherente o Inválida
    IF NEW.`intento` = 2 THEN
        SELECT ev.`estado`, ev.`dictamen` INTO v_e1, v_d1
          FROM `evidencia` e JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`
         WHERE e.`id_submeta` = NEW.`id_submeta` AND e.`intento` = 1;
        IF v_e1 IS NULL OR v_e1 <> 'evaluada' OR v_d1 NOT IN ('incoherente','invalida') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-EVID-016: el segundo envío exige un primer dictamen Incoherente o Inválida (409)';
        END IF;
    END IF;
END$$

CREATE TRIGGER `evidencia_bu` BEFORE UPDATE ON `evidencia`
FOR EACH ROW
BEGIN
    IF NEW.`id_submeta` <> OLD.`id_submeta` OR NEW.`id_usuario` <> OLD.`id_usuario` OR NEW.`intento` <> OLD.`intento`
       OR NEW.`ventana` <> OLD.`ventana` OR NEW.`porcentaje_tiempo_transcurrido` <> OLD.`porcentaje_tiempo_transcurrido`
       OR NOT (NEW.`fecha_carga` <=> OLD.`fecha_carga`) THEN                 -- fecha_carga también es inmutable
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden modificar submeta, usuario, intento, ventana, porcentaje ni fecha de carga de una evidencia (500)';
    END IF;
END$$

-- una evidencia evaluada, o de una submeta ya cerrada, no se borra con un DELETE directo (evita
-- borrar y reinsertar para cambiar el dictamen o dejar puntaje sin respaldo). El borrado en cascada por
-- cuenta, meta o submeta NO activa triggers en MariaDB y sigue funcionando; solo se rechaza el DELETE
-- directo sobre la propia fila. El borrado de la evidencia arrastra a su evaluación también en cascada.
CREATE TRIGGER `evidencia_bd` BEFORE DELETE ON `evidencia`
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM `evaluacion` WHERE `id_evidencia` = OLD.`id_evidencia` AND `estado` = 'evaluada')
       OR EXISTS (SELECT 1 FROM `submeta` WHERE `id_submeta` = OLD.`id_submeta` AND `estado` = 'finalizada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: una evidencia evaluada o de una submeta finalizada no se elimina (solo por borrado de la cuenta o de la meta) (409)';
    END IF;
END$$

-- ---- evaluacion: puntos por BR-004, transiciones BR-029, Error (RF-ADM-018) --------------
CREATE TRIGGER `evaluacion_bi` BEFORE INSERT ON `evaluacion`
FOR EACH ROW
BEGIN
    DECLARE v_intento INT; DECLARE v_ventana VARCHAR(10); DECLARE v_pts INT;
    SELECT `intento`, `ventana` INTO v_intento, v_ventana FROM `evidencia` WHERE `id_evidencia` = NEW.`id_evidencia`;
    IF v_intento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evidencia referenciada no existe (404)';
    END IF;
    IF NEW.`estado` = 'evaluada' THEN
        SET v_pts = `fn_puntos_evidencia`(v_intento, v_ventana, NEW.`dictamen`);
        IF NEW.`puntos_otorgados` IS NOT NULL AND NEW.`puntos_otorgados` <> v_pts THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-004: puntos_otorgados no corresponde a la tabla de puntaje (500)';
        END IF;
        SET NEW.`puntos_otorgados` = v_pts;
        IF NEW.`fecha_evaluacion` IS NULL THEN SET NEW.`fecha_evaluacion` = CURRENT_TIMESTAMP; END IF;
    ELSEIF NEW.`estado` = 'error' AND NEW.`fecha_ultimo_error` IS NULL THEN
        SET NEW.`fecha_ultimo_error` = CURRENT_TIMESTAMP;
    END IF;
END$$

CREATE TRIGGER `evaluacion_bu` BEFORE UPDATE ON `evaluacion`
FOR EACH ROW
BEGIN
    DECLARE v_intento INT; DECLARE v_ventana VARCHAR(10); DECLARE v_pts INT; DECLARE v_estado_sub VARCHAR(20);
    IF NEW.`id_evidencia` <> OLD.`id_evidencia` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la evidencia evaluada (500)';
    END IF;
    -- una evaluación evaluada es inmutable (dictamen, puntos_otorgados, justificación y fecha)
    IF OLD.`estado` = 'evaluada' AND (NEW.`estado` <> 'evaluada' OR NOT (NEW.`dictamen` <=> OLD.`dictamen`)
       OR NOT (NEW.`puntos_otorgados` <=> OLD.`puntos_otorgados`)
       OR NOT (NEW.`justificacion` <=> OLD.`justificacion`)
       OR NOT (NEW.`fecha_evaluacion` <=> OLD.`fecha_evaluacion`)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: una evaluación evaluada es definitiva (409)';
    END IF;
    -- Máquina de estados: en_evaluacion -> evaluada | error ; error -> en_evaluacion (Reintentar, BR-017)
    IF OLD.`estado` = 'error' AND NEW.`estado` = 'evaluada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: de error solo se vuelve a en_evaluacion (Reintentar) (409)';
    END IF;
    IF OLD.`estado` = 'error' AND NEW.`estado` = 'en_evaluacion' THEN
        SELECT s.`estado` INTO v_estado_sub
          FROM `evidencia` e JOIN `submeta` s ON s.`id_submeta` = e.`id_submeta`
         WHERE e.`id_evidencia` = OLD.`id_evidencia`;
        IF v_estado_sub = 'finalizada' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-019: la submeta ya está cerrada; no se puede reintentar (409)';
        END IF;
    END IF;
    IF NEW.`estado` = 'evaluada' AND OLD.`estado` <> 'evaluada' THEN
        SELECT `intento`, `ventana` INTO v_intento, v_ventana FROM `evidencia` WHERE `id_evidencia` = OLD.`id_evidencia`;
        SET v_pts = `fn_puntos_evidencia`(v_intento, v_ventana, NEW.`dictamen`);
        IF NEW.`puntos_otorgados` IS NOT NULL AND NEW.`puntos_otorgados` <> v_pts THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-004: puntos_otorgados no corresponde a la tabla de puntaje (500)';
        END IF;
        SET NEW.`puntos_otorgados` = v_pts;
        IF NEW.`fecha_evaluacion` IS NULL THEN SET NEW.`fecha_evaluacion` = CURRENT_TIMESTAMP; END IF;
    END IF;
    -- Cada entrada a Error reinicia la cuenta de 48 h (RF-EVID-008, RF-ADM-018)
    IF NEW.`estado` = 'error' AND OLD.`estado` <> 'error' AND NEW.`fecha_ultimo_error` <=> OLD.`fecha_ultimo_error` THEN
        SET NEW.`fecha_ultimo_error` = CURRENT_TIMESTAMP;
    END IF;
END$$

-- una evaluación evaluada, o de una submeta ya cerrada, no se borra con un DELETE directo (BR-029:
-- el dictamen es definitivo). La cascada por cuenta, meta, submeta o evidencia no activa este trigger.
CREATE TRIGGER `evaluacion_bd` BEFORE DELETE ON `evaluacion`
FOR EACH ROW
BEGIN
    IF OLD.`estado` = 'evaluada'
       OR EXISTS (SELECT 1 FROM `evidencia` e JOIN `submeta` s ON s.`id_submeta` = e.`id_submeta`
                   WHERE e.`id_evidencia` = OLD.`id_evidencia` AND s.`estado` = 'finalizada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-029: una evaluación evaluada o de una submeta finalizada no se elimina (el dictamen es definitivo) (409)';
    END IF;
END$$

-- ---- uso_llm: vínculos obligatorios al insertar (RNF-014, RF-ADM-007). No es un CHECK permanente:
-- tras ON DELETE SET NULL los vínculos quedan vacíos por diseño. -----------------------------------
CREATE TRIGGER `uso_llm_bi` BEFORE INSERT ON `uso_llm`
FOR EACH ROW
BEGIN
    IF NEW.`operacion` = 'evaluacion' AND NEW.`id_evaluacion` IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-007: una llamada de evaluación debe informar id_evaluacion (500)';
    END IF;
    IF NEW.`operacion` = 'desglose' AND NEW.`id_meta` IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-007: una llamada de desglose debe informar id_meta (500)';
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- 4. PROCEDIMIENTOS DE NEGOCIO
--    Llamarlos con autocommit activo y sin transacción abierta los que abren la suya
--    (sp_crear_desglose, sp_cambiar_rol, sp_cambiar_nivel_acceso, sp_inicializar_primer_super); los demás
--    se ejecutan dentro de la transacción del llamante.
-- ============================================================================

DELIMITER $$

-- Cierre de una submeta con evidencia o sin ella (BR-018 a, b, c, d) y tabla 3.6.1.
--   p_ahora: instante UTC de la decisión (parámetro para poder simularlo en pruebas, CP con reloj simulado).
--   OUT p_cerrada: 1 si la submeta quedó finalizada; OUT p_puntaje: puntaje final (NULL = sin calificación).
-- El puntaje del perfil lo suma el trigger submeta_au en el mismo UPDATE (atómico).
CREATE PROCEDURE `sp_cerrar_submeta`(IN p_id_submeta INT, IN p_ahora DATETIME, OUT p_cerrada TINYINT, OUT p_puntaje INT)
SQL SECURITY DEFINER
cuerpo: BEGIN
    DECLARE v_estado VARCHAR(20); DECLARE v_inicio DATETIME; DECLARE v_t INT; DECLARE v_req TINYINT;
    DECLARE v_fin_inicial DATETIME; DECLARE v_fin_gracia DATETIME;
    DECLARE v_n_env INT DEFAULT 0; DECLARE v_n_eval INT DEFAULT 0; DECLARE v_suma INT DEFAULT 0;
    DECLARE v_e1 VARCHAR(15); DECLARE v_d1 VARCHAR(15); DECLARE v_p1 INT;
    DECLARE v_cerrar TINYINT DEFAULT 0; DECLARE v_final INT DEFAULT NULL;

    SET p_cerrada = 0;
    SET p_puntaje = NULL;

    SELECT s.`estado`, s.`hora_inicio_real`, TIME_TO_SEC(s.`horario_fin`) - TIME_TO_SEC(s.`horario_inicio`), m.`requiere_evidencia`
      INTO v_estado, v_inicio, v_t, v_req
      FROM `submeta` s JOIN `meta` m ON m.`id_meta` = s.`id_meta`
     WHERE s.`id_submeta` = p_id_submeta
       FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La submeta no existe (404)';
    END IF;
    IF v_estado <> 'en_curso' THEN
        LEAVE cuerpo;                              -- ya finalizada o aún no iniciada: nada que cerrar aquí
    END IF;

    SET v_fin_inicial = DATE_ADD(v_inicio, INTERVAL v_t SECOND);                 -- fin del periodo inicial: T
    SET v_fin_gracia  = DATE_ADD(v_inicio, INTERVAL (v_t + v_t DIV 10) SECOND);  -- fin de la gracia: 1,1 T (BR-003)

    IF v_req = 0 THEN
        -- BR-010 / BR-018 (d): meta sin evidencia, cierra al vencer el tiempo estipulado, sin calificación
        IF p_ahora >= v_fin_inicial THEN SET v_cerrar = 1; SET v_final = NULL; END IF;
    ELSE
        SELECT COUNT(*), COALESCE(SUM(ev.`estado` = 'evaluada'), 0),
               COALESCE(SUM(CASE WHEN ev.`estado` = 'evaluada' THEN ev.`puntos_otorgados` END), 0)
          INTO v_n_env, v_n_eval, v_suma
          FROM `evidencia` e LEFT JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`
         WHERE e.`id_submeta` = p_id_submeta;
        -- agregados (MAX) para que, sin primer envío, no se levante la condición NOT FOUND hacia el llamador
        SELECT MAX(ev.`estado`), MAX(ev.`dictamen`), MAX(ev.`puntos_otorgados`) INTO v_e1, v_d1, v_p1
          FROM `evidencia` e JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`
         WHERE e.`id_submeta` = p_id_submeta AND e.`intento` = 1;

        IF v_n_env >= 1 AND v_e1 = 'evaluada' AND v_d1 = 'excelente' THEN
            -- (a) primer envío Excelente: 100 en el periodo inicial, 50 en gracia; sin tope (RF-PUNT-001)
            SET v_cerrar = 1; SET v_final = v_p1;
        ELSEIF v_n_env = 2 AND v_n_eval = 2 THEN
            -- (b) dictamen del segundo envío: suma con tope de 90 (RF-PUNT-004, RF-PUNT-013)
            SET v_cerrar = 1; SET v_final = LEAST(v_suma, 90);
        ELSEIF v_n_eval = v_n_env AND p_ahora >= v_fin_gracia THEN
            -- (c) fin de la gracia sin evaluaciones pendientes ni en Error: puntaje del primer envío o 0 (RF-PUNT-006)
            SET v_cerrar = 1; SET v_final = IF(v_n_env = 2, LEAST(v_suma, 90), v_suma);
        END IF;
    END IF;

    IF v_cerrar = 1 THEN
        UPDATE `submeta`
           SET `estado` = 'finalizada', `puntaje_obtenido` = v_final,
               `hora_fin_real` = GREATEST(p_ahora, DATE_ADD(v_inicio, INTERVAL 1 SECOND))
         WHERE `id_submeta` = p_id_submeta;
        SET p_cerrada = 1;
        SET p_puntaje = v_final;
    END IF;
END$$

-- BR-018 (e) / BR-027 / RF-META-026: submeta manual no iniciada. p_ahora_local = fecha-hora local del usuario.
CREATE PROCEDURE `sp_cerrar_submeta_no_iniciada`(IN p_id_submeta INT, IN p_ahora_local DATETIME, OUT p_cerrada TINYINT)
SQL SECURITY DEFINER
cuerpo: BEGIN
    DECLARE v_estado VARCHAR(20); DECLARE v_fecha DATE; DECLARE v_req TINYINT; DECLARE v_modo VARCHAR(10);
    SET p_cerrada = 0;
    SELECT s.`estado`, s.`fecha_programada`, m.`requiere_evidencia`, m.`modo_inicio`
      INTO v_estado, v_fecha, v_req, v_modo
      FROM `submeta` s JOIN `meta` m ON m.`id_meta` = s.`id_meta`
     WHERE s.`id_submeta` = p_id_submeta FOR UPDATE;
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La submeta no existe (404)';
    END IF;
    IF v_estado = 'pendiente' AND v_modo = 'manual' AND DATE(p_ahora_local) > v_fecha THEN
        UPDATE `submeta` SET `estado` = 'finalizada', `puntaje_obtenido` = IF(v_req = 1, 0, NULL)
         WHERE `id_submeta` = p_id_submeta;
        SET p_cerrada = 1;
    END IF;
END$$

-- Dictamen del LLM + evaluación del cierre en una sola transacción lógica (CU-014, CU-016).
CREATE PROCEDURE `sp_registrar_dictamen`(IN p_id_evaluacion INT, IN p_dictamen VARCHAR(15), IN p_justificacion TEXT,
                                         IN p_ahora DATETIME, OUT p_cerrada TINYINT, OUT p_puntaje INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_id_submeta INT;
    UPDATE `evaluacion`
       SET `estado` = 'evaluada', `dictamen` = p_dictamen, `justificacion` = p_justificacion, `fecha_evaluacion` = p_ahora
     WHERE `id_evaluacion` = p_id_evaluacion AND `estado` = 'en_evaluacion';
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evaluación no existe o no está en_evaluacion (409)';
    END IF;
    SELECT e.`id_submeta` INTO v_id_submeta
      FROM `evaluacion` ev JOIN `evidencia` e ON e.`id_evidencia` = ev.`id_evidencia`
     WHERE ev.`id_evaluacion` = p_id_evaluacion;
    CALL `sp_cerrar_submeta`(v_id_submeta, p_ahora, p_cerrada, p_puntaje);
END$$

-- Barrido periódico (por ejemplo cada minuto): cierra las submetas EN CURSO cuyo plazo venció.
-- NO cierra las submetas manuales pendientes que no se iniciaron (BR-018 e, BR-027): eso exige la fecha-hora
-- LOCAL de cada usuario y lo hace la aplicación llamando sp_cerrar_submeta_no_iniciada.
CREATE PROCEDURE `sp_cerrar_submetas_vencidas`(IN p_ahora DATETIME, OUT p_total INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_id INT; DECLARE v_fin BOOLEAN DEFAULT FALSE; DECLARE v_c TINYINT; DECLARE v_p INT;
    DECLARE cur CURSOR FOR
        SELECT `id_submeta` FROM `submeta`
         WHERE `estado` = 'en_curso'
           AND DATE_ADD(`hora_inicio_real`, INTERVAL (TIME_TO_SEC(`horario_fin`) - TIME_TO_SEC(`horario_inicio`)) SECOND) <= p_ahora;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = TRUE;
    SET p_total = 0;
    OPEN cur;
    bucle: LOOP
        FETCH cur INTO v_id;
        IF v_fin THEN LEAVE bucle; END IF;
        CALL `sp_cerrar_submeta`(v_id, p_ahora, v_c, v_p);
        SET v_fin = FALSE;                      -- por si el procedimiento llamado levantó NOT FOUND
        SET p_total = p_total + v_c;
    END LOOP;
    CLOSE cur;
END$$

-- RF-ADM-019 / CU-030: cierre administrativo tras 48 h de una evaluación en Error.
CREATE PROCEDURE `sp_cerrar_submeta_admin`(IN p_id_submeta INT, IN p_id_admin INT, IN p_ahora DATETIME, OUT p_puntaje INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_nivel VARCHAR(20); DECLARE v_estado VARCHAR(20); DECLARE v_inicio DATETIME; DECLARE v_n_error INT DEFAULT 0;
    SELECT `nivel_acceso` INTO v_nivel FROM `administrador` WHERE `id_usuario` = p_id_admin;
    IF v_nivel IS NULL OR v_nivel NOT IN ('super','moderador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-019: solo el administrador super o moderador puede cerrar (403)';
    END IF;
    SELECT `estado`, `hora_inicio_real` INTO v_estado, v_inicio FROM `submeta` WHERE `id_submeta` = p_id_submeta FOR UPDATE;
    IF v_estado IS NULL OR v_estado <> 'en_curso' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-019: la submeta no está abierta (409)';
    END IF;
    SELECT COUNT(*) INTO v_n_error
      FROM `evidencia` e JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`
     WHERE e.`id_submeta` = p_id_submeta AND ev.`estado` = 'error'
       AND ev.`fecha_ultimo_error` <= DATE_SUB(p_ahora, INTERVAL 48 HOUR);
    IF v_n_error = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-019: ninguna evaluación lleva 48 h o más en Error (409)';
    END IF;
    SET p_puntaje = `fn_puntaje_provisional`(p_id_submeta);
    UPDATE `submeta`
       SET `estado` = 'finalizada', `puntaje_obtenido` = p_puntaje,
           `hora_fin_real` = GREATEST(p_ahora, DATE_ADD(v_inicio, INTERVAL 1 SECOND)),
           `cerrada_por_administrador` = 1, `id_administrador_cierre` = p_id_admin, `fecha_cierre_administrativo` = p_ahora
     WHERE `id_submeta` = p_id_submeta;
END$$

-- Día activo (BR-009): lo registra un inicio MANUAL o el envío de una evidencia; nunca un inicio automático.
CREATE PROCEDURE `sp_registrar_dia_activo`(IN p_id_usuario INT, IN p_fecha_local DATE, IN p_instante DATETIME, IN p_inicio_manual TINYINT)
SQL SECURITY DEFINER
BEGIN
    INSERT INTO `dia_activo` (`id_usuario`, `fecha`, `primera_submeta_inicio`, `total_submetas_iniciadas`)
    VALUES (p_id_usuario, p_fecha_local, IF(p_inicio_manual = 1, p_instante, NULL), IF(p_inicio_manual = 1, 1, 0))
    ON DUPLICATE KEY UPDATE
        `total_submetas_iniciadas` = `total_submetas_iniciadas` + IF(p_inicio_manual = 1, 1, 0),
        `primera_submeta_inicio`   = COALESCE(`primera_submeta_inicio`, IF(p_inicio_manual = 1, p_instante, NULL));
END$$

-- Inicio de una submeta (CU-009). p_manual = 0 para el inicio automático: no activa el día.
CREATE PROCEDURE `sp_iniciar_submeta`(IN p_id_submeta INT, IN p_ahora_utc DATETIME, IN p_ahora_local DATETIME, IN p_manual TINYINT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_estado VARCHAR(20); DECLARE v_fecha DATE; DECLARE v_usuario INT;
    SELECT s.`estado`, s.`fecha_programada`, m.`id_usuario` INTO v_estado, v_fecha, v_usuario
      FROM `submeta` s JOIN `meta` m ON m.`id_meta` = s.`id_meta`
     WHERE s.`id_submeta` = p_id_submeta FOR UPDATE;
    IF v_estado IS NULL OR v_estado <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La submeta no existe o no está pendiente (409)';
    END IF;
    IF p_manual = 1 AND DATE(p_ahora_local) > v_fecha THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-027: el inicio manual venció a las 23:59 de la fecha programada (409)';
    END IF;
    -- BR-027: el inicio manual vale durante su fecha programada (00:00:00-23:59:59 local);
    -- NO depende de horario_inicio. Antes de esa fecha se rechaza.
    IF p_manual = 1 AND DATE(p_ahora_local) < v_fecha THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-027: el inicio manual no puede ser anterior a la fecha programada (409)';
    END IF;
    UPDATE `submeta` SET `estado` = 'en_curso', `hora_inicio_real` = p_ahora_utc WHERE `id_submeta` = p_id_submeta;
    IF p_manual = 1 THEN
        CALL `sp_registrar_dia_activo`(v_usuario, DATE(p_ahora_local), p_ahora_utc, 1);
    END IF;
END$$

-- Calendario de actividad (BR-034): días activos de los últimos 12 meses móviles que terminan hoy (zona del usuario).
CREATE PROCEDURE `sp_calendario_actividad`(IN p_id_usuario INT, IN p_hoy DATE)
SQL SECURITY DEFINER
BEGIN
    SELECT `fecha`, `total_submetas_iniciadas`
      FROM `dia_activo`
     WHERE `id_usuario` = p_id_usuario
       AND `fecha` BETWEEN DATE_ADD(DATE_SUB(p_hoy, INTERVAL 12 MONTH), INTERVAL 1 DAY) AND p_hoy
     ORDER BY `fecha`;
END$$

-- Otorgamiento único de logros (RF-LOGR-002): la PK compuesta lo garantiza; p_otorgado = 1 si es nuevo.
CREATE PROCEDURE `sp_otorgar_logro`(IN p_id_usuario INT, IN p_codigo VARCHAR(40), OUT p_otorgado TINYINT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_id_logro INT;
    SELECT `id_logro` INTO v_id_logro FROM `logro` WHERE `codigo` = p_codigo;
    IF v_id_logro IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Código de logro inexistente (500)';
    END IF;
    INSERT INTO `usuario_logro` (`id_usuario`, `id_logro`) VALUES (p_id_usuario, v_id_logro)
    ON DUPLICATE KEY UPDATE `id_usuario` = `id_usuario`;
    SET p_otorgado = IF(ROW_COUNT() = 1, 1, 0);
END$$

-- Creación / regeneración del desglose en UNA transacción (RNF-014, RF-META-003/027/033/034).
-- p_submetas: arreglo JSON [{"fecha":"2026-11-11","inicio":"08:00:00","fin":"10:00:00","nombre":"...","descripcion_ia":"..."}, ...]
-- Si la suma de duraciones difiere de tiempo_total (o el número de submetas de dias_destinados) se revierte todo.
CREATE PROCEDURE `sp_crear_desglose`(IN p_id_meta INT, IN p_submetas JSON)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    SELECT `id_meta` INTO v_id FROM `meta` WHERE `id_meta` = p_id_meta FOR UPDATE;
    IF v_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La meta no existe (404)';
    END IF;
    IF EXISTS (SELECT 1 FROM `submeta` WHERE `id_meta` = p_id_meta AND `estado` <> 'pendiente') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-025: hay submetas iniciadas; no se regenera el desglose (409)';
    END IF;
    DELETE FROM `submeta` WHERE `id_meta` = p_id_meta;
    INSERT INTO `submeta` (`id_meta`, `fecha_programada`, `horario_inicio`, `horario_fin`, `nombre`, `descripcion_ia`)
    SELECT p_id_meta, jt.`fecha`, jt.`inicio`, jt.`fin`, jt.`nombre`, jt.`descripcion_ia`
      FROM JSON_TABLE(p_submetas, '$[*]' COLUMNS (
               `fecha` DATE PATH '$.fecha',
               `inicio` TIME PATH '$.inicio',
               `fin` TIME PATH '$.fin',
               `nombre` VARCHAR(150) PATH '$.nombre',
               `descripcion_ia` TEXT PATH '$.descripcion_ia')) AS jt;
    CALL `sp_validar_suma_desglose`(p_id_meta);
    COMMIT;
END$$

-- Cambio de rol de una cuenta SIN datos (RF-ADM-009, RF-ADM-020, BR-013). p_nivel obligatorio al pasar a administrador.
-- BR-021: lo ejecuta un administrador IDENTIFICADO (p_id_actor) que debe ser de nivel super; si no, 403.
-- La lectura del actor es con bloqueo (FOR UPDATE): una lectura consistente previa fijaría la instantánea y
-- sp_validar_no_ultimo_super contaría los supers con datos viejos (ver su comentario).
-- La cuenta que vuelve a ser cliente nace SIN la declaración de mayoría de edad (RF-AUT-018): la hace en su primer inicio de sesión.
CREATE PROCEDURE `sp_cambiar_rol`(IN p_id_actor INT, IN p_id_usuario INT, IN p_nuevo_rol VARCHAR(20), IN p_nivel VARCHAR(20))
SQL SECURITY DEFINER
BEGIN
    DECLARE v_rol VARCHAR(20);
    DECLARE v_nivel_actor VARCHAR(20) DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET @fs_rol_autorizado = NULL;
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    SELECT `nivel_acceso` INTO v_nivel_actor FROM `administrador` WHERE `id_usuario` = p_id_actor FOR UPDATE;
    IF v_nivel_actor IS NULL OR v_nivel_actor <> 'super' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-021: solo un administrador super identificado puede cambiar el rol de una cuenta (403)';
    END IF;
    SELECT `rol` INTO v_rol FROM `usuario` WHERE `id_usuario` = p_id_usuario FOR UPDATE;
    IF v_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta no existe (404)';
    END IF;
    IF p_nuevo_rol NOT IN ('cliente','administrador') OR p_nuevo_rol = v_rol THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol inválido o igual al actual (422)';
    END IF;
    IF p_nuevo_rol = 'administrador' AND (p_nivel IS NULL OR p_nivel NOT IN ('super','moderador','soporte')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-014: el nivel de acceso es obligatorio (422)';
    END IF;
    SET @fs_rol_autorizado = p_id_usuario;                                         -- autoriza usuario_bu solo para esta cuenta
    UPDATE `usuario` SET `rol` = p_nuevo_rol WHERE `id_usuario` = p_id_usuario;   -- usuario_bu valida datos y último super
    SET @fs_rol_autorizado = NULL;
    IF p_nuevo_rol = 'administrador' THEN
        DELETE FROM `cliente` WHERE `id_usuario` = p_id_usuario;                  -- zona, preferencias, IA, push y declaración de edad (RF-ADM-020)
        INSERT INTO `administrador` (`id_usuario`, `nivel_acceso`) VALUES (p_id_usuario, p_nivel);
    ELSE
        DELETE FROM `administrador` WHERE `id_usuario` = p_id_usuario;
        INSERT INTO `cliente` (`id_usuario`, `zona_horaria`, `notificaciones_push`, `fecha_aceptacion_ia`, `zona_pendiente_deteccion`,
                               `fecha_confirmacion_mayoria_edad`)
        VALUES (p_id_usuario, 'America/Bogota', 1, NULL, 1, NULL);                -- RF-AUT-018: zona y mayoría de edad pendientes
    END IF;
    COMMIT;
END$$

-- Cambio de nivel de acceso de un administrador (RF-ADM-014, BR-021). Sustituye al UPDATE directo de
-- administrador.nivel_acceso, que la cuenta de la aplicación no tiene (permisos por columna).
--   * p_id_actor: administrador identificado; debe ser de nivel super, si no 403.
--   * p_id_usuario: la cuenta cuyo nivel cambia; debe ser un administrador (404 si no existe o no lo es).
--   * p_nivel: super | moderador | soporte (422 si falta o está fuera del catálogo).
--   * BR-021: no se puede dejar al sistema sin un super sin bloquear. La regla la aplica administrador_bu, que
--     llama a sp_validar_no_ultimo_super (cerrojo_sistema) al bajar de nivel a un super; responde 409.
--   * Mismo nivel que el actual: no hace nada (idempotente), sin error.
-- Llamarlo SIN transacción abierta (abre la suya). Los accesos previos al cerrojo son lecturas con bloqueo.
CREATE PROCEDURE `sp_cambiar_nivel_acceso`(IN p_id_actor INT, IN p_id_usuario INT, IN p_nivel VARCHAR(20))
SQL SECURITY DEFINER
BEGIN
    DECLARE v_nivel_actor VARCHAR(20) DEFAULT NULL;
    DECLARE v_nivel_actual VARCHAR(20) DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    IF p_nivel IS NULL OR p_nivel NOT IN ('super','moderador','soporte') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-ADM-014: el nivel de acceso es obligatorio y debe ser super, moderador o soporte (422)';
    END IF;
    START TRANSACTION;
    SELECT `nivel_acceso` INTO v_nivel_actor FROM `administrador` WHERE `id_usuario` = p_id_actor FOR UPDATE;
    IF v_nivel_actor IS NULL OR v_nivel_actor <> 'super' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BR-021: solo un administrador super identificado puede cambiar niveles de acceso (403)';
    END IF;
    SELECT `nivel_acceso` INTO v_nivel_actual FROM `administrador` WHERE `id_usuario` = p_id_usuario FOR UPDATE;
    IF v_nivel_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta no existe o no es administrador (404)';
    END IF;
    IF v_nivel_actual <> p_nivel THEN
        UPDATE `administrador` SET `nivel_acceso` = p_nivel WHERE `id_usuario` = p_id_usuario;   -- administrador_bu aplica BR-021
    END IF;
    COMMIT;
END$$

-- Declaración de mayoría de edad (RF-AUT-018). Fija el sello solo si es NULL (idempotente:
-- una segunda llamada no lo modifica) y solo en una cuenta de rol cliente. El registro (RF-AUT-017) no la usa: la
-- aplicación inserta la fila de cliente ya con el sello. La respuesta 403 MAYORIA_EDAD_REQUERIDA de las funciones de cliente
-- mientras el sello sea NULL la aplica la APLICACIÓN (no hay trigger: no puede interceptar lecturas ni las llamadas del backend).
CREATE PROCEDURE `sp_confirmar_mayoria_edad`(IN p_id_cliente INT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_rol VARCHAR(20) DEFAULT NULL;
    DECLARE v_es_cliente INT DEFAULT 0;
    SELECT u.`rol`, COUNT(c.`id_usuario`) INTO v_rol, v_es_cliente
      FROM `usuario` u LEFT JOIN `cliente` c ON c.`id_usuario` = u.`id_usuario`
     WHERE u.`id_usuario` = p_id_cliente
     GROUP BY u.`rol`;
    IF v_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cuenta no existe (404)';
    END IF;
    IF v_rol <> 'cliente' OR v_es_cliente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RF-AUT-018: la cuenta no es de un cliente; los administradores no declaran la mayoría de edad (403)';
    END IF;
    UPDATE `cliente` SET `fecha_confirmacion_mayoria_edad` = UTC_TIMESTAMP()
     WHERE `id_usuario` = p_id_cliente AND `fecha_confirmacion_mayoria_edad` IS NULL;
END$$

-- Semilla del primer administrador super (RF-ADM-017, CU-029). Sin credenciales en el script:
-- el hash lo calcula el proceso de arranque a partir de las variables de entorno (ver cabecera).
CREATE PROCEDURE `sp_inicializar_primer_super`(IN p_correo VARCHAR(150), IN p_nombre VARCHAR(100), IN p_hash VARCHAR(255), OUT p_resultado VARCHAR(40))
SQL SECURITY DEFINER
cuerpo: BEGIN
    DECLARE v_id INT;
    DECLARE v_bloqueo INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_bloqueo = 1 THEN DO RELEASE_LOCK('fs_primer_super'); END IF;
        ROLLBACK;
        RESIGNAL;
    END;
    IF GET_LOCK('fs_primer_super', 10) <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener el bloqueo de inicialización';
    END IF;
    SET v_bloqueo = 1;
    -- basta que exista UN super, aunque esté bloqueado; moderador y soporte no cuentan
    IF EXISTS (SELECT 1 FROM `administrador` WHERE `nivel_acceso` = 'super') THEN
        SET p_resultado = 'omitido_ya_existe_super';
    ELSEIF EXISTS (SELECT 1 FROM `usuario` WHERE `correo` = p_correo) THEN
        SET p_resultado = 'omitido_correo_existente';
    ELSE
        -- RNF-005: solo se acepta un hash bcrypt ($2b$, costo >= 12) o argon2id; jamás texto plano
        IF p_hash NOT REGEXP '^(\\$2b\\$(1[2-9]|2[0-9]|3[01])\\$|\\$argon2id\\$)' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RNF-005: la contraseña debe llegar como hash bcrypt (costo >= 12) o argon2id';
        END IF;
        START TRANSACTION;
        INSERT INTO `usuario` (`nombre`, `correo`, `contrasena_hash`, `rol`) VALUES (p_nombre, p_correo, p_hash, 'administrador');
        SET v_id = LAST_INSERT_ID();
        INSERT INTO `administrador` (`id_usuario`, `nivel_acceso`) VALUES (v_id, 'super');
        COMMIT;
        SET p_resultado = 'creado';
    END IF;
    DO RELEASE_LOCK('fs_primer_super');
END$$

-- Mantenimiento (programar con el event scheduler o con el planificador del despliegue)
CREATE PROCEDURE `sp_limpiar_tokens_expirados`()
SQL SECURITY DEFINER
BEGIN
    DELETE FROM `token_sesion` WHERE `revocado` = 1 OR `fecha_expiracion` < UTC_TIMESTAMP();
    SELECT ROW_COUNT() AS tokens_eliminados;
END$$

CREATE PROCEDURE `sp_limpiar_codigos_expirados`()
SQL SECURITY DEFINER
BEGIN
    DELETE FROM `codigo_recuperacion` WHERE `usado` = 1 OR `fecha_expiracion` < UTC_TIMESTAMP();
    SELECT ROW_COUNT() AS codigos_eliminados;
END$$

-- Métricas del LLM por operación (RF-ADM-011): incluyen llamadas fallidas y registros con vínculos vacíos.
CREATE PROCEDURE `sp_metricas_llm`(IN p_desde DATETIME)
SQL SECURITY DEFINER
BEGIN
    SELECT `operacion`, COUNT(*) AS llamadas, SUM(`tokens_consumidos`) AS tokens,
           SUM(`costo`) AS costo, AVG(`latencia_ms`) AS latencia_promedio_ms
      FROM `uso_llm`
     WHERE `fecha` >= p_desde
     GROUP BY `operacion`;
END$$

DELIMITER ;

-- ============================================================================
-- 5. VISTAS
-- ============================================================================

-- Cuenta con sus datos de subtipo.  No expone contrasena_hash.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW `v_usuario_completo` AS
SELECT u.`id_usuario`, u.`nombre`, u.`correo`, u.`puntaje_acumulado`, u.`estado_bloqueo`, u.`rol`,
       u.`intentos_fallidos`, u.`bloqueado_hasta`, u.`fecha_registro`,
       a.`nivel_acceso`, a.`fecha_asignacion` AS admin_fecha_asignacion,
       c.`zona_horaria`, c.`notificaciones_push`, c.`fecha_aceptacion_ia`,
       c.`zona_pendiente_deteccion`, c.`fecha_confirmacion_mayoria_edad`
  FROM `usuario` u
  LEFT JOIN `administrador` a ON a.`id_usuario` = u.`id_usuario`
  LEFT JOIN `cliente` c ON c.`id_usuario` = u.`id_usuario`;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW `v_meta_con_submetas` AS
SELECT m.*, COUNT(s.`id_submeta`) AS total_submetas,
       COALESCE(SUM(s.`estado` = 'finalizada'), 0) AS submetas_finalizadas,
       AVG(s.`puntaje_obtenido`) AS promedio_puntaje
  FROM `meta` m LEFT JOIN `submeta` s ON s.`id_meta` = m.`id_meta`
 GROUP BY m.`id_meta`;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW `v_evidencia_con_evaluacion` AS
SELECT e.*, ev.`id_evaluacion`, ev.`estado` AS eval_estado, ev.`dictamen`, ev.`puntos_otorgados`,
       ev.`justificacion`, ev.`fecha_evaluacion`, ev.`fecha_ultimo_error`
  FROM `evidencia` e LEFT JOIN `evaluacion` ev ON ev.`id_evidencia` = e.`id_evidencia`;

-- Ranking global (BR-023): clientes no bloqueados administrativamente; empates con la misma posición y
-- orden alfabético; solo nombre y puntaje. (La vista de administración, RF-ADM-005, usa v_usuario_completo.)
CREATE OR REPLACE SQL SECURITY DEFINER VIEW `v_ranking_global` AS
SELECT RANK() OVER (ORDER BY u.`puntaje_acumulado` DESC) AS posicion, u.`id_usuario`, u.`nombre`, u.`puntaje_acumulado`
  FROM `usuario` u
 WHERE u.`rol` = 'cliente' AND u.`estado_bloqueo` = 0
 ORDER BY `posicion`, u.`nombre`, u.`id_usuario`;   -- el desempate alfabético lo da esta vista; el servicio puede repetir ORDER BY posicion, nombre

-- Evaluaciones con 48 h o más en Error sin resolver y submeta aún abierta (RF-ADM-018). Reloj: UTC_TIMESTAMP().
CREATE OR REPLACE SQL SECURITY DEFINER VIEW `v_evaluaciones_error_48h` AS
SELECT ev.`id_evaluacion`, e.`id_evidencia`, s.`id_submeta`, m.`id_usuario`, ev.`fecha_ultimo_error`
  FROM `evaluacion` ev
  JOIN `evidencia` e ON e.`id_evidencia` = ev.`id_evidencia`
  JOIN `submeta` s ON s.`id_submeta` = e.`id_submeta`
  JOIN `meta` m ON m.`id_meta` = s.`id_meta`
 WHERE ev.`estado` = 'error' AND s.`estado` <> 'finalizada'
   AND ev.`fecha_ultimo_error` <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL 48 HOUR);

-- ============================================================================
-- 6. EVENTOS PROGRAMADOS (opcionales; requieren event_scheduler=ON)
-- ============================================================================
-- CREATE EVENT `ev_limpiar_tokens_expirados` ON SCHEDULE EVERY 1 HOUR DO CALL `sp_limpiar_tokens_expirados`();
-- CREATE EVENT `ev_limpiar_codigos_expirados` ON SCHEDULE EVERY 15 MINUTE DO CALL `sp_limpiar_codigos_expirados`();
-- CREATE EVENT `ev_cerrar_submetas_vencidas` ON SCHEDULE EVERY 1 MINUTE DO CALL `sp_cerrar_submetas_vencidas`(UTC_TIMESTAMP(), @n);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
