/// Application configuration parameters
///
/// Environment variables are the primary configuration source, facilitating 
/// secure deployment via Kubernetes Secrets. Command-line flags are also supported
///
/// For local development, the application can also load configuration from a `.env` 
/// file in the current working directory. Refer to `.env.sample` in the repository 
/// root for a template
#[derive(clap::Parser)]
pub struct Config {
    /// The connection URL for the Postgres database
    #[clap(long, env)]
    pub database_url: String,

    /// Number of the max connection for the Postgres database
    #[clap(long, env)]
    pub database_max_connections: u32
}