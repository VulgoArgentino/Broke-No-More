-- =============================================
-- BROKE NO MORE — Setup do Supabase
-- Rode este SQL no SQL Editor do Supabase
-- =============================================

-- 1. Tabela de perfis (criada automaticamente no signup)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text default '',
  role text default '',
  salary numeric default 0,
  salary_day integer default 5,
  photo text default '',
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;
create policy "Users manage own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

-- Trigger: cria perfil automaticamente quando o usuário se registra
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. Transações (receitas e gastos)
create table public.transactions (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null default auth.uid(),
  description text not null,
  category text not null,
  type text not null check (type in ('credit','debit')),
  amount numeric not null,
  date date not null,
  month text not null,
  is_fixed boolean default false,
  created_at timestamptz default now()
);

alter table public.transactions enable row level security;
create policy "Users manage own transactions" on public.transactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 3. Gastos fixos recorrentes
create table public.fixed_expenses (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null default auth.uid(),
  description text not null,
  category text not null,
  amount numeric not null,
  day integer not null,
  created_at timestamptz default now()
);

alter table public.fixed_expenses enable row level security;
create policy "Users manage own fixed_expenses" on public.fixed_expenses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 4. Carteira de investimentos
create table public.portfolio (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null default auth.uid(),
  asset_id text not null,
  symbol text not null,
  name text not null,
  color text default '',
  logo text default '',
  quantity numeric not null,
  avg_price numeric not null,
  purchase_date date,
  created_at timestamptz default now()
);

alter table public.portfolio enable row level security;
create policy "Users manage own portfolio" on public.portfolio
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
