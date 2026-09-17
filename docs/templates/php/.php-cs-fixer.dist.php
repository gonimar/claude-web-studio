<?php
// PHP-CS-Fixer — Web Studio template (stack-reference/php.md). `php_cs_tool: php-cs-fixer`.
// `@PER-CS` is the latest PER Coding Style edition the fixer ships; run `vendor/bin/php-cs-fixer fix --dry-run --diff`
// (composer `lint`) and `vendor/bin/php-cs-fixer fix` after every write.
declare(strict_types=1);

$finder = PhpCsFixer\Finder::create()
    ->in(array_filter([__DIR__ . '/src', __DIR__ . '/app', __DIR__ . '/tests', __DIR__ . '/config'], 'is_dir'));

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules([
        '@PER-CS' => true,
        '@PER-CS:risky' => true,
        'declare_strict_types' => true,
        'no_unused_imports' => true,
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'trailing_comma_in_multiline' => ['elements' => ['arguments', 'arrays', 'parameters']],
    ])
    ->setFinder($finder);
