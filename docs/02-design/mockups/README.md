# Mockups de alta fidelidad — FocusStrike

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1 | 2026-11-11 | Equipo FocusStrike | Línea base |

## Qué son

Mockups de alta fidelidad de las **54 pantallas** (PAN-001 a PAN-054) de la interfaz de FocusStrike: pantallas del visitante y del cliente, administración, modales y estados de sistema (errores, sesión expirada, sin conexión). Cada pantalla se entrega en escritorio y móvil, en tema claro y oscuro: **54 × 4 = 216 archivos SVG**.

Los SVG son editables: el texto es real (`<text>`), cada componente es un grupo `<g>` con `id` y `data-name`, y los íconos son trazos. Cada mockup muestra el estado más representativo de su pantalla; el detalle está en el `<desc>` de cada SVG. Los datos de ejemplo (personas, metas, puntajes) son ficticios.

## Convención de nombres

`PAN-nnn_nombre_{desktop|mobile}_{light|dark}.svg`

- `PAN-nnn`: identificador de la pantalla.
- `nombre`: nombre corto de la pantalla en minúsculas y con guiones.
- `desktop` (artboard de 1280 px de ancho) o `mobile` (375 px).
- `light` (tema claro) o `dark` (tema oscuro).

Ejemplo: `PAN-001_register_desktop_light.svg`.

## Cómo abrirlos

- **Ver:** cualquier navegador moderno (arrastrar el archivo a una ventana).
- **Editar o importar:** Figma, Penpot, Sketch e Illustrator abren SVG y conservan las capas por grupo. La tipografía es Inter; si no está instalada, el programa usará una alternativa.

## Enlace de Figma

**Enlace de Figma:** _pendiente — agrega aquí el enlace del archivo_

## Índice de pantallas (54)

Cada fila corresponde a cuatro archivos (`desktop`/`mobile` × `light`/`dark`).

