# id: php
# name: PHP
# type: backend
# detect: composer.json+!laravel+!artisan|index.php

## Stack
- PHP 8.2+, Composer, PDO / Doctrine, PHPUnit

## Padrões

- `declare(strict_types=1)` em todo arquivo
- PSR-12 + PSR-4 autoloading
- Type declarations em parâmetros e retornos
- Nunca `@` para suprimir erros
- Nunca concatene SQL — use prepared statements
- Escape output com `htmlspecialchars()`
- `password_hash()` / `password_verify()` para senhas

## Testes
```php
public function test_should_do_x_when_y(): void {
    // Arrange → Act → Assert
}
```

## Comandos
```bash
php -S localhost:8000 -t public
./vendor/bin/phpunit
./vendor/bin/phpunit --coverage-text
./vendor/bin/php-cs-fixer fix
```
