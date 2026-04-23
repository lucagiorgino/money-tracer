use anyhow::Context;
use clap::Parser;
use server::config::Config;
use sqlx::postgres::PgPoolOptions;
use server::routers;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    
    // This returns an error if the `.env` file doesn't exist
    dotenv::dotenv().ok();

    // Initialize the logger
    env_logger::init();

    // Parse the configuration from the environment
    // This will exit with a help message if something is wrong
    let config = Config::parse();

    log::info!("Starting server with configuration: {:?}", config);

    // Create a connection pool shared across the whole application
    // set the maximum number of connections
    let db  = PgPoolOptions::new()
    .max_connections(config.database_max_connections)
    .connect(&config.database_url)
    .await
    .context("Could not connect to DATABASE_URL")?;

    log::info!("Successfully connected to the database");


    // This embeds database migrations in the application binary so we can ensure the database
    // is migrated correctly on startup
    sqlx::migrate!().run(&db).await?;

    // Start web server
    log::info!("Starting web server on {}:{}", config.server_host, config.server_port);
    routers::serve(config, db).await?;

    Ok(())
}
