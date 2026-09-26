<?php
// Easy Coding Standard — Web Studio template (stack-reference/php.md). `php_cs_tool: ecs`.
// PER Coding Style (current edition) through the prepared set; run `vendor/bin/ecs check` (composer `lint`)
// and `vendor/bin/ecs check --fix` after every write.
// Comment form (rules/comments.md) through Slevomat sniffs — `composer require --dev slevomat/coding-standard`
// (/test-setup adds it next to ecs): no docblock that repeats the signature, no empty comment, no story history
// or bare TODO in code, no @author/@package/@version noise.
declare(strict_types=1);

use SlevomatCodingStandard\Sniffs\Commenting\EmptyCommentSniff;
use SlevomatCodingStandard\Sniffs\Commenting\ForbiddenAnnotationsSniff;
use SlevomatCodingStandard\Sniffs\Commenting\ForbiddenCommentsSniff;
use SlevomatCodingStandard\Sniffs\Commenting\UselessFunctionDocCommentSniff;
use SlevomatCodingStandard\Sniffs\Commenting\UselessInheritDocCommentSniff;
use Symplify\EasyCodingStandard\Config\ECSConfig;

return ECSConfig::configure()
    ->withPaths(array_filter([__DIR__ . '/src', __DIR__ . '/app', __DIR__ . '/tests', __DIR__ . '/config'], 'is_dir'))
    ->withRootFiles()
    ->withPreparedSets(perCs: true, arrays: true, namespaces: true, cleanup: true)
    ->withRules([EmptyCommentSniff::class, UselessFunctionDocCommentSniff::class, UselessInheritDocCommentSniff::class])
    ->withConfiguredRule(ForbiddenAnnotationsSniff::class, [
        'forbiddenAnnotations' => ['@author', '@created', '@version', '@package', '@copyright', '@license'],
    ])
    ->withConfiguredRule(ForbiddenCommentsSniff::class, [
        'forbiddenCommentPatterns' => [
            '~(?<!TODO\(|FIXME\(|HACK\()\b(S|I|OPS|ARCH|SEC)-\d+\b~', // story/finding ids belong in the PR, not the code (tests excluded below); TODO(S-NNN) is the one allowed form
            '~\bpre-S-\d+~', '~\bused to\b~', '~\bpreviously\b~',
            '~\bTODO(?!\((S|I)-\d+\))~',                 // a TODO carries a story or idea id or does not exist
        ],
    ])
    ->withSkip([ForbiddenCommentsSniff::class => [__DIR__ . '/tests/*']]);
