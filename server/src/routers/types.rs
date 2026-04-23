use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[derive(sqlx::Type)]
#[sqlx(type_name = "transaction_type", rename_all = "lowercase")]
pub enum TransactionType {
    Income,
    Expense,
    Transfer,
    Correction,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[derive(sqlx::Type)]
#[sqlx(type_name = "reoccurrence_type", rename_all = "lowercase")]
pub enum ReoccurrenceType {
    None,
    Daily,
    Weekly,
    Monthly,
    Yearly,
}


#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Transaction {
    pub transaction_id: Uuid,
    pub user_id: Uuid,
    pub description: Option<String>,
    
    // numeric maps best to rust_decimal::Decimal
    pub amount: Decimal,
    pub date: DateTime<Utc>,

    // 'type' is a reserved keyword in Rust
    pub transaaction_type: TransactionType,
    pub reoccurrence: ReoccurrenceType,
    pub transfer_key: Option<Uuid>,
    
    pub wallet_id: Uuid,
    pub to_wallet_id: Option<Uuid>,
    
    pub main_category_id: Uuid,
    pub sub_category_id: Option<Uuid>,
    
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct Category {
    pub category_id: Uuid,
    pub name: String,
    pub colour: String,
    pub icon: Option<String>,
    
    pub built_in: bool,
    pub is_main: bool,
    
    // Foreign key to the users table
    pub owner_id: Uuid,
    
    // Self-referencing ID. None if it's a main category.
    pub parent_id: Option<Uuid>,
    
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct Wallet {
    pub wallet_id: Uuid,
    
    // Foreign key to the users table
    pub owner_id: Uuid,
    
    // Case-insensitive name in DB maps to standard String
    pub name: String,
    
    pub sort_order: i32,
    
    // HEX code (e.g., "#FFFFFF")
    pub colour: String,
    
    pub icon: Option<String>,
    
    // numeric maps best to rust_decimal::Decimal
    pub initial_amount: Decimal,
    
    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct User {
    pub user_id: Uuid,

    // The external identifier from Keycloak
    pub keycloak_id: String,

    pub created_at: DateTime<Utc>,
    pub updated_at: Option<DateTime<Utc>>,
}