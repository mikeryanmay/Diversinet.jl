# Diversinet

[![Build Status](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia interface for the Diversinet native C++ library.

## Installation before DiversinetRegistry is available

Diversinet currently supports Julia 1.12 on x86-64 and ARM64 Linux and macOS.
Until the custom registry is published, install the released binary wrapper
and this package directly from GitHub:

```julia
import Pkg
Pkg.add(url="https://github.com/mikeryanmay/Diversinet_jll.git",
        rev="Diversinet-v0.1.0+1")
Pkg.add(url="https://github.com/mikeryanmay/Diversinet.jl.git")
```

No compiler, Meson installation, Boost installation, Eigen installation, or
C++ source checkout is required. `using Diversinet` downloads the appropriate
prebuilt artifact through `Diversinet_jll`.

Verify the installation with:

```sh
julia --startup-file=no -e 'using Diversinet; println("Diversinet loaded")'
```

## Installation from DiversinetRegistry

Once DiversinetRegistry is published, installation will be:

```julia
import Pkg
Pkg.Registry.add(url="https://github.com/mikeryanmay/DiversinetRegistry.git")
Pkg.add("Diversinet")
```

## Local Julia development

Because `Diversinet_jll` is not registered yet, add its release before
developing this checkout:

```sh
cd ~/repos/Diversinet.jl
julia --startup-file=no --project=. -e 'import Pkg; Pkg.add(Pkg.PackageSpec(url="https://github.com/mikeryanmay/Diversinet_jll.git", rev="Diversinet-v0.1.0+1")); Pkg.instantiate(); Pkg.test()'
```

Native C++ and bridge development is intentionally separate from ordinary
package installation. Make native changes in `Diversinet` and
`cpp/jlDiversinetInterface.cpp`, then rebuild the artifacts with
`DiversinetJLLBuilder`. This keeps developer toolchain requirements out of the
user installation path. The old `DIVERSINET_CPP_ROOT`, `DIVERSINET_CORE_LIB`,
and `DIVERSINET_CORE_INCLUDE_DIRS` installation variables are no longer used.

## License

Diversinet.jl is licensed under the GNU General Public License, version 3 or,
at your option, any later version (`GPL-3.0-or-later`). See
[LICENSE](LICENSE).
