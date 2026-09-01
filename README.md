# Diversinet

[![Build Status](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia interface for the Diversinet native C++ library.

## Local Development Install

The expected local repo layout is:

```text
~/repos/Diversinet.jl       # this Julia package
~/repos/Diversinet          # C++ core library checkout
~/repos/DiversinetSims      # optional downstream simulation project
```

### 1. Build The C++ Core Library

```sh
cd ~/repos/Diversinet
meson setup builddir .
meson compile -C builddir
```

This should produce:

- macOS: `builddir/src/libdiversinet.dylib`
- Linux: `builddir/src/libdiversinet.so`

### 2. Build This Julia Package

Build the Julia package by pointing it at the C++ checkout:

```sh
cd ~/repos/Diversinet.jl
DIVERSINET_CPP_ROOT=~/repos/Diversinet \
julia --startup-file=no --project=. -e 'import Pkg; Pkg.resolve(); Pkg.instantiate(; allow_autoprecomp=false); Pkg.build("Diversinet"); Pkg.precompile()'
```

Verify that `Diversinet` loads:

```sh
julia --startup-file=no --project=. -e 'using Diversinet; println("ok")'
```

`DIVERSINET_CPP_ROOT` is only needed when building the native bridge. Once
`deps/deps.jl` has been generated, normal `using Diversinet` calls use the
recorded bridge library path.

If you only want to provide the compiled core library directly, also provide
the C++ include directories:

```sh
cd ~/repos/Diversinet.jl
DIVERSINET_CORE_LIB=~/repos/Diversinet/builddir/src/libdiversinet.dylib \
DIVERSINET_CORE_INCLUDE_DIRS=~/repos/Diversinet/include \
julia --startup-file=no --project=. -e 'import Pkg; Pkg.build("Diversinet"); Pkg.precompile()'
```

On Linux, use `libdiversinet.so` instead of `libdiversinet.dylib`.

### 3. Use From Another Local Project

For a downstream project such as `DiversinetSims`, develop this local package
into that project environment:

```sh
cd ~/repos/DiversinetSims
julia --startup-file=no --project=. -e 'import Pkg; Pkg.develop(path=joinpath(homedir(), "repos/Diversinet.jl")); Pkg.resolve(); Pkg.instantiate()'
```

Then run downstream scripts with the top-level downstream project active:

```sh
cd ~/repos/DiversinetSims/analyses/simulation_study
julia --project=../.. analysis/template.jl
```

or set the project once in the shell:

```sh
export JULIA_PROJECT=~/repos/DiversinetSims
```

## Binary Package Direction

The local source workflow above intentionally does not require
`Diversinet_jll`. Once `Diversinet_jll` is registered, this package can add it
as the default binary dependency for ordinary `Pkg.add` installs, while keeping
`DIVERSINET_CPP_ROOT` and `DIVERSINET_CORE_LIB` as explicit source-build
overrides.

## License

Diversinet.jl is licensed under the GNU General Public License, version 3 or,
at your option, any later version (`GPL-3.0-or-later`). See
[LICENSE](LICENSE).
