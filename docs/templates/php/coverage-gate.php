#!/usr/bin/env php
<?php
/**
 * coverage-gate.php — fails when a layer's line coverage is below its threshold.
 * Web Studio template (stack-reference/php.md "Tests by layer"); installed as scripts/coverage-gate.php,
 * called from `composer ci` after `phpunit --coverage-clover=build/clover.xml`.
 *
 * Usage: php scripts/coverage-gate.php [--clover=build/clover.xml] [Domain=90] [Application=80] ...
 *   a layer is the namespace segment right under the root namespace (App\Domain\... → "Domain"),
 *   matched on the file path segment src/<Layer>/; a layer with no files is reported and skipped.
 */
declare(strict_types=1);

$clover = 'build/clover.xml';
$gates = [];
foreach (array_slice($argv, 1) as $arg) {
    if (str_starts_with($arg, '--clover=')) {
        $clover = substr($arg, 9);
        continue;
    }
    [$layer, $min] = array_pad(explode('=', $arg, 2), 2, null);
    if ($layer === '' || $min === null || !is_numeric($min)) {
        fwrite(STDERR, "coverage-gate: bad argument '$arg' (expected Layer=percent)\n");
        exit(2);
    }
    $gates[$layer] = (float) $min;
}
if ($gates === []) {
    $gates = ['Domain' => 90.0, 'Application' => 80.0];
}
if (!is_file($clover)) {
    fwrite(STDERR, "coverage-gate: $clover not found — run phpunit with --coverage-clover=$clover first\n");
    exit(2);
}
$xml = @simplexml_load_file($clover);
if ($xml === false) {
    fwrite(STDERR, "coverage-gate: $clover is not a clover report\n");
    exit(2);
}
$totals = [];
foreach ($xml->xpath('//file') as $file) {
    $name = (string) $file['name'];
    foreach (array_keys($gates) as $layer) {
        if (preg_match('#/src/' . preg_quote($layer, '#') . '/#', $name) !== 1) {
            continue;
        }
        $m = $file->metrics;
        $totals[$layer]['statements'] = ($totals[$layer]['statements'] ?? 0) + (int) $m['statements'];
        $totals[$layer]['covered'] = ($totals[$layer]['covered'] ?? 0) + (int) $m['coveredstatements'];
    }
}
$rc = 0;
foreach ($gates as $layer => $min) {
    if (!isset($totals[$layer]) || $totals[$layer]['statements'] === 0) {
        echo "coverage-gate: $layer — no files under src/$layer, skipped\n";
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
