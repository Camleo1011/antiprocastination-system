# Documentación de FocusStrike

Los nombres de carpetas y archivos están en inglés; el contenido de los documentos está en español.
Versión 0.1.

## Estado por fase

| Fase | Estado | Ubicación |
|---|---|---|
| Análisis | Completa | `01-analysis/` |
| Modelado | Completa | `02-design/uml/`, `02-design/database/` y `../database/schema.sql` |
| Planificación | Parcial: diagramas de arquitectura y de clases publicados; contrato de la API y decisiones de arquitectura pendientes de publicar | `02-design/architecture/`, `02-design/uml/classes/`, `03-planning/` |
| Diseño UI/UX | Mockups completos (54 pantallas); enlace de Figma pendiente | `02-design/mockups/` |
| Frontend | Pendiente | `../frontend/` |
| Backend | Pendiente | `../backend/` |

## Índice

### 01-analysis/ — Análisis
| Archivo | Contenido |
|---|---|
| `SRS.md` | Especificación de requisitos de software en Markdown (ISO/IEC/IEEE 29148), sin versión en PDF: 168 RF, 24 RNF, 65 HU, 36 BR, 34 CU y 127 CP |
| `user-stories.md` | Las 65 historias de usuario con sus criterios de aceptación |
| `business-rules.md` | Las 36 reglas de negocio y las tablas de tiempo y puntaje de una submeta |
| `traceability-matrix.xlsx` | Matriz RF, HU, CU, CP, reglas de negocio, entidades, actividades, pantallas y endpoints, con hoja de cobertura |

### 02-design/uml/ — Modelos UML
| Carpeta | Contenido |
|---|---|
| `use-cases/` | Diagrama de casos de uso (`use-cases.puml` y `.png`) |
| `activities/` | Un diagrama de actividades por caso de uso, `CU-nnn-nombre.puml` y `.png` (34 CU) |
| `domain-model/` | Modelo de dominio |
| `classes/` | Diagrama de clases general y sus variantes de aplicación e infraestructura |

### 02-design/database/ — Modelo de datos
| Archivo | Contenido |
|---|---|
| `erd.puml` / `erd.png` | Modelo entidad-relación |
| `relational.puml` / `relational.png` | Modelo relacional |
| `data-dictionary.xlsx` | Diccionario de datos |

### 02-design/architecture/ — Arquitectura
| Carpeta | Contenido |
|---|---|
| `diagrams/` | Diagramas de componentes (`components`) y de despliegue (`deployment`), en `.puml` y `.png` |
| `api/` | Contrato de la API (carpeta vacía; pendiente de publicar) |
| `decisions/` | Decisiones de arquitectura (carpeta vacía; pendiente de publicar) |

### 02-design/mockups/ — Mockups
216 archivos SVG (54 pantallas PAN-001 a PAN-054, en escritorio y móvil, tema claro y oscuro) y un `README.md` con la
convención de nombres, el índice de pantallas y el enlace de Figma.

### Otras carpetas
| Carpeta | Contenido |
|---|---|
| `03-planning/` | Planificación (pendiente) |
| `assets/` | Imágenes y recursos compartidos (vacía por ahora) |

## Dónde empezar
1. `01-analysis/SRS.md` para los requisitos.
2. `01-analysis/traceability-matrix.xlsx` para seguir un requisito hasta su caso de uso, prueba, entidad y pantalla.
3. `02-design/` para el diseño y `../database/schema.sql` para el esquema.
