export const PROJECT_STATUS_LABELS = {
  pendiente: "Pendiente",
  en_preparacion: "En preparación",
  en_instalacion: "En instalación",
  requiere_correccion: "Requiere corrección",
  finalizada: "Finalizada",
  entregada: "Entregada",
};

export const ITEM_STATUS_LABELS = {
  pendiente: "Pendiente",
  completado: "Completado",
  requiere_correccion: "Requiere corrección",
  no_aplica: "No aplica",
};

export function statusLabel(status) {
  return PROJECT_STATUS_LABELS[status] || status;
}

export function itemStatusLabel(status) {
  return ITEM_STATUS_LABELS[status] || status;
}

export function escapeHtml(str) {
  return String(str ?? "").replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}
