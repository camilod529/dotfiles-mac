---
name: address-pr-comments
description: Atiende el feedback de review de una PR de GitHub. Lee comentarios con gh, aplica cambios en la rama actual y entrega un reporte por comentario.
argument-hint: [pr-number]
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/fetch-pr-feedback.sh) Bash(${CLAUDE_SKILL_DIR}/scripts/fetch-pr-feedback.sh *) Bash(git status *) Bash(git diff *) Bash(git branch *) Bash(gh pr view *)
---

# Atender comentarios de la PR

PR objetivo: $ARGUMENTS (si está vacío, usa la PR asociada a la rama actual).

## 1. Contexto y guardas

- Ejecuta `${CLAUDE_SKILL_DIR}/scripts/fetch-pr-feedback.sh $ARGUMENTS` para traer threads en línea, reviews y comentarios generales.
- Si la rama local no coincide con la rama head de la PR, o `git status` muestra cambios sin commitear, DETENTE y avísame antes de tocar código.

## 2. Triage

Revisa cada thread NO resuelto (ignora `isResolved: true`; los `isOutdated` compáralos contra el código actual) y cada review o comentario general con algo accionable. Clasifica:

- Cambio solicitado: aplicar.
- Sugerencia / nit: aplicar si es barato y no choca con las convenciones del repo.
- Pregunta: no tocar código; prepara un borrador de respuesta.
- Desacuerdo, fuera de alcance o ambiguo: no tocar código; explica por qué.

Ignora ruido de bots (CI, coverage, changesets) salvo que señale un fallo real. Si dos comentarios se contradicen, no decidas tú: márcalo en el reporte.

## 3. Cambios (aplica durante toda la tarea)

- Lee el archivo y el contexto alrededor de `path:line` antes de editar; la línea puede haberse movido desde el comentario.
- Cambios mínimos y enfocados en lo que pidió cada comentario. Nada de refactors oportunistas.
- Respeta CLAUDE.md, el linter y el estilo existente del repo.
- Al terminar, corre lint, typecheck y tests relevantes si existen (revisa package.json / Makefile).
- NO hagas commit, push, ni respondas o resuelvas threads en GitHub, salvo que te lo pida explícitamente.

## 4. Reporte final

Tabla con una fila por comentario:

| # | Autor | Ubicación | Comentario (resumen) | Estado | Qué se hizo / por qué no |

Estados posibles: Aplicado, Parcial, No aplicado, Pregunta, Ya resuelto/obsoleto.

- Para cada "No aplicado" o "Parcial": razón concreta y un borrador corto de respuesta para el thread.
- Para cada "Pregunta": el borrador de respuesta.
- Al final: archivos modificados y resultado de lint/typecheck/tests.
