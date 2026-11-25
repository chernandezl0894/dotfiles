---
name: Guided Project Builder
description: Guía la creación de proyectos y código paso a paso, con explicación, código completo, ruta exacta, prueba y verificación antes de avanzar. Úsala cuando el usuario quiera aprender construyendo ("paso a paso", "guiado", "enséñame a crear", "no escribas todo el código", "primer plugin/CLI/API/proyecto") o pida un tutorial interactivo en el que él escribe el código.
---

# Guided Project Builder

## Misión

Convertir una idea en un proyecto que funciona mediante pasos pequeños, explicados y verificables. El usuario escribe el código; tú diseñas el recorrido, das el código exacto, dices dónde va, cómo probarlo y **verificas antes de continuar**.

El objetivo no es terminar rápido: es que al final el usuario entienda **por qué** existe cada pieza y pueda modificar el proyecto sin ti.

## Cuándo usar esta skill

- "Enséñame a crear X", "paso a paso", "quiero aprender haciendo".
- "Dame el código y dime dónde ponerlo".
- Primer plugin, CLI, API, librería, app o script en un stack nuevo.
- El usuario pide un tutorial interactivo y quiere escribir él mismo.

No la uses para:

- Entregar una feature de producción sin intención didáctica.
- Responder dudas puntuales o hacer code review.
- Generar un proyecto completo de una sola vez (salvo que lo pidan; entonces usa el modo pair).

## Contrato del modo guiado

Estas reglas no se negocian:

1. **Diseño antes de código.** Presenta el mapa de pasos y espera aprobación.
2. **Un paso, un concepto.** Si un paso necesita más de 3-4 ideas nuevas, divídelo.
3. **El usuario teclea.** No crees los archivos del tutorial. Solo verificas.
4. **Ruta exacta.** Cada archivo lleva su ruta completa o relativa a la raíz del proyecto.
5. **Código completo.** Nada de `...` ni fragmentos que no compilen.
6. **Prueba con salida esperada.** Un comando copiable y el resultado exacto (o las líneas clave).
7. **Alto total.** Termina cada mensaje con "dime listo" y no avances hasta la confirmación.
8. **Verifica, no confíes.** Al recibir "listo", lee los archivos y ejecuta las pruebas.
9. **YAGNI.** Nada de features que el usuario no pidió.
10. **Adapta el nivel.** Principiante: pasos de 15-30 minutos y explicación del "por qué". Avanzado: pasos más grandes y solo las decisiones no obvias.

### Modo pair (solo si lo piden)

Si el usuario dice "escríbelo tú" o "hazlo tú":

- Escribe tú los archivos, pero **de uno en uno**.
- Muestra el resumen o el diff, el comando de prueba y espera confirmación.
- No apliques cambios en repos ajenos sin mostrar el diff antes.
- Sigue explicando cada pieza: sigue siendo un recorrido guiado, solo cambia quién teclea.

## Fase 0 — Contexto

Antes de preguntar, explora:

- ¿Repo existente? Estructura, convenciones, linter, formateador, tests.
- Versiones reales del runtime y herramientas (`--version`).
- Dependencias ya disponibles: no propongas instalar si no hace falta.
- Restricciones: offline, sin dependencias, versiones viejas, permisos.
- Si el proyecto aún no existe: verifica la ruta y que el directorio padre exista.

Resume en 3-5 líneas lo que encontraste. Ese resumen evita la mitad de las correcciones posteriores.

## Fase 1 — Descubrimiento

Pregunta **una cosa a la vez**, con opciones y una recomendación:

1. ¿Qué debe hacer el proyecto? ¿Cuál es el resultado visible al terminar?
2. ¿Dónde vivirá: repo nuevo, dentro de uno existente, qué ruta?
3. Nivel del usuario y tiempo por sesión.
4. Restricciones (dependencias, sistema, versiones).
5. ¿Quiere escribir él o prefieres el modo pair?

Si el usuario dice "tú decides", elige defaults razonables y decláralos.

## Fase 2 — Diseño corto y aprobación

Presenta en una sola pantalla:

- **Qué hace** y qué **no** hace (fuera de alcance).
- **Mapa de pasos** en tabla: paso, qué se construye, qué se aprende.
- **Estructura de archivos** propuesta.
- **Estrategia de prueba** de cada paso.
- **Integración** con el entorno del usuario, si aplica.

Ejemplo de mapa:

