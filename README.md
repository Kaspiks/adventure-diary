# Adventure Diary

This README documents the steps necessary to get the application up and running.

## Ruby Version

* Ruby 3.2.3
* Rails 8.0

## Development Setup

### Using Docker (recommended)

```bash
docker compose up --build
```

This starts the development server at http://localhost:3000

### Local Development

Requires Ruby 3.2.3 installed locally. Uses SQLite by default.

```bash
bundle install
rails db:prepare
rails server
```

## Running the Test Suite

### Using Docker (recommended)

The test container runs alongside the dev containers using the same `docker-compose.yml`.

**Start all services:**

```bash
docker compose up -d
```

**Access the test container:**

```bash
docker compose exec test bash
```

**Run tests inside the container:**

```bash
bundle exec rspec
```

**Run specific test files:**

```bash
bundle exec rspec spec/models/
```

### Local Testing

Requires Redis running locally for session storage:

```bash
export REDIS_SESSION_STORE_URL=redis://localhost:6379/0
bundle exec rspec
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `REDIS_SESSION_STORE_URL` | Yes (dev/test) | Redis URL for session storage |
| `DATABASE_ADAPTER` | No | Set to `postgresql` to use PostgreSQL instead of SQLite |
| `DATABASE_HOST` | If PostgreSQL | PostgreSQL host |
| `DATABASE_PORT` | If PostgreSQL | PostgreSQL port (default: 5432) |
| `DATABASE_NAME` | If PostgreSQL | Database name |
| `DATABASE_USERNAME` | If PostgreSQL | Database username |
| `DATABASE_PASSWORD` | If PostgreSQL | Database password |

## Icons

This project uses [Tabler Icons](https://tabler.io/icons) bundled into an SVG sprite.

### Adding New Icons

1. Open `icons/build-sprite.js`
2. Add the icon name to the `includedIcons` array (use the icon name from Tabler, e.g., `"category"`)
3. Rebuild the sprite:

```bash
# Using Docker (recommended)
docker compose run --rm node sh -c "npm install && node build-sprite.js"

# Or locally if you have Node.js installed
cd icons
npm install
node build-sprite.js
```

The sprite is output to `vendor/assets/images/icons.svg`.

### Using Icons in Views

```slim
= icon("category")
```

## Services

* **Redis** - Session storage (required for development and test)
* **PostgreSQL** - Production database (SQLite used for local dev/test by default)
