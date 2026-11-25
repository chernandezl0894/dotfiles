# Stack adapter — TypeScript / NestJS

Secondary adapter, useful when the course targets NestJS.

## Structure

```text
src/
  <context>/
    domain/
    application/
    infrastructure/
  shared/
```

- `domain` has no NestJS, Prisma or HTTP.
- `application` has use cases and DTOs.
- `infrastructure` has controllers, repositories, adapters.
- `@Module()` is wiring, not a domain boundary.

## Idioms

- TypeScript strict mode.
- Classes with private fields and factory methods for Entities.
- `abstract class` ports for DI tokens.
- DTOs with primitives and `class-validator` at the boundary.
- `@Injectable()` for services; avoid decorators in the domain if the team prefers purity.
- Errors as classes; map to HTTP at the edge.
- Jest with `Test.createTestingModule` when DI matters.
- Prisma for persistence; `schema.prisma` per Bounded Context.
- Transactions via a `TransactionalSession` port.

## Delivery

- NestJS controllers, `@Body()`/`@Param()`, `ValidationPipe`.
- `@nestjs/cqrs` only when a command bus is justified.
- `nest-commander` for CLI.
- REST/OpenAPI; gRPC optional.

## TypeScript-specific anti-patterns

- Anemic Entities with public setters.
- Domain importing Prisma or `@nestjs/common`.
- One `@Module()` per layer.
- DTOs with Entities.
- `any` to silence the compiler.
- Generic repositories that hide the domain.
- Tests mocking the framework instead of the ports.

## What not to translate literally

- Go structs → classes with behavior, not interfaces for everything.
- Go errors → typed exceptions at the edge; domain errors as classes.
- Go packages → NestJS modules only for wiring; domain boundaries are folders.
- Manual DI → NestJS DI, but do not inject the container.

## Review checklist

- [ ] No NestJS/Prisma in `domain`.
- [ ] Ports are DI tokens.
- [ ] DTOs use primitives.
- [ ] Tests cover domain without infrastructure.
- [ ] `@Module()` does not define the model.
- [ ] No project scaffolding in the course.
