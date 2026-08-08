// =====================================================================
// Cliente Supabase compartido por toda la app interna.
//
// Estas dos claves son PÚBLICAS a propósito (la "anon key" está
// diseñada para vivir en el navegador; la seguridad real la da RLS en
// la base de datos, no el secreto de esta clave). NUNCA pongas aquí
// la "service_role key" — esa se queda solo en el backend de Supabase.
// =====================================================================
const SUPABASE_URL = "https://ehjtyoxzvodvecqjtmod.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_nWkaYJzqf6u0db-zqzKFlw_Fp2osUvq";

export const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true },
});

// ---------------------------------------------------------------------
// Sesión y rol actuales (cacheados en memoria, no en localStorage como
// fuente de verdad — solo para no repetir la consulta en cada pantalla)
// ---------------------------------------------------------------------
let _cachedProfile = null;

export async function requireSession() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    window.location.href = resolvePath("login.html");
    return null;
  }
  return session;
}

export async function getCurrentProfile() {
  if (_cachedProfile) return _cachedProfile;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: profile }, { data: roleRow }] = await Promise.all([
    supabase.from("profiles").select("*").eq("id", user.id).single(),
    supabase.from("user_roles").select("role").eq("user_id", user.id).single(),
  ]);

  _cachedProfile = { ...user, ...profile, role: roleRow?.role || null };
  return _cachedProfile;
}

export function clearProfileCache() {
  _cachedProfile = null;
}

export async function signOut() {
  await supabase.auth.signOut();
  clearProfileCache();
  window.location.href = resolvePath("login.html");
}

// Resuelve rutas relativas a la raíz de la app interna (app.hdcocinas.com/...)
export function resolvePath(path) {
  return path;
}

// ---------------------------------------------------------------------
// Caché temporal offline (NO es la base de datos — solo evita perder
// un cambio si el instalador se queda sin señal un momento). Se vacía
// apenas el cambio se confirma en Supabase.
// ---------------------------------------------------------------------
const OFFLINE_QUEUE_KEY = "hdops:pending-writes";

export function queueOfflineWrite(entry) {
  const queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || "[]");
  queue.push({ ...entry, queuedAt: Date.now() });
  localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
}

export function getOfflineQueue() {
  return JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY) || "[]");
}

export function clearOfflineQueueEntry(index) {
  const queue = getOfflineQueue();
  queue.splice(index, 1);
  localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
}

// Reintenta escrituras pendientes cuando vuelve la señal.
window.addEventListener("online", async () => {
  const queue = getOfflineQueue();
  for (let i = queue.length - 1; i >= 0; i--) {
    const entry = queue[i];
    try {
      await supabase.from(entry.table).update(entry.values).eq("id", entry.id);
      clearOfflineQueueEntry(i);
    } catch (e) {
      // se queda en la cola para el próximo intento
    }
  }
});
