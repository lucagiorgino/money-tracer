use anyhow::Context;
use clap::Parser;
use server::config::Config;
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    
    // This returns an error if the `.env` file doesn't exist
    dotenv::dotenv().ok();

    // Initialize the logger
    env_logger::init();

    // Parse the configuration from the environment
    // This will exit with a help message if something is wrong
    let config = Config::parse();

    // Create a connection pool, set the maximum number of connections
    let _pool = PgPoolOptions::new()
    .max_connections(config.database_max_connections)
    .connect(&config.database_url)
    .await
    .context("Could not connect to DATABASE_URL")?;



    Ok(())
}
