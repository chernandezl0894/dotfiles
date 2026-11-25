---
name: aws-cognito-auth
description: Fase 4 del stack serverless. Configura Amazon Cognito User Pools (Free Tier hasta 50k MAU) y JWT Authorizers en API Gateway para proteger rutas privadas sin código de auth manual.
---

# Fase 4: Autenticación y Autorización (Amazon Cognito)

## Objetivo

Proteger los endpoints privados delegando el manejo de usuarios, contraseñas y tokens JWT a **Amazon Cognito** y **API Gateway**, evitando ejecuciones innecesarias de Lambda para peticiones no autenticadas.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica cómo funcionan **Cognito User Pools** (capa gratuita de hasta 50,000 usuarios activos al mes) y el **JWT Authorizer** de HTTP API Gateway (rechaza tokens inválidos en la puerta sin cobrar invocaciones de Lambda).
2. **Implementación Simple en CDK y Backend:**
   - Configurar `UserPool` (login con email, auto-verificación) y `UserPoolClient` (`generateSecret: false`).
   - Proteger las rutas privadas en `HttpApi` con `HttpUserPoolAuthorizer`.
   - En el `Handler`, extraer el `sub` (ID único del usuario) de los `claims` del token validado y pasarlo al `Service` para asegurar que cada usuario solo acceda a sus propios datos en DynamoDB.
3. **Criterio de Validación (Stop):**
   - Detente y pide al usuario que corra el linter, despliegue y verifique: (1) respuesta `401 Unauthorized` sin token, y (2) respuesta `200/201` autenticando un usuario de prueba vía AWS CLI y enviando el header `Authorization: Bearer <token>`.
