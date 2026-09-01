// Lightweight baseline benchmark for Diversinet's current likelihood path.
//
// Build from /Users/mike/repos/Diversinet.jl:
//   c++ -std=c++17 -O3 -I../Diversinet/include \
//     -I/opt/homebrew/include -I/opt/homebrew/Cellar/eigen/3.4.0_1/include/eigen3 \
//     scratch/bench_diversinet_current.cpp \
//     -L../Diversinet/builddir/src -ldiversinet \
//     -Wl,-rpath,../Diversinet/builddir/src \
//     -o /tmp/bench_diversinet_current
//
// Run:
//   /tmp/bench_diversinet_current ../Diversinet/scratch/tree1.tre 100 128
//
// Optional args:
//   tree reps kmax lambda mu eta zeta nu psi rho warmups integration_scheme

#include <chrono>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>

#include <Diversinet/DiversinetInterface.h>

namespace {

double parse_double(const char* s) {
    return std::strtod(s, nullptr);
}

size_t parse_size(const char* s) {
    return static_cast<size_t>(std::strtoull(s, nullptr, 10));
}

std::string read_first_line(const std::string& path) {
    std::ifstream in(path);
    if (!in) {
        throw std::runtime_error("Could not open tree file: " + path);
    }

    std::string line;
    std::getline(in, line);
    return line;
}

} // namespace

int main(int argc, char** argv) {
    try {
        const std::string tree_path = argc > 1 ? argv[1] : "../Diversinet/scratch/tree1.tre";
        const size_t reps = argc > 2 ? parse_size(argv[2]) : 100;
        const size_t kmax = argc > 3 ? parse_size(argv[3]) : 128;

        const double lambda = argc > 4 ? parse_double(argv[4]) : 1.0;
        const double mu     = argc > 5 ? parse_double(argv[5]) : 0.5;
        const double eta    = argc > 6 ? parse_double(argv[6]) : 0.0;
        const double zeta   = argc > 7 ? parse_double(argv[7]) : 0.1;
        const double nu     = argc > 8 ? parse_double(argv[8]) : 0.0;
        const double psi    = argc > 9 ? parse_double(argv[9]) : 0.0;
        const double rho    = argc > 10 ? parse_double(argv[10]) : 1.0;
        const size_t warmups = argc > 11 ? parse_size(argv[11]) : 3;
        const bool has_integration_scheme = argc > 12;
        const int integration_scheme = has_integration_scheme ? static_cast<int>(parse_size(argv[12])) : -1;

        Diversinet::Interface::DiversinetInterface interface;
        if (has_integration_scheme) {
            interface.setIntegrationScheme(integration_scheme);
        }
        interface.setLambda(lambda);
        interface.setMu(mu);
        interface.setEta(eta);
        interface.setZeta(zeta);
        interface.setNu(nu);
        interface.setPsi(psi);
        interface.setRho(rho);
        interface.setKMax(kmax);
        interface.readNewick(read_first_line(tree_path));

        double log_likelihood = 0.0;
        for (size_t i = 0; i < warmups; ++i) {
            log_likelihood = interface.computeLogLikelihood();
        }

        const auto start = std::chrono::steady_clock::now();
        for (size_t i = 0; i < reps; ++i) {
            log_likelihood = interface.computeLogLikelihood();
        }
        const auto stop = std::chrono::steady_clock::now();

        const double seconds = std::chrono::duration<double>(stop - start).count();
        const double ms_per_eval = 1000.0 * seconds / static_cast<double>(reps);

        std::cout << std::setprecision(17);
        std::cout << "tree\t" << tree_path << "\n";
        std::cout << "reps\t" << reps << "\n";
        std::cout << "warmups\t" << warmups << "\n";
        std::cout << "integration_scheme\t" << (has_integration_scheme ? std::to_string(integration_scheme) : "default") << "\n";
        std::cout << "kmax\t" << kmax << "\n";
        std::cout << "log_likelihood\t" << log_likelihood << "\n";
        std::cout << "seconds\t" << seconds << "\n";
        std::cout << "ms_per_eval\t" << ms_per_eval << "\n";
        std::cout << "evals_per_second\t" << static_cast<double>(reps) / seconds << "\n";
    } catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << "\n";
        return 1;
    }

    return 0;
}
