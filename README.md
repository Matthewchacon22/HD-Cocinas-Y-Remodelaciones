# HD Cocinas — App interna de operaciones

Esta es la Fase 1 del proyecto: la aplicación real conectada a Supabase que
reemplaza al `Checklist.html` basado en `localStorage`. El sitio público
(`Pagina_Web.html`) todavía **no se ha tocado** — eso es la Fase 2, a
propósito, para no arriesgar el configurador mientras validamos esto.

## Qué es cada archivo

```
schema.sql          → todo el esquema de base de datos + seguridad (RLS)
seed_template.sql    → carga la plantilla maestra inicial (11 secciones)
services/supabase.js → conexión a Supabase + sesión + cola offline
css/app.css          → estilos compartidos (botones grandes, colores de estado)
login/index.html     → inicio de sesión
obras/index.html      → tablero principal (tarjetas de obra)
obra/nueva.html       → crear obra (copia la plantilla activa)
obra/index.html        → detalle de obra: secciones, checklist, fotos, cantidades
js/format.js          → textos en español de los estados
```

No hay build step: es HTML/CSS/JS plano + el SDK de Supabase por CDN. Se
puede editar y probar directamente abriendo los archivos, y se sube tal cual
a GitHub Pages.

---

## Paso 1 — Crear el proyecto en Supabase

1. Entra a **https://supabase.com** → "New project".
2. Nombre: `hdcocinas-operaciones`. Elige una contraseña de base de datos
   fuerte y guárdala en un lugar seguro (no la vuelves a ver).
3. Región: la más cercana a Colombia (normalmente `us-east-1` o similar
   disponible en el selector).
4. Espera ~2 minutos a que aprovisione el proyecto.

## Paso 2 — Ejecutar el esquema

1. En el panel del proyecto, ve a **SQL Editor → New query**.
2. Pega el contenido completo de `schema.sql` y dale **Run**.
3. Repite lo mismo con `seed_template.sql` (pégalo en una nueva query).

## Paso 3 — Obtener las claves públicas

1. Ve a **Project Settings → API**.
2. Copia:
   - `Project URL` → pégalo en `services/supabase.js` en `SUPABASE_URL`.
   - `anon public` key → pégalo en `SUPABASE_ANON_KEY`.
3. **Nunca copies la `service_role` key aquí** — esa nunca debe salir del
   panel de Supabase ni vivir en el navegador.

## Paso 4 — Crear tu primer usuario administrador

1. Ve a **Authentication → Users → Add user** y crea tu propio usuario
   (correo + contraseña). Anota el `UUID` que Supabase le asigna.
2. Vuelve a **SQL Editor** y ejecuta (reemplazando el UUID y tu nombre):

```sql
insert into public.profiles (id, full_name)
values ('PEGA-AQUI-EL-UUID', 'Tu Nombre')
on conflict (id) do update set full_name = excluded.full_name;

insert into public.user_roles (user_id, role)
values ('PEGA-AQUI-EL-UUID', 'admin')
on conflict (user_id) do update set role = 'admin';
```

3. Repite lo mismo (con rol `'supervisor'` o `'instalador'`) para cada
   persona de tu equipo — o, una vez tengas el panel de administración
   (Fase 3, todavía por construir), hazlo desde ahí.

## Paso 5 — Probar en tu computador antes de publicar

Como los archivos usan `import`/`export` (módulos ES), los navegadores no
los abren directo con `file://`. Necesitas un servidor local simple:

```bash
cd hdcocinas-operaciones
python3 -m http.server 8080
# abre http://localhost:8080/login/
```

Inicia sesión con el usuario admin que creaste. Deberías ver el tablero de
obras (vacío) y el botón `+` para crear la primera obra.

## Paso 6 — Subir a GitHub y publicar con GitHub Pages

```bash
cd hdcocinas-operaciones
git init
git add .
git commit -m "App interna de operaciones — Fase 1"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/hdcocinas-operaciones.git
git push -u origin main
```

Luego en GitHub: **Settings → Pages → Deploy from a branch → main → /(root)**.
Te dará una URL tipo `https://tu-usuario.github.io/hdcocinas-operaciones/` —
pruébala ahí antes de conectar el dominio propio.

## Paso 7 — Conectar `app.hdcocinas.com`

1. En GitHub: **Settings → Pages → Custom domain** → escribe
   `app.hdcocinas.com` → Save (esto crea un archivo `CNAME` en el repo).
2. En Namecheap (Advanced DNS del dominio `hdcocinas.com`): agrega un
   registro **CNAME** — Host: `app` → Value: `tu-usuario.github.io.`
3. Espera la propagación (minutos a un par de horas) y activa **Enforce
   HTTPS** en GitHub Pages una vez el dominio quede verificado.

No toques el registro del dominio raíz (`www.hdcocinas.com`) todavía — eso
es parte de la migración del sitio público (Fase 2), que se hace por
separado para no arriesgar el sitio que ya funciona.

---

## Lo que falta (próximas fases)

- **Fase 2**: separar `Pagina_Web.html` en `hdcocinas-web/` (css/js/assets
  aparte) sin tocar el configurador, y desplegarlo igual por GitHub Pages
  en `www.hdcocinas.com`.
- **Fase 3**: panel de `administracion/` para editar la plantilla maestra
  y gestionar usuarios/roles desde la interfaz (hoy se hace por SQL).
- **Fase 4**: GitHub Actions para que cada `git push` despliegue solo,
  y las 10 pruebas de verificación que pediste (crear obra desde celular,
  abrir desde otro dispositivo, permisos por rol, fotos, etc.) — esas
  requieren un proyecto Supabase real ya con datos, así que se corren
  después del Paso 4 de arriba.
