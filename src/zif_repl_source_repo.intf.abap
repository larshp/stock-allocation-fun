INTERFACE zif_repl_source_repo PUBLIC.

  TYPES:
    BEGIN OF ty_request,
      material                TYPE mara-matnr,
      plant                   TYPE t001w-werks,
      purchasing_org          TYPE eine-ekorg,
      delivery_date           TYPE d,
      requested_quantity      TYPE decfloat34,
      requested_quantity_unit TYPE eina-lmein,
      preferred_vendor        TYPE eina-lifnr,
    END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_info_record,
      material                       TYPE mara-matnr,
      purchasing_org                 TYPE eine-ekorg,
      record_plant                   TYPE eine-werks,
      vendor                         TYPE eina-lifnr,
      info_record                    TYPE eina-infnr,
      source_category                TYPE eina-esokz,
      planned_delivery_days          TYPE eine-aplfz,
      auto_source_indicator          TYPE eine-aut_source,
      purchase_order_unit            TYPE eina-meins,
      base_unit                      TYPE eina-lmein,
      order_unit_to_base_numerator   TYPE eina-umrez,
      order_unit_to_base_denominator TYPE eina-umren,
      minimum_order_quantity         TYPE eine-minbm,
      maximum_order_quantity         TYPE eine-bstma,
      valid_from                     TYPE eina-lifab,
      valid_to                       TYPE eina-lifbi,
      general_deletion_indicator     TYPE eina-loekz,
      purchasing_deletion_indicator  TYPE eine-loekz,
    END OF ty_info_record.
  TYPES ty_info_records TYPE STANDARD TABLE OF ty_info_record
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_source_context,
      material                   TYPE mara-matnr,
      plant                      TYPE t001w-werks,
      source_list_required       TYPE marc-kordb,
      quota_arrangement_usage    TYPE marc-usequ,
      source_list_vendor         TYPE eord-lifnr,
      source_list_purchasing_org TYPE eord-ekorg,
      source_list_agreement      TYPE eord-ebeln,
      source_list_agreement_item TYPE eord-ebelp,
      source_list_record         TYPE eord-zeord,
      source_list_valid_from     TYPE eord-vdatu,
      source_list_valid_to       TYPE eord-bdatu,
      source_list_blocked        TYPE eord-notkz,
      source_list_fixed          TYPE eord-flifn,
      source_list_mrp_usage      TYPE eord-autet,
    END OF ty_source_context.
  TYPES ty_source_contexts TYPE STANDARD TABLE OF ty_source_context
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_quota_arrangement,
      material                 TYPE equk-matnr,
      plant                    TYPE equk-werks,
      quota_valid_from         TYPE equk-vdatu,
      quota_valid_to           TYPE equk-bdatu,
      quota_number             TYPE equk-qunum,
      quota_item               TYPE equp-qupos,
      procurement_type         TYPE equp-beskz,
      special_procurement_type TYPE equp-sobes,
      vendor                   TYPE equp-lifnr,
      quota                    TYPE equp-quote,
      quota_base_quantity      TYPE equp-qubmg,
      quota_allocated_quantity TYPE equp-qumng,
    END OF ty_quota_arrangement.
  TYPES ty_quota_arrangements TYPE STANDARD TABLE OF ty_quota_arrangement
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_quota_usage_rule,
      quota_usage                    TYPE tmq2-usequ,
      includes_purchase_orders       TYPE tmq2-qbest,
      includes_manual_sa_schedules   TYPE tmq2-qlpet,
      includes_manual_planned_orders TYPE tmq2-qplaf,
      includes_purchase_requisitions TYPE tmq2-qbanf,
      active_in_automatic_mrp        TYPE tmq2-qdisp,
      active_in_production_orders    TYPE tmq2-qfauf,
      includes_invoices              TYPE tmq2-qfir,
    END OF ty_quota_usage_rule.
  TYPES ty_quota_usage_rules TYPE STANDARD TABLE OF ty_quota_usage_rule
    WITH EMPTY KEY.

  METHODS get_candidates_bulk
    IMPORTING
      it_requests       TYPE ty_requests
    RETURNING
      VALUE(rt_records) TYPE ty_info_records.

  METHODS get_source_contexts_bulk
    IMPORTING
      it_requests        TYPE ty_requests
    RETURNING
      VALUE(rt_contexts) TYPE ty_source_contexts.

  METHODS get_quota_arrangements_bulk
    IMPORTING
      it_requests            TYPE ty_requests
    RETURNING
      VALUE(rt_arrangements) TYPE ty_quota_arrangements.

  METHODS get_quota_usage_rules_bulk
    IMPORTING
      it_usages       TYPE ty_quota_usage_rules
    RETURNING
      VALUE(rt_rules) TYPE ty_quota_usage_rules.

ENDINTERFACE.
