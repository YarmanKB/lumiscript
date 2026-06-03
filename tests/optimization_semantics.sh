#!/bin/sh
set -eu

srcdir="$1"
builddir="$2"

normalize_output() {
    sed 's/ steps=[0-9][0-9]*//g'
}

check_equivalent() {
    name="$1"
    source="$2"
    input="$3"

    "$builddir/lumic" -O0 "$srcdir/$source" -o "$builddir/$name-o0.lbc"
    "$builddir/lumic" -O1 "$srcdir/$source" -o "$builddir/$name-o1.lbc"
    "$builddir/lumic" -O2 "$srcdir/$source" -o "$builddir/$name-o2.lbc"
    "$builddir/lumic" -O3 "$srcdir/$source" -o "$builddir/$name-o3.lbc"

    "$builddir/lumivm" "$builddir/$name-o0.lbc" <"$srcdir/$input" | normalize_output >"$builddir/$name-o0.out"
    "$builddir/lumivm" "$builddir/$name-o1.lbc" <"$srcdir/$input" | normalize_output >"$builddir/$name-o1.out"
    "$builddir/lumivm" "$builddir/$name-o2.lbc" <"$srcdir/$input" | normalize_output >"$builddir/$name-o2.out"
    "$builddir/lumivm" "$builddir/$name-o3.lbc" <"$srcdir/$input" | normalize_output >"$builddir/$name-o3.out"

    diff -u "$builddir/$name-o0.out" "$builddir/$name-o1.out"
    diff -u "$builddir/$name-o0.out" "$builddir/$name-o2.out"
    diff -u "$builddir/$name-o0.out" "$builddir/$name-o3.out"
}

check_equivalent optimizer-control tests/fixtures/optimization-semantics.lumi tests/inputs/optimization-semantics-input.txt
check_equivalent optimizer-rand tests/fixtures/optimization-rand-semantics.lumi tests/inputs/optimization-rand-semantics-input.txt
check_equivalent optimizer-ripple examples/example-ripple.lumi tests/inputs/optimization-ripple-input.txt
check_equivalent optimizer-aurora examples/example-aurora.lumi tests/inputs/optimization-aurora-input.txt
check_equivalent optimizer-meteors examples/example-meteors.lumi tests/inputs/optimization-meteors-input.txt
