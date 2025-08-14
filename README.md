# Srecha Invoice Management System - Backend

Полноценный REST API для системы управления инвойсами и отпремницами компании Среħа 2024.

## 🚀 Технологии

- **Node.js** + **Express.js** - серверный фреймворк
- **PostgreSQL** - база данных
- **JWT** - аутентификация
- **bcryptjs** - хеширование паролей
- **Puppeteer** - генерация PDF
- **ExcelJS** - экспорт в Excel
- **Helmet** - безопасность
- **Rate Limiting** - защита от спама

## 📦 Установка

1. **Клонируйте репозиторий:**
```bash
git clone <repository-url>
cd srecha-invoice-backend
```

2. **Установите зависимости:**
```bash
npm install
```

3. **Настройте базу данных PostgreSQL:**
```bash
# Создайте базу данных
createdb srecha_invoice

# Или через psql
psql -c "CREATE DATABASE srecha_invoice;"
```

4. **Настройте переменные окружения:**
```bash
cp env.example .env
# Отредактируйте .env файл со своими настройками
```

5. **Запустите миграции:**
```bash
npm run migrate
```

6. **Заполните базу начальными данными:**
```bash
npm run seed
```

**Пользователи по умолчанию:**
- **Админ:** `BrankoFND` / `MoskvaSlezamNeVeryt2024` (полные права)
- **Тест:** `тест` / `тест` (все права кроме управления пользователями)

7. **Запустите сервер:**
```bash
# Для разработки
npm run dev

# Для продакшена
npm start
```

## 🔧 Переменные окружения

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=srecha_invoice
DB_USER=postgres
DB_PASSWORD=your_password

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d

