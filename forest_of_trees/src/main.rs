use dynamic_weighted_index::DynamicWeightedIndex;
use rand::Rng;
use rand::SeedableRng;
use pcg_rand::Pcg64;
use rand_distr::{StandardNormal, Distribution};
use std::{
    hint::black_box,
    time::Instant,
};
use std::path::Path;

fn setup(rng: &mut Pcg64, size: usize) -> DynamicWeightedIndex<f64> {
    let mut dw_index = DynamicWeightedIndex::new(size);
    for i in 0..size {
        let weight: f64 = StandardNormal.sample(rng);
        let abs_weight = weight.abs();
        dw_index.set_weight(i, abs_weight);
    }
    dw_index
}

fn sample_fixed(
    rng: &mut Pcg64,
    dw_index: &DynamicWeightedIndex<f64>,
    n: usize,
) -> Vec<usize> {
    let mut samples = Vec::with_capacity(n);
    for _ in 0..n {
        samples.push(dw_index.sample(rng).unwrap());
    }
    samples
}

fn sample_variable(
    rng: &mut Pcg64,
    dw_index: &mut DynamicWeightedIndex<f64>,
    n: usize,
) -> Vec<usize> {
    let mut samples = Vec::with_capacity(n);
    for _ in 0..n {
        samples.push(dw_index.sample(rng).unwrap());
        let index_to_modify = rng.gen_range(0..n);
        dw_index.remove_weight(index_to_modify);
        let new_weight: f64 = StandardNormal.sample(rng);
        let abs_new_weight = new_weight.abs();
        dw_index.set_weight(index_to_modify, abs_new_weight);
    }
    samples
}

use std::error::Error;
use csv::{ReaderBuilder, StringRecord, WriterBuilder};

/// Read `path` into memory, append `column_name` with one entry per row from `values`,
/// and atomically rewrite the original CSV.
fn append_column_to_csv(
    path: &Path,
    column_name: &str,
    values: &[f64],
) -> Result<(), Box<dyn Error>> {
    // 1) Read existing CSV
    let mut rdr = ReaderBuilder::new()
        .has_headers(true)
        .from_path(path)?;
    let headers = rdr.headers()?.clone();
    let mut records: Vec<StringRecord> = rdr
        .records()
        .enumerate()
        .map(|(i, r)| {
            let mut rec = r?;
            if i >= values.len() {
                Err("CSV has more rows than values provided")?
            }
            Ok(rec)
        })
        .collect::<Result<_, Box<dyn Error>>>()?;

    // 2) Prepare a new temporary writer
    let tmp_path = path.with_extension("tmp");
    let mut wtr = WriterBuilder::new()
        .has_headers(true)
        .from_path(&tmp_path)?;

    // 3) Write out headers + new column name
    let mut new_headers = headers.clone();
    new_headers.push_field(column_name);
    wtr.write_record(&new_headers)?;

    // 4) Write each record with the appended value
    for (i, mut rec) in records.into_iter().enumerate() {
        let val = values
            .get(i)
            .ok_or("Not enough values to fill all rows")?
            .to_string();
        rec.push_field(&val);
        wtr.write_record(&rec)?;
    }
    wtr.flush()?;

    // 5) Atomically replace the original file
    std::fs::rename(tmp_path, path)?;
    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let mut rng = Pcg64::seed_from_u64(42);
    let sample_sizes: Vec<usize> = (3..=7).map(|i| 10usize.pow(i)).collect();
    let mut repetitions = 50;

    // --- 1) static (fixed) sampling ---
    let mut static_medians = Vec::with_capacity(sample_sizes.len());
    for &size in &sample_sizes {
        if size > 100000 {repetitions = 5;}
        let dw_index = setup(&mut rng, size);
        let mut times: Vec<u128> = Vec::with_capacity(repetitions);
        for _ in 0..repetitions {
            let idx = black_box(&dw_index);
            let n   = black_box(size);
            let start = Instant::now();
            sample_fixed(&mut rng, idx, n);
            times.push(start.elapsed().as_nanos());
        }
        times.sort();
        let median_ns = if repetitions % 2 == 0 {
            (times[repetitions / 2 - 1] + times[repetitions / 2]) / 2
        } else {
            times[repetitions / 2]
        };
        let median_per_sample = median_ns as f64 / size as f64;
        println!(
            "Size: {:>8}, Fixed ({} reps): {:.2} ns/sample (median)",
            size, repetitions, median_per_sample
        );
        static_medians.push(median_per_sample);
    }

    // write static_medians out
    let manifest_dir = Path::new(env!("CARGO_MANIFEST_DIR"));
    let static_csv = manifest_dir
        .parent().unwrap()
        .join("data")
        .join("static.csv");
    append_column_to_csv(&static_csv, "FOREST_OF_TREES", &static_medians)
        .expect("Failed to append FOREST_OF_TREES to static.csv");

    repetitions = 50;

    // --- 2) variable sampling ---
    let mut variable_medians = Vec::with_capacity(sample_sizes.len());
    for &size in &sample_sizes {

        if size > 100000 {repetitions = 5;}
        let mut times: Vec<u128> = Vec::with_capacity(repetitions);
        for _ in 0..repetitions {
            let mut dw_index = setup(&mut rng, size);
            let idx = black_box(&mut dw_index);
            let n   = black_box(size);
            let start = Instant::now();
            sample_variable(&mut rng, idx, n);
            times.push(start.elapsed().as_nanos());
        }
        times.sort();
        let median_ns = if repetitions % 2 == 0 {
            (times[repetitions / 2 - 1] + times[repetitions / 2]) / 2
        } else {
            times[repetitions / 2]
        };
        let median_per_sample = median_ns as f64 / size as f64;
        println!(
            "Size: {:>8}, Variable ({} reps): {:.2} ns/sample (median)",
            size, repetitions, median_per_sample
        );
        variable_medians.push(median_per_sample);
    }

    // write variable_medians out
    let variable_csv = manifest_dir
        .parent().unwrap()
        .join("data")
        .join("dynamic_fixed.csv");
    append_column_to_csv(&variable_csv, "FOREST_OF_TREES", &variable_medians)
        .expect("Failed to append FOREST_OF_TREES to dynamic_fixed.csv");

    Ok(())
}

