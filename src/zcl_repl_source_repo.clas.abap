CLASS zcl_repl_source_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_repl_source_repo.
ENDCLASS.

CLASS zcl_repl_source_repo IMPLEMENTATION.

  METHOD zif_repl_source_repo~get_candidates_bulk.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_requests TYPE zif_repl_source_repo=>ty_requests.
    lt_requests = it_requests.
    SORT lt_requests BY material plant purchasing_org delivery_date.
    DELETE ADJACENT DUPLICATES FROM lt_requests
      COMPARING material plant purchasing_org.

    SELECT eina~matnr AS material,
           eine~ekorg AS purchasing_org,
           eine~werks AS record_plant,
           eina~lifnr AS vendor,
           eina~infnr AS info_record,
           eina~esokz AS source_category,
           eine~aplfz AS planned_delivery_days,
           eine~aut_source AS auto_source_indicator,
           eina~meins AS purchase_order_unit,
           eina~lmein AS base_unit,
           eina~umrez AS order_unit_to_base_numerator,
           eina~umren AS order_unit_to_base_denominator,
           eine~minbm AS minimum_order_quantity,
           eine~bstma AS maximum_order_quantity,
           eina~lifab AS valid_from,
           eina~lifbi AS valid_to,
           eina~loekz AS general_deletion_indicator,
           eine~loekz AS purchasing_deletion_indicator
      FROM eina
      INNER JOIN eine
        ON eine~infnr = eina~infnr
      FOR ALL ENTRIES IN @lt_requests
      WHERE eina~matnr = @lt_requests-material
        AND eine~ekorg = @lt_requests-purchasing_org
        AND ( eine~werks = @lt_requests-plant
          OR eine~werks = @space )
      INTO CORRESPONDING FIELDS OF TABLE @rt_records.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_source_contexts_bulk.
    TYPES:
      BEGIN OF ty_material_plant,
        material TYPE mara-matnr,
        plant    TYPE t001w-werks,
      END OF ty_material_plant.
    TYPES ty_material_plants TYPE STANDARD TABLE OF ty_material_plant
      WITH EMPTY KEY.
    DATA lt_material_plants TYPE ty_material_plants.
    DATA lt_policy_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA lt_source_list_entries TYPE zif_repl_source_repo=>ty_source_contexts.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_material_plants = CORRESPONDING #( it_requests ).
    SORT lt_material_plants BY material plant.
    DELETE ADJACENT DUPLICATES FROM lt_material_plants
      COMPARING material plant.

    SELECT marc~matnr AS material,
           marc~werks AS plant,
           marc~kordb AS source_list_required,
           marc~usequ AS quota_arrangement_usage
      FROM marc
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE marc~matnr = @lt_material_plants-material
        AND marc~werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_policy_contexts.

    IF lt_policy_contexts IS INITIAL.
      RETURN.
    ENDIF.

    SELECT eord~matnr AS material,
           eord~werks AS plant,
           eord~lifnr AS source_list_vendor,
           eord~ekorg AS source_list_purchasing_org,
           eord~ebeln AS source_list_agreement,
           eord~ebelp AS source_list_agreement_item,
           eord~zeord AS source_list_record,
           eord~vdatu AS source_list_valid_from,
           eord~bdatu AS source_list_valid_to,
           eord~notkz AS source_list_blocked,
           eord~flifn AS source_list_fixed,
           eord~autet AS source_list_mrp_usage
      FROM eord
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE eord~matnr = @lt_material_plants-material
        AND eord~werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_source_list_entries.
    SORT lt_source_list_entries BY material plant source_list_vendor
      source_list_purchasing_org source_list_valid_from source_list_record.

    rt_contexts = lt_policy_contexts.
    LOOP AT lt_source_list_entries INTO DATA(ls_entry).
      READ TABLE lt_policy_contexts INTO DATA(ls_policy)
        WITH KEY material = ls_entry-material
                 plant = ls_entry-plant.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ls_entry-source_list_required = ls_policy-source_list_required.
      ls_entry-quota_arrangement_usage =
        ls_policy-quota_arrangement_usage.
      APPEND ls_entry TO rt_contexts.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_arrangements_bulk.
    TYPES:
      BEGIN OF ty_material_plant,
        material TYPE mara-matnr,
        plant    TYPE t001w-werks,
      END OF ty_material_plant.
    TYPES ty_material_plants TYPE STANDARD TABLE OF ty_material_plant
      WITH EMPTY KEY.
    DATA lt_material_plants TYPE ty_material_plants.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_material_plants = CORRESPONDING #( it_requests ).
    SORT lt_material_plants BY material plant.
    DELETE ADJACENT DUPLICATES FROM lt_material_plants
      COMPARING material plant.

    SELECT equk~matnr AS material,
           equk~werks AS plant,
           equk~vdatu AS quota_valid_from,
           equk~bdatu AS quota_valid_to,
           equk~qunum AS quota_number,
           equp~qupos AS quota_item,
           equp~beskz AS procurement_type,
           equp~sobes AS special_procurement_type,
           equp~lifnr AS vendor,
           equp~quote AS quota,
           equp~qubmg AS quota_base_quantity,
           equp~qumng AS quota_allocated_quantity
      FROM equk
      INNER JOIN equp
        ON equp~qunum = equk~qunum
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE equk~matnr = @lt_material_plants-material
        AND equk~werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_arrangements.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_usage_rules_bulk.
    IF it_usages IS INITIAL.
      RETURN.
    ENDIF.

    SELECT tmq2~usequ AS quota_usage,
           tmq2~qbest AS includes_purchase_orders,
           tmq2~qlpet AS includes_manual_sa_schedules,
           tmq2~qplaf AS includes_manual_planned_orders,
           tmq2~qbanf AS includes_purchase_requisitions,
           tmq2~qdisp AS active_in_automatic_mrp,
           tmq2~qfauf AS active_in_production_orders,
           tmq2~qfir AS includes_invoices
      FROM tmq2
      FOR ALL ENTRIES IN @it_usages
      WHERE tmq2~usequ = @it_usages-quota_usage
      INTO CORRESPONDING FIELDS OF TABLE @rt_rules.
  ENDMETHOD.

ENDCLASS.