| PAN | Pantalla | Tipo | Actor | Archivos |
|---|---|---|---|---|
| PAN-001 | Registro | Pantalla | visitante | `PAN-001_register_{desktop,mobile}_{light,dark}.svg` |
| PAN-002 | Inicio de sesión | Pantalla | visitante | `PAN-002_login_{desktop,mobile}_{light,dark}.svg` |
| PAN-003 | Recuperar contraseña: solicitar código | Pantalla | visitante | `PAN-003_recover-request_{desktop,mobile}_{light,dark}.svg` |
| PAN-004 | Recuperar contraseña: restablecer | Pantalla | visitante | `PAN-004_recover-reset_{desktop,mobile}_{light,dark}.svg` |
| PAN-005 | Declaración de mayoría de edad pendiente | Pantalla | cliente | `PAN-005_age-confirmation_{desktop,mobile}_{light,dark}.svg` |
| PAN-006 | Inicio | Pantalla | cliente | `PAN-006_home_{desktop,mobile}_{light,dark}.svg` |
| PAN-007 | Agenda | Pantalla | cliente | `PAN-007_agenda_{desktop,mobile}_{light,dark}.svg` |
| PAN-008 | Mis metas | Pantalla | cliente | `PAN-008_my-goals_{desktop,mobile}_{light,dark}.svg` |
| PAN-009 | Detalle de meta | Pantalla | cliente | `PAN-009_goal-detail_{desktop,mobile}_{light,dark}.svg` |
| PAN-010 | Crear meta (paso 1): datos | Pantalla | cliente | `PAN-010_create-goal-step1_{desktop,mobile}_{light,dark}.svg` |
| PAN-011 | Crear meta (paso 2): fechas de trabajo | Pantalla | cliente | `PAN-011_create-goal-step2_{desktop,mobile}_{light,dark}.svg` |
| PAN-012 | Crear meta: recomendación de IA (más de 12 h por día) | Pantalla | cliente | `PAN-012_ai-recommendation_{desktop,mobile}_{light,dark}.svg` |
| PAN-013 | Crear meta: tipo de desglose | Pantalla | cliente | `PAN-013_create-goal-breakdown_{desktop,mobile}_{light,dark}.svg` |
| PAN-014 | Desglose manual de submetas | Pantalla | cliente | `PAN-014_manual-breakdown_{desktop,mobile}_{light,dark}.svg` |
| PAN-015 | Crear meta: resumen y guardar | Pantalla | cliente | `PAN-015_create-goal-summary_{desktop,mobile}_{light,dark}.svg` |
| PAN-016 | Desglose por IA: espera, resultado y fallo | Pantalla | cliente | `PAN-016_ai-wait_{desktop,mobile}_{light,dark}.svg` |
| PAN-017 | Editar meta | Pantalla | cliente | `PAN-017_edit-goal_{desktop,mobile}_{light,dark}.svg` |
| PAN-018 | Detalle de submeta | Pantalla | cliente | `PAN-018_subgoal-detail_{desktop,mobile}_{light,dark}.svg` |
| PAN-019 | Cargar evidencia (1.er y 2.º envío) | Pantalla | cliente | `PAN-019_upload-evidence_{desktop,mobile}_{light,dark}.svg` |
| PAN-020 | Estado de la evaluación y reintento | Pantalla | cliente | `PAN-020_evaluation-status_{desktop,mobile}_{light,dark}.svg` |
| PAN-021 | Resultado y puntaje de la submeta | Pantalla | cliente | `PAN-021_result_{desktop,mobile}_{light,dark}.svg` |
| PAN-022 | Pomodoro | Pantalla | cliente | `PAN-022_pomodoro_{desktop,mobile}_{light,dark}.svg` |
| PAN-023 | Perfil | Pantalla | cliente | `PAN-023_profile_{desktop,mobile}_{light,dark}.svg` |
| PAN-024 | Calendario de actividad: detalle y tabla | Pantalla | cliente | `PAN-024_activity-calendar_{desktop,mobile}_{light,dark}.svg` |
| PAN-025 | Logros | Pantalla | cliente | `PAN-025_achievements_{desktop,mobile}_{light,dark}.svg` |
| PAN-026 | Ranking global | Pantalla | cliente | `PAN-026_ranking_{desktop,mobile}_{light,dark}.svg` |
| PAN-027 | Preferencias de cuenta | Pantalla | cliente | `PAN-027_preferences_{desktop,mobile}_{light,dark}.svg` |
| PAN-028 | Aviso de consentimiento de IA | Modal | cliente | `PAN-028_ai-notice_{desktop,mobile}_{light,dark}.svg` |
| PAN-029 | Confirmar eliminación de meta | Modal | cliente | `PAN-029_confirm-delete-goal_{desktop,mobile}_{light,dark}.svg` |
| PAN-030 | Panel de administración | Pantalla | soporte+ | `PAN-030_admin-panel_{desktop,mobile}_{light,dark}.svg` |
| PAN-031 | Cuentas: listado | Pantalla | soporte+ | `PAN-031_accounts-list_{desktop,mobile}_{light,dark}.svg` |
| PAN-032 | Cuenta: detalle | Pantalla | soporte+ | `PAN-032_account-detail_{desktop,mobile}_{light,dark}.svg` |
| PAN-033 | Cuentas: crear | Pantalla | moderador+ | `PAN-033_accounts-create_{desktop,mobile}_{light,dark}.svg` |
| PAN-034 | Cuentas: editar | Pantalla | moderador+ | `PAN-034_accounts-edit_{desktop,mobile}_{light,dark}.svg` |
| PAN-035 | Bloquear o desbloquear cuenta | Modal | moderador+ | `PAN-035_block-account_{desktop,mobile}_{light,dark}.svg` |
| PAN-036 | Cambiar rol de la cuenta | Modal | super | `PAN-036_change-role_{desktop,mobile}_{light,dark}.svg` |
| PAN-037 | Cambiar nivel de acceso | Modal | super | `PAN-037_change-level_{desktop,mobile}_{light,dark}.svg` |
| PAN-038 | Eliminar cuenta | Modal | super | `PAN-038_delete-account_{desktop,mobile}_{light,dark}.svg` |
| PAN-039 | Métricas de la aplicación | Pantalla | moderador+ | `PAN-039_app-metrics_{desktop,mobile}_{light,dark}.svg` |
| PAN-040 | Métricas del uso del LLM | Pantalla | super | `PAN-040_llm-metrics_{desktop,mobile}_{light,dark}.svg` |
| PAN-041 | Evidencias: listado | Pantalla | soporte+ | `PAN-041_evidence-list_{desktop,mobile}_{light,dark}.svg` |
| PAN-042 | Evidencia: detalle y archivo | Pantalla | soporte+ | `PAN-042_evidence-detail_{desktop,mobile}_{light,dark}.svg` |
| PAN-043 | Ranking de administración | Pantalla | soporte+ | `PAN-043_admin-ranking_{desktop,mobile}_{light,dark}.svg` |
| PAN-044 | Evaluaciones en Error persistente | Pantalla | moderador+ | `PAN-044_persistent-error_{desktop,mobile}_{light,dark}.svg` |
| PAN-045 | Cierre administrativo: detalle de la submeta | Pantalla | moderador+ | `PAN-045_admin-closure_{desktop,mobile}_{light,dark}.svg` |
| PAN-046 | Confirmar cierre administrativo | Modal | moderador+ | `PAN-046_confirm-admin-closure_{desktop,mobile}_{light,dark}.svg` |
| PAN-047 | Sesión cerrada o expirada | Estado de sistema | todos | `PAN-047_session-expired_{desktop,mobile}_{light,dark}.svg` |
| PAN-048 | Error 403: sin permiso | Estado de sistema | todos | `PAN-048_error-403-age-confirmation_{desktop,mobile}_{light,dark}.svg` |
| PAN-049 | Error 404: no encontrado | Estado de sistema | todos | `PAN-049_error-404_{desktop,mobile}_{light,dark}.svg` |
| PAN-050 | Error 409: conflicto | Estado de sistema | todos | `PAN-050_error-409_{desktop,mobile}_{light,dark}.svg` |
| PAN-051 | Error 422: errores de validación (patrón) | Patrón transversal | todos | `PAN-051_error-422_{desktop,mobile}_{light,dark}.svg` |
| PAN-052 | Error 429: demasiados intentos o solicitudes | Estado de sistema | todos | `PAN-052_error-429_{desktop,mobile}_{light,dark}.svg` |
| PAN-053 | Error 5xx: fallo del servidor o servicio no disponible | Estado de sistema | todos | `PAN-053_error-5xx_{desktop,mobile}_{light,dark}.svg` |
| PAN-054 | Sin conexión | Estado de sistema | todos | `PAN-054_offline_{desktop,mobile}_{light,dark}.svg` |
