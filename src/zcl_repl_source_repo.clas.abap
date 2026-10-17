CLASS zcl_repl_source_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_repl_source_repo.
ENDCLASS.

CLASS zcl_repl_source_repo IMPLEMENTATION.

  METHOD zif_repl_source_repo~get_candidates_bulk.
    TYPES:
      BEGIN OF ty_general_info,
        infnr TYPE eina-infnr,
        matnr TYPE eina-matnr,
        lifnr TYPE eina-lifnr,
        esokz TYPE eina-esokz,
        meins TYPE eina-meins,
        lmein TYPE eina-lmein,
        umrez TYPE eina-umrez,
        umren TYPE eina-umren,
        lifab TYPE eina-lifab,
        lifbi TYPE eina-lifbi,
        loekz TYPE eina-loekz,
      END OF ty_general_info,
      ty_general_infos TYPE SORTED TABLE OF ty_general_info
        WITH NON-UNIQUE KEY matnr,
      BEGIN OF ty_purchasing_info,
        infnr      TYPE eine-infnr,
        ekorg      TYPE eine-ekorg,
        werks      TYPE eine-werks,
        aplfz      TYPE eine-aplfz,
        aut_source TYPE eine-aut_source,
        minbm      TYPE eine-minbm,
        bstma      TYPE eine-bstma,
        loekz      TYPE eine-loekz,
      END OF ty_purchasing_info,
      ty_purchasing_infos TYPE SORTED TABLE OF ty_purchasing_info
        WITH NON-UNIQUE KEY infnr ekorg werks,
      BEGIN OF ty_purchasing_info_key,
        infnr TYPE eine-infnr,
        ekorg TYPE eine-ekorg,
        werks TYPE eine-werks,
      END OF ty_purchasing_info_key,
      ty_purchasing_info_keys TYPE SORTED TABLE OF
        ty_purchasing_info_key WITH UNIQUE KEY infnr ekorg werks.
    DATA lt_eina TYPE ty_general_infos.
    DATA lt_eine TYPE ty_purchasing_infos.
    DATA lt_eine_keys TYPE ty_purchasing_info_keys.
    DATA lv_blank_plant TYPE eine-werks.
    DATA ls_record TYPE zif_repl_source_repo=>ty_info_record.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_requests TYPE zif_repl_source_repo=>ty_requests.
    lt_requests = it_requests.
    SORT lt_requests BY material purchasing_org plant delivery_date.
    DELETE ADJACENT DUPLICATES FROM lt_requests
      COMPARING material purchasing_org plant.

    SELECT infnr,
           matnr,
           lifnr,
           esokz,
           meins,
           lmein,
           umrez,
           umren,
           lifab,
           lifbi,
           loekz
      FROM eina
      FOR ALL ENTRIES IN @lt_requests
      WHERE matnr = @lt_requests-material
      INTO CORRESPONDING FIELDS OF TABLE @lt_eina.

    IF lt_eina IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_requests INTO DATA(ls_request_key).
      LOOP AT lt_eina INTO DATA(ls_eina_key)
          WHERE matnr = ls_request_key-material.
        INSERT VALUE #(
          infnr = ls_eina_key-infnr
          ekorg = ls_request_key-purchasing_org
          werks = ls_request_key-plant ) INTO TABLE lt_eine_keys.
        INSERT VALUE #(
          infnr = ls_eina_key-infnr
          ekorg = ls_request_key-purchasing_org
          werks = lv_blank_plant ) INTO TABLE lt_eine_keys.
      ENDLOOP.
    ENDLOOP.

    SELECT infnr,
           ekorg,
           werks,
           aplfz,
           aut_source,
           minbm,
           bstma,
           loekz
      FROM eine
      FOR ALL ENTRIES IN @lt_eine_keys
      WHERE infnr = @lt_eine_keys-infnr
        AND ekorg = @lt_eine_keys-ekorg
        AND werks = @lt_eine_keys-werks
      INTO CORRESPONDING FIELDS OF TABLE @lt_eine.

    LOOP AT lt_requests INTO DATA(ls_request).
      LOOP AT lt_eina INTO DATA(ls_eina)
          WHERE matnr = ls_request-material.
        LOOP AT lt_eine INTO DATA(ls_eine)
            WHERE infnr = ls_eina-infnr
              AND ekorg = ls_request-purchasing_org.
          IF ls_eine-werks <> ls_request-plant
              AND ls_eine-werks IS NOT INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR ls_record.
          ls_record-material = ls_eina-matnr.
          ls_record-purchasing_org = ls_eine-ekorg.
          ls_record-record_plant = ls_eine-werks.
          ls_record-vendor = ls_eina-lifnr.
          ls_record-info_record = ls_eina-infnr.
          ls_record-source_category = ls_eina-esokz.
          ls_record-planned_delivery_days = ls_eine-aplfz.
          ls_record-auto_source_indicator = ls_eine-aut_source.
          ls_record-purchase_order_unit = ls_eina-meins.
          ls_record-base_unit = ls_eina-lmein.
          ls_record-order_unit_to_base_numerator = ls_eina-umrez.
          ls_record-order_unit_to_base_denominator = ls_eina-umren.
          ls_record-minimum_order_quantity = ls_eine-minbm.
          ls_record-maximum_order_quantity = ls_eine-bstma.
          ls_record-valid_from = ls_eina-lifab.
          ls_record-valid_to = ls_eina-lifbi.
          ls_record-general_deletion_indicator = ls_eina-loekz.
          ls_record-purchasing_deletion_indicator = ls_eine-loekz.
          APPEND ls_record TO rt_records.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    SORT rt_records BY material purchasing_org record_plant info_record.
    DELETE ADJACENT DUPLICATES FROM rt_records
      COMPARING material purchasing_org record_plant info_record.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_outline_agreements_bulk.
    TYPES:
      BEGIN OF ty_source_list_entry,
        matnr TYPE eord-matnr,
        werks TYPE eord-werks,
        ekorg TYPE eord-ekorg,
        ebeln TYPE eord-ebeln,
        ebelp TYPE eord-ebelp,
        zeord TYPE eord-zeord,
        vdatu TYPE eord-vdatu,
        bdatu TYPE eord-bdatu,
        notkz TYPE eord-notkz,
        lifnr TYPE eord-lifnr,
        flifn TYPE eord-flifn,
        autet TYPE eord-autet,
      END OF ty_source_list_entry,
      ty_source_list_entries TYPE SORTED TABLE OF ty_source_list_entry
        WITH NON-UNIQUE KEY matnr werks,
      BEGIN OF ty_agreement_header,
        ebeln TYPE ekko-ebeln,
        ekorg TYPE ekko-ekorg,
        lifnr TYPE ekko-lifnr,
        bstyp TYPE ekko-bstyp,
        kdatb TYPE ekko-kdatb,
        kdate TYPE ekko-kdate,
        loekz TYPE ekko-loekz,
      END OF ty_agreement_header,
      ty_agreement_headers TYPE HASHED TABLE OF ty_agreement_header
        WITH UNIQUE KEY ebeln,
      BEGIN OF ty_agreement_item,
        ebeln TYPE ekpo-ebeln,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
        werks TYPE ekpo-werks,
        loekz TYPE ekpo-loekz,
        elikz TYPE ekpo-elikz,
      END OF ty_agreement_item,
      ty_agreement_items TYPE HASHED TABLE OF ty_agreement_item
        WITH UNIQUE KEY ebeln ebelp,
      BEGIN OF ty_request_key,
        material       TYPE eord-matnr,
        plant          TYPE eord-werks,
        purchasing_org TYPE ekko-ekorg,
      END OF ty_request_key,
      ty_request_keys TYPE SORTED TABLE OF ty_request_key
        WITH UNIQUE KEY material plant purchasing_org.
    DATA lt_eord TYPE ty_source_list_entries.
    DATA lt_ekko TYPE ty_agreement_headers.
    DATA lt_ekpo TYPE ty_agreement_items.
    DATA lt_request_keys TYPE ty_request_keys.
    DATA ls_agreement TYPE zif_repl_source_repo=>ty_outline_agreement.
    DATA lv_blank_plant TYPE ekpo-werks.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request_to_key).
      INSERT VALUE #(
        material       = ls_request_to_key-material
        plant          = ls_request_to_key-plant
        purchasing_org = ls_request_to_key-purchasing_org )
        INTO TABLE lt_request_keys.
    ENDLOOP.

    SELECT matnr,
           werks,
           ekorg,
           ebeln,
           ebelp,
           zeord,
           vdatu,
           bdatu,
           notkz,
           lifnr,
           flifn,
           autet
      FROM eord
      FOR ALL ENTRIES IN @lt_request_keys
      WHERE matnr = @lt_request_keys-material
        AND werks = @lt_request_keys-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_eord.

    IF lt_eord IS INITIAL.
      RETURN.
    ENDIF.

    SELECT ebeln,
           ekorg,
           lifnr,
           bstyp,
           kdatb,
           kdate,
           loekz
      FROM ekko
      FOR ALL ENTRIES IN @lt_eord
      WHERE ebeln = @lt_eord-ebeln
      INTO CORRESPONDING FIELDS OF TABLE @lt_ekko.

    SELECT ebeln,
           ebelp,
           matnr,
           werks,
           loekz,
           elikz
      FROM ekpo
      FOR ALL ENTRIES IN @lt_eord
      WHERE ebeln = @lt_eord-ebeln
        AND ebelp = @lt_eord-ebelp
      INTO CORRESPONDING FIELDS OF TABLE @lt_ekpo.

    LOOP AT lt_request_keys INTO DATA(ls_request).
      LOOP AT lt_eord INTO DATA(ls_eord)
          WHERE matnr = ls_request-material
            AND werks = ls_request-plant.
        READ TABLE lt_ekko INTO DATA(ls_ekko)
          WITH TABLE KEY ebeln = ls_eord-ebeln.
        IF sy-subrc <> 0
            OR ls_ekko-ekorg <> ls_request-purchasing_org.
          CONTINUE.
        ENDIF.

        READ TABLE lt_ekpo INTO DATA(ls_ekpo)
          WITH TABLE KEY ebeln = ls_eord-ebeln
                         ebelp = ls_eord-ebelp.
        IF sy-subrc <> 0
            OR ls_ekpo-matnr <> ls_request-material
            OR ( ls_ekpo-werks <> ls_request-plant
              AND ls_ekpo-werks <> lv_blank_plant ).
          CONTINUE.
        ENDIF.

        CLEAR ls_agreement.
        ls_agreement-material = ls_eord-matnr.
        ls_agreement-plant = ls_eord-werks.
        ls_agreement-source_list_purchasing_org = ls_eord-ekorg.
        ls_agreement-purchasing_document = ls_eord-ebeln.
        ls_agreement-purchasing_item = ls_eord-ebelp.
        ls_agreement-source_list_record = ls_eord-zeord.
        ls_agreement-source_list_valid_from = ls_eord-vdatu.
        ls_agreement-source_list_valid_to = ls_eord-bdatu.
        ls_agreement-source_list_blocked = ls_eord-notkz.
        ls_agreement-source_list_vendor = ls_eord-lifnr.
        ls_agreement-source_list_fixed = ls_eord-flifn.
        ls_agreement-source_list_mrp_usage = ls_eord-autet.
        ls_agreement-purchasing_org = ls_ekko-ekorg.
        ls_agreement-vendor = ls_ekko-lifnr.
        ls_agreement-document_category = ls_ekko-bstyp.
        ls_agreement-agreement_valid_from = ls_ekko-kdatb.
        ls_agreement-agreement_valid_to = ls_ekko-kdate.
        ls_agreement-header_deletion_indicator = ls_ekko-loekz.
        ls_agreement-item_deletion_indicator = ls_ekpo-loekz.
        ls_agreement-item_delivery_complete = ls_ekpo-elikz.
        APPEND ls_agreement TO rt_agreements.
      ENDLOOP.
    ENDLOOP.

    SORT rt_agreements BY material plant source_list_purchasing_org
      purchasing_document purchasing_item source_list_record.
    DELETE ADJACENT DUPLICATES FROM rt_agreements
      COMPARING material plant source_list_purchasing_org
        purchasing_document purchasing_item source_list_record.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_source_contexts_bulk.
    TYPES:
      BEGIN OF ty_material_plant,
        material TYPE mara-matnr,
        plant    TYPE t001w-werks,
      END OF ty_material_plant.
    TYPES ty_material_plants TYPE STANDARD TABLE OF ty_material_plant
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_policy_lookup,
        material                TYPE mara-matnr,
        plant                   TYPE t001w-werks,
        source_list_required    TYPE marc-kordb,
        quota_arrangement_usage TYPE marc-usequ,
      END OF ty_policy_lookup.
    TYPES ty_policy_lookups TYPE HASHED TABLE OF ty_policy_lookup
      WITH UNIQUE KEY material plant.
    DATA lt_material_plants TYPE ty_material_plants.
    DATA lt_policy_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA lt_policy_lookups TYPE ty_policy_lookups.
    DATA lt_source_list_entries TYPE zif_repl_source_repo=>ty_source_contexts.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_material_plants = CORRESPONDING #( it_requests ).
    SORT lt_material_plants BY material plant.
    DELETE ADJACENT DUPLICATES FROM lt_material_plants
      COMPARING material plant.

    SELECT matnr AS material,
           werks AS plant,
           kordb AS source_list_required,
           usequ AS quota_arrangement_usage
      FROM marc
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE matnr = @lt_material_plants-material
        AND werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_policy_contexts.

    IF lt_policy_contexts IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_policy_contexts INTO DATA(ls_policy_context).
      INSERT VALUE #(
        material                = ls_policy_context-material
        plant                   = ls_policy_context-plant
        source_list_required    = ls_policy_context-source_list_required
        quota_arrangement_usage =
          ls_policy_context-quota_arrangement_usage )
        INTO TABLE lt_policy_lookups.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           lifnr AS source_list_vendor,
           ekorg AS source_list_purchasing_org,
           ebeln AS source_list_agreement,
           ebelp AS source_list_agreement_item,
           zeord AS source_list_record,
           vdatu AS source_list_valid_from,
           bdatu AS source_list_valid_to,
           notkz AS source_list_blocked,
           flifn AS source_list_fixed,
           autet AS source_list_mrp_usage
      FROM eord
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE matnr = @lt_material_plants-material
        AND werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_source_list_entries.
    SORT lt_source_list_entries BY material plant source_list_vendor
      source_list_purchasing_org source_list_valid_from source_list_record.

    rt_contexts = lt_policy_contexts.
    LOOP AT lt_source_list_entries INTO DATA(ls_entry).
      READ TABLE lt_policy_lookups INTO DATA(ls_policy)
        WITH TABLE KEY material = ls_entry-material
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
      BEGIN OF ty_quota_header,
        matnr TYPE equk-matnr,
        werks TYPE equk-werks,
        vdatu TYPE equk-vdatu,
        bdatu TYPE equk-bdatu,
        qunum TYPE equk-qunum,
        scmng TYPE equk-scmng,
      END OF ty_quota_header,
      ty_quota_headers TYPE STANDARD TABLE OF ty_quota_header
        WITH EMPTY KEY,
      BEGIN OF ty_quota_item,
        qunum TYPE equp-qunum,
        qupos TYPE equp-qupos,
        preih TYPE equp-preih,
        minls TYPE equp-minls,
        maxls TYPE equp-maxls,
        rdprf TYPE equp-rdprf,
        kzein TYPE equp-kzein,
        beskz TYPE equp-beskz,
        sobes TYPE equp-sobes,
        lifnr TYPE equp-lifnr,
        quote TYPE equp-quote,
        qubmg TYPE equp-qubmg,
        qumng TYPE equp-qumng,
        maxmg TYPE equp-maxmg,
      END OF ty_quota_item,
      ty_quota_items TYPE SORTED TABLE OF ty_quota_item
        WITH NON-UNIQUE KEY qunum.
    DATA lt_equk TYPE ty_quota_headers.
    DATA lt_equp TYPE ty_quota_items.
    DATA ls_arrangement TYPE zif_repl_source_repo=>ty_quota_arrangement.
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

    SELECT matnr,
           werks,
           vdatu,
           bdatu,
           qunum,
           scmng
      FROM equk
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE matnr = @lt_material_plants-material
        AND werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_equk.

    IF lt_equk IS INITIAL.
      RETURN.
    ENDIF.

    SELECT qunum,
           qupos,
           preih,
           minls,
           maxls,
           rdprf,
           kzein,
           beskz,
           sobes,
           lifnr,
           quote,
           qubmg,
           qumng,
           maxmg
      FROM equp
      FOR ALL ENTRIES IN @lt_equk
      WHERE qunum = @lt_equk-qunum
      INTO CORRESPONDING FIELDS OF TABLE @lt_equp.

    LOOP AT lt_equk INTO DATA(ls_equk).
      LOOP AT lt_equp INTO DATA(ls_equp)
          WHERE qunum = ls_equk-qunum.
        CLEAR ls_arrangement.
        ls_arrangement-material = ls_equk-matnr.
        ls_arrangement-plant = ls_equk-werks.
        ls_arrangement-quota_valid_from = ls_equk-vdatu.
        ls_arrangement-quota_valid_to = ls_equk-bdatu.
        ls_arrangement-quota_number = ls_equk-qunum.
        ls_arrangement-minimum_split_quantity = ls_equk-scmng.
        ls_arrangement-quota_item = ls_equp-qupos.
        ls_arrangement-quota_priority = ls_equp-preih.
        ls_arrangement-quota_minimum_lot_size = ls_equp-minls.
        ls_arrangement-quota_maximum_lot_size = ls_equp-maxls.
        ls_arrangement-quota_rounding_profile = ls_equp-rdprf.
        ls_arrangement-source_assigned_once = ls_equp-kzein.
        ls_arrangement-procurement_type = ls_equp-beskz.
        ls_arrangement-special_procurement_type = ls_equp-sobes.
        ls_arrangement-vendor = ls_equp-lifnr.
        ls_arrangement-quota = ls_equp-quote.
        ls_arrangement-quota_base_quantity = ls_equp-qubmg.
        ls_arrangement-quota_allocated_quantity = ls_equp-qumng.
        ls_arrangement-quota_maximum_quantity = ls_equp-maxmg.
        APPEND ls_arrangement TO rt_arrangements.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_roundings_bulk.
    IF it_profile_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT werks AS plant,
           rdprf AS rounding_profile,
           rdzae AS level_number,
           bdmng AS threshold_quantity,
           vormg AS rounding_quantity
      FROM rdpr
      FOR ALL ENTRIES IN @it_profile_keys
      WHERE werks = @it_profile_keys-plant
        AND rdprf = @it_profile_keys-rounding_profile
      INTO CORRESPONDING FIELDS OF TABLE @rt_profiles.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_usage_rules_bulk.
    IF it_usages IS INITIAL.
      RETURN.
    ENDIF.

    SELECT usequ AS quota_usage,
           qbest AS includes_purchase_orders,
           qlpet AS includes_manual_sa_schedules,
           qplaf AS includes_manual_planned_orders,
           qbanf AS includes_purchase_requisitions,
           qdisp AS active_in_automatic_mrp,
           qfauf AS active_in_production_orders,
           qfir AS includes_invoices
      FROM tmq2
      FOR ALL ENTRIES IN @it_usages
      WHERE usequ = @it_usages-quota_usage
      INTO CORRESPONDING FIELDS OF TABLE @rt_rules.
  ENDMETHOD.

ENDCLASS.
