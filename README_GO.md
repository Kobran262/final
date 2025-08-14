# Srecha Invoice API - Go Implementation

This is a Go implementation of the Srecha Invoice Management System API, originally written in Node.js.

## 🚀 Features

- **User Authentication & Authorization** - JWT-based authentication with role-based access control
- **Client Management** - Complete CRUD operations for managing clients
- **Product Management** - Manage products and product groups with inventory tracking
- **Invoice Management** - Create, update, and track invoices with automatic stock management
- **Delivery Management** - Handle delivery notes and tracking
- **Export Functionality** - Export data to various formats
- **Activity Logging** - Comprehensive audit trail for all operations
- **Rate Limiting** - Built-in request rate limiting for API protection
- **CORS Support** - Configurable CORS for frontend integration

## 🛠 Technology Stack

- **Language**: Go 1.21+
- **Web Framework**: Gin (HTTP router)
- **Database**: PostgreSQL
- **Authentication**: JWT tokens
- **Password Hashing**: bcrypt
- **Configuration**: Environment variables with godotenv

## 📦 Dependencies

```go
require (
    github.com/gin-contrib/cors v1.4.0
    github.com/gin-gonic/gin v1.9.1
    github.com/golang-jwt/jwt/v5 v5.0.0
    github.com/joho/godotenv v1.4.0
    github.com/lib/pq v1.10.9
    golang.org/x/crypto v0.10.0
    github.com/google/uuid v1.3.0
    github.com/go-playground/validator/v10 v10.14.0
)
```

## 🚀 Getting Started

### Prerequisites

- Go 1.21 or higher
- PostgreSQL 12 or higher
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd srecha-invoice-api
   ```

2. **Install dependencies**
   ```bash
   go mod download
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up the database**
   - Create a PostgreSQL database
   - Run the migration scripts from the original project
   - Update DATABASE_URL in your .env file

5. **Run the application**
   ```bash
   # Development mode
   go run main.go
   
   # Or build and run
   go build -o srecha-api
   ./srecha-api
   ```

## 🔧 Configuration

The application uses environment variables for configuration. Copy `.env.example` to `.env` and adjust the values:

### Required Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | Required |
| `JWT_SECRET` | Secret key for JWT tokens | Required |
| `JWT_EXPIRES_IN` | JWT token expiration | `7d` |
| `GIN_MODE` | Gin framework mode | `debug` |
| `FRONTEND_URL` | Frontend URL for CORS | `http://localhost:8080` |

### Optional Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_MAX_OPEN_CONNS` | Max open database connections | `20` |
| `DB_MAX_IDLE_CONNS` | Max idle database connections | `10` |
| `DB_CONN_MAX_LIFETIME` | Connection max lifetime (seconds) | `3600` |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window (milliseconds) | `900000` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |

## 📁 Project Structure

```
srecha-invoice-api/
├── config/
│   └── database.go          # Database configuration
├── handlers/
│   ├── auth.go             # Authentication handlers
│   ├── client.go           # Client management handlers
│   ├── product.go          # Product management handlers
│   ├── invoice.go          # Invoice handlers (TODO)
│   ├── delivery.go         # Delivery handlers (TODO)
│   ├── export.go           # Export handlers (TODO)
│   └── log.go              # Logging handlers (TODO)
├── middleware/
│   ├── auth.go             # JWT authentication middleware
│   └── rate_limit.go       # Rate limiting middleware
├── models/
│   ├── user.go             # User models and DTOs
│   ├── client.go           # Client models and DTOs
│   ├── product.go          # Product models and DTOs
│   └── invoice.go          # Invoice models and DTOs
├── main.go                 # Application entry point
├── go.mod                  # Go module file
├── go.sum                  # Go dependencies
├── .env.example            # Environment variables template
└── README_GO.md            # This file
```

## 🔒 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Endpoints

#### Public Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /health` - Health check

#### Protected Endpoints
All other endpoints require authentication.

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get current user profile
- `PUT /api/auth/profile` - Update user profile
- `PUT /api/auth/change-password` - Change password
- `POST /api/auth/logout` - Logout (client-side)

### User Management (Admin only)
- `GET /api/auth/users` - Get all users
- `POST /api/auth/users` - Create new user
- `PUT /api/auth/users/:id/permissions` - Update user permissions
- `DELETE /api/auth/users/:id` - Delete user
- `PUT /api/auth/users/:id/toggle-status` - Toggle user status

### Clients
- `GET /api/clients` - Get all clients (with pagination)
- `GET /api/clients/:id` - Get client by ID
- `POST /api/clients` - Create new client
- `PUT /api/clients/:id` - Update client
- `DELETE /api/clients/:id` - Delete client
- `GET /api/clients/:id/invoices` - Get client's invoices
- `GET /api/clients/:id/deliveries` - Get client's deliveries
- `GET /api/clients/:id/statistics` - Get client statistics

### Products
- `GET /api/products` - Get all products (with pagination)
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Product Groups
- `GET /api/product-groups` - Get all product groups
- `GET /api/product-groups/:id` - Get product group by ID
- `POST /api/product-groups` - Create new product group
- `PUT /api/product-groups/:id` - Update product group
- `DELETE /api/product-groups/:id` - Delete product group
- `POST /api/product-groups/:id/products` - Add product to group
- `DELETE /api/product-groups/:id/products/:productId` - Remove product from group

### Invoices (TODO)
- `GET /api/invoices` - Get all invoices
- `GET /api/invoices/:id` - Get invoice by ID
- `POST /api/invoices` - Create new invoice
- `PATCH /api/invoices/:id/status` - Update invoice status
- `PATCH /api/invoices/:id/tracking` - Update invoice tracking
- `DELETE /api/invoices/:id` - Delete invoice

## 🏗 Development Status

### ✅ Completed
- [x] Project structure and configuration
- [x] Database connection and health checks
- [x] JWT authentication middleware
- [x] User authentication (register, login, profile management)
- [x] User management (admin functions)
- [x] Client management (full CRUD)
- [x] Product management (full CRUD)
- [x] Product group management (full CRUD)
- [x] Rate limiting middleware
- [x] CORS configuration
- [x] Activity logging infrastructure

### 🚧 TODO
- [ ] Invoice management implementation
- [ ] Delivery management implementation
- [ ] Export functionality (Excel, PDF)
- [ ] Email notifications
- [ ] File upload handling
- [ ] Advanced reporting
- [ ] API documentation (Swagger)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Docker configuration
- [ ] CI/CD pipeline

## 🧪 Testing

```bash
# Run tests (when implemented)
go test ./...

# Run tests with coverage
go test -cover ./...

# Run specific package tests
go test ./handlers
```

## 🐳 Docker

Docker configuration will be added in a future update.

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Submit a pull request

## 📞 Support

For support, please create an issue in the repository or contact the development team.

---

**Note**: This is a Go port of the original Node.js Srecha Invoice API. Some features are still being implemented. Check the development status section for current progress.
