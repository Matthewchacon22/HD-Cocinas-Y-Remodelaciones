-- =====================================================================
-- Plantilla maestra inicial — ejecutar UNA vez, después de schema.sql
-- =====================================================================
-- Ajusta las cantidades por defecto y agrega/quita ítems según tu
-- checklist real; esto es un punto de partida basado en las 11
-- secciones que describiste. Puedes editar todo esto luego desde el
-- panel de Administración sin volver a tocar SQL.

do $$
declare
  v_template_id uuid;
  v_section_id  uuid;
begin
  insert into public.template_versions (version_label, is_active)
  values ('v1 - plantilla inicial', true)
  returning id into v_template_id;

  -- 1. Lista de compras
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'lista_compras', 'Lista de compras', 1) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, default_quantity, unit, order_index) values
    (v_section_id, 'Bolsas de escombros', 'compra', 5, 'unid', 1),
    (v_section_id, 'Silicona transparente', 'compra', 2, 'unid', 2),
    (v_section_id, 'Tornillería general', 'compra', 1, 'kit', 3);

  -- 2. Kit carro
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'kit_carro', 'Kit carro', 2) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, default_quantity, unit, order_index) values
    (v_section_id, 'Herramienta eléctrica cargada', 'checklist', null, null, 1),
    (v_section_id, 'Nivel y flexómetro', 'checklist', null, null, 2);

  -- 3. Kit instalación
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'kit_instalacion', 'Kit instalación', 3) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, default_quantity, unit, order_index) values
    (v_section_id, 'Tacos y tornillos de anclaje', 'compra', 1, 'kit', 1),
    (v_section_id, 'Bisagras de repuesto', 'compra', 2, 'unid', 2);

  -- 4. Instalación de mesón
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'instalacion_meson', 'Instalación de mesón', 4) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, order_index) values
    (v_section_id, 'Nivelación de base', 'checklist', 1),
    (v_section_id, 'Fijación del mesón', 'checklist', 2),
    (v_section_id, 'Sellado de bordes', 'checklist', 3);

  -- 5. Instalación de salpicadero
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'instalacion_salpicadero', 'Instalación de salpicadero', 5) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, order_index) values
    (v_section_id, 'Corte a medida', 'checklist', 1),
    (v_section_id, 'Fijación y sellado', 'checklist', 2);

  -- 6. Instalación de lavaplatos
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'instalacion_lavaplatos', 'Instalación de lavaplatos', 6) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, order_index) values
    (v_section_id, 'Corte de mesón para lavaplatos', 'checklist', 1),
    (v_section_id, 'Conexión de grifería', 'checklist', 2),
    (v_section_id, 'Prueba de fugas', 'checklist', 3);

  -- 7. Instalación de horno y estufa
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'instalacion_horno_estufa', 'Instalación de horno y estufa', 7) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, order_index) values
    (v_section_id, 'Espacio y ventilación verificados', 'checklist', 1),
    (v_section_id, 'Conexión eléctrica/gas', 'checklist', 2),
    (v_section_id, 'Prueba de encendido', 'checklist', 3);

  -- 8. Control de calidad
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'control_calidad', 'Control de calidad', 8) returning id into v_section_id;
  insert into public.template_items (template_section_id, name, item_type, order_index) values
    (v_section_id, 'Puertas y cajones alineados', 'checklist', 1),
    (v_section_id, 'Sin rayones ni golpes visibles', 'checklist', 2),
    (v_section_id, 'Limpieza final de la obra', 'checklist', 3);

  -- 9. Observaciones y correcciones (sección libre, sin ítems predefinidos)
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'observaciones', 'Observaciones y correcciones', 9);

  -- 10. Fotografías y evidencias (sección libre)
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'fotografias', 'Fotografías y evidencias', 10);

  -- 11. Historial (se genera solo, a partir de activity_log — no necesita ítems)
  insert into public.template_sections (template_version_id, key, name, order_index)
  values (v_template_id, 'historial', 'Historial', 11);

end $$;
