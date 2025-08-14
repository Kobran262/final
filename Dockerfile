# Multi-stage Dockerfile для Srecha Invoice Backend

# Базовый образ для всех стадий
FROM node:18-alpine AS base
WORKDIR /app

# Установка системных зависимостей
RUN apk add --no-cache \
    curl \
    postgresql-client \
    tzdata \
    && cp /usr/share/zoneinfo/Europe/Belgrade /etc/localtime \
    && echo "Europe/Belgrade" > /etc/timezone

# Копирование package files
COPY package*.json ./

# Development стадия
FROM base AS development
ENV NODE_ENV=development
RUN npm ci --include=dev
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Dependencies стадия (для production)
FROM base AS dependencies
ENV NODE_ENV=production
RUN npm ci --only=production && npm cache clean --force

# Production build стадия
FROM base AS production
ENV NODE_ENV=production

# Создание пользователя для безопасности
RUN addgroup -g 1001 -S nodejs && \
    adduser -S srecha -u 1001

# Копирование зависимостей
COPY --from=dependencies /app/node_modules ./node_modules

# Копирование исходного кода
COPY --chown=srecha:nodejs . .

# Создание необходимых директорий
RUN mkdir -p uploads logs backups && \
    chown -R srecha:nodejs uploads logs backups

# Установка прав и переключение на пользователя
USER srecha

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Открытие порта
EXPOSE 3000

# Запуск приложения
CMD ["npm", "start"]
