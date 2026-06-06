# Diversinet

[![Build Status](https://github.com/self/Divesinet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/self/Divesinet.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia interface for the Diversinet native C++ library.

## Local Development Install

This package currently depends on a local, unregistered `Diversinet_jll`
package. Until `Diversinet_jll` is registered, every downstream Julia
environment that uses this local checkout must know where that JLL package
lives.

The expected local repo layout is:

```text
~/repos/Diversinet          # this Julia package
~/repos/Diversinet_jll      # BinaryBuilder recipe workspace
~/repos/DiversinetSims      # optional downstream simulation project
```

### 1. Build Or Regenerate `Diversinet_jll`

If the generated local JLL package does not already exist at
`~/.julia/dev/Diversinet_jll`, generate it from the recipe workspace:

```sh
cd ~/repos/Diversinet_jll
BINARYBUILDER_AUTOMATIC_APPLE=true julia --project=. build_tarballs.jl --verbose
BINARYBUILDER_AUTOMATIC_APPLE=true julia --project=. build_tarballs.jl --deploy-jll=local --skip-build
```

Check that the generated JLL loads:

```sh
julia --startup-file=no --project=~/.julia/dev/Diversinet_jll -e 'import Pkg; Pkg.instantiate(); using Libdl, Diversinet_jll; h = Libdl.dlopen(Diversinet_jll.libdiversinet); println(h != C_NULL); Libdl.dlclose(h)'
```

### 2. Build This Package

Develop the local JLL into this package, resolve the environment, and build the
CxxWrap bridge:

```sh
cd ~/repos/Diversinet
julia --startup-file=no --project=. -e 'import Pkg; Pkg.develop(path=joinpath(homedir(), ".julia/dev/Diversinet_jll")); Pkg.resolve(); Pkg.instantiate(); Pkg.build("Diversinet")'
```

Verify that `Diversinet` loads:

```sh
julia --startup-file=no --project=. -e 'using Diversinet; println("ok")'
```

By default, the build uses `Diversinet_jll.libdiversinet`. No
`DIVERSINET_CPP_ROOT` or `DIVERSINET_CORE_LIB` setting is needed for ordinary
local use.

### 3. Use From Another Local Project

For a downstream project such as `DiversinetSims`, develop both local packages
into that project environment:

```sh
cd ~/repos/DiversinetSims
julia --startup-file=no --project=. -e 'import Pkg; Pkg.develop(path=joinpath(homedir(), "repos/Diversinet")); Pkg.develop(path=joinpath(homedir(), ".julia/dev/Diversinet_jll")); Pkg.resolve(); Pkg.instantiate()'
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

### Local C++ Library Override

For active C++ development in `phyloploid_lib`, build against that checkout
instead of the JLL:

```sh
cd ~/repos/phyloploid_lib
meson setup builddir .
meson compile -C builddir

cd ~/repos/Diversinet
DIVERSINET_CPP_ROOT=~/repos/phyloploid_lib julia --startup-file=no --project=. -e 'import Pkg; Pkg.build("Diversinet")'
```

Use this override only when testing local C++ changes. For normal work, leave
`DIVERSINET_CPP_ROOT` and `DIVERSINET_CORE_LIB` unset.
