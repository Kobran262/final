# 🐳 Docker Развертывание Srecha Invoice System

Полное руководство по развертыванию системы управления инвойсами с помощью Docker и Docker Compose.

## 🚀 Быстрый старт

### Минимальные требования
- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM
- 5GB свободного места на диске

### Запуск одной командой
```bash
make quick-start
```

Эта команда выполнит:
1. Настройку окружения
2. Сборку Docker образов
3. Запуск всех сервисов
4. Создание структуры БД
5. Заполнение начальными данными

## 📋 Пошаговое развертывание

### 1. Подготовка окружения
```bash
# Клонируйте проект
git clone <repository-url>
cd srecha-invoice

# Настройте переменные окружения
make setup
```

### 2. Настройка .env файла
Отредактируйте файл `.env` и измените следующие параметры:

```env
# Обязательно измените эти пароли!
DB_PASSWORD=your_secure_database_password
JWT_SECRET=your_very_long_and_random_jwt_secret_key
REDIS_PASSWORD=your_secure_redis_password

# Настройки компании
COMPANY_NAME=Ваша Компания
COMPANY_ADDRESS=Ваш Адрес
```

### 3. Сборка и запуск
```bash
# Сборка образов
make build

# Запуск всех сервисов
make up

# Создание структуры БД
make migrate

# Заполнение начальными данными
make seed
```

### 4. Проверка работы
```bash
# Проверка статуса сервисов
make status

# Проверка здоровья сервисов
make health

# Просмотр логов
make logs
```

## 🏗️ Архитектура системы

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   PostgreSQL    │
│   (Nginx)       │◄──►│   (Node.js)     │◄──►│   Database      │
│   Port: 8080    │    │   Port: 3000    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│     Redis       │◄─────────────┘
                        │   (Cache)       │
                        │   Port: 6379    │
                        └─────────────────┘
```

### Компоненты системы

| Сервис | Описание | Порт | Образ |
|--------|----------|------|-------|
| **frontend** | Nginx + статические файлы | 8080 | nginx:alpine |
| **backend** | Node.js API сервер | 3000 | node:18-alpine |
| **postgres** | База данных PostgreSQL | 5432 | postgres:15-alpine |
| **redis** | Кэш и сессии | 6379 | redis:7-alpine |
| **backup** | Сервис резервного копирования | - | postgres:15-alpine |

## 🔧 Управление сервисами

### Основные команды
```bash
# Запуск
make up              # Запустить все сервисы
make dev             # Запуск в режиме разработки
make prod            # Запуск в продакшн режиме

# Остановка
make down            # Остановить все сервисы
make restart         # Перезапустить сервисы

# Мониторинг
make logs            # Показать логи всех сервисов
make logs-backend    # Логи только backend
make logs-frontend   # Логи только frontend
make logs-db         # Логи базы данных
make status          # Статус всех сервисов
make health          # Проверка здоровья сервисов
```

### Работа с базой данных
```bash
# Подключение к БД
make db-shell

# Миграции
make migrate

# Заполнение данными
make seed

# Резервное копирование
make backup

# Восстановление из резервной копии
make restore BACKUP_FILE=backup_filename.sql.custom

# Список доступных резервных копий
make list-backups
```

## 💾 Резервное копирование

### Автоматическое резервное копирование
Система автоматически создает резервные копии базы данных:

```bash
# Создать резервную копию вручную
make backup

# Резервные копии сохраняются в папке ./backups/
# Формат файлов:
# - srecha_invoice_backup_YYYYMMDD_HHMMSS.sql.gz (SQL формат)
# - srecha_invoice_backup_YYYYMMDD_HHMMSS.sql.custom (Custom формат)
```

### Восстановление из резервной копии
```bash
# 1. Остановить приложение
make down

# 2. Запустить только базу данных
docker-compose up -d postgres

# 3. Восстановить из резервной копии
make restore BACKUP_FILE=srecha_invoice_backup_20240101_120000.sql.custom

# 4. Запустить все сервисы
make up
```

## 📊 Мониторинг (опционально)

### Запуск системы мониторинга
```bash
# Запуск Prometheus + Grafana
make monitoring

