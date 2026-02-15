create table wallets
(

    wallet_id uuid primary key default uuidv7(),

    -- owner user id (todo extend to multiple owner)
    owner_id   uuid not null references users (user_id) on delete cascade,

    -- name of the wallet, bank account, etc
    name text collate "case_insensitive" not null,

    -- "order" is a reserved keyword in SQL; naming it "sort_order" is safer
    -- This indicates the user's preferred wallet order
    sort_order integer not null default 0,

    -- colour for styling - HEX codes (e.g., #FFFFFF) are exactly 7 chars
    colour varchar(7) not null default '#7f8c8d',

    -- typically a string identifier for a library, a path, etc
    icon text,

    -- initial amount of the wallet, live amount is computed using transactions
    initial_amount numeric(19, 4) not null default 0.0000,

    -- CONSTRAINTS --
    -- ensure that different users can have wallets with the same name
    constraint unique_wallet_name_per_owner unique (owner_id, name),

    -- If you want to be really pedantic you can add a trigger that enforces this column will never change,
    -- but that seems like overkill for something that's relatively easy to enforce in code-review.
    created_at timestamptz not null default now(),

    updated_at timestamptz
);

-- And applying our `updated_at` trigger is as easy as this.
select trigger_updated_at('wallets');
