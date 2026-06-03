#!/bin/sh
set -eu

srcdir="$1"
builddir="$2"

compile_level() {
    level="$1"
    source="$2"
    output="$3"
    "$builddir/lumic" "-O$level" "$srcdir/$source" -o "$builddir/$output"
}

assert_smaller() {
    smaller="$1"
    larger="$2"
    label="$3"
    smaller_size=$(wc -c <"$builddir/$smaller")
    larger_size=$(wc -c <"$builddir/$larger")
    if [ "$smaller_size" -ge "$larger_size" ]; then
        echo "expected $label bytecode to be smaller: $smaller=$smaller_size $larger=$larger_size" >&2
        exit 1
    fi
}

run_and_diff() {
    bytecode="$1"
    input="$2"
    expected="$3"
    output="$4"
    "$builddir/lumivm" "$builddir/$bytecode" <"$srcdir/$input" >"$builddir/$output"
    diff -u "$srcdir/$expected" "$builddir/$output"
}

assert_ripple_age_once() {
    bytecode="$1"
    output="$2"
    expected="update g0=0.000000 g1=0.000000 g2=0.000000 g3=0.000000 g4=0.000000 g5=0.000000 g6=0.000000 g7=0.000000 g8=16.000000"
    "$builddir/lumivm" "$builddir/$bytecode" <"$srcdir/tests/inputs/optimization-ripple-input.txt" >"$builddir/$output"
    grep -Fq "$expected" "$builddir/$output"
}

compile_level 0 tests/fixtures/optimization.lumi optimization-o0.lbc
compile_level 1 tests/fixtures/optimization.lumi optimization-o1.lbc
compile_level 2 tests/fixtures/optimization.lumi optimization-o2.lbc
compile_level 3 tests/fixtures/optimization.lumi optimization-o3.lbc
compile_level 2 tests/fixtures/optimization-cse.lumi optimization-cse-o2.lbc
compile_level 3 tests/fixtures/optimization-cse.lumi optimization-cse-o3.lbc
compile_level 1 examples/example-ripple.lumi optimization-ripple-o1.lbc
compile_level 3 examples/example-ripple.lumi optimization-ripple-o3.lbc

assert_smaller optimization-o2.lbc optimization-o0.lbc "-O2 vs -O0"
assert_smaller optimization-o2.lbc optimization-o1.lbc "-O2 vs -O1"
assert_smaller optimization-o3.lbc optimization-o2.lbc "-O3 vs -O2"
assert_smaller optimization-cse-o3.lbc optimization-cse-o2.lbc "CSE -O3 vs -O2"

run_and_diff optimization-o3.lbc tests/inputs/optimization-input.txt tests/expected/optimization-expected.txt optimization-o3.out
run_and_diff optimization-cse-o3.lbc tests/inputs/optimization-cse-input.txt tests/expected/optimization-cse-expected.txt optimization-cse-o3.out
assert_ripple_age_once optimization-ripple-o1.lbc optimization-ripple-o1.out
assert_ripple_age_once optimization-ripple-o3.lbc optimization-ripple-o3.out
