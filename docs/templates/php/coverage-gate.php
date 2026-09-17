#!/usr/bin/env php
<?php
/**
 * coverage-gate.php — fails when a layer's line coverage is below its threshold.
 * Web Studio template (stack-reference/php.md "Tests by layer"); installed as scripts/coverage-gate.php,
 * called from `composer ci` after `phpunit --coverage-clover=build/clover.xml`.
 *
 * Usage: php scripts/coverage-gate.php [--clover=build/clover.xml] [--root=src] Domain=90 Application=80 ...
 *   a layer is the directory <root>/<Layer>/ (src/ by default; --root=app for a Laravel-rooted tree),
 *   matched on the clover file paths; a layer with no files is an error (exit 2) — a project without that
 *   layer removes the gate from `ci` instead of letting it pass on nothing. The thresholds are written by
 *   /test-setup into the composer `coverage-gate` line from technical-preferences.
 */
declare(strict_types=1);

$clover = 'build/clover.xml';
$root = 'src';
$gates = [];
foreach (array_slice($argv, 1) as $arg) {
    if (str_starts_with($arg, '--clover=')) {
        $clover = substr($arg, 9);
        continue;
    }
    if (str_starts_with($arg, '--root=')) {
        $root = trim(substr($arg, 7), '/');
        continue;
    }
    if (str_starts_with($arg, '--')) {
        fwrite(STDERR, "coverage-gate: unknown option '$arg' (want --clover=FILE or --root=DIR)\n");
        exit(2);
    }
    [$layer, $min] = array_pad(explode('=', $arg, 2), 2, null);
    if ($layer === '' || $min === null || !is_numeric($min) || (float) $min < 0 || (float) $min > 100) {
        fwrite(STDERR, "coverage-gate: bad argument '$arg' (expected Layer=percent)\n");
        exit(2);
    }
    $gates[$layer] = (float) $min;
}
if ($gates === []) {
    fwrite(STDERR, "coverage-gate: no gates given (e.g. Domain=90 Application=80)\n");
    exit(2);
}
if (!is_file($clover)) {
    fwrite(STDERR, "coverage-gate: $clover not found — run phpunit with --coverage-clover=$clover first\n");
    exit(2);
}
$reader = new XMLReader();
if (!@$reader->open($clover)) {
    fwrite(STDERR, "coverage-gate: $clover is not readable as XML\n");
    exit(2);
}
$totals = [];
$currentLayer = null;
// Stream the report: a clover file lists <file name="…"> elements with one <metrics> child each; the <line>
// elements (most of the bytes) are skipped, so a report of any size fits in the default memory_limit.
while ($reader->read()) {
    if ($reader->nodeType !== XMLReader::ELEMENT) {
        continue;
    }
    if ($reader->name === 'file') {
        $currentLayer = null;
        $name = (string) $reader->getAttribute('name');
        foreach (array_keys($gates) as $layer) {
            if (preg_match('#(^|/)' . preg_quote($root, '#') . '/' . preg_quote($layer, '#') . '/#', $name) === 1) {
                $currentLayer = $layer;
                break;
            }
        }
        continue;
    }
    if ($reader->name === 'metrics' && $currentLayer !== null) {
        $totals[$currentLayer]['statements'] = ($totals[$currentLayer]['statements'] ?? 0) + (int) $reader->getAttribute('statements');
        $totals[$currentLayer]['covered'] = ($totals[$currentLayer]['covered'] ?? 0) + (int) $reader->getAttribute('coveredstatements');
        $currentLayer = null;
    }
}
$reader->close();
$rc = 0;
foreach ($gates as $layer => $min) {
    if (!isset($totals[$layer]) || $totals[$layer]['statements'] === 0) {
        echo "coverage-gate: $layer — no files under $root/$layer in $clover; remove the gate or add the layer\n";
        $rc = 2;
        continue;
    }
    $pct = 100.0 * $totals[$layer]['covered'] / $totals[$layer]['statements'];
    if ($pct + 1e-9 >= $min) {
        printf("coverage-gate: %s %.1f%% >= %.0f%% OK\n", $layer, $pct, $min);
    } else {
        printf("coverage-gate: %s %.1f%% < %.0f%% — add tests under tests/Unit/%s before this change lands\n", $layer, $pct, $min, $layer);
        $rc = 1;
    }
}
exit($rc);
