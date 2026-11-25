---
name: aws-cicd-github-oidc
description: Fase 6 del stack serverless. Configura GitHub Actions con calidad de código obligatoria (linters + tests) y despliegue seguro a AWS mediante OIDC sin secretos estáticos.
---

# Fase 6: CI/CD con Quality Gates y AWS OIDC

## Objetivo

Automatizar la verificación de calidad (linter, formateo y tests) y el despliegue continuo de infraestructura y código mediante credenciales temporales **OIDC**.

## Instrucciones de Guía

1. **Explicación Didáctica:** Explica qué es **OpenID Connect (OIDC)** entre GitHub Actions y AWS, por qué elimina el riesgo de filtrar `AWS_ACCESS_KEY_ID` y para qué sirven los **Quality Gates** antes de tocar producción.
2. **Implementación:**
   - Crear en CDK el `OpenIdConnectProvider` de GitHub y un rol IAM limitado al repositorio y rama del usuario.
   - Configurar `.github/workflows/deploy.yml` con pasos secuenciales estrictos:
     1. Checkout e instalación de toolchains.
     2. **Quality Gate:** Ejecutar linter, verificación de formato y tests unitarios (si falla, detiene el pipeline).
     3. **Build & Deploy:** Compilar artefactos y ejecutar `npx cdk deploy --require-approval never`.
3. **Criterio de Validación (Stop):**
   - Detente y pide al usuario que haga push de una rama o commit, verifique en la pestaña **Actions** de GitHub que los checks de linter y el deploy con OIDC pasen en verde, y te confirme el resultado.
