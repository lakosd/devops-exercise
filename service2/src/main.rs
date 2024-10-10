use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde_json::json;
use std::process::{Command, Stdio};
use std::str;

async fn get_system_info() -> impl Responder {
    let df = Command::new("df")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let awk = Command::new("awk")
        .arg("$6 == \"/\" {print $4}")
        .stdin(Stdio::from(df.stdout.unwrap()))
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let df_output = awk.wait_with_output().unwrap();
    let df_result = str::from_utf8(&df_output.stdout).unwrap().trim();
    
    let uptime = Command::new("uptime")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let sed = Command::new("sed")
        .arg("s/^ [^ ]* up \\([^,]*,[^,]*\\),.*/\\1/")
        .stdin(Stdio::from(uptime.stdout.unwrap()))
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let uptime_output = sed.wait_with_output().unwrap();
    let uptime_result = str::from_utf8(&uptime_output.stdout).unwrap().trim();

    let hostname = Command::new("hostname")
        .arg("-i")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let hostname_output = hostname.wait_with_output().unwrap();
    let hostname_result = str::from_utf8(&hostname_output.stdout).unwrap().trim();

    let ps = Command::new("ps")
        .arg("-ax")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let ps_output = ps.wait_with_output().unwrap();
    let ps_result = str::from_utf8(&ps_output.stdout).unwrap().trim();
    let ps_lines: Vec<String> = ps_result
        .split('\n')
        .map(|line| line.trim().to_string())
        .skip(1)
        .collect();

    let system_info = json!({
        "ip": hostname_result,
        "processes": ps_lines,
        "diskSpace": df_result,
        "uptime": uptime_result,
    });

    HttpResponse::Ok().json(system_info)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(get_system_info))
    })
    .bind(("0.0.0.0", 8198))?
    .run()
    .await
}

