# ProStaff API - Guia de Integração Frontend

## 📋 Sumário
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Autenticação](#autenticação)
- [Endpoints da API](#endpoints-da-api)
- [Exemplos de Integração](#exemplos-de-integração)
- [Tratamento de Erros](#tratamento-de-erros)

## 🔧 Configuração do Ambiente

### Variáveis de Ambiente (.env)

\`\`\`bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=development_secret_key_base_change_in_production

# JWT - IMPORTANTE: Use chaves fortes em produção
JWT_SECRET_KEY=your_super_secret_jwt_key_change_in_production
JWT_EXPIRATION_HOURS=24

# Riot API (opcional para testes iniciais)
RIOT_API_KEY=RGAPI-your-riot-api-key-here

# Redis
REDIS_URL=redis://localhost:6379/0

# CORS - Adicione a URL do seu frontend
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:8080

# Frontend URL (para links em emails)
FRONTEND_URL=http://localhost:5173

# Rate Limiting
RACK_ATTACK_LIMIT=300
RACK_ATTACK_PERIOD=300
\`\`\`

### Iniciar a API

\`\`\`bash
# Opção 1: Localmente
DB_PASSWORD=password bundle exec puma -p 3333

# Opção 2: Docker
docker-compose up

# Opção 3: Com Sidekiq para background jobs
DB_PASSWORD=password bundle exec puma -p 3333 &
DB_PASSWORD=password bundle exec sidekiq
\`\`\`

### URLs Importantes

- **API Base URL**: \`http://localhost:3333/api/v1\`
- **Swagger UI**: \`http://localhost:3333/api-docs\`
- **Sidekiq Dashboard**: \`http://localhost:3333/sidekiq\` (dev only)
- **Health Check**: \`http://localhost:3333/up\`

---

## 🔐 Autenticação

A API usa **JWT (JSON Web Tokens)** com access e refresh tokens.

### Fluxo de Autenticação

1. **Registro/Login** → Recebe \`access_token\` + \`refresh_token\`
2. Inclui \`Authorization: Bearer {access_token}\` em todas as requests
3. Quando access token expira (24h) → Use refresh token
4. Refresh token expira em 7 dias

### Headers Necessários

\`\`\`http
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
\`\`\`

---

## 📍 Endpoints da API

### 🔑 Authentication (\`/api/v1/auth/auth/*\`)

#### 1. Registrar Organização + Admin

\`\`\`bash
curl -X POST http://localhost:3333/api/v1/auth/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{
    "organization": {
      "name": "Team Alpha",
      "region": "BR",
      "tier": "semi_pro"
    },
    "user": {
      "email": "admin@teamalpha.gg",
      "password": "password123",
      "full_name": "John Doe",
      "timezone": "America/Sao_Paulo",
      "language": "pt-BR"
    }
  }'
\`\`\`

**Response (201):**
\`\`\`json
{
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "uuid",
      "email": "admin@teamalpha.gg",
      "full_name": "John Doe",
      "role": "owner"
    },
    "organization": {
      "id": "uuid",
      "name": "Team Alpha",
      "region": "BR",
      "tier": "semi_pro"
    },
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 86400
  }
}
\`\`\`

#### 2. Login

\`\`\`bash
curl -X POST http://localhost:3333/api/v1/auth/auth/login \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "admin@teamalpha.gg",
    "password": "password123"
  }'
\`\`\`

#### 3. Refresh Token

\`\`\`bash
curl -X POST http://localhost:3333/api/v1/auth/auth/refresh \\
  -H "Content-Type: application/json" \\
  -d '{
    "refresh_token": "eyJhbGc..."
  }'
\`\`\`

#### 4. Get Current User

\`\`\`bash
curl -X GET http://localhost:3333/api/v1/auth/auth/me \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

#### 5. Logout

\`\`\`bash
curl -X POST http://localhost:3333/api/v1/auth/auth/logout \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

---

### 📊 Dashboard (\`/api/v1/dashboard\`)

\`\`\`bash
# Get complete dashboard
curl -X GET http://localhost:3333/api/v1/dashboard \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Get stats only
curl -X GET http://localhost:3333/api/v1/dashboard/stats \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Get activities
curl -X GET http://localhost:3333/api/v1/dashboard/activities \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Get schedule
curl -X GET http://localhost:3333/api/v1/dashboard/schedule \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

---

### 👥 Players (\`/api/v1/players\`)

#### List Players (with filters)

\`\`\`bash
curl -X GET "http://localhost:3333/api/v1/players?page=1&per_page=10&role=mid&status=active" \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

**Query Parameters:**
- \`page\`: Número da página
- \`per_page\`: Items por página
- \`role\`: top, jungle, mid, adc, support
- \`status\`: active, inactive, benched, trial
- \`search\`: Buscar por nome

#### Create Player

\`\`\`bash
curl -X POST http://localhost:3333/api/v1/players \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \\
  -d '{
    "player": {
      "summoner_name": "Faker",
      "real_name": "Lee Sang-hyeok",
      "role": "mid",
      "status": "active",
      "jersey_number": 7,
      "country": "KR"
    }
  }'
\`\`\`

#### Get/Update/Delete Player

\`\`\`bash
# Get
curl -X GET http://localhost:3333/api/v1/players/{player_id} \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Update  
curl -X PUT http://localhost:3333/api/v1/players/{player_id} \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \\
  -d '{"player": {"status": "benched"}}'

# Delete
curl -X DELETE http://localhost:3333/api/v1/players/{player_id} \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

#### Get Player Stats

\`\`\`bash
curl -X GET http://localhost:3333/api/v1/players/{player_id}/stats \\
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
\`\`\`

---

## 🔄 Exemplo de Integração React/Next.js

### API Client Setup

\`\`\`typescript
// lib/api.ts
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3333/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = \`Bearer \${token}\`;
  }
  return config;
});

// Handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401 && !error.config._retry) {
      error.config._retry = true;
      const refreshToken = localStorage.getItem('refresh_token');
      
      try {
        const { data } = await axios.post(\`\${API_BASE_URL}/auth/auth/refresh\`, {
          refresh_token: refreshToken,
        });
        
        localStorage.setItem('access_token', data.data.access_token);
        localStorage.setItem('refresh_token', data.data.refresh_token);
        
        error.config.headers.Authorization = \`Bearer \${data.data.access_token}\`;
        return api(error.config);
      } catch {
        localStorage.clear();
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export default api;
\`\`\`

### Auth Service

\`\`\`typescript
// services/auth.ts
import api from '@/lib/api';

export const authService = {
  async register(data: any) {
    const response = await api.post('/auth/auth/register', data);
    this.saveTokens(response.data.data);
    return response.data;
  },

  async login(email: string, password: string) {
    const response = await api.post('/auth/auth/login', { email, password });
    this.saveTokens(response.data.data);
    return response.data;
  },

  async logout() {
    await api.post('/auth/auth/logout');
    localStorage.clear();
  },

  async getCurrentUser() {
    const response = await api.get('/auth/auth/me');
    return response.data.data;
  },

  saveTokens(data: any) {
    localStorage.setItem('access_token', data.access_token);
    localStorage.setItem('refresh_token', data.refresh_token);
    localStorage.setItem('user', JSON.stringify(data.user));
  },
};
\`\`\`

### Players Service

\`\`\`typescript
// services/players.ts
import api from '@/lib/api';

export const playersService = {
  async getPlayers(filters = {}) {
    const response = await api.get('/players', { params: filters });
    return response.data.data;
  },

  async getPlayer(id: string) {
    const response = await api.get(\`/players/\${id}\`);
    return response.data.data;
  },

  async createPlayer(data: any) {
    const response = await api.post('/players', { player: data });
    return response.data.data;
  },

  async updatePlayer(id: string, data: any) {
    const response = await api.put(\`/players/\${id}\`, { player: data });
    return response.data.data;
  },

  async deletePlayer(id: string) {
    await api.delete(\`/players/\${id}\`);
  },
};
\`\`\`

---

## ❌ Tratamento de Erros

### Formato de Erro

\`\`\`json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": { "field": ["error"] }
  }
}
\`\`\`

### Códigos Comuns

- \`UNAUTHORIZED\` (401): Token inválido
- \`INVALID_CREDENTIALS\` (401): Email/senha incorretos
- \`VALIDATION_ERROR\` (422): Dados inválidos
- \`NOT_FOUND\` (404): Recurso não encontrado

---

## 🧪 Teste Rápido

\`\`\`bash
# 1. Registrar
curl -X POST http://localhost:3333/api/v1/auth/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{
    "organization": {"name": "Test Team", "region": "BR", "tier": "amateur"},
    "user": {"email": "test@test.com", "password": "test123", "full_name": "Test User"}
  }'

# 2. Salve o access_token da resposta

# 3. Buscar dashboard
curl -X GET http://localhost:3333/api/v1/dashboard \\
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
\`\`\`

---

## 📚 Recursos

- **Swagger UI**: http://localhost:3333/api-docs
- **Health Check**: http://localhost:3333/up
- **Sidekiq**: http://localhost:3333/sidekiq

---

**Versão**: v1  
**Última Atualização**: Outubro 2024
