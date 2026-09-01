#include <Diversinet/DiversinetInterface.h>

#include "jlcxx/jlcxx.hpp"
#include "jlcxx/stl.hpp"

JLCXX_MODULE define_julia_module(jlcxx::Module& mod)
{
    using Diversinet::Interface::DiversinetInterface;

    mod.add_bits<Diversinet::Interface::conditionalProbability_t>(
        "Diversinet!Interface!conditionalProbability_t", jlcxx::julia_type("CppEnum"));
    mod.set_const("Diversinet!Interface!TIME", Diversinet::Interface::TIME);
    mod.set_const("Diversinet!Interface!ROOT_SURVIVAL", Diversinet::Interface::ROOT_SURVIVAL);
    mod.set_const("Diversinet!Interface!ROOT_MRCA", Diversinet::Interface::ROOT_MRCA);
    mod.set_const("Diversinet!Interface!STEM_SURVIVAL", Diversinet::Interface::STEM_SURVIVAL);
    mod.set_const("Diversinet!Interface!STEM_TWO_SAMPLES", Diversinet::Interface::STEM_TWO_SAMPLES);

    mod.add_bits<Diversinet::Interface::integrationScheme_t>(
        "Diversinet!Interface!integrationScheme_t", jlcxx::julia_type("CppEnum"));
    mod.set_const("Diversinet!Interface!EULER", Diversinet::Interface::EULER);
    mod.set_const("Diversinet!Interface!RUNGE_KUTTA4", Diversinet::Interface::RUNGE_KUTTA4);
    mod.set_const("Diversinet!Interface!RUNGE_KUTTA54", Diversinet::Interface::RUNGE_KUTTA54);
    mod.set_const("Diversinet!Interface!RUNGE_KUTTA_DOPRI5", Diversinet::Interface::RUNGE_KUTTA_DOPRI5);
    mod.set_const("Diversinet!Interface!EXPONENTIAL", Diversinet::Interface::EXPONENTIAL);
    mod.set_const("Diversinet!Interface!UNIFORMIZATION", Diversinet::Interface::UNIFORMIZATION);

    mod.add_type<DiversinetInterface>("Diversinet!Interface!DiversinetInterface")
        .constructor<>()
        .method("setLambda", &DiversinetInterface::setLambda)
        .method("setMu", &DiversinetInterface::setMu)
        .method("setEta", &DiversinetInterface::setEta)
        .method("setZeta", &DiversinetInterface::setZeta)
        .method("setNu", &DiversinetInterface::setNu)
        .method("setPsi", &DiversinetInterface::setPsi)
        .method("setRho", &DiversinetInterface::setRho)
        .method("setKMaxInt", &DiversinetInterface::setKMaxInt)
        .method("setIntegrationScheme", &DiversinetInterface::setIntegrationScheme)
        .method("setConditionalProbabilityType", &DiversinetInterface::setConditionalProbabilityType)
        .method("computeLogLikelihood", &DiversinetInterface::computeLogLikelihood)
        .method("simulate",
            static_cast<std::string (DiversinetInterface::*)(
                double, std::string, int, bool, int, bool)>(&DiversinetInterface::simulate))
        .method("simulate_many",
            static_cast<std::vector<std::string> (DiversinetInterface::*)(
                double, std::string, size_t, int, bool, int, bool)>(&DiversinetInterface::simulate))
        .method("readNewick", &DiversinetInterface::readNewick)
        .method("jitterNewick", &DiversinetInterface::jitterNewick);
}
