// Compare SimpleNetworkModel direct operators against the sparse matrices.
//
// Build from /Users/mike/repos/Diversinet:
//   c++ -std=c++17 -O3 -I../phyloploid_lib/src -I/opt/homebrew/include \
//     -I/opt/homebrew/Cellar/eigen/3.4.0_1/include/eigen3 \
//     scratch/check_phyloploid_direct_ops.cpp \
//     -L../phyloploid_lib/builddir/src -ldiversinet \
//     -Wl,-rpath,../phyloploid_lib/builddir/src \
//     -o /tmp/check_phyloploid_direct_ops

#include <cmath>
#include <iomanip>
#include <iostream>
#include <string>

#include "Models/SimpleNetworkModel.h"
#include "Parameters/Container.h"

namespace {

double max_abs_diff(const Eigen::VectorXd& a, const Eigen::VectorXd& b) {
    return (a - b).cwiseAbs().maxCoeff();
}

void report(const std::string& name, const Eigen::VectorXd& sparse, const Eigen::VectorXd& direct) {
    const double diff = max_abs_diff(sparse, direct);
    std::cout << std::setw(32) << std::left << name
              << " max_abs_diff=" << std::setprecision(17) << diff << "\n";
    if (diff > 1e-12) {
        for (Eigen::Index i = 0; i < sparse.size(); ++i) {
            const double d = std::abs(sparse(i) - direct(i));
            if (d > 1e-12) {
                std::cout << "  first mismatch i=" << i
                          << " sparse=" << sparse(i)
                          << " direct=" << direct(i)
                          << " diff=" << d << "\n";
                break;
            }
        }
    }
}

void report_three(const std::string& name,
                  const Eigen::VectorXd& expected,
                  const Eigen::VectorXd& inplace,
                  const Eigen::VectorXd& direct) {
    std::cout << std::setw(32) << std::left << name
              << " inplace_diff=" << std::setprecision(17) << max_abs_diff(expected, inplace)
              << " direct_diff=" << max_abs_diff(expected, direct) << "\n";
    if (max_abs_diff(expected, inplace) > 1e-12) {
        for (Eigen::Index i = 0; i < expected.size(); ++i) {
            const double d = std::abs(expected(i) - inplace(i));
            if (d > 1e-12) {
                std::cout << "  first inplace mismatch i=" << i
                          << " expected=" << expected(i)
                          << " inplace=" << inplace(i)
                          << " diff=" << d << "\n";
                break;
            }
        }
    }
}

} // namespace

int main() {
    const size_t kmax = 32;
    Parameters::ContainerSharedPtr params(new Parameters::Container());
    params->lambda = 1.0;
    params->mu = 0.5;
    params->eta = 0.1;
    params->zeta = 0.1;
    params->nu = 0.1;
    params->psi = 0.1;
    params->rho = 1.0;

    Models::SimpleNetworkModel model(params, kmax);
    Eigen::VectorXd sparse(kmax);
    Eigen::VectorXd direct(kmax);
    Eigen::VectorXd inplace(kmax);

    for (size_t lineages = 1; lineages <= 128; ++lineages) {
        model.setNumberOfLineages(lineages);

        Eigen::VectorXd p(kmax);
        for (Eigen::Index i = 0; i < p.size(); ++i) {
            p(i) = 0.25 + 0.1 * static_cast<double>(i) + 0.03 * std::sin(static_cast<double>(i + lineages));
        }

        sparse = model.getTransitionRateMatrix(0.0) * p;
        model.computeTransitionRateAction(direct, p, 0.0);
        const double transition_diff = max_abs_diff(sparse, direct);
        if (transition_diff > 1e-10) {
            std::cout << "transition lineages=" << lineages << " diff=" << transition_diff << "\n";
        }
    }

    model.setNumberOfLineages(5);

    Eigen::VectorXd p(kmax);
    for (Eigen::Index i = 0; i < p.size(); ++i) {
        p(i) = 0.25 + 0.1 * static_cast<double>(i) + 0.03 * std::sin(static_cast<double>(i));
    }

    sparse = model.getTransitionRateMatrix(0.0) * p;
    model.computeTransitionRateAction(direct, p, 0.0);
    report("transition", sparse, direct);

    sparse = model.getSpeciationEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getSpeciationEventMatrix(0.0) * inplace;
    direct = p;
    model.applySpeciationEvent(direct, 0.0);
    report_three("speciation", sparse, inplace, direct);

    sparse = model.getDirectionalTriangleEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getDirectionalTriangleEventMatrix(0.0) * inplace;
    direct = p;
    model.applyDirectionalTriangleEvent(direct, 0.0);
    report_three("directional_triangle", sparse, inplace, direct);

    sparse = model.getBidirectionalTriangleEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getBidirectionalTriangleEventMatrix(0.0) * inplace;
    direct = p;
    model.applyBidirectionalTriangleEvent(direct, 0.0);
    report_three("bidirectional_triangle", sparse, inplace, direct);

    sparse = model.getNewHybridTriangleEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getNewHybridTriangleEventMatrix(0.0) * inplace;
    direct = p;
    model.applyNewHybridTriangleEvent(direct, 0.0);
    report_three("new_hybrid_triangle", sparse, inplace, direct);

    sparse = model.getHybridDiamondEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getHybridDiamondEventMatrix(0.0) * inplace;
    direct = p;
    model.applyHybridDiamondEvent(direct, 0.0);
    report_three("hybrid_diamond", sparse, inplace, direct);

    sparse = model.getPolyploidTriangleEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getPolyploidTriangleEventMatrix(0.0) * inplace;
    direct = p;
    model.applyPolyploidTriangleEvent(direct, 0.0);
    report_three("polyploid_triangle", sparse, inplace, direct);

    sparse = model.getNewPolyploidTriangleEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getNewPolyploidTriangleEventMatrix(0.0) * inplace;
    direct = p;
    model.applyNewPolyploidTriangleEvent(direct, 0.0);
    report_three("new_polyploid_triangle", sparse, inplace, direct);

    sparse = model.getPolyploidDiamondEventMatrix(0.0) * p;
    inplace = p;
    inplace = model.getPolyploidDiamondEventMatrix(0.0) * inplace;
    direct = p;
    model.applyPolyploidDiamondEvent(direct, 0.0);
    report_three("polyploid_diamond", sparse, inplace, direct);

    return 0;
}
