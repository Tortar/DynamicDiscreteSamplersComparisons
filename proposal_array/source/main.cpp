
#include <iostream>
#include <random>
#include <vector>
#include <chrono>
#include <cmath>
#include "DynamicProposalArrayStar.hpp"

// Setup function for the sampler
sampling::DynamicProposalArrayStar setup_sampler(size_t size, std::mt19937& rng) {
    std::normal_distribution<double> weight_dist(0.0, 1.0);
    std::vector<double> weights(size);

    // Randomly initialize weights
    for (size_t i = 0; i < size; ++i) {
        weights[i] = std::abs(weight_dist(rng));
    }

    return sampling::DynamicProposalArrayStar(weights);
}

// Fixed sampling benchmark
std::vector<size_t> benchmark_sample_static(sampling::DynamicProposalArrayStar& sampler, std::mt19937& rng, size_t n) {
    std::vector<size_t> samples;
    samples.reserve(n);

    for (size_t i = 0; i < n; ++i) {
        samples.push_back(sampler.sample(rng));
    }

    return samples;
}

// Variable sampling benchmark
std::vector<size_t> benchmark_sample_dynamic_fixed(sampling::DynamicProposalArrayStar& sampler, std::mt19937& rng, size_t n) {
    std::vector<size_t> samples;
    samples.reserve(n);

    std::uniform_int_distribution<size_t> index_dist(0, n - 1);
    std::normal_distribution<double> weight_dist(0.0, 1.0);

    for (size_t i = 0; i < n; ++i) {
        samples.push_back(sampler.sample(rng));
        size_t index = index_dist(rng);
        double new_weight = std::abs(weight_dist(rng));
        sampler.update(index, new_weight);
    }

    return samples;
}

std::vector<size_t> benchmark_sample_dynamic_variable(sampling::DynamicProposalArrayStar& sampler, std::mt19937& rng, size_t n) {
    std::vector<size_t> samples;
    samples.reserve(9*n);

    std::normal_distribution<double> weight_dist(0.0, 1.0);    

    for (size_t i = 0; i < 9*n; ++i) {
        samples.push_back(sampler.sample(rng));
        std::uniform_int_distribution<size_t> index_dist(0, i);
        size_t index = n+index_dist(rng);
        double new_weight = std::abs(weight_dist(rng));
        if (index > sampler.size_indices()){
            for (size_t j = sampler.size_indices(); j < index+1; ++j) {
                sampler.push_zero();
            }
        }
        sampler.update(index, new_weight);
    }

    return samples;
}

int main() {
    std::mt19937 rng(42);
    const int repetitions = 5;

    for (int exp = 3; exp <= 7; ++exp) {
        size_t size = static_cast<size_t>(std::pow(10, exp));

        double total_static_ns = 0;
        double total_dynamic_fixed_ns = 0;
        double total_dynamic_variable_ns = 0;

        for (int rep = 1; rep <= repetitions; ++rep) {

            auto sampler = setup_sampler(size, rng);

            // Benchmark static sampling
            auto fixed_start = std::chrono::high_resolution_clock::now();
            auto fixed_samples = benchmark_sample_static(sampler, rng, size);
            auto fixed_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> fixed_time = fixed_end - fixed_start;
            total_static_ns += fixed_time.count();

            auto sampler = setup_sampler(size, rng);

            // Benchmark dynamic fixed sampling
            auto variable_start = std::chrono::high_resolution_clock::now();
            auto variable_samples = benchmark_sample_dynamic_fixed(sampler, rng, size);
            auto variable_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> variable_time = variable_end - variable_start;
            total_dynamic_fixed_ns += variable_time.count();

            auto sampler = setup_sampler(size, rng);
            
            // Benchmark dynamic variable sampling
            auto variable2_start = std::chrono::high_resolution_clock::now();
            auto variable2_samples = benchmark_sample_dynamic_variable(sampler, rng, size);
            auto variable2_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> variable2_time = variable2_end - variable2_start;
            total_dynamic_variable_ns += variable2_time.count();
        }

        // Compute average times per element/sample
        double avg_static_per_sample = (total_static_ns / repetitions) / size;
        double avg_dynamic_fixed_per_sample = (total_dynamic_fixed_ns / repetitions) / size;
        double avg_dynamic_variable_per_sample = (total_dynamic_variable_ns / repetitions) / (9*size);

        std::cout << "Size: " << size
                  << ", Avg Static sampling: " << avg_static_per_sample << " ns/sample"
                  << ", Avg Dynamic Fixed sampling: " << avg_dynamic_fixed_per_sample << " ns/sample"
                  << ", Avg Dynamic Variable sampling: " << avg_dynamic_variable_per_sample << " ns/sample"
                  << std::endl;
    }

    return 0;
}