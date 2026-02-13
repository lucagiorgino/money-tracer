# Migration Source

From `sqlx` documentation:
```
a MigrationSource is a directory which contains the migration SQL scripts. All these scripts must be stored in files with names using the format <VERSION>_<DESCRIPTION>.sql, where <VERSION> is a string that can be parsed into i64 and its value is greater than zero, and <DESCRIPTION> is a string.

Files that don’t match this format are silently ignored.

You can create a new empty migration script using sqlx-cli: sqlx migrate add <DESCRIPTION>.

Note that migrations for each database are tracked using the _sqlx_migrations table (stored in the database). If a migration’s hash changes and it has already been run, this will cause an error.
```

`sqlx-cli` can be used to manage migrations
```bash
# supports all databases supported by SQLx
cargo install sqlx-cli

# Creates the database specified in DATABASE_URL and runs any pending migrations
sqlx database setup
```