#!/bin/sh

until nc -z -v -w30 mysql 3306; do
  sleep 5
done

yes | php artisan key:generate

echo "Lancement des migrations..."

if [ ! -f "/var/www/html/storage/migrations_done" ]; then
  composer install --no-interaction --prefer-dist --optimize-autoloader
  npm install --silent
  npm run build --silent

  yes | php artisan migrate --force

  touch /var/www/html/storage/migrations_done
  echo "Migrations effectuées."
else
  echo "Les migrations ont déjà été effectuées, passage au démarrage de PHP-FPM."
fi


echo "Démarrage de PHP-FPM..."
exec php-fpm
