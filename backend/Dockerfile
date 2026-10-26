FROM php:8.3.36-cli

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libcurl4-openssl-dev \
    libpq-dev \
    && docker-php-ext-install curl pdo pdo_pgsql opcache pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Los procesos de Laravel, Reverb, queue y scheduler heredan este
# usuario porque todos utilizan esta imagen.
RUN groupadd --gid 1000 laravel \
    && useradd --uid 1000 --gid laravel --create-home --shell /usr/sbin/nologin laravel

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Carpeta de trabajo
WORKDIR /app

# WORKDIR crea /app como root. Composer debe poder crear vendor/ cuando la
# imagen se construye desde un checkout limpio (como ocurre en GitHub Actions).
RUN chown laravel:laravel /app

# Copiar el proyecto Laravel con permisos para el usuario de la aplicación.
COPY --chown=laravel:laravel laravel/ .

# Composer y los scripts de Artisan se ejecutan sin privilegios; esto también
# deja vendor, storage y bootstrap/cache con propietarios correctos.
USER laravel
RUN composer install --no-interaction --prefer-dist

# Exponer puerto
EXPOSE 8000

# Correr Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
