create table categories (

    category_id uuid primary key default uuidv7(),
        
    -- name of the category with our custom collation
    name text not null collate case_insensitive,
    
    -- colour for styling - HEX codes (e.g., #FFFFFF) are exactly 7 chars
    colour varchar(7) not null default '#7f8c8d',

    -- typically a string identifier for a library, a path, etc
    icon text,

    -- built-in (prefefined) categories if equal to true  
    built_in boolean not null default false,

    -- discriminate between main-category and sub-category
    is_main boolean not null,

    -- FOREIGN KEYS --

    -- owner (author) of the category, users can define their own categories
    owner_id uuid references users (user_id) not null,
    
    -- self-referencing foreign key for sub-categories
    -- 
    parent_id uuid references categories (category_id) on delete cascade,
    

    -- CONSTRAINTS --
    constraint unique_category_name_per_owner unique (owner_id, parent_id, name),
    constraint no_self_parent check (category_id <> parent_id),
    -- We must ensures that you can never "bind" a subcategory to something that is already a subcategory.
    constraint check_category_hierarchy check (
        (is_main = true and parent_id is null) or
        (is_main = false and parent_id is not null)
    ),

    -- If you want to be really pedantic you can add a trigger that enforces this column will never change,
    -- but that seems like overkill for something that's relatively easy to enforce in code-review.
    created_at timestamptz not null default now(),

    updated_at timestamptz
);

-- And applying our `updated_at` trigger is as easy as this.
select trigger_updated_at('categories');

create or replace function fn_enforce_main_category_parent()
returns trigger as $$
begin
    if new.is_main = false then
        -- 1. Check if the new parent is actually a main category
        if not exists (
            select 1 from categories 
            where category_id = new.parent_id and is_main = true
        ) then
            raise exception 'invalid hierarchy: parent must be a main category';
        end if;

        -- 2. Check if THIS category is already a parent to someone else
        if exists (
            select 1 from categories where parent_id = new.category_id
        ) then
            raise exception 'invalid hierarchy: cannot turn a parent category into a sub-category';
        end if;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_check_category_parent_level
    before insert or update on categories
    for each row
    execute function fn_enforce_main_category_parent();