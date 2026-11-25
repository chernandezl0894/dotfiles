---
name: aws-lambda-apigw-core
description: Fase 3 del stack serverless. Implementa casos de uso y handlers desacoplados en AWS Lambda (ARM64), expone rutas en HTTP API Gateway con CORS y emite logs estructurados en JSON.
---

# Fase 3: Lógica de Negocio (Service + Handler + HTTP API Gateway)

## Objetivo

Conectar la capa de datos a internet mediante **HTTP API Gateway (v2)** y **AWS Lambda (ARM64)** usando una arquitectura limpia (`Handler -> Service -> Repository`) y logs JSON.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica qué hace **HTTP API Gateway v2** (y por qué es hasta 70% más barato que REST API v1), por qué usamos **ARM64 (Graviton)** con memoria ajustada (`128 MB`) y para qué sirven los **logs estructurados en JSON**.
2. **Buenas Prácticas de Código Limpio y Costo:**
   - **Separación de responsabilidades:**
     - `Service`: Contiene las reglas de negocio y validaciones puras (fácil de testear sin AWS).
     - `Handler`: Solo parsea el evento HTTP, llama al `Service` y formatea la respuesta HTTP + status code.
   - **Reutilización de conexiones:** Inicializar clientes AWS y dependencias una sola vez fuera del handler.
   - **Consolidación pragmática:** Para apps pequeñas/medianas, agrupa rutas relacionadas en una sola Lambda con un router ligero (ej. Hono en TS, `net/http` en Go) para reducir _cold starts_ y simplificar el despliegue.
   - **Mínimo Privilegio IAM:** Usar `table.grantReadData()` / `table.grantWriteData()` en CDK.
   - **Observabilidad:** Logs en JSON puro con `correlation_id`, nivel (`INFO`, `WARN`, `ERROR`) y contexto.
3. **Criterio de Validación (Stop):**
   - Detente y pide al usuario que ejecute el **linter/tests**, despliegue con `cdk deploy`, pruebe los endpoints con `curl` y revise una línea de log JSON en CloudWatch (`aws logs tail`).
