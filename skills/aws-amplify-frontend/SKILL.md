---
name: aws-amplify-frontend
description: Fase 5 del stack serverless. Construye y despliega un frontend rápido y económico (landing estática + panel interactivo) en AWS Amplify Hosting o S3 + CloudFront conectado a Cognito y API Gateway.
---

# Fase 5: Frontend Rápido y Hosting Económico (Amplify / Static CDN)

## Objetivo

Construir la interfaz de usuario manteniendo tiempos de carga instantáneos, código tipado y formateado, y despliegue automatizado sin servidores 24/7.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica por qué separar o renderizar estáticamente la landing page (0 JS innecesario) frente al panel interactivo maximiza velocidad y SEO mientras mantiene el costo en ~$0/mes en **AWS Amplify Hosting** (o S3 + CloudFront).
2. **Buenas Prácticas de Frontend:**
   - Estructura limpia por capas: `components/` (UI), `services/` o `api/` (cliente HTTP centralizado que inyecta el token JWT de Cognito y maneja errores) y `pages/` o `app/`.
   - Ejecutar linter y type-check (`npm run lint`, `tsc --noEmit`) antes de compilar.
   - Configurar las variables de entorno (`API_URL`, `USER_POOL_ID`, `CLIENT_ID`) desde los Outputs de CDK y restringir el `AllowOrigins` de CORS en API Gateway al dominio final del frontend.
3. **Criterio de Validación (Stop):**
   - Detente y pide al usuario que valide el linter/build del frontend, el despliegue en Amplify/CloudFront y el flujo completo en el navegador (registro/login -> operación CRUD en el panel -> verificación en DynamoDB).
