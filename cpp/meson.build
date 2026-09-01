project('diversinet-julia-bridge', 'cpp',
  version : '0.1.0',
  default_options : ['cpp_std=c++20', 'optimization=3'],
  license : 'GPL-3.0-or-later')

fs = import('fs')
cpp = meson.get_compiler('cpp')

core_root = get_option('core_root')
core_lib = get_option('core_lib')
core_include_dirs = get_option('core_include_dirs')
core_lib_dir = fs.parent(core_lib)
cxxwrap_prefix = get_option('cxxwrap_prefix')
julia_include = get_option('julia_include_dir')
cxxwrap_lib_dir = join_paths(cxxwrap_prefix, 'lib')

cxxwrap_dep = declare_dependency(
  include_directories : include_directories(
    join_paths(cxxwrap_prefix, 'include'),
    julia_include,
    join_paths(julia_include, 'julia')),
  dependencies : [
    cpp.find_library('cxxwrap_julia', dirs : cxxwrap_lib_dir),
  ])

boost_dep = dependency('boost', required : true)
core_dep = cpp.find_library('diversinet', dirs : core_lib_dir)
if core_include_dirs == '' and core_root == ''
  error('core_include_dirs or core_root must be supplied')
endif
core_inc_dirs = core_include_dirs == '' ? [join_paths(core_root, 'include')] : core_include_dirs.split(':')
core_inc = include_directories(core_inc_dirs)

shared_module(
  'jlDiversinetInterface',
  'jlDiversinetInterface.cpp',
  include_directories : core_inc,
  dependencies : [cxxwrap_dep, core_dep, boost_dep],
  name_prefix : 'lib',
  build_rpath : cxxwrap_lib_dir + ':' + core_lib_dir,
  install : true,
  install_dir : get_option('libdir'))