# Доступ к интерфейсам:
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin123)
```

### Остановка мониторинга
```bash
make monitoring-down
```

## 🔒 Безопасность

### Рекомендации по безопасности

1. **Смените пароли по умолчанию**:
   ```env
   DB_PASSWORD=complex_database_password_123
   JWT_SECRET=very_long_random_string_for_jwt_signing
   REDIS_PASSWORD=secure_redis_password_456
   ```

2. **Используйте HTTPS в продакшене**:
   ```yaml
   # В docker-compose.yml добавьте SSL сертификаты
   volumes:
     - /path/to/ssl/cert.pem:/etc/ssl/cert.pem:ro
     - /path/to/ssl/key.pem:/etc/ssl/key.pem:ro
   ```

3. **Ограничьте доступ к портам**:
   ```yaml
   # Закройте порты БД от внешнего доступа
   postgres:
     ports:
       - "127.0.0.1:5432:5432"  # Только localhost
   ```

4. **Регулярно обновляйте образы**:
   ```bash
   make update  # Обновление всех образов
   ```

## 🐛 Устранение неполадок

### Частые проблемы

#### 1. Ошибка подключения к базе данных
```bash
# Проверьте статус контейнера БД
docker-compose ps postgres

# Проверьте логи БД
make logs-db

# Проверьте подключение
docker-compose exec postgres pg_isready -U postgres
```

#### 2. Backend не запускается
```bash
# Проверьте переменные окружения
cat .env

# Проверьте логи backend
make logs-backend

# Пересоберите образ
make build-no-cache
```

#### 3. Frontend недоступен
```bash
# Проверьте статус Nginx
make logs-frontend

# Проверьте конфигурацию
docker-compose exec frontend nginx -t
```

#### 4. Проблемы с правами доступа
```bash
# Исправьте права на папки
sudo chown -R $USER:$USER uploads/ logs/ backups/
```

### Полная очистка и переустановка
```bash
# Остановить все и удалить данные
make clean-all

# Начать заново
make quick-start
```

## 🔄 Обновление системы

### Обновление до новой версии
```bash
# 1. Создать резервную копию
make backup

# 2. Остановить сервисы
make down

# 3. Получить новый код
git pull origin main

# 4. Обновить образы и запустить
make update

# 5. Выполнить миграции (если есть)
make migrate
```

## 📁 Структура файлов

```
srecha-invoice/
├── docker-compose.yml      # Основная конфигурация Docker Compose
├── Dockerfile              # Dockerfile для backend
├── Dockerfile.frontend     # Dockerfile для frontend
├── nginx.conf              # Конфигурация Nginx
├── Makefile                # Команды управления
├── .env                    # Переменные окружения
├── .dockerignore           # Исключения для Docker
├── scripts/
│   └── backup.sh           # Скрипт резервного копирования
├── monitoring/
│   └── prometheus.yml      # Конфигурация Prometheus
├── backups/                # Резервные копии БД
├── uploads/                # Загруженные файлы
└── logs/                   # Логи приложения
```

## 📞 Поддержка

### Полезные команды для диагностики
```bash
# Информация о системе
docker version
docker-compose version

# Использование ресурсов
docker stats

# Информация о сети
docker network ls
docker network inspect srecha-invoice_srecha_network

# Информация о томах
docker volume ls
docker volume inspect srecha-invoice_postgres_data
```

### Логи и отладка
```bash
# Подробные логи с временными метками
docker-compose logs -f -t

# Логи конкретного сервиса
docker-compose logs -f backend

# Выполнение команд в контейнере
make shell-backend
make shell-frontend
```

## 🎯 Рекомендации для продакшена

1. **Используйте внешнюю базу данных** для критически важных данных
2. **Настройте регулярные резервные копии** с помощью cron
3. **Используйте Docker Swarm или Kubernetes** для масштабирования
4. **Настройте мониторинг** с алертами
5. **Используйте reverse proxy** (Traefik, nginx) для SSL терминации
6. **Настройте логирование** в централизованную систему

---

## 🚀 Готово!

После выполнения всех шагов система будет доступна по адресам:
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Мониторинг**: http://localhost:9090 (Prometheus), http://localhost:3001 (Grafana)

**Данные для входа по умолчанию:**
- **Админ**: `BrankoFND` / `MoskvaSlezamNeVeryt2024`
- **Тест**: `тест` / `тест`
