# Stack adapter — Go

Default stack for the factory. Read this before planning or writing a Go module.

## Structure

```text
cmd/
  api/main.go
  worker/main.go
internal/
  <context>/
    domain/
    app/
    adapters/
  shared/
```

- `cmd/` does wiring only.
- `internal/` protects private packages.
- `domain` has no `net/http`, `pgx`, `database/sql` or frameworks.
- `app` orchestrates use cases.
- `adapters` contains HTTP, SQL, messaging and external clients.

## Idioms

- Structs with unexported fields.
- Constructors `NewX(...) (T, error)`.
- No setters; methods express intent.
- Interfaces are small and defined by the consumer.
- Errors are values; use `errors.Is` / `errors.As`.
- No `panic` for business flows.
- `context.Context` as the first parameter for I/O.
- No DI container; manual wiring in `cmd/`.
- Tests with `testing`, table-driven and `t.Parallel` when safe.
- `gofmt`, `go vet`, `staticcheck`, `golangci-lint`.

## Persistence

- Default: `pgx` + `sqlc`.
- GORM is an alternative for CRUD, not the default for rich domains.
- Repositories are interfaces in the consumer package.
- Transactions via a `UnitOfWork` port and `pgx.Tx`.
- Optimistic concurrency with a `version` column.
- Integration tests with `testcontainers-go`.

## Delivery

- `net/http` + `chi`.
- `gin`/`echo` are options, not defaults.
- Handlers are thin adapters.
- Use `httptest` for handler tests.

## Messaging

- `amqp091-go` or Watermill for RabbitMQ.
- NATS for lightweight messaging.
- Outbox for critical events.
- Idempotent consumers.

## Go-specific anti-patterns

- Java-style interfaces for everything.
- DI containers and service locators.
- Getters/setters instead of behavior.
- `interface{}` to avoid design.
- `panic` as control flow.
- Global mutable state.
- Domain importing `pgx` or `net/http`.
- One package per layer for the whole project.
- `shared` as a dumping ground.
- Lazy loading with SQL inside the domain.

## What not to translate literally

- Classes → structs + methods, not structs + interface + factory + DI.
- Annotations → explicit mapping in adapters.
- Framework modules → packages and `internal/`.
- Exceptions → error values.
- ORM entities → domain structs + mappers.
- `EntityManager`/`flush` → `pgx.Tx` + Unit of Work.

## Review checklist

- [ ] No framework imports in `domain`.
- [ ] Constructors validate.
- [ ] Interfaces are consumer-owned.
- [ ] Errors are explicit and wrapped.
- [ ] `context` is propagated.
- [ ] Tests are table-driven.
- [ ] `cmd/` has the wiring.
- [ ] No project scaffolding in the course.