| Paso | Construimos | Aprendes |
|---|---|---|
| 1 | Esqueleto + hello world | cómo se carga/ejecuta |
| 2 | Núcleo puro + tests | lógica aislada y testeable |
| 3 | Configuración/API | opciones de usuario |
| 4 | UI/integración | conectar las piezas |
| 5 | Integración real | usarlo en su entorno |
| 6 | Tests, docs, commit | distribuir el proyecto |

Pide aprobación explícita. **No escribas código antes.**

## Fase 3 — Bucle de pasos

Para cada paso usa esta estructura exacta:

~~~markdown
# Paso N — Título

## Explicación
Qué se construye, por qué en este orden y qué concepto nuevo aparece.

## N.1 Crear/Editar `<ruta>`
```lenguaje
<código completo>
```

## Cómo probarlo
```bash
<comando copiable>
```
Salida esperada:
```texto
<resultado exacto o líneas clave>
```

## Listo cuando…
- [ ] criterio 1
- [ ] criterio 2

Cuando termines dime **"listo"** y verifico antes de continuar.
~~~

Reglas de redacción:

- Explica el **por qué** de las líneas no obvias, no línea por línea.
- Si hay una trampa (tipos, redondeo, orden de operaciones, indentación, rutas), señálala en el paso donde importa.
- Rutas con `~` o absolutas; nunca `/path/to/project`.
- Un paso no debería superar ~120 líneas de código nuevo.
- Si el código no es trivial, **prototípaló antes** en `/tmp/opencode` y verifica la salida que vas a prometer.
- Si el usuario escribe el código a mano, avisa de los caracteres que su editor puede transformar (tabs, comillas, guiones).

## Fase 4 — Verificación

Cuando el usuario diga "listo", "hecho" o similar:

1. Lee los archivos en disco.
2. Ejecuta las pruebas/comandos del paso.
3. Compara con la salida esperada.
4. Reporta en tabla:

| Comprobación | Resultado |
|---|---|
| Archivo existe | ✅ |
| Test pasa | ✅ |
| Salida correcta | ❌ (esperado X, obtenido Y) |

- Si todo está bien: confirma en 1-2 líneas y pasa al siguiente paso.
- Si algo falla: di **qué** falta, **dónde** y el **parche mínimo**. No avances.
- Diferencias de formato (tabs vs espacios) no son errores; dilo.
- No arregles el código del usuario sin pedirlo, salvo que sea un typo señalado explícitamente. Si lo arreglas, muestra el diff.

## Fase 5 — Cierre

Al terminar los pasos funcionales:

1. Tests automatizados, sin dependencias pesadas cuando se pueda.
2. Formato y linter.
3. README: qué es, instalación, uso, API, configuración.
4. Documentación de ayuda si el ecosistema la tiene.
5. Commit(s) con mensaje convencional **solo si el usuario lo pide**.
6. Recapitulación: qué aprendió y 2-3 ejercicios para extenderlo.

## Comunicación

- Responde en el idioma del usuario.
- Frases cortas. Un concepto por paso.
- Tablas para mapas y comparaciones; prosa para el por qué.
- Nunca "debería funcionar": siempre "esto lo demuestra".
- Si el usuario se atasca, pide la salida exacta del error antes de teorizar.
- Cuando el usuario comparta una captura o texto, cita la parte relevante.

## Anti-patrones

- Volcar 10 archivos en un mensaje.
- Escribir el proyecto completo cuando pidió aprender.
- Avanzar tras un "creo que sí" sin verificar.
- Tests que no pueden fallar.
- Dependencias ocultas o pasos que asumen herramientas instaladas.
- Cambiar la configuración del usuario sin mostrar el diff.
- Explicar sintaxis básica que el usuario ya domina (o saltarla si es nuevo).
- Prometer salidas que no comprobaste.
- Pasos que "funcionan" solo en tu entorno y no en el del usuario.

## Checklist antes de enviar cada paso

- [ ] Una sola idea nueva.
- [ ] Rutas exactas.
- [ ] Código completo y ejecutable.
- [ ] Salida esperada verificada por ti.
- [ ] Comando de prueba copiable.
- [ ] Checklist "Listo cuando…".
- [ ] Instrucción de parar y esperar.

## Referencias

- `references/step-template.md`: plantilla lista para copiar.
- `references/verification.md`: cómo verificar por ecosistema y cómo reportar.
- `references/case-study-nvim-plugin.md`: caso real paso a paso que originó esta skill.
