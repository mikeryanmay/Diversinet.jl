project('diversinet-julia-bridge', 'cpp',
  version : '0.0.1',
  default_options : ['cpp_std=c++20', 'optimization=3'])

fs = import('fs')
cpp = meson.get_compiler('cpp')

core_root = get_option('core_root')
core_lib = get_option('core_lib')
core_include_dirs = get_option('core_include_dirs')
core_lib_dir = fs.parent(core_lib)
julia_project = get_option('julia_project')
julia = find_program(get_option('julia'), required : true)

cxxwrap_prefix_cmd = run_command(
  julia, '--startup-file=no', '--project=' + julia_project,
  '-e', 'import CxxWrap; print(CxxWrap.prefix_path())',
  check : true)
julia_include_cmd = run_command(
  julia, '--startup-file=no', '--project=' + julia_project,
  '-e', 'print(joinpath(Sys.BINDIR, Base.INCLUDEDIR))',
  check : true)

cxxwrap_prefix = cxxwrap_prefix_cmd.stdout().strip()
julia_include = julia_include_cmd.stdout().strip()
cxxwrap_lib_dir = join_paths(cxxwrap_prefix, 'lib')

cxxwrap_dep = declare_dependency(
  include_directories : include_directories(
    join_paths(cxxwrap_prefix, 'include'),
    julia_include,
    join_paths(julia_include, 'julia')),
  dependencies : [
    cpp.find_library('cxxwrap_julia', dirs : cxxwrap_lib_dir),
  ])

core_dep = cpp.find_library('diversinet', dirs : core_lib_dir)
core_inc_dirs = core_include_dirs == '' ? [
  join_paths(core_root, 'api'),
  join_paths(core_root, 'src')
] : core_include_dirs.split(':')
core_inc = include_directories(core_inc_dirs)

shared_module(
  'jlDiversinetInterface',
  'jlDiversinetInterface.cpp',
  include_directories : core_inc,
  dependencies : [cxxwrap_dep, core_dep],
  name_prefix : 'lib',
  build_rpath : cxxwrap_lib_dir + ':' + core_lib_dir,
  install : false)
