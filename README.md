# FocusStrike

Web application for setting **goals**, splitting them into **subgoals**, submitting **evidence** of the work done and
receiving an **AI-assisted evaluation**. Academic project, version 0.1.

> **Language note:** file and folder names are in English. The content of the documentation under `docs/`
> (requirements, models, design) is written in Spanish.

## Description
A user creates a goal with a total time budget and a daily schedule. The goal is split into subgoals (manually or with
AI help). When each subgoal is done, the user uploads evidence (image, PDF, text or another supported format) and a
language model rates it as **Excellent**, **Inconsistent** or **Invalid**. From these ratings come the score, the streak,
the achievements and the ranking. An admin panel with access levels manages accounts and usage metrics.

## Project status
| Phase | Status |
|---|---|
| 1. Analysis (SRS, user stories, business rules, traceability) | Complete |
| 2. Modeling (UML diagrams, ER and relational models, data dictionary, database schema) | Complete |
| 3. Planning (architecture diagrams) | Partial: component, deployment and class diagrams published; API contract and architecture decisions pending |
| 4. UI/UX design (mockups) | Complete |
| 5. Frontend | In progress: initial scaffold (Vite) |
| 6. Backend | Pending |

`backend/` does not contain code yet, `frontend/` only has the initial scaffold, and `database/seeds.sql` is an empty placeholder.

### Version 0.1 in numbers
- **Analysis:** 168 functional requirements, 24 non-functional requirements, 65 user stories, 36 business rules,
  34 use cases and 127 test cases.
- **Design:** 54 screens with high-fidelity mockups (light and dark theme, desktop and mobile: 216 SVG files),
  34 activity diagrams (one per use case), use case diagram, domain model, ER and relational models and data dictionary.

## Planned architecture
| Layer | Technology |
|---|---|
| Backend | Modular monolith: Django + Django REST Framework (API and worker share the same code) |
| Frontend | React, TypeScript, Vite and Tailwind (PWA) |
| Database | MariaDB 10.11 or later |
| AI | Google Gemini behind a swappable interface |
| Evidence storage | Private disk behind a swappable interface |
| Deployment | VPS with Docker Compose |

All timestamps are stored in UTC. The component and deployment diagrams are in
[`docs/02-design/architecture/diagrams/`](docs/02-design/architecture/diagrams/).

## Repository structure
```
FocusStrike/
├── backend/                          # pending
├── frontend/                         # initial scaffold (Vite)
├── database/
│   ├── schema.sql                    # tables, triggers, routines and views
│   ├── seeds.sql                     # test data (empty placeholder)
│   └── migrations/
├── docs/
│   ├── README.md                     # documentation index
│   ├── 01-analysis/                  # SRS.md, user stories, business rules, traceability matrix
│   ├── 02-design/
│   │   ├── uml/                      # use-cases, activities, domain-model, classes
│   │   ├── database/                 # ER and relational models, data dictionary
│   │   ├── architecture/             # diagrams (components, deployment); api and decisions: empty, pending
│   │   └── mockups/                  # SVG mockups and Figma link
│   ├── 03-planning/                  # pending
│   └── assets/
└── README.md
```

## Documentation
Start with the [`docs/` index](docs/README.md). Main documents:

| Document | Path |
|---|---|
| Software requirements specification (SRS, Markdown) | [`docs/01-analysis/SRS.md`](docs/01-analysis/SRS.md) |
| User stories | [`docs/01-analysis/user-stories.md`](docs/01-analysis/user-stories.md) |
| Business rules | [`docs/01-analysis/business-rules.md`](docs/01-analysis/business-rules.md) |
| Traceability matrix | [`docs/01-analysis/traceability-matrix.xlsx`](docs/01-analysis/traceability-matrix.xlsx) |
| UML diagrams | [`docs/02-design/uml/`](docs/02-design/uml/) |
| ER and relational models, data dictionary | [`docs/02-design/database/`](docs/02-design/database/) |
| Architecture diagrams | [`docs/02-design/architecture/diagrams/`](docs/02-design/architecture/diagrams/) |
| Mockups | [`docs/02-design/mockups/`](docs/02-design/mockups/) |

## Database
Requirements: MariaDB 10.11 or later (production on 11.8 LTS or 12.3 LTS) with `time_zone = '+00:00'`.

Load the schema on an empty instance with an account that owns the database objects (not `root`), as described in the
header of the script:
```bash
mariadb -u <owner_account> -p < database/schema.sql
```

## Next steps
1. Publish the API contract and the architecture decisions.
2. Implement the backend (Django + DRF) from the requirements and the schema.
3. Implement the frontend (React + Vite) from the mockups.
4. Write `seeds.sql` with synthetic data.
