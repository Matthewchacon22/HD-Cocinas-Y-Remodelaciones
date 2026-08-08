:root {
  --bg: #F5F2EB;
  --ink: #1E1B16;
  --ink-soft: #6B6459;
  --gold: #C89B3C;
  --gold-dark: #A47D2A;
  --white: #FFFFFF;
  --line: #E5DFD2;

  --pendiente: #E5DFD2;
  --pendiente-ink: #6B6459;
  --completado: #DDEFE1;
  --completado-ink: #1E7A3D;
  --correccion: #FBE0D8;
  --correccion-ink: #C64A22;
  --no-aplica: #E8E8E8;
  --no-aplica-ink: #8A8A8A;

  --radius: 16px;
  --radius-sm: 10px;
  --shadow: 0 2px 10px rgba(30,27,22,.08);
}

* { box-sizing: border-box; }
html, body {
  margin: 0; padding: 0;
  background: var(--bg);
  color: var(--ink);
  font-family: 'Space Grotesk', system-ui, sans-serif;
  -webkit-tap-highlight-color: transparent;
}
h1, h2, h3 { font-family: 'Fraunces', serif; margin: 0 0 .3em; }
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }

.app-shell { max-width: 560px; margin: 0 auto; min-height: 100vh; padding-bottom: 90px; }

/* --------- top bar --------- */
.topbar {
  position: sticky; top: 0; z-index: 20;
  background: var(--bg);
  border-bottom: 1px solid var(--line);
  padding: 14px 16px;
  display: flex; align-items: center; justify-content: space-between;
}
.topbar .back { font-size: 22px; padding: 6px 10px; margin-left: -10px; }
.topbar h1 { font-size: 19px; }
.topbar .role-pill {
  font-size: 12px; background: var(--white); border: 1px solid var(--line);
  border-radius: 999px; padding: 5px 12px; color: var(--ink-soft);
}

/* --------- big buttons --------- */
.btn {
  display: inline-flex; align-items: center; justify-content: center;
  min-height: 52px; padding: 14px 20px;
  border-radius: var(--radius-sm); border: none;
  font-size: 16px; font-weight: 600;
  width: 100%;
}
.btn-primary { background: var(--gold); color: var(--white); }
.btn-primary:active { background: var(--gold-dark); }
.btn-secondary { background: var(--white); color: var(--ink); border: 1px solid var(--line); }
.btn-danger { background: var(--correccion); color: var(--correccion-ink); }

/* --------- project cards (dashboard) --------- */
.project-card {
  background: var(--white); border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 18px; margin: 0 16px 14px;
  display: block;
}
.project-card .name { font-size: 20px; font-family: 'Fraunces', serif; margin-bottom: 4px; }
.project-card .meta { font-size: 14px; color: var(--ink-soft); margin-bottom: 10px; }
.project-card .progress-track {
  height: 8px; border-radius: 4px; background: var(--line); overflow: hidden; margin-bottom: 10px;
}
.project-card .progress-fill { height: 100%; background: var(--gold); }
.status-badge {
  display: inline-block; font-size: 13px; font-weight: 600;
  padding: 5px 12px; border-radius: 999px;
}
.status-pendiente { background: var(--pendiente); color: var(--pendiente-ink); }
.status-en_preparacion { background: #E3EAF6; color: #2F5FA8; }
.status-en_instalacion { background: #FCEFD0; color: #966A00; }
.status-requiere_correccion { background: var(--correccion); color: var(--correccion-ink); }
.status-finalizada { background: var(--completado); color: var(--completado-ink); }
.status-entregada { background: #E4E0F5; color: #5B3FA6; }

/* --------- checklist item cards (touch-first, whole card changes color) --------- */
.item-card {
  background: var(--white); border: 2px solid var(--line); border-radius: var(--radius);
  padding: 16px; margin-bottom: 10px;
  transition: background .15s, border-color .15s;
}
.item-card.st-pendiente { background: var(--white); border-color: var(--line); }
.item-card.st-completado { background: var(--completado); border-color: var(--completado-ink); }
.item-card.st-requiere_correccion { background: var(--correccion); border-color: var(--correccion-ink); }
.item-card.st-no_aplica { background: var(--no-aplica); border-color: var(--no-aplica-ink); opacity: .75; }

.item-card .item-name { font-size: 16px; font-weight: 600; margin-bottom: 10px; }
.item-status-row { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 8px; }
.status-btn {
  flex: 1 1 auto; min-width: 76px; min-height: 44px;
  border-radius: var(--radius-sm); border: 1px solid var(--line);
  background: var(--white); font-size: 13px; font-weight: 600; color: var(--ink-soft);
}
.status-btn.active.sb-completado { background: var(--completado-ink); color: var(--white); border-color: var(--completado-ink); }
.status-btn.active.sb-requiere_correccion { background: var(--correccion-ink); color: var(--white); border-color: var(--correccion-ink); }
.status-btn.active.sb-no_aplica { background: var(--no-aplica-ink); color: var(--white); border-color: var(--no-aplica-ink); }
.status-btn.active.sb-pendiente { background: var(--ink-soft); color: var(--white); }

.qty-row { display: flex; align-items: center; gap: 12px; margin: 10px 0; }
.qty-btn {
  width: 44px; height: 44px; border-radius: 10px; border: 1px solid var(--line);
  background: var(--white); font-size: 20px; font-weight: 700;
}
.qty-value { min-width: 40px; text-align: center; font-size: 18px; font-weight: 700; }

.item-actions { display: flex; gap: 8px; margin-top: 8px; }
.icon-btn {
  min-height: 40px; padding: 8px 14px; border-radius: var(--radius-sm);
  border: 1px solid var(--line); background: var(--white); font-size: 13px;
}
.item-note { font-size: 13px; color: var(--ink-soft); margin-top: 8px; white-space: pre-wrap; }

/* --------- section accordion --------- */
.section-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px; margin: 0 16px 8px; background: var(--white);
  border-radius: var(--radius); box-shadow: var(--shadow);
}
.section-head .title { font-size: 16px; font-weight: 700; }
.section-head .count { font-size: 13px; color: var(--ink-soft); }
.section-body { padding: 0 16px 8px; display: none; }
.section-body.open { display: block; }

/* --------- form fields --------- */
.field { margin-bottom: 14px; padding: 0 16px; }
.field label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--ink-soft); }
.field input, .field select, .field textarea {
  width: 100%; min-height: 48px; padding: 10px 14px;
  border: 1px solid var(--line); border-radius: var(--radius-sm);
  font-size: 16px; background: var(--white); color: var(--ink);
}
.field textarea { min-height: 80px; }

.fab-new {
  position: fixed; bottom: 24px; right: 20px;
  width: 60px; height: 60px; border-radius: 50%;
  background: var(--gold); color: var(--white); border: none;
  font-size: 30px; box-shadow: 0 6px 18px rgba(200,155,60,.5);
  z-index: 30;
}

.empty-state { text-align: center; padding: 60px 24px; color: var(--ink-soft); }
.loading-state { text-align: center; padding: 40px; color: var(--ink-soft); }
.toast {
  position: fixed; bottom: 100px; left: 50%; transform: translateX(-50%);
  background: var(--ink); color: var(--white); padding: 10px 18px;
  border-radius: 999px; font-size: 14px; z-index: 50;
}
