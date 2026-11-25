---
name: aws-dynamodb-modeling
description: Fase 2 del stack serverless. Diseña el modelo de datos más simple y económico en Amazon DynamoDB (PK/SK/GSI), lo aprovisiona en AWS CDK y crea la capa Repository desacoplada.
---

# Fase 2: Modelado Económico en DynamoDB y Capa Repository

## Objetivo

Modelar los datos para responder todas las consultas mediante operaciones `Query` o `GetItem` (nunca `Scan`), manteniendo una sola tabla cuando sea posible para reducir complejidad y costos.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica qué es **Amazon DynamoDB**, por qué el modo `PAY_PER_REQUEST` cuesta $0 cuando no hay tráfico y para qué sirven `PK` (Partition Key), `SK` (Sort Key) y `GSI` (Global Secondary Index).
2. **Diseño Minimalista (Single-Table First):**
   - Define en una tabla Markdown las entidades y sus llaves (`PK`, `SK`), asegurando aislamiento por usuario/tenant si aplica (ej. `TENANT#<id>#USER#<id>`).
   - Agrega un `GSI` **únicamente** si existe un patrón de acceso real que no pueda resolverse con `PK` y `SK`.
3. **Clean Code — Capa Repository:**
   - En `backend/`, implementa una interfaz o módulo `Repository` puro que encapsule las llamadas al SDK de DynamoDB (`PutItem`, `Query`, `GetItem`, `DeleteItem`), sin mezclar HTTP ni JSON de API Gateway.
   - Asegura que el código pase el linter y formateador configurado en la Fase 1.
4. **Criterio de Validación (Stop):**
   - Detente cuando el usuario ejecute el linter, despliegue la tabla con `cdk deploy` y te muestre el `TableName` generado.
