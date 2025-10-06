# ProStaff API - Claude Code Instructions

## Project Overview
This is a Ruby on Rails 7.1 API-only application for ProStaff.gg, an esports team management platform. The API serves as the backend for a React frontend and follows a modular monolith architecture.

## Architecture
- **Type**: Rails API-only application
- **Pattern**: Modular monolith with DDD principles
- **Database**: PostgreSQL with UUID primary keys
- **Authentication**: JWT with refresh tokens
- **Background Jobs**: Sidekiq
- **Caching**: Redis
- **Testing**: RSpec

## Key Commands

### Development
```bash
# Start development server
rails server

# Run tests
bundle exec rspec

# Run migrations
rails db:migrate

# Seed database
rails db:seed

# Reset database
rails db:drop db:create db:migrate db:seed

# Start Sidekiq
bundle exec sidekiq

# Check routes
rails routes

# Console
rails console
```

### Docker
```bash
# Start all services
docker-compose up

# Build and start
docker-compose up --build

# Stop services
docker-compose down

# View logs
docker-compose logs api
```

### Code Quality
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Annotate models
bundle exec annotate

# Generate API docs
bundle exec rswag
```

## Module Structure

The application is organized into bounded contexts:

- `authentication/` - User auth, JWT tokens, registration
- `dashboard/` - Dashboard stats and metrics
- `players/` - Player management and statistics
- `scouting/` - Player scouting and recruitment
- `analytics/` - Performance analytics and reporting
- `matches/` - Match data and statistics
- `schedules/` - Event and schedule management
- `vod_reviews/` - Video review and analysis
- `team_goals/` - Goal setting and tracking
- `riot_integration/` - Riot Games API integration

## API Endpoints

### Base URL
`http://localhost:3333/api/v1`

### Authentication (No auth required)
- `POST /auth/register` - Register organization + admin user
- `POST /auth/login` - User login
- `POST /auth/refresh` - Refresh JWT token
- `POST /auth/forgot-password` - Password reset request
- `POST /auth/reset-password` - Reset password

### Authenticated Endpoints
- `GET /auth/me` - Current user info
- `POST /auth/logout` - User logout
- `GET /dashboard` - Dashboard data
- `GET /players` - List players
- `POST /players` - Create player
- `GET /matches` - List matches
- `GET /scouting/players` - Scouting targets

## Database Models

### Core Models
- `Organization` - Team/organization entity
- `User` - System users with roles (owner, admin, coach, analyst, viewer)
- `Player` - Team players with Riot API integration
- `Match` - Game matches with detailed statistics
- `PlayerMatchStat` - Individual player performance per match

### Supporting Models
- `ChampionPool` - Player champion mastery
- `ScoutingTarget` - Recruitment prospects
- `Schedule` - Events and calendar
- `VodReview` + `VodTimestamp` - Video analysis
- `TeamGoal` - Performance goals
- `AuditLog` - Security audit trail

## Key Patterns

### Controllers
All controllers inherit from `Api::V1::BaseController` which includes:
- JWT authentication via `Authenticatable` concern
- Standardized error handling
- Organization scoping
- Audit logging helpers

### Authentication
- JWT tokens with 24-hour expiration
- Refresh tokens with 7-day expiration
- Role-based authorization (Pundit patterns ready)
- Automatic audit logging

### Error Handling
Standardized error responses:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {} // Optional validation details
  }
}
```

### Response Format
Successful responses:
```json
{
  "message": "Optional success message",
  "data": {} // Response data
}
```

## Environment Variables

Required for development:
```bash
DATABASE_URL=postgresql://postgres:password@localhost:5432/prostaff_api_development
REDIS_URL=redis://localhost:6379/0
JWT_SECRET_KEY=your_development_secret
RIOT_API_KEY=your_riot_api_key
CORS_ORIGINS=http://localhost:5173,http://localhost:3001
```

## Test Data

Default seeded accounts:
- **Admin**: `admin@teamalpha.gg` / `password123`
- **Coach**: `coach@teamalpha.gg` / `password123`
- **Analyst**: `analyst@teamalpha.gg` / `password123`

Organization: "Team Alpha" (BR region, semi_pro tier)

## Development Guidelines

### Adding New Modules
1. Create module directory in `app/modules/module_name/`
2. Add controllers, services, serializers as needed
3. Update routes in `config/routes.rb`
4. Add authorization policies if needed
5. Write tests in `spec/requests/`

### Adding New Models
1. Generate migration with UUID: `rails g migration CreateModelName`
2. Use UUID primary keys: `create_table :table_name, id: :uuid`
3. Add proper associations and validations
4. Include audit logging for sensitive models
5. Add serializer for API responses

### API Development
1. All endpoints require authentication (except auth endpoints)
2. Use organization scoping: `organization_scoped(Model)`
3. Implement proper authorization checks
4. Return consistent error responses
5. Add audit logging for important actions

### Security
- Never expose sensitive data in responses
- Always validate and sanitize inputs
- Use proper HTTP status codes
- Implement rate limiting for auth endpoints
- Log security-relevant actions

## Troubleshooting

### Common Issues
1. **Database connection**: Check PostgreSQL is running
2. **Redis connection**: Ensure Redis server is started
3. **JWT errors**: Verify JWT_SECRET_KEY is set
4. **CORS issues**: Check CORS_ORIGINS includes frontend URL
5. **Migration errors**: Run `rails db:reset` for clean slate

### Logs Location
- Development: `log/development.log`
- Docker: `docker-compose logs api`
- Sidekiq: Check Sidekiq web UI at `/sidekiq`

## Frontend Integration

The API is designed to work with the React frontend at `http://localhost:5173`. Key integration points:

1. **Authentication**: JWT tokens in Authorization header
2. **Error handling**: Standardized error format for UI
3. **Data format**: Consistent serialized responses
4. **CORS**: Pre-configured for frontend origins

## Next Development Steps

Priority order for implementation:
1. Complete Dashboard module endpoints
2. Implement Players CRUD operations
3. Add Pundit authorization policies
4. Build Analytics module
5. Integrate Riot Games API
6. Implement remaining modules (Scouting, Matches, etc.)

## Useful Resources

- Rails API documentation
- JWT gem documentation
- PostgreSQL UUID functions
- Sidekiq configuration
- RSpec testing patterns
- Blueprinter serialization