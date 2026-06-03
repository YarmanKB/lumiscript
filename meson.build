project('lumiscript', 'c', version: '0.1.0', default_options: ['c_std=c11', 'warning_level=3'])

cc = meson.get_compiler('c')
libm = cc.find_library('m', required: true)

inc = include_directories('include')

liblumiscript = library(
  'lumiscript',
  [
    'src/bytecode.c',
    'src/compiler.c',
    'src/lexer.c',
    'src/parser.c',
    'src/vm.c',
  ],
  include_directories: inc,
  dependencies: libm,
  install: true,
)

lumiscript_dep = declare_dependency(
  include_directories: inc,
  link_with: liblumiscript,
)

executable(
  'lumic',
  'src/main.c',
  include_directories: inc,
  dependencies: lumiscript_dep,
  install: true,
)

executable(
  'lumivm',
  'src/vm_main.c',
  include_directories: inc,
  dependencies: lumiscript_dep,
  install: true,
)

executable(
  'lumils',
  'src/lsp_main.c',
  include_directories: [inc, include_directories('src')],
  dependencies: lumiscript_dep,
  install: true,
)

executable(
  'bytecode_assert_sections',
  'tests/bytecode_assert_sections.c',
  install: false,
)

src_root = meson.project_source_root()
build_root = meson.project_build_root()

compile_example = find_program('tests/compile_example.sh')
compile_fail = find_program('tests/compile_fail.sh')
compile_and_run_vm = find_program('tests/compile_and_run_vm.sh')

compile_cases = [
  ['static', 'examples/example-static.lumi', 'static.lbc'],
  ['animation', 'examples/example-animation.lumi', 'animation.lbc'],
  ['stateful', 'examples/example-stateful.lumi', 'stateful.lbc'],
  ['conditional', 'examples/example-conditional.lumi', 'conditional.lbc'],
  ['nested', 'examples/example-nested.lumi', 'nested.lbc'],
  ['math', 'examples/example-math.lumi', 'math.lbc'],
  ['array', 'tests/fixtures/example-array.lumi', 'array.lbc'],
  ['ripple', 'examples/example-ripple.lumi', 'ripple.lbc'],
  ['rand', 'tests/fixtures/example-rand.lumi', 'rand.lbc'],
  ['rounding', 'tests/fixtures/example-rounding.lumi', 'rounding.lbc'],
  ['aurora', 'examples/example-aurora.lumi', 'aurora.lbc'],
  ['meteors', 'examples/example-meteors.lumi', 'meteors.lbc'],
]

foreach case : compile_cases
  test(
    'compile-' + case[0] + '-example',
    compile_example,
    args: [src_root, build_root, case[1], case[2]],
  )
endforeach

test('lsp-smoke', find_program('tests/lsp_smoke.sh'), args: [build_root])

reject_cases = [
  ['assign-let', 'tests/fixtures/error-assign-let.lumi', 'can be reassigned'],
  ['unknown-symbol', 'tests/fixtures/error-unknown-symbol.lumi', 'unknown symbol'],
  ['missing-color', 'tests/fixtures/error-missing-color.lumi', 'render section must assign color on all control-flow paths'],
  ['render-missing-else-color', 'tests/fixtures/error-render-missing-else-color.lumi', 'render section must assign color on all control-flow paths'],
  ['if-expr-without-else', 'tests/fixtures/error-if-expr-no-else.lumi', 'if expression requires else branch'],
  ['dynamic-array-index', 'tests/fixtures/error-dynamic-array-index.lumi', 'array index'],
]

foreach case : reject_cases
  test(
    'reject-' + case[0],
    compile_fail,
    args: [src_root, build_root, case[1], case[2]],
  )
endforeach

test('compile-optimized-bytecode', find_program('tests/compile_optimization.sh'), args: [src_root, build_root])
test('optimization-semantics', find_program('tests/optimization_semantics.sh'), args: [src_root, build_root])

vm_cases = [
  ['static', 'examples/example-static.lumi', 'vm-static.lbc', 'tests/inputs/vm-static-input.txt', 'tests/expected/vm-static-expected.txt'],
  ['animation', 'examples/example-animation.lumi', 'vm-animation.lbc', 'tests/inputs/vm-animation-input.txt', 'tests/expected/vm-animation-expected.txt'],
  ['conditional', 'examples/example-conditional.lumi', 'vm-conditional.lbc', 'tests/inputs/vm-conditional-input.txt', 'tests/expected/vm-conditional-expected.txt'],
  ['stateful', 'examples/example-stateful.lumi', 'vm-stateful.lbc', 'tests/inputs/vm-stateful-input.txt', 'tests/expected/vm-stateful-expected.txt'],
  ['nested', 'examples/example-nested.lumi', 'vm-nested.lbc', 'tests/inputs/vm-nested-input.txt', 'tests/expected/vm-nested-expected.txt'],
  ['ripple', 'examples/example-ripple.lumi', 'vm-ripple.lbc', 'tests/inputs/vm-ripple-input.txt', 'tests/expected/vm-ripple-expected.txt'],
  ['aurora', 'examples/example-aurora.lumi', 'vm-aurora.lbc', 'tests/inputs/vm-aurora-input.txt', 'tests/expected/vm-aurora-expected.txt'],
  ['meteors', 'examples/example-meteors.lumi', 'vm-meteors.lbc', 'tests/inputs/vm-meteors-input.txt', 'tests/expected/vm-meteors-expected.txt'],
  ['branching', 'tests/fixtures/example-branching.lumi', 'vm-branching.lbc', 'tests/inputs/vm-branching-input.txt', 'tests/expected/vm-branching-expected.txt'],
  ['counter', 'examples/example-counter.lumi', 'vm-counter.lbc', 'tests/inputs/vm-counter-input.txt', 'tests/expected/vm-counter-expected.txt'],
  ['math', 'examples/example-math.lumi', 'vm-math.lbc', 'tests/inputs/vm-math-input.txt', 'tests/expected/vm-math-expected.txt'],
  ['array', 'tests/fixtures/example-array.lumi', 'vm-array.lbc', 'tests/inputs/vm-array-input.txt', 'tests/expected/vm-array-expected.txt'],
  ['rand', 'tests/fixtures/example-rand.lumi', 'vm-rand.lbc', 'tests/inputs/vm-rand-input.txt', 'tests/expected/vm-rand-expected.txt'],
  ['rounding', 'tests/fixtures/example-rounding.lumi', 'vm-rounding.lbc', 'tests/inputs/vm-rounding-input.txt', 'tests/expected/vm-rounding-expected.txt'],
]

foreach case : vm_cases
  test(
    'run-' + case[0] + '-vm',
    compile_and_run_vm,
    args: [src_root, build_root, case[1], case[2], case[3], case[4]],
  )
endforeach

test(
  'assert-static-bytecode-sections',
  find_program('tests/compile_and_assert_sections.sh'),
  args: [
    src_root,
    build_root,
    'examples/example-static.lumi',
    'static-sections.lbc',
    '1',
    '3',
    '0',
    '0',
    '3',
    '150,200,255',
    '-',
    '-',
    '26',
    '26',
    '1,0,0,1,1,0,1,2,0,22,4,3,25,26',
  ],
)

test(
  'reject-vm-small-stack',
  find_program('tests/run_vm_fail.sh'),
  args: [
    src_root,
    build_root,
    'tests/fixtures/example-branching.lumi',
    'vm-small-stack.lbc',
    '--stack-cap',
    '1',
    'capacity check failed: runtime stack too small',
  ],
)
