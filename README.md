# ElixTogether

A full-stack web application built with **Elixir and Phoenix**, demonstrating modern real-time web development with LiveView, PostgreSQL, and Tailwind CSS.

## What This Is

ElixTogether is a multi-feature Phoenix web application that combines server-rendered pages, real-time interactive components, and a RESTful post management system. It showcases best practices in Elixir web development, including LiveView for reactive UIs, Ecto for data persistence, and Phoenix's routing and session management patterns.

## Stack

- **Language:** Elixir 1.15+
- **Framework:** Phoenix 1.8.1 with Phoenix LiveView 1.1.0
- **Database:** PostgreSQL (via Ecto & PostGrex)
- **Frontend:** Tailwind CSS 4.1.7 + esbuild + Phoenix Components
- **Notable Libraries:**
  - **Phoenix LiveView** — Real-time, stateful UI components without writing JavaScript
  - **Ecto & Ecto SQL** — Type-safe database queries and migrations
  - **Tailwind CSS** — Utility-first styling
  - **Swoosh** — Email handling (configured for local development)

## How It's Organized

```
lib/
  elix_together/              Domain logic and business contexts
    application.ex            OTP application startup & supervision
    repo.ex                   Database connection layer
  elix_together_web/          Web layer (controllers, views, components)
    router.ex                 Route definitions & pipelines
    endpoint.ex               Phoenix endpoint configuration
    controllers/              Traditional HTTP request handlers
    live/                     Real-time LiveView modules
    components/               Reusable Phoenix Components
    layouts/                  Shared HTML layouts

config/
  config.exs                  General app configuration
  dev.exs                     Development environment
  prod.exs                    Production environment
  runtime.exs                 Runtime configuration

assets/
  css/                        Tailwind styles
  js/                         JavaScript (bundled via esbuild)

priv/
  repo/                       Database migrations & seeds
  static/                     Compiled assets (generated)

test/                         ExUnit test suite
```

**How it fits together:**

When a request arrives, the `Endpoint` processes it through a pipeline of plugs (session handling, CSRF protection, static file serving). The `Router` directs it to either a traditional `Controller` or a `LiveView` module. Controllers render templates using Phoenix Components; LiveView modules establish WebSocket connections for bidirectional, stateful communication. Both access data through `Repo` (Ecto), which translates to PostgreSQL queries. Styles are compiled from Tailwind, and JavaScript is bundled with esbuild.

## Features

- **Home Page** — Static controller-based homepage
- **Clock Live** — Real-time clock component (demonstrates LiveView reactivity)
- **Listings Live** — Dynamic listings view
- **Post Management** — Full CRUD operations on posts with comments
- **Playground** — Input validation and URL-based form display
- **Development Tools** — LiveDashboard and Swoosh mailbox preview

## How to Run It

### Prerequisites
- Elixir 1.15+ and Erlang/OTP 25+
- PostgreSQL 14+
- Node.js 18+ (for asset compilation)

### Setup

```bash
# Clone the repo
git clone <repo-url>
cd etog

# Install dependencies and set up database
mix setup

# Start the development server
mix phx.server
```

The app will be available at `http://localhost:4000`.

### Running Tests

```bash
mix test
```

### Pre-commit Checks

```bash
mix precommit
```

This runs compilation with warnings-as-errors, checks for unused dependencies, formats code, and runs the full test suite.

### Asset Development

Assets are compiled automatically in dev mode. To manually rebuild:

```bash
mix assets.build      # Development build
mix assets.deploy     # Production build (minified)
```

## Environment Configuration

The app uses standard Elixir config files:
- `config/config.exs` — Base configuration
- `config/dev.exs` — Development overrides
- `config/prod.exs` — Production overrides
- `config/runtime.exs` — Runtime config (loaded at boot, not compile-time)

Update database credentials and other secrets in `config/dev.exs` or via environment variables in production.

## Key Design Patterns

- **Phoenix Pipelines** — Pluggable request processing (authentication, layout injection, CSRF protection)
- **LiveView** — Real-time UIs with server state, eliminating much client-side complexity
- **Contexts** — Domain logic isolated in modules separate from web layer (Ecto-based repos and services)
- **Components** — Reusable, composable UI pieces (Tailwind-styled Phoenix Components)
- **Supervision Trees** — OTP application supervision for robust fault tolerance

## Development Notes

- **Code Reloading** — Enabled in dev; changes trigger automatic recompilation
- **Email Preview** — Visit `/dev/mailbox` to preview emails (Swoosh local adapter)
- **Live Dashboard** — Available at `/dev/dashboard` for metrics and telemetry
- **Database Migrations** — Run with `mix ecto.migrate`; reset with `mix ecto.reset`

## Next Steps

- Add authentication (consider `pow` or `phx_gen_auth`)
- Deploy to production (Fly.io, Heroku, or VPS with Elixir support)
- Expand test coverage (integration tests for LiveView, unit tests for contexts)
- Implement caching strategies (Redis via `Cachex` or `Exredis`)

---

Built with **Elixir**, **Phoenix**, and ❤️
