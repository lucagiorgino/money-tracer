-- Enums are more efficient than strings for fixed options
create type transaction_type as enum ('income', 'expense', 'transfer');
create type reoccurrence_type as enum ('none', 'daily', 'weekly', 'monthly', 'yearly');

create table transactions
(

    transaction_id uuid primary key default uuidv7(),

    -- owner user id (to extend to multiple owner)
    user_id   uuid not null references users (user_id) on delete cascade,

    -- description: using collation for better searching
    description text collate case_insensitive,

    -- amount of the transaction
    amount numeric(19, 4) not null,

    -- date of the transaction: TIMESTAMPTZ stores UTC and handles timezone offsets
    date timestamptz not null default now(),

    -- uses the types we created above
    -- type of the transaction ('income', 'expense', 'transfer')
    type transaction_type not null,

    -- uses the types we created above
    -- reoccurrence of the transaction ('none', 'daily', 'weekly', 'monthly', 'yearly')
    reoccurrence reoccurrence_type not null default 'none',

    -- Links two transactions together (double-entry solution)
    transfer_key uuid, 

    -- FOREIGN KEYS --

    -- id of the wallet from which the transaction is generated
    wallet_id uuid not null references wallets(wallet_id),

    -- id of the receiving wallet - only used if type is 'transfer'
    to_wallet_id uuid references wallets(wallet_id),

    -- main category of the transfer
    main_category_id uuid not null references categories(category_id),
    
    -- second category of the transfer (optional, may be null)
    sub_category_id uuid references categories(category_id), 

    -- If you want to be really pedantic you can add a trigger that enforces this column will never change,
    -- but that seems like overkill for something that's relatively easy to enforce in code-review.
    created_at timestamptz not null default now(),

    updated_at timestamptz,

    -- CONSTRAINTS --
    
    -- 1. Ensure Transfer Logic: If it's a transfer, we MUST have a destination.
    -- If it's not, we MUST NOT have a destination.
    constraint valid_transfer_target check (
        (type = 'transfer' and to_wallet_id is not null) or 
        (type <> 'transfer' and to_wallet_id is null)
    ),

    -- 2. Prevent "Self-Transfers": You can't transfer from a wallet to itself.
    constraint no_self_transfer check (
        wallet_id <> to_wallet_id
    ),

    -- 3. Sanity Check: Amount should probably not be zero
    constraint non_zero_amount check (amount <> 0)
);

-- And applying our `updated_at` trigger is as easy as this.
select trigger_updated_at('transactions');

create or replace function fn_enforce_transaction_category_relation()
returns trigger as $$
begin
    -- only perform the check if a sub-category is actually provided
    if new.sub_category_id is not null then
        if not exists (
            select 1 from categories 
            where category_id = new.sub_category_id 
            and parent_id = new.main_category_id
            and is_main = false
        ) then
            raise exception 'invalid category relation: sub_category_id % is not a child of main_category_id %', 
                new.sub_category_id, new.main_category_id;
        end if;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger trg_validate_transaction_categories
    before insert or update on transactions
    for each row
    execute function fn_enforce_transaction_category_relation();