# CORS
FRONTEND_URL=http://localhost:8080
```

## 🗄️ Структура базы данных

### Основные таблицы:
- **users** - пользователи системы (с ролями и разрешениями)
- **clients** - клиенты (с расширенными профилями)
- **products** - товары (с весом для складского учета)
- **product_groups** - группы товаров для склада
- **product_group_items** - связь товаров с группами
- **invoices** - инвойсы (с отслеживанием доставки/оплаты)
- **invoice_items** - позиции инвойсов
- **deliveries** - отпремницы (с отслеживанием подписи)
- **delivery_items** - позиции отпремниц
- **activity_logs** - логи активности

## 🛠️ API Endpoints

### 🔐 Аутентификация (`/api/auth`)
```
POST   /register                   - Регистрация пользователя
POST   /login                      - Вход в систему
GET    /profile                    - Получить профиль
PUT    /profile                    - Обновить профиль
PUT    /change-password            - Сменить пароль
POST   /logout                     - Выход из системы
GET    /users                      - Список пользователей (только админ)
POST   /users                      - Создать пользователя (только админ)
PUT    /users/:id/permissions      - Обновить разрешения (только админ)
DELETE /users/:id                  - Удалить пользователя (только админ)
PUT    /users/:id/toggle-status    - Активировать/деактивировать (только админ)
```

### 👥 Клиенты (`/api/clients`)
```
GET    /                  - Список клиентов (с пагинацией и поиском)
GET    /:id               - Получить клиента
POST   /                  - Создать клиента
PUT    /:id               - Обновить клиента
DELETE /:id               - Удалить клиента
GET    /:id/invoices      - Инвойсы клиента
GET    /:id/deliveries    - Отпремницы клиента
GET    /:id/statistics    - Статистика клиента (средний заказ, популярные товары)
```

### 📦 Товары (`/api/products`)
```
GET    /                  - Список товаров
GET    /categories        - Категории товаров
GET    /:id               - Получить товар
POST   /                  - Создать товар
PUT    /:id               - Обновить товар
DELETE /:id               - Удалить/деактивировать товар
PATCH  /:id/activate      - Активировать товар
GET    /:id/stats         - Статистика товара
```

### 📦 Группы товаров (`/api/product-groups`)
```
GET    /                  - Список групп товаров
GET    /:id               - Получить группу товаров
POST   /                  - Создать группу товаров
PUT    /:id               - Обновить группу товаров
DELETE /:id               - Удалить группу товаров
POST   /:id/products      - Добавить товар в группу
DELETE /:id/products/:pid  - Удалить товар из группы
POST   /update-stock      - Обновить остатки при утверждении инвойса
```

### 🧾 Инвойсы (`/api/invoices`)
```
GET    /                  - Список инвойсов
GET    /:id               - Получить инвойс
POST   /                  - Создать инвойс
DELETE /:id               - Удалить инвойс
PATCH  /:id/status        - Обновить статус (черновик/утвержден)
PATCH  /:id/tracking      - Обновить статус доставки/оплаты
```

### 🚚 Отпремницы (`/api/deliveries`)
```
GET    /                  - Список отпремниц
GET    /:id               - Получить отпремницу
POST   /                  - Создать отпремницу
DELETE /:id               - Удалить отпремницу
PATCH  /:id/status        - Обновить статус (черновик/утвержден)
PATCH  /:id/signed        - Отметить как подписанную
```

### 📊 Логи (`/api/logs`)
```
GET    /                  - Список логов активности
GET    /stats             - Статистика активности (только админ)
GET    /entity-types      - Типы сущностей
GET    /users             - Пользователи для фильтрации (только админ)
DELETE /cleanup           - Очистка старых логов (только админ)
```

### 📈 Экспорт (`/api/export`)
```
GET    /invoices/excel    - Экспорт инвойсов в Excel
GET    /deliveries/excel  - Экспорт отпремниц в Excel
GET    /clients/excel     - Экспорт клиентов в Excel
GET    /products/excel    - Экспорт товаров в Excel
GET    /logs/excel        - Экспорт логов в Excel
```

## 🔒 Аутентификация

Все защищенные маршруты требуют JWT токен в заголовке:
```
Authorization: Bearer <your-jwt-token>
```

## 📝 Примеры использования

### Регистрация пользователя
```javascript
const response = await fetch('/api/auth/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    username: 'john_doe',
    password: 'securepassword',
    email: 'john@example.com',
    full_name: 'John Doe'
  })
});
```

### Создание клиента
```javascript
const response = await fetch('/api/clients', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    name: 'Test Company DOO',
    mb: '12345678',
    pib: '987654321',
    address: 'Belgrade, Serbia',
    contact: 'test@company.com'
  })
});
```

### Создание инвойса
```javascript
const response = await fetch('/api/invoices', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    number: 'INV-001',
    date: '2024-01-15',
    due_date: '2024-01-30',
    client_id: 'client-uuid',
    vat_rate: 20,
    items: [
      {
        product_id: 'product-uuid',
        quantity: 2,
        unit_price: 1500
      }
    ]
  })
});
```

## 🛡️ Безопасность

- **Helmet** - защита заголовков HTTP
- **Rate Limiting** - ограничение запросов
- **CORS** - настройка междоменных запросов
- **JWT** - безопасная аутентификация
- **bcrypt** - хеширование паролей
- **SQL Injection** - защита через параметризованные запросы
- **Input Validation** - валидация всех входных данных

## 📊 Мониторинг

- Логирование всех действий пользователей
- Отслеживание производительности запросов
- Мониторинг подключений к базе данных
- Health check endpoint: `GET /health`

## 🚀 Развертывание

### Docker (рекомендуется)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### PM2 (для продакшена)
```bash
npm install -g pm2
pm2 start server.js --name "srecha-api"
pm2 startup
pm2 save
```

## 🧪 Тестирование

```bash
# Запуск тестов (когда будут добавлены)
npm test

# Проверка health check
curl http://localhost:3000/health
```

## 📚 Документация API

После запуска сервера API документация будет доступна по адресу:
`http://localhost:3000/api-docs` (планируется добавить Swagger)

## 🤝 Вклад в проект

1. Fork проекта
2. Создайте feature branch
3. Commit ваши изменения
4. Push в branch
5. Создайте Pull Request

## 📄 Лицензия

MIT License - см. файл LICENSE

## 🆘 Поддержка

Если у вас есть вопросы или проблемы, создайте issue в GitHub репозитории.

---

**Среħа 2024** - Система управления документами

