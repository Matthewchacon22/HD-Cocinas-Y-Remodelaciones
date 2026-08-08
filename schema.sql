-- =====================================================================
-- HD Cocinas y Remodelaciones — Esquema de operaciones (Supabase)
-- =====================================================================
-- Cómo usar este archivo:
--   1. Entra a tu proyecto en https://supabase.com/dashboard
--   2. Ve a "SQL Editor" → "New query"
--   3. Pega TODO este archivo y dale "Run"
--   4. Ejecuta primero seed_admin.sql (te lo explico en el README) para
--      convertir tu primer usuario en administrador.
--
-- Este script es idempotente: puedes volver a ejecutarlo sin duplicar
-- nada (usa "if not exists" / "or replace" en todas partes).
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- 1. PERFILES Y ROLES
-- ---------------------------------------------------------------------
-- auth.users ya existe (lo crea Supabase Auth). profiles guarda los
-- datos visibles de negocio; user_roles guarda el rol real usado por RLS.

create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null,
  phone       text,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create type public.app_role as enum ('admin', 'supervisor', 'instalador');

create table if not exists public.user_roles (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  role        public.app_role not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Función helper: rol del usuario autenticado actual.
-- security definer + search_path fijo para que no se pueda burlar con RLS recursiva.
create or replace function public.current_role_name()
returns public.app_role
language sql
security definer
set search_path = public
stable
as $$
  select role from public.user_roles where user_id = auth.uid();
$$;

create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public stable
as $$ select public.current_role_name() = 'admin'; $$;

create or replace function public.is_supervisor_or_admin()
returns boolean language sql security definer set search_path = public stable
as $$ select public.current_role_name() in ('admin','supervisor'); $$;

-- ---------------------------------------------------------------------
-- 2. PLANTILLAS MAESTRAS
-- ---------------------------------------------------------------------
-- Sólo el admin las edita. Cada obra copia la versión activa al crearse.

create table if not exists public.template_versions (
  id            uuid primary key default gen_random_uuid(),
  version_label text not null,           -- ej. "v3 - agosto 2026"
  is_active     boolean not null default false,
  created_by    uuid references auth.users(id),
  created_at    timestamptz not null default now()
);

-- Sólo puede haber UNA plantilla activa a la vez.
create unique index if not exists one_active_template
  on public.template_versions (is_active)
  where is_active;

create table if not exists public.template_sections (
  id                  uuid primary key default gen_random_uuid(),
  template_version_id uuid not null references public.template_versions(id) on delete cascade,
  key                 text not null,     -- ej. 'lista_compras', 'kit_carro'
  name                text not null,     -- ej. 'Lista de compras'
  order_index         integer not null default 0
);

create table if not exists public.template_items (
  id                 uuid primary key default gen_random_uuid(),
  template_section_id uuid not null references public.template_sections(id) on delete cascade,
  name               text not null,
  item_type          text not null default 'checklist' check (item_type in ('checklist','compra')),
  category           text,
  default_quantity   numeric,
  unit               text,
  order_index        integer not null default 0
);

-- ---------------------------------------------------------------------
-- 3. OBRAS (PROYECTOS)
-- ---------------------------------------------------------------------

create table if not exists public.projects (
  id                    uuid primary key default gen_random_uuid(),
  name                  text not null,             -- "Casa Pérez"
  client_name           text,
  client_phone          text,
  address               text,
  start_date            date,
  estimated_delivery    date,
  installer_id          uuid references auth.users(id),
  supervisor_id         uuid references auth.users(id),
  status                text not null default 'pendiente'
                          check (status in ('pendiente','en_preparacion','en_instalacion','requiere_correccion','finalizada','entregada')),
  progress_pct          integer not null default 0 check (progress_pct between 0 and 100),
  observations          text,
  template_version_id   uuid references public.template_versions(id),
  created_by            uuid references auth.users(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_projects_installer on public.projects(installer_id);
create index if not exists idx_projects_supervisor on public.projects(supervisor_id);
create index if not exists idx_projects_status on public.projects(status);

-- Miembros adicionales de una obra (por si hay más de un instalador/supervisor).
create table if not exists public.project_members (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  role_in_project text not null check (role_in_project in ('instalador','supervisor')),
  created_at  timestamptz not null default now(),
  unique (project_id, user_id)
);

create table if not exists public.project_sections (
  id                   uuid primary key default gen_random_uuid(),
  project_id           uuid not null references public.projects(id) on delete cascade,
  template_section_id  uuid references public.template_sections(id),
  name                 text not null,
  order_index          integer not null default 0
);
create index if not exists idx_project_sections_project on public.project_sections(project_id);

create table if not exists public.project_items (
  id                 uuid primary key default gen_random_uuid(),
  project_section_id uuid not null references public.project_sections(id) on delete cascade,
  template_item_id   uuid references public.template_items(id),
  name               text not null,
  item_type          text not null default 'checklist' check (item_type in ('checklist','compra')),
  quantity           numeric,
  unit               text,
  status             text not null default 'pendiente'
                        check (status in ('pendiente','completado','requiere_correccion','no_aplica')),
  note               text,
  order_index        integer not null default 0,
  updated_by         uuid references auth.users(id),
  updated_at         timestamptz not null default now(),
  created_at         timestamptz not null default now()
);
create index if not exists idx_project_items_section on public.project_items(project_section_id);
create index if not exists idx_project_items_status on public.project_items(status);

create table if not exists public.project_observations (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  item_id     uuid references public.project_items(id) on delete cascade,
  body        text not null,
  created_by  uuid references auth.users(id),
  created_at  timestamptz not null default now()
);
create index if not exists idx_observations_project on public.project_observations(project_id);

create table if not exists public.project_attachments (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid not null references public.projects(id) on delete cascade,
  item_id      uuid references public.project_items(id) on delete cascade,
  storage_path text not null,       -- ruta dentro del bucket privado "evidencias"
  uploaded_by  uuid references auth.users(id),
  created_at   timestamptz not null default now()
);
create index if not exists idx_attachments_project on public.project_attachments(project_id);

create table if not exists public.activity_log (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid references public.projects(id) on delete cascade,
  user_id     uuid references auth.users(id),
  action      text not null,        -- 'item_status_changed', 'project_created', etc.
  entity_type text,
  entity_id   uuid,
  detail      jsonb,
  created_at  timestamptz not null default now()
);
create index if not exists idx_activity_project on public.activity_log(project_id);

-- updated_at automático
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

drop trigger if exists trg_projects_updated on public.projects;
create trigger trg_projects_updated before update on public.projects
  for each row execute function public.set_updated_at();

drop trigger if exists trg_items_updated on public.project_items;
create trigger trg_items_updated before update on public.project_items
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 4. ¿ESTE USUARIO TIENE ACCESO A ESTA OBRA?
-- ---------------------------------------------------------------------
create or replace function public.has_project_access(p_project_id uuid)
returns boolean
language sql security definer set search_path = public stable
as $$
  select
    public.is_supervisor_or_admin()
    or exists (
      select 1 from public.projects p
      where p.id = p_project_id and p.installer_id = auth.uid()
    )
    or exists (
      select 1 from public.project_members m
      where m.project_id = p_project_id and m.user_id = auth.uid()
    );
$$;

-- ---------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.template_versions enable row level security;
alter table public.template_sections enable row level security;
alter table public.template_items enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.project_sections enable row level security;
alter table public.project_items enable row level security;
alter table public.project_observations enable row level security;
alter table public.project_attachments enable row level security;
alter table public.activity_log enable row level security;

-- profiles: cualquier usuario autenticado puede leer perfiles (para ver
-- nombres de instalador/supervisor en las tarjetas); sólo admin edita otros.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select
  using (auth.role() = 'authenticated');

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles for update
  using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles for insert
  with check (id = auth.uid() or public.is_admin());

-- user_roles: el usuario ve su propio rol; sólo admin ve/edita todos.
drop policy if exists roles_select on public.user_roles;
create policy roles_select on public.user_roles for select
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists roles_write on public.user_roles;
create policy roles_write on public.user_roles for all
  using (public.is_admin()) with check (public.is_admin());

-- plantillas: todos los autenticados leen; sólo admin escribe.
drop policy if exists templates_select on public.template_versions;
create policy templates_select on public.template_versions for select
  using (auth.role() = 'authenticated');
drop policy if exists templates_write on public.template_versions;
create policy templates_write on public.template_versions for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists tsections_select on public.template_sections;
create policy tsections_select on public.template_sections for select
  using (auth.role() = 'authenticated');
drop policy if exists tsections_write on public.template_sections;
create policy tsections_write on public.template_sections for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists titems_select on public.template_items;
create policy titems_select on public.template_items for select
  using (auth.role() = 'authenticated');
drop policy if exists titems_write on public.template_items;
create policy titems_write on public.template_items for all
  using (public.is_admin()) with check (public.is_admin());

-- projects: admin/supervisor ven todas; instalador sólo las suyas.
drop policy if exists projects_select on public.projects;
create policy projects_select on public.projects for select
  using (public.has_project_access(id));

drop policy if exists projects_insert on public.projects;
create policy projects_insert on public.projects for insert
  with check (public.is_supervisor_or_admin());

drop policy if exists projects_update on public.projects;
create policy projects_update on public.projects for update
  using (public.has_project_access(id));

drop policy if exists projects_delete on public.projects;
create policy projects_delete on public.projects for delete
  using (public.is_admin());

-- project_members: visibles/editables por quien tiene acceso a la obra; sólo supervisor/admin asigna.
drop policy if exists members_select on public.project_members;
create policy members_select on public.project_members for select
  using (public.has_project_access(project_id));
drop policy if exists members_write on public.project_members;
create policy members_write on public.project_members for all
  using (public.is_supervisor_or_admin()) with check (public.is_supervisor_or_admin());

-- project_sections
drop policy if exists psections_select on public.project_sections;
create policy psections_select on public.project_sections for select
  using (public.has_project_access(project_id));
drop policy if exists psections_write on public.project_sections;
create policy psections_write on public.project_sections for all
  using (public.has_project_access(project_id)) with check (public.has_project_access(project_id));

-- project_items: instalador puede actualizar (marcar estado/cantidad/nota)
-- pero no borrar ni crear ítems nuevos fuera de su obra asignada.
drop policy if exists pitems_select on public.project_items;
create policy pitems_select on public.project_items for select
  using (public.has_project_access(
    (select project_id from public.project_sections s where s.id = project_section_id)
  ));

drop policy if exists pitems_update on public.project_items;
create policy pitems_update on public.project_items for update
  using (public.has_project_access(
    (select project_id from public.project_sections s where s.id = project_section_id)
  ));

drop policy if exists pitems_insert on public.project_items;
create policy pitems_insert on public.project_items for insert
  with check (public.is_supervisor_or_admin());

drop policy if exists pitems_delete on public.project_items;
create policy pitems_delete on public.project_items for delete
  using (public.is_supervisor_or_admin());

-- project_observations: cualquiera con acceso a la obra puede leer/crear; nadie edita el histórico.
drop policy if exists obs_select on public.project_observations;
create policy obs_select on public.project_observations for select
  using (public.has_project_access(project_id));
drop policy if exists obs_insert on public.project_observations;
create policy obs_insert on public.project_observations for insert
  with check (public.has_project_access(project_id) and created_by = auth.uid());

-- project_attachments
drop policy if exists att_select on public.project_attachments;
create policy att_select on public.project_attachments for select
  using (public.has_project_access(project_id));
drop policy if exists att_insert on public.project_attachments;
create policy att_insert on public.project_attachments for insert
  with check (public.has_project_access(project_id) and uploaded_by = auth.uid());
drop policy if exists att_delete on public.project_attachments;
create policy att_delete on public.project_attachments for delete
  using (public.is_supervisor_or_admin());

-- activity_log: sólo lectura para quien tiene acceso a la obra; las
-- inserciones las hace siempre el trigger/servidor, nunca el cliente directo.
drop policy if exists log_select on public.activity_log;
create policy log_select on public.activity_log for select
  using (project_id is null or public.has_project_access(project_id));
drop policy if exists log_insert on public.activity_log;
create policy log_insert on public.activity_log for insert
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- 6. REGISTRAR CAMBIOS DE ITEM EN activity_log AUTOMÁTICAMENTE
-- ---------------------------------------------------------------------
create or replace function public.log_item_change()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_project_id uuid;
begin
  select project_id into v_project_id from public.project_sections where id = coalesce(new.project_section_id, old.project_section_id);
  insert into public.activity_log (project_id, user_id, action, entity_type, entity_id, detail)
  values (
    v_project_id,
    auth.uid(),
    'item_status_changed',
    'project_item',
    new.id,
    jsonb_build_object('status', new.status, 'quantity', new.quantity, 'name', new.name)
  );
  return new;
end; $$;

drop trigger if exists trg_log_item_change on public.project_items;
create trigger trg_log_item_change after update on public.project_items
  for each row when (old.status is distinct from new.status or old.quantity is distinct from new.quantity)
  execute function public.log_item_change();

-- ---------------------------------------------------------------------
-- 7. PROCEDIMIENTO: crear obra copiando la plantilla activa
-- ---------------------------------------------------------------------
-- Uso desde el cliente: select public.create_project_from_template(
--   p_name, p_client_name, p_client_phone, p_address, p_start_date,
--   p_estimated_delivery, p_installer_id, p_supervisor_id
-- );
create or replace function public.create_project_from_template(
  p_name               text,
  p_client_name        text,
  p_client_phone       text,
  p_address            text,
  p_start_date         date,
  p_estimated_delivery date,
  p_installer_id       uuid,
  p_supervisor_id      uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_template_id uuid;
  v_project_id  uuid;
  v_section     record;
  v_new_section_id uuid;
  v_item        record;
begin
  if not public.is_supervisor_or_admin() then
    raise exception 'No autorizado para crear obras';
  end if;

  select id into v_template_id from public.template_versions where is_active limit 1;
  if v_template_id is null then
    raise exception 'No hay una plantilla maestra activa';
  end if;

  insert into public.projects (
    name, client_name, client_phone, address, start_date, estimated_delivery,
    installer_id, supervisor_id, template_version_id, created_by
  ) values (
    p_name, p_client_name, p_client_phone, p_address, p_start_date, p_estimated_delivery,
    p_installer_id, p_supervisor_id, v_template_id, auth.uid()
  ) returning id into v_project_id;

  for v_section in
    select * from public.template_sections where template_version_id = v_template_id order by order_index
  loop
    insert into public.project_sections (project_id, template_section_id, name, order_index)
    values (v_project_id, v_section.id, v_section.name, v_section.order_index)
    returning id into v_new_section_id;

    for v_item in
      select * from public.template_items where template_section_id = v_section.id order by order_index
    loop
      insert into public.project_items (
        project_section_id, template_item_id, name, item_type, quantity, unit, order_index
      ) values (
        v_new_section_id, v_item.id, v_item.name, v_item.item_type, v_item.default_quantity, v_item.unit, v_item.order_index
      );
    end loop;
  end loop;

  insert into public.activity_log (project_id, user_id, action, entity_type, entity_id, detail)
  values (v_project_id, auth.uid(), 'project_created', 'project', v_project_id, jsonb_build_object('name', p_name));

  return v_project_id;
end;
$$;

-- ---------------------------------------------------------------------
-- 8. STORAGE: bucket privado para fotos de evidencia
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('evidencias', 'evidencias', false)
on conflict (id) do nothing;

-- Estructura de ruta esperada: evidencias/<project_id>/<item_id>/<archivo>
-- Sólo puede subir/leer quien tenga acceso a esa obra (primer segmento del path).
drop policy if exists evidencias_select on storage.objects;
create policy evidencias_select on storage.objects for select
  using (
    bucket_id = 'evidencias'
    and public.has_project_access((storage.foldername(name))[1]::uuid)
  );

drop policy if exists evidencias_insert on storage.objects;
create policy evidencias_insert on storage.objects for insert
  with check (
    bucket_id = 'evidencias'
    and public.has_project_access((storage.foldername(name))[1]::uuid)
  );

drop policy if exists evidencias_delete on storage.objects;
create policy evidencias_delete on storage.objects for delete
  using (
    bucket_id = 'evidencias'
    and public.is_supervisor_or_admin()
  );

-- =====================================================================
-- FIN — siguiente paso: ejecuta seed_template.sql para cargar la
-- plantilla maestra inicial (las 11 secciones descritas en el proyecto).
-- =====================================================================
