-- kolabora Supabase schema and RLS
create extension if not exists "uuid-ossp";

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  role text not null check (role in ('owner', 'vendor', 'both')),
  bio text,
  location text,
  created_at timestamptz not null default now()
);

create table if not exists public.fields (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique
);

create table if not exists public.profile_fields (
  profile_id uuid references public.profiles (id) on delete cascade,
  field_id uuid references public.fields (id) on delete cascade,
  primary key (profile_id, field_id)
);

create table if not exists public.posts (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid references public.profiles (id) on delete cascade,
  type text not null check (type in ('looking_vendor', 'open_project', 'collaboration', 'offer_service')),
  title text not null,
  description text not null,
  compensation_type text not null check (compensation_type in ('paid', 'rev_share', 'negotiable')),
  timeline text,
  status text not null default 'open' check (status in ('open', 'closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.post_fields (
  post_id uuid references public.posts (id) on delete cascade,
  field_id uuid references public.fields (id) on delete cascade,
  primary key (post_id, field_id)
);

create table if not exists public.applications (
  id uuid primary key default uuid_generate_v4(),
  post_id uuid references public.posts (id) on delete cascade,
  applicant_id uuid references public.profiles (id) on delete cascade,
  message text,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.workspaces (
  id uuid primary key default uuid_generate_v4(),
  post_id uuid references public.posts (id) on delete cascade,
  owner_id uuid references public.profiles (id) on delete cascade,
  status text not null default 'ongoing' check (status in ('ongoing', 'completed'))
);

create table if not exists public.workspace_members (
  workspace_id uuid references public.workspaces (id) on delete cascade,
  member_id uuid references public.profiles (id) on delete cascade,
  role text not null check (role in ('owner', 'vendor', 'partner')),
  primary key (workspace_id, member_id)
);

create table if not exists public.workspace_messages (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid references public.workspaces (id) on delete cascade,
  sender_id uuid references public.profiles (id) on delete cascade,
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.endorsements (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid references public.workspaces (id) on delete cascade,
  from_user_id uuid references public.profiles (id) on delete cascade,
  to_user_id uuid references public.profiles (id) on delete cascade,
  rating int,
  comment text,
  created_at timestamptz not null default now()
);

-- RLS policies
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.applications enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_messages enable row level security;
alter table public.endorsements enable row level security;
alter table public.workspace_members enable row level security;
alter table public.fields enable row level security;
alter table public.profile_fields enable row level security;
alter table public.post_fields enable row level security;

-- profiles: anyone authenticated can read, users manage only their own row
create policy "Profiles can be read by authenticated users"
  on public.profiles for select
  using (auth.role() = 'authenticated');

create policy "Users insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- fields: read-only catalog for authenticated users
create policy "Read fields"
  on public.fields for select
  using (auth.role() = 'authenticated');

-- posts: authenticated read, only author writes
create policy "Posts readable to authenticated"
  on public.posts for select
  using (auth.role() = 'authenticated');

create policy "Authors can insert posts"
  on public.posts for insert
  with check (auth.uid() = author_id);

create policy "Authors update their posts"
  on public.posts for update
  using (auth.uid() = author_id);

create policy "Authors delete their posts"
  on public.posts for delete
  using (auth.uid() = author_id);

-- post_fields: ensure authors manage their mappings
create policy "Post fields readable"
  on public.post_fields for select
  using (auth.role() = 'authenticated');

create policy "Authors manage post fields"
  on public.post_fields for all
  using (
    auth.uid() in (
      select author_id from public.posts where id = post_id
    )
  );

-- profile_fields
create policy "Profile fields readable"
  on public.profile_fields for select
  using (auth.role() = 'authenticated');

create policy "Owners manage their profile fields"
  on public.profile_fields for all
  using (auth.uid() = profile_id);

-- applications: authenticated users can create for themselves; post author can read
create policy "Authenticated users create applications"
  on public.applications for insert
  with check (
    auth.role() = 'authenticated'
    and applicant_id = auth.uid()
  );

create policy "Post author reads applications"
  on public.applications for select
  using (
    auth.uid() in (
      select author_id from public.posts where id = post_id
    )
  );

create policy "Post author updates applications"
  on public.applications for update
  using (
    auth.uid() in (
      select author_id from public.posts where id = post_id
    )
  );

-- allow applicants to see their own application rows (needed for insert returning)
create policy "Applicants read their applications"
  on public.applications for select
  using (applicant_id = auth.uid());

-- workspaces: only members can read/write
-- allow owners to create workspace rows
create policy "Owners create workspaces"
  on public.workspaces for insert
  with check (auth.uid() = owner_id);

create policy "Workspace members read"
  on public.workspaces for select
  using (
    auth.uid() in (
      select member_id from public.workspace_members
      where workspace_id = id
    )
  );

create policy "Workspace members write"
  on public.workspaces for update
  using (
    auth.uid() in (
      select member_id from public.workspace_members
      where workspace_id = id
    )
  );

-- workspace_members: controlled by existing members (simple check)
-- Simplify workspace_members policy to avoid recursive self-reference
drop policy if exists "Members manage workspace_members" on public.workspace_members;

create policy "Members manage their workspace_members rows"
  on public.workspace_members for all
  using (
    auth.uid() = member_id
    or auth.uid() in (
      select owner_id from public.workspaces where id = workspace_id
    )
  );

-- workspace_messages: members only
create policy "Members read workspace messages"
  on public.workspace_messages for select
  using (
    auth.uid() in (
      select member_id from public.workspace_members wm
      where wm.workspace_id = workspace_messages.workspace_id
    )
  );

create policy "Members write workspace messages"
  on public.workspace_messages for insert
  with check (
    auth.uid() in (
      select member_id from public.workspace_members wm
      where wm.workspace_id = workspace_messages.workspace_id
    )
  );

-- endorsements: only workspace members can create
create policy "Members create endorsements"
  on public.endorsements for insert
  with check (
    auth.uid() in (
      select member_id from public.workspace_members wm
      where wm.workspace_id = endorsements.workspace_id
    )
  );
