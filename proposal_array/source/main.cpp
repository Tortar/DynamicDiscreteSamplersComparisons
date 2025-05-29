
#include <iostream>
#include <random>
#include <vector>
#include <chrono>
#include <cmath>
#include <fstream>
#include <string>
#include "DynamicProposalArrayStar.hpp"

double median(std::vector<double> v) {
    if (v.empty()) throw std::domain_error("median of empty vector");
    std::sort(v.begin(), v.end());
    size_t n = v.size();
    if (n % 2 == 1) {
        // odd number of elements
        return v[n/2];
    } else {
        // even number of elements: average the two middle
        return 0.5 * (v[n/2 - 1] + v[n/2]);
    }
}

void append_column_in_place(const std::string& file_path, const std::vector<double>& vec) {
    std::ifstream fin(file_path);
    if (!fin.is_open()) {
        throw std::runtime_error("Could not open input file: " + file_path);
    }

    std::vector<std::string> lines;
    std::string line;

    // Read and modify header
    if (std::getline(fin, line)) {
        lines.push_back(line + ",PROPOSAL_ARRAY");
    } else {
        throw std::runtime_error("Empty input file: " + file_path);
    }

    // Read each row and append corresponding vector value
    size_t i = 0;
    while (std::getline(fin, line)) {
        if (i < vec.size()) {
            lines.push_back(line + ',' + std::to_string(vec[i]));
        } else {
            lines.push_back(line + ",");
        }
        ++i;
    }

    fin.close();

    if (i < vec.size()) {
        std::cerr << "Warning: vector has " << (vec.size() - i) << " extra elements\n";
    }

    // Now write everything back to the same file
    std::ofstream fout(file_path);
    if (!fout.is_open()) {
        throw std::runtime_error("Could not open output file: " + file_path);
    }

    for (const auto& l : lines) {
        fout << l << '\n';
    }
}

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
        if (index >= sampler.size_indices()){
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
    int repetitions = 50;

    std::vector<double> static_times;
    std::vector<double> dynamic_fixed_times;
    std::vector<double> dynamic_variable_times;

    for (int exp = 3; exp <= 7; ++exp) {
        size_t size = static_cast<size_t>(std::pow(10, exp));

        std::vector<double> static_ns;
        std::vector<double> dynamic_fixed_ns;
        std::vector<double> dynamic_variable_ns;

        if (exp == 6) {repetitions /= 10;}

        auto sampler1 = setup_sampler(size, rng);

        for (int rep = 1; rep <= repetitions; ++rep) {

            // Benchmark static sampling
            auto fixed_start = std::chrono::high_resolution_clock::now();
            auto fixed_samples = benchmark_sample_static(sampler1, rng, size);
            auto fixed_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> fixed_time = fixed_end - fixed_start;
            static_ns.push_back(fixed_time.count() / size);
        }

        auto sampler2 = setup_sampler(size, rng);

        for (int rep = 1; rep <= repetitions; ++rep) {

            // Benchmark dynamic fixed sampling
            auto variable_start = std::chrono::high_resolution_clock::now();
            auto variable_samples = benchmark_sample_dynamic_fixed(sampler2, rng, size);
            auto variable_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> variable_time = variable_end - variable_start;
            dynamic_fixed_ns.push_back(variable_time.count() / size);
        }
        
        auto sampler3 = setup_sampler(size, rng);

        for (int rep = 1; rep <= repetitions; ++rep) {
  
            // Benchmark dynamic variable sampling
            auto variable2_start = std::chrono::high_resolution_clock::now();
            auto variable2_samples = benchmark_sample_dynamic_variable(sampler3, rng, size);
            auto variable2_end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::nano> variable2_time = variable2_end - variable2_start;
            dynamic_variable_ns.push_back(variable2_time.count() / (9*size));
        }

        static_times.push_back(median(static_ns));
        dynamic_fixed_times.push_back(median(dynamic_fixed_ns));
        dynamic_variable_times.push_back(median(dynamic_variable_ns));

    }

    const std::string data_dir = "../../data/";

    try {
        append_column_in_place(data_dir + "static.csv", static_times);
        append_column_in_place(data_dir + "dynamic_fixed.csv", dynamic_fixed_times);
        append_column_in_place(data_dir + "dynamic_variable.csv", dynamic_variable_times);
        std::cout << "All three files written successfully.\n";
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }

    return 0;
}