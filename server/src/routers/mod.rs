use anyhow::Context;
use axum::{Router, routing::get};
use sqlx::PgPool;

use crate::config::Config;

/// Defines the types used accross the whole project.
mod types;

/// Defines a common error type to use for all request handlers, compliant with the Realworld spec.
mod error;


pub async fn serve(config: Config, db: PgPool) -> anyhow::Result<()> {

    // build our application with a route
    let app = Router::new().route("/", get(|| async { "Hello, World!" }));

    
    let listener = tokio::net::TcpListener::bind(format!("{}:{}", config.server_host, config.server_port))
        .await
        .unwrap();
    log::info!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app)
    .await
    .context("Error running axum server")

}

