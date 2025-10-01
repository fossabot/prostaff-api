# ProStaff API

Ruby on Rails API for the ProStaff.gg esports team management platform.

## Technology Stack

- **Ruby**: 3.2+
- **Rails**: 7.1+ (API-only mode)
- **Database**: PostgreSQL 14+
- **Authentication**: JWT
- **Background Jobs**: Sidekiq
- **Caching**: Redis
- **Testing**: RSpec

## Architecture

This API follows a modular monolith architecture with the following modules:

- `authentication` - User authentication and authorization
- `dashboard` - Dashboard statistics and metrics
- `players` - Player management and statistics
- `scouting` - Player scouting and talent discovery
- `analytics` - Performance analytics and reporting
- `matches` - Match data and statistics
- `schedules` - Event and schedule management
- `vod_reviews` - Video review and timestamp management
- `team_goals` - Goal setting and tracking
- `riot_integration` - Riot Games API integration

## Setup

### Prerequisites

- Ruby 3.2+
- PostgreSQL 14+
- Redis 6+

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd prostaff-api
```

2. Install dependencies:
```bash
bundle install
```

3. Setup environment variables:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
- Database credentials
- JWT secret key
- Riot API key
- Redis URL
- CORS origins

4. Setup the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

5. Start the services:

Start Redis:
```bash
redis-server
```

Start Sidekiq (in another terminal):
```bash
bundle exec sidekiq
```

Start the Rails server:
```bash
rails server
```

The API will be available at `http://localhost:3333`

## API Documentation

### Base URL
```
http://localhost:3333/api/v1
```

### Authentication

All endpoints (except auth endpoints) require a Bearer token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Authentication Endpoints

- `POST /auth/register` - Register new organization and admin user
- `POST /auth/login` - Login user
- `POST /auth/refresh` - Refresh JWT token
- `POST /auth/logout` - Logout user
- `POST /auth/forgot-password` - Request password reset
- `POST /auth/reset-password` - Reset password
- `GET /auth/me` - Get current user info

### Core Endpoints

#### Dashboard
- `GET /dashboard` - Get complete dashboard data
- `GET /dashboard/stats` - Get quick stats
- `GET /dashboard/activities` - Get recent activities
- `GET /dashboard/schedule` - Get upcoming schedule

#### Players
- `GET /players` - List players
- `GET /players/:id` - Get player details
- `POST /players` - Create player
- `PATCH /players/:id` - Update player
- `DELETE /players/:id` - Delete player
- `GET /players/stats` - Get roster statistics
- `POST /players/import` - Import player from Riot API

#### Matches
- `GET /matches` - List matches
- `GET /matches/:id` - Get match details
- `POST /matches` - Create match
- `POST /matches/import` - Import match from Riot API

#### Scouting
- `GET /scouting/players` - List scouting targets
- `GET /scouting/regions` - Get available regions
- `POST /scouting/players` - Add scouting target

#### Analytics
- `GET /analytics/performance` - Player performance data
- `GET /analytics/champions/:player_id` - Champion statistics
- `GET /analytics/kda-trend/:player_id` - KDA trend analysis

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## Deployment

### Environment Variables

Required environment variables for production:

```bash
DATABASE_URL=postgresql://user:password@host:5432/database
REDIS_URL=redis://host:6379/0
JWT_SECRET_KEY=your-production-secret
RIOT_API_KEY=your-riot-api-key
CORS_ORIGINS=https://your-frontend-domain.com
SECRET_KEY_BASE=your-rails-secret
```

### Docker

A Dockerfile is provided for containerized deployment:

```bash
docker build -t prostaff-api .
docker run -p 3333:3000 prostaff-api
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Add tests
4. Ensure all tests pass
5. Submit a pull request

## License

This project is proprietary software for ProStaff.gg.


Shield: 

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg