---
name: aws-cdk-iac-foundation
description: Fase 1 del stack serverless. Establece la estructura de carpetas limpia, configura linters y formateadores, verifica credenciales SSO/IAM e inicializa AWS CDK con CloudWatch Logs de retención controlada.
---

# Fase 1: Cimientos Limpios (Estructura, Linter, AWS CDK & CloudWatch)

## Objetivo

Preparar un repositorio ordenado, con verificación automática de estilo/calidad de código y el esqueleto mínimo de AWS CDK listo para desplegar sin costos ocultos.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica qué es **AWS CDK**, por qué la separación de carpetas evita acoplamiento y para qué sirven los **linters/formateadores** y las **políticas de retención en CloudWatch Logs** (evitar cargos mensuales por logs eternos).
2. **Estructura de Carpetas Estándar:**
   - Propón una estructura clara y modular desde el inicio:
     ```text
     project-root/
     ├── infra/          # Stack de AWS CDK
     ├── backend/        # Lógica de negocio (cmd/ o handlers/, internal/service/, internal/repository/)
     └── frontend/       # Aplicación web
     ```
3. **Configuración de Linter y Formateo (Obligatorio):**
   - Configura archivos de reglas base según el lenguaje elegido (`.golangci.yml`, `biome.json` / `.eslintrc`, o `ruff.toml`) y un `Makefile` (o `package.json` scripts) con comandos `lint`, `format` y `test`.
4. **Infraestructura Base en CDK:**
   - Verifica `aws sts get-caller-identity --profile <perfil>` y `cdk bootstrap`.
   - Crea los `LogGroup` de CloudWatch explícitamente con `Retention: ONE_WEEK` y `RemovalPolicy: DESTROY`.
5. **Criterio de Validación (Stop):**
   - Detente tras pedirle al usuario que ejecute el comando de linter/formateo y `cdk synth`.
   - Verifica que ambos pasen sin errores antes de avanzar a la Fase 2.
