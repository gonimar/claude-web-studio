<?php
// Easy Coding Standard — Web Studio template (stack-reference/php.md). `php_cs_tool: ecs`.
// PER Coding Style (current edition) through the prepared set; run `vendor/bin/ecs check` (composer `lint`)
// and `vendor/bin/ecs check --fix` after every write.
declare(strict_types=1);

use Symplify\EasyCodingStandard\Config\ECSConfig;

return ECSConfig::configure()
    ->withPaths(array_filter([__DIR__ . '/src', __DIR__ . '/app', __DIR__ . '/tests', __DIR__ . '/config'], 'is_dir'))
    ->withRootFiles()
    ->withPreparedSets(perCs: true, arrays: true, namespaces: true, cleanup: true);
