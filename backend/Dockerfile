FROM php:8.3-cli

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Carpeta de trabajo
WORKDIR /app

# Copiar composer
COPY laravel/composer.json laravel/composer.lock ./

# Instalar dependencias PHP
RUN composer install --no-interaction --prefer-dist

# Copiar el resto del proyecto Laravel
COPY laravel/ .

# Exponer puerto
EXPOSE 8000

# Correr Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]