# Diversinet

[![Build Status](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mikeryanmay/Diversinet.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia interface for the Diversinet native C++ library.

## Installation

Diversinet currently supports Julia 1.12 on x86-64 and ARM64 Linux and macOS.
Add the public prerelease registry once, then install Diversinet by name:

```julia
import Pkg
Pkg.Registry.add("General")
Pkg.Registry.add(
    Pkg.RegistrySpec(
        url="https://github.com/mikeryanmay/DiversinetRegistry.git",
    ),
)
Pkg.add("Diversinet")
```

No compiler, Meson installation, Boost installation, Eigen installation, or
C++ source checkout is required. `using Diversinet` downloads the appropriate
prebuilt artifact through `Diversinet_jll`.

Verify the installation with a likelihood calculation:

```julia
using Diversinet

network = "((A:0.5,B:0.5):0.25,C:0.75):0.25;"
Diversinet.computeLogLikelihood(
    network;
    λ=0.5,
    μ=0.1,
    ρ=0.5,
    kmax=16,
)
```

The expected value is approximately `-3.7565154492458603`.

For a self-contained alternative that requires Docker but no local Julia
installation, see
[DiversinetDocker](https://github.com/mikeryanmay/DiversinetDocker).

## Simulation

```julia
using Diversinet

networks = Diversinet.simulate(
    1.0,
    10;
    λ=1.0,
    condition=Diversinet.Tree,
    root=true,
)
```

## Development

Add the prerelease registry so Julia can resolve `Diversinet_jll`, then
instantiate and test this checkout:

```sh
julia --startup-file=no --project=. -e 'import Pkg; Pkg.Registry.add("General"); Pkg.Registry.add(url="https://github.com/mikeryanmay/DiversinetRegistry.git"); Pkg.instantiate(); Pkg.test()'
```

Native C++ and bridge development is separate from ordinary package
installation. Make core changes in the
[Diversinet](https://github.com/mikeryanmay/Diversinet) repository and bridge
changes in `cpp/jlDiversinetInterface.cpp`, then rebuild both libraries with
[DiversinetJLLBuilder](https://github.com/mikeryanmay/DiversinetJLLBuilder).
The generated `Diversinet_jll` supplies both `libdiversinet` and
`libjlDiversinetInterface`; this package does not compile native code during
installation.

## License

Diversinet.jl is licensed under the GNU General Public License, version 3 or,
at your option, any later version (`GPL-3.0-or-later`). See
[LICENSE](LICENSE).
