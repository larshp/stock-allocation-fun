CLASS zcl_mard_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    INTERFACES zif_so_reservation_finder.

  PRIVATE SECTION.
    METHODS convert_to_stock_quantity
      IMPORTING
        iv_quantity        TYPE decfloat34
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_mard_stock_repository IMPLEMENTATION.

  METHOD zif_stock_repository~get_projected_receipts.
    DATA(lt_results) =
      zif_stock_repository~get_projected_receipts_bulk(
        it_requests                    = VALUE #(
          ( request_id   = 'SINGLE-PROJECTED'
            material     = iv_material
            plant        = iv_plant
            through_date = iv_through_date ) )
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_po_confirmations    = abap_false
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    READ TABLE lt_results INTO DATA(ls_result)
      WITH KEY request_id = 'SINGLE-PROJECTED'.
    IF sy-subrc = 0.
      rt_receipts = ls_result-receipts.
      SORT rt_receipts BY material plant base_unit receipt_date source_type
        source_document source_item source_schedule_line.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts_bulk.
    TYPES:
      BEGIN OF ty_scope,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_scope.
    TYPES ty_scopes TYPE SORTED TABLE OF ty_scope
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_po_item,
        source_document     TYPE ekpo-ebeln,
        source_item         TYPE ekpo-ebelp,
        material            TYPE ekpo-matnr,
        plant               TYPE ekpo-werks,
        storage_location    TYPE ekpo-lgort,
        delivery_complete   TYPE ekpo-elikz,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
      END OF ty_po_item.
    TYPES ty_po_items TYPE STANDARD TABLE OF ty_po_item WITH EMPTY KEY.
    TYPES ty_po_item_index TYPE HASHED TABLE OF ty_po_item
      WITH UNIQUE KEY source_document source_item.
    TYPES:
      BEGIN OF ty_po_document,
        source_document     TYPE ekko-ebeln,
        document_category   TYPE ekko-bstyp,
        supplying_plant     TYPE ekko-reswk,
        special_procurement TYPE ekko-bsakz,
      END OF ty_po_document.
    TYPES ty_po_documents TYPE STANDARD TABLE OF ty_po_document
      WITH EMPTY KEY.
    TYPES ty_po_document_index TYPE HASHED TABLE OF ty_po_document
      WITH UNIQUE KEY source_document.
    TYPES:
      BEGIN OF ty_po_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_po_unit.
    TYPES ty_po_units TYPE STANDARD TABLE OF ty_po_unit WITH EMPTY KEY.
    TYPES ty_po_unit_index TYPE HASHED TABLE OF ty_po_unit
      WITH UNIQUE KEY material.
    TYPES:
      BEGIN OF ty_po_schedule_key,
        source_document TYPE eket-ebeln,
        source_item     TYPE eket-ebelp,
        through_date    TYPE d,
      END OF ty_po_schedule_key.
    TYPES ty_po_schedule_keys TYPE STANDARD TABLE OF ty_po_schedule_key
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_schedule_row,
        source_document      TYPE eket-ebeln,
        source_item          TYPE eket-ebelp,
        source_schedule_line TYPE eket-etenr,
        receipt_date         TYPE eket-eindt,
        scheduled_quantity   TYPE eket-menge,
        issued_quantity      TYPE eket-wamng,
        received_quantity    TYPE eket-wemng,
        batch                TYPE eket-charg,
      END OF ty_po_schedule_row.
    TYPES ty_po_schedule_rows TYPE STANDARD TABLE OF ty_po_schedule_row
      WITH EMPTY KEY.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_schedule,
        material             TYPE ekpo-matnr,
        plant                TYPE ekpo-werks,
        base_unit            TYPE mara-meins,
        source_document      TYPE eket-ebeln,
        source_item          TYPE eket-ebelp,
        source_schedule_line TYPE eket-etenr,
        receipt_date         TYPE eket-eindt,
        scheduled_quantity   TYPE eket-menge,
        issued_quantity      TYPE eket-wamng,
        received_quantity    TYPE eket-wemng,
        storage_location     TYPE ekpo-lgort,
        batch                TYPE eket-charg,
        delivery_complete    TYPE ekpo-elikz,
        order_to_base_num    TYPE ekpo-umrez,
        order_to_base_denom  TYPE ekpo-umren,
      END OF ty_schedule.
    TYPES ty_schedules TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_production_receipt,
        material            TYPE afpo-matnr,
        plant               TYPE afpo-werks,
        base_unit           TYPE mara-meins,
        production_order    TYPE afpo-aufnr,
        production_item     TYPE afpo-posnr,
        order_category      TYPE aufk-autyp,
        receipt_date        TYPE afko-gltrp,
        order_quantity      TYPE afpo-psmng,
        received_quantity   TYPE afpo-wemng,
        order_to_base_num   TYPE afpo-umrez,
        order_to_base_denom TYPE afpo-umren,
        sales_order         TYPE afpo-kdauf,
        storage_location    TYPE afpo-lgort,
        batch               TYPE afpo-charg,
      END OF ty_production_receipt.
    TYPES ty_production_receipts TYPE STANDARD TABLE OF
      ty_production_receipt WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_production_order_key,
        production_order TYPE afko-aufnr,
        through_date     TYPE d,
      END OF ty_production_order_key.
    TYPES ty_production_order_keys TYPE HASHED TABLE OF
      ty_production_order_key WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_production_order_date,
        production_order TYPE afko-aufnr,
        receipt_date     TYPE afko-gltrp,
      END OF ty_production_order_date.
    TYPES ty_production_order_dates TYPE STANDARD TABLE OF
      ty_production_order_date WITH EMPTY KEY.
    TYPES ty_production_order_date_index TYPE HASHED TABLE OF
      ty_production_order_date WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_production_order_status,
        production_order TYPE aufk-aufnr,
        order_category   TYPE aufk-autyp,
      END OF ty_production_order_status.
    TYPES ty_production_order_statuses TYPE STANDARD TABLE OF
      ty_production_order_status WITH EMPTY KEY.
    TYPES ty_production_order_status_index TYPE HASHED TABLE OF
      ty_production_order_status WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_pr_receipt,
        material                 TYPE eban-matnr,
        plant                    TYPE eban-werks,
        source_document          TYPE eban-banfn,
        source_item              TYPE eban-bnfpo,
        item_category            TYPE eban-pstyp,
        supplying_plant          TYPE eban-reswk,
        storage_location         TYPE eban-lgort,
        receipt_date             TYPE eban-lfdat,
        requested_quantity       TYPE eban-menge,
        ordered_quantity         TYPE eban-bsmng,
        requisition_unit         TYPE eban-meins,
        base_unit                TYPE mara-meins,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_pr_receipt.
    TYPES ty_pr_receipts TYPE STANDARD TABLE OF ty_pr_receipt
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_pr_unit_key,
        material         TYPE eban-matnr,
        requisition_unit TYPE eban-meins,
      END OF ty_pr_unit_key.
    TYPES ty_pr_unit_keys TYPE SORTED TABLE OF ty_pr_unit_key
      WITH UNIQUE KEY material requisition_unit.
    TYPES:
      BEGIN OF ty_pr_unit_conversion,
        material                 TYPE marm-matnr,
        requisition_unit         TYPE marm-meinh,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_pr_unit_conversion.
    TYPES ty_pr_unit_conversions TYPE STANDARD TABLE OF
      ty_pr_unit_conversion WITH EMPTY KEY.
    TYPES ty_pr_unit_conversion_index TYPE HASHED TABLE OF
      ty_pr_unit_conversion WITH UNIQUE KEY material requisition_unit.
    TYPES:
      BEGIN OF ty_planned_receipt,
        material                 TYPE plaf-matnr,
        plant                    TYPE plaf-pwwrk,
        planned_order            TYPE plaf-plnum,
        fixed_indicator          TYPE plaf-auffx,
        planning_scenario        TYPE plaf-plscn,
        special_stock_indicator  TYPE plaf-sobkz,
        sales_order              TYPE plaf-kdauf,
        storage_location         TYPE plaf-lgort,
        receipt_date             TYPE plaf-pedtr,
        planned_quantity         TYPE plaf-gsmng,
        order_unit               TYPE plaf-meins,
        base_unit                TYPE mara-meins,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_planned_receipt.
    TYPES ty_planned_receipts TYPE STANDARD TABLE OF ty_planned_receipt
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_planned_unit_key,
        material   TYPE plaf-matnr,
        order_unit TYPE plaf-meins,
      END OF ty_planned_unit_key.
    TYPES ty_planned_unit_keys TYPE SORTED TABLE OF ty_planned_unit_key
      WITH UNIQUE KEY material order_unit.
    TYPES:
      BEGIN OF ty_planned_unit_conversion,
        material                 TYPE marm-matnr,
        order_unit               TYPE marm-meinh,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_planned_unit_conversion.
    TYPES ty_planned_unit_conversions TYPE STANDARD TABLE OF
      ty_planned_unit_conversion WITH EMPTY KEY.
    TYPES ty_planned_unit_conversion_index TYPE HASHED TABLE OF
      ty_planned_unit_conversion WITH UNIQUE KEY material order_unit.
    TYPES ty_projected_receipt_rows TYPE STANDARD TABLE OF
      zif_stock_repository=>ty_projected_receipt WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    DATA lt_scopes TYPE ty_scopes.
    DATA lt_po_items_raw TYPE ty_po_items.
    DATA lt_po_items TYPE ty_po_item_index.
    DATA lt_po_documents_raw TYPE ty_po_documents.
    DATA lt_po_documents TYPE ty_po_document_index.
    DATA lt_po_units_raw TYPE ty_po_units.
    DATA lt_po_units TYPE ty_po_unit_index.
    DATA lt_po_schedule_keys TYPE ty_po_schedule_keys.
    DATA lt_po_schedule_rows TYPE ty_po_schedule_rows.
    DATA lt_request_ids TYPE ty_request_ids.
    DATA lt_schedules TYPE ty_schedules.
    DATA lt_production_items_raw TYPE ty_production_receipts.
    DATA lt_production_receipts TYPE ty_production_receipts.
    DATA lt_production_order_keys TYPE ty_production_order_keys.
    DATA lt_production_order_dates_raw TYPE ty_production_order_dates.
    DATA lt_production_order_dates TYPE ty_production_order_date_index.
    DATA lt_prod_statuses_raw TYPE
      ty_production_order_statuses.
    DATA lt_prod_statuses TYPE
      ty_production_order_status_index.
    DATA lt_production_units_raw TYPE ty_po_units.
    DATA lt_production_units TYPE ty_po_unit_index.
    DATA lt_pr_receipts TYPE ty_pr_receipts.
    DATA lt_sto_pr_receipts TYPE ty_pr_receipts.
    DATA lt_pr_receipts_enriched TYPE ty_pr_receipts.
    DATA lt_pr_units_raw TYPE ty_po_units.
    DATA lt_pr_units TYPE ty_po_unit_index.
    DATA lt_pr_unit_keys TYPE ty_pr_unit_keys.
    DATA lt_pr_unit_conversions_raw TYPE ty_pr_unit_conversions.
    DATA lt_pr_unit_conversions TYPE ty_pr_unit_conversion_index.
    DATA lt_planned_candidates TYPE ty_planned_receipts.
    DATA lt_planned_receipts_enriched TYPE ty_planned_receipts.
    DATA lt_planned_units_raw TYPE ty_po_units.
    DATA lt_planned_units TYPE ty_po_unit_index.
    DATA lt_planned_unit_keys TYPE ty_planned_unit_keys.
    DATA lt_plan_uom_raw TYPE ty_planned_unit_conversions.
    DATA lt_planned_unit_conversions TYPE
      ty_planned_unit_conversion_index.
    DATA lt_planned_receipts TYPE ty_planned_receipts.
    DATA lt_receipts TYPE ty_projected_receipt_rows.
    DATA lt_confirmation_requests TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_requests.
    DATA lt_confirmation_results TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_results.
    DATA lv_initial_date TYPE d.
    DATA ls_scope TYPE ty_scope.
    DATA ls_result TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_result.
    DATA lv_confirmation_request_id TYPE ty_request_id.
    FIELD-SYMBOLS <ls_scope> TYPE ty_scope.
    DATA(lo_po_calculator) = NEW zcl_po_sched_qty_calc( ).

    IF ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_request-through_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_scopes ASSIGNING <ls_scope>
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        IF <ls_scope>-through_date < ls_request-through_date.
          <ls_scope>-through_date = ls_request-through_date.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          INTO TABLE lt_scopes.
      ENDIF.
    ENDLOOP.

    IF iv_include_po_receipts = abap_false
        AND iv_include_po_confirmations = abap_false
        AND iv_include_sto_in_transit = abap_false
        AND iv_include_unissued_sto = abap_false
        AND iv_include_prod_receipts = abap_false
        AND iv_include_pr_receipts = abap_false
        AND iv_include_sto_pr_receipts = abap_false
        AND iv_include_planned_receipts = abap_false
        AND iv_include_fixed_planned = abap_false
        AND iv_include_sched_agmt_receipts = abap_false.
      LOOP AT it_requests INTO ls_request.
        APPEND VALUE #(
          request_id   = ls_request-request_id
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          TO rt_results.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF iv_include_po_receipts = abap_true.
      SELECT ebeln AS source_document,
             ebelp AS source_item,
             matnr AS material,
             werks AS plant,
             lgort AS storage_location,
             elikz AS delivery_complete,
             umrez AS order_to_base_num,
             umren AS order_to_base_denom
        FROM ekpo
        FOR ALL ENTRIES IN @lt_scopes
        WHERE matnr = @lt_scopes-material
          AND werks = @lt_scopes-plant
          AND pstyp = '0'
          AND knttp = @space
          AND loekz = @space
          AND elikz = @space
          AND retpo = @space
          AND wepos = 'X'
          AND insmk = @space
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_items_raw.

      LOOP AT lt_po_items_raw INTO DATA(ls_po_item_raw).
        INSERT ls_po_item_raw INTO TABLE lt_po_items.
      ENDLOOP.

      IF lt_po_items IS NOT INITIAL.
        SELECT ebeln AS source_document
          FROM ekko
          FOR ALL ENTRIES IN @lt_po_items
          WHERE ebeln = @lt_po_items-source_document
            AND bstyp = 'F'
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_documents_raw.

        SELECT matnr AS material,
               meins AS base_unit
          FROM mara
          FOR ALL ENTRIES IN @lt_po_items
          WHERE matnr = @lt_po_items-material
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_units_raw.

        LOOP AT lt_po_documents_raw INTO DATA(ls_po_document_raw).
          INSERT ls_po_document_raw INTO TABLE lt_po_documents.
        ENDLOOP.
        LOOP AT lt_po_units_raw INTO DATA(ls_po_unit_raw).
          INSERT ls_po_unit_raw INTO TABLE lt_po_units.
        ENDLOOP.

        LOOP AT lt_po_items INTO DATA(ls_po_item).
          READ TABLE lt_scopes ASSIGNING <ls_scope>
            WITH TABLE KEY material = ls_po_item-material
                           plant = ls_po_item-plant.
          IF sy-subrc = 0.
            APPEND VALUE #(
              source_document = ls_po_item-source_document
              source_item     = ls_po_item-source_item
              through_date    = <ls_scope>-through_date )
              TO lt_po_schedule_keys.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lt_po_schedule_keys IS NOT INITIAL.
        SELECT ebeln AS source_document,
               ebelp AS source_item,
               etenr AS source_schedule_line,
               eindt AS receipt_date,
               menge AS scheduled_quantity,
               wamng AS issued_quantity,
               wemng AS received_quantity,
               charg AS batch
          FROM eket
          FOR ALL ENTRIES IN @lt_po_schedule_keys
          WHERE ebeln = @lt_po_schedule_keys-source_document
            AND ebelp = @lt_po_schedule_keys-source_item
            AND eindt > @lv_initial_date
            AND eindt <= @lt_po_schedule_keys-through_date
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedule_rows.

        LOOP AT lt_po_schedule_rows INTO DATA(ls_po_schedule_row).
          READ TABLE lt_po_items INTO ls_po_item
            WITH TABLE KEY source_document =
                             ls_po_schedule_row-source_document
                           source_item = ls_po_schedule_row-source_item.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_documents TRANSPORTING NO FIELDS
            WITH TABLE KEY source_document =
              ls_po_schedule_row-source_document.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_units INTO DATA(ls_po_unit)
            WITH TABLE KEY material = ls_po_item-material.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material             = ls_po_item-material
            plant                = ls_po_item-plant
            base_unit            = ls_po_unit-base_unit
            source_document      = ls_po_schedule_row-source_document
            source_item          = ls_po_schedule_row-source_item
            source_schedule_line =
              ls_po_schedule_row-source_schedule_line
            receipt_date         = ls_po_schedule_row-receipt_date
            scheduled_quantity   = ls_po_schedule_row-scheduled_quantity
            issued_quantity      = ls_po_schedule_row-issued_quantity
            received_quantity    = ls_po_schedule_row-received_quantity
            storage_location     = ls_po_item-storage_location
            batch                = ls_po_schedule_row-batch
            delivery_complete    = ls_po_item-delivery_complete
            order_to_base_num    = ls_po_item-order_to_base_num
            order_to_base_denom  = ls_po_item-order_to_base_denom )
            TO lt_schedules.
        ENDLOOP.
      ENDIF.

      LOOP AT lt_schedules INTO DATA(ls_po_schedule).
        DATA(lv_po_quantity) =
          lo_po_calculator->calculate_open_base_quantity(
            iv_scheduled_quantity  = ls_po_schedule-scheduled_quantity
            iv_received_quantity   = ls_po_schedule-received_quantity
            iv_order_to_base_num   = ls_po_schedule-order_to_base_num
            iv_order_to_base_denom = ls_po_schedule-order_to_base_denom ).
        DATA(lv_po_base_quantity) = convert_to_stock_quantity(
  iv_quantity = lv_po_quantity ).
        IF lv_po_base_quantity > 0.
          APPEND VALUE #(
            material             = ls_po_schedule-material
            plant                = ls_po_schedule-plant
            base_unit            = ls_po_schedule-base_unit
            receipt_date         = ls_po_schedule-receipt_date
            quantity             = lv_po_base_quantity
            source_type          = 'PO'
            source_document      = ls_po_schedule-source_document
            source_item          = ls_po_schedule-source_item
            storage_location     = ls_po_schedule-storage_location
            batch                = ls_po_schedule-batch
            source_schedule_line = ls_po_schedule-source_schedule_line )
            TO lt_receipts.
        ENDIF.
      ENDLOOP.
      CLEAR lt_schedules.
    ENDIF.

    IF iv_include_sched_agmt_receipts = abap_true.
      CLEAR lt_po_items_raw.
      CLEAR lt_po_items.
      CLEAR lt_po_documents_raw.
      CLEAR lt_po_documents.
      CLEAR lt_po_units_raw.
      CLEAR lt_po_units.
      CLEAR lt_po_schedule_keys.
      CLEAR lt_po_schedule_rows.
      CLEAR lt_schedules.

      SELECT ebeln AS source_document,
             ebelp AS source_item,
             matnr AS material,
             werks AS plant,
             lgort AS storage_location,
             elikz AS delivery_complete,
             umrez AS order_to_base_num,
             umren AS order_to_base_denom
        FROM ekpo
        FOR ALL ENTRIES IN @lt_scopes
        WHERE matnr = @lt_scopes-material
          AND werks = @lt_scopes-plant
          AND pstyp = '0'
          AND knttp = @space
          AND loekz = @space
          AND elikz = @space
          AND stapo = @space
          AND retpo = @space
          AND wepos = 'X'
          AND insmk = @space
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_items_raw.

      LOOP AT lt_po_items_raw INTO DATA(ls_sched_item_raw).
        INSERT ls_sched_item_raw INTO TABLE lt_po_items.
      ENDLOOP.

      IF lt_po_items IS NOT INITIAL.
        SELECT ebeln AS source_document,
               reswk AS supplying_plant
          FROM ekko
          FOR ALL ENTRIES IN @lt_po_items
          WHERE ebeln = @lt_po_items-source_document
            AND bstyp = 'L'
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_documents_raw.

        SELECT matnr AS material,
               meins AS base_unit
          FROM mara
          FOR ALL ENTRIES IN @lt_po_items
          WHERE matnr = @lt_po_items-material
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_units_raw.

        LOOP AT lt_po_documents_raw INTO DATA(ls_sched_document_raw).
          INSERT ls_sched_document_raw INTO TABLE lt_po_documents.
        ENDLOOP.
        LOOP AT lt_po_units_raw INTO DATA(ls_sched_unit_raw).
          INSERT ls_sched_unit_raw INTO TABLE lt_po_units.
        ENDLOOP.

        LOOP AT lt_po_items INTO DATA(ls_sched_item).
          READ TABLE lt_scopes ASSIGNING <ls_scope>
            WITH TABLE KEY material = ls_sched_item-material
                           plant = ls_sched_item-plant.
          IF sy-subrc = 0.
            APPEND VALUE #(
              source_document = ls_sched_item-source_document
              source_item     = ls_sched_item-source_item
              through_date    = <ls_scope>-through_date )
              TO lt_po_schedule_keys.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lt_po_schedule_keys IS NOT INITIAL.
        SELECT ebeln AS source_document,
               ebelp AS source_item,
               etenr AS source_schedule_line,
               eindt AS receipt_date,
               menge AS scheduled_quantity,
               wamng AS issued_quantity,
               wemng AS received_quantity,
               charg AS batch
          FROM eket
          FOR ALL ENTRIES IN @lt_po_schedule_keys
          WHERE ebeln = @lt_po_schedule_keys-source_document
            AND ebelp = @lt_po_schedule_keys-source_item
            AND eindt > @lv_initial_date
            AND eindt <= @lt_po_schedule_keys-through_date
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedule_rows.

        LOOP AT lt_po_schedule_rows INTO DATA(ls_sched_schedule_row).
          READ TABLE lt_po_items INTO ls_sched_item
            WITH TABLE KEY source_document =
                             ls_sched_schedule_row-source_document
                           source_item = ls_sched_schedule_row-source_item.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_documents INTO DATA(ls_sched_document)
            WITH TABLE KEY source_document =
              ls_sched_schedule_row-source_document.
          IF sy-subrc <> 0 OR ls_sched_document-supplying_plant IS NOT INITIAL.
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_units INTO DATA(ls_sched_unit)
            WITH TABLE KEY material = ls_sched_item-material.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material             = ls_sched_item-material
            plant                = ls_sched_item-plant
            base_unit            = ls_sched_unit-base_unit
            source_document      = ls_sched_schedule_row-source_document
            source_item          = ls_sched_schedule_row-source_item
            source_schedule_line =
              ls_sched_schedule_row-source_schedule_line
            receipt_date         = ls_sched_schedule_row-receipt_date
            scheduled_quantity   = ls_sched_schedule_row-scheduled_quantity
            issued_quantity      = ls_sched_schedule_row-issued_quantity
            received_quantity    = ls_sched_schedule_row-received_quantity
            storage_location     = ls_sched_item-storage_location
            batch                = ls_sched_schedule_row-batch
            delivery_complete    = ls_sched_item-delivery_complete
            order_to_base_num    = ls_sched_item-order_to_base_num
            order_to_base_denom  = ls_sched_item-order_to_base_denom )
            TO lt_schedules.
        ENDLOOP.
      ENDIF.

      DATA(lo_sched_agreement_calculator) = NEW zcl_po_sched_qty_calc( ).
      LOOP AT lt_schedules INTO DATA(ls_sched_agreement).
        DATA(lv_sched_agreement_quantity) =
          lo_sched_agreement_calculator->calculate_open_base_quantity(
            iv_scheduled_quantity  = ls_sched_agreement-scheduled_quantity
            iv_received_quantity   = ls_sched_agreement-received_quantity
            iv_order_to_base_num   = ls_sched_agreement-order_to_base_num
            iv_order_to_base_denom =
              ls_sched_agreement-order_to_base_denom ).
        DATA(lv_sched_agreement_base_qty) =
          convert_to_stock_quantity(
            iv_quantity = lv_sched_agreement_quantity ).
        IF lv_sched_agreement_base_qty > 0.
          APPEND VALUE #(
            material             = ls_sched_agreement-material
            plant                = ls_sched_agreement-plant
            base_unit            = ls_sched_agreement-base_unit
            receipt_date         = ls_sched_agreement-receipt_date
            quantity             = lv_sched_agreement_base_qty
            source_type          = 'SCHED_AGREEMENT'
            source_document      = ls_sched_agreement-source_document
            source_item          = ls_sched_agreement-source_item
            storage_location     = ls_sched_agreement-storage_location
            batch                = ls_sched_agreement-batch
            source_schedule_line =
              ls_sched_agreement-source_schedule_line )
            TO lt_receipts.
        ENDIF.
      ENDLOOP.
      CLEAR lt_schedules.
    ENDIF.

    IF iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true.
      CLEAR lt_po_items_raw.
      CLEAR lt_po_items.
      CLEAR lt_po_documents_raw.
      CLEAR lt_po_documents.
      CLEAR lt_po_units_raw.
      CLEAR lt_po_units.
      CLEAR lt_po_schedule_keys.
      CLEAR lt_po_schedule_rows.
      CLEAR lt_schedules.

      SELECT ebeln AS source_document,
             ebelp AS source_item,
             matnr AS material,
             werks AS plant,
             lgort AS storage_location,
             elikz AS delivery_complete,
             umrez AS order_to_base_num,
             umren AS order_to_base_denom
        FROM ekpo
        FOR ALL ENTRIES IN @lt_scopes
        WHERE matnr = @lt_scopes-material
          AND werks = @lt_scopes-plant
          AND pstyp = '7'
          AND knttp = @space
          AND loekz = @space
          AND stapo = @space
          AND retpo = @space
          AND wepos = 'X'
          AND insmk = @space
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_items_raw.

      LOOP AT lt_po_items_raw INTO DATA(ls_sto_item_raw).
        INSERT ls_sto_item_raw INTO TABLE lt_po_items.
      ENDLOOP.

      IF lt_po_items IS NOT INITIAL.
        SELECT ebeln AS source_document,
               bstyp AS document_category,
               reswk AS supplying_plant,
               bsakz AS special_procurement
          FROM ekko
          FOR ALL ENTRIES IN @lt_po_items
          WHERE ebeln = @lt_po_items-source_document
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_documents_raw.

        SELECT matnr AS material,
               meins AS base_unit
          FROM mara
          FOR ALL ENTRIES IN @lt_po_items
          WHERE matnr = @lt_po_items-material
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_units_raw.

        LOOP AT lt_po_documents_raw INTO DATA(ls_sto_document_raw).
          INSERT ls_sto_document_raw INTO TABLE lt_po_documents.
        ENDLOOP.
        LOOP AT lt_po_units_raw INTO DATA(ls_sto_unit_raw).
          INSERT ls_sto_unit_raw INTO TABLE lt_po_units.
        ENDLOOP.

        LOOP AT lt_po_items INTO DATA(ls_sto_item).
          READ TABLE lt_scopes ASSIGNING <ls_scope>
            WITH TABLE KEY material = ls_sto_item-material
                           plant = ls_sto_item-plant.
          IF sy-subrc = 0.
            APPEND VALUE #(
              source_document = ls_sto_item-source_document
              source_item     = ls_sto_item-source_item
              through_date    = <ls_scope>-through_date )
              TO lt_po_schedule_keys.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lt_po_schedule_keys IS NOT INITIAL.
        SELECT ebeln AS source_document,
               ebelp AS source_item,
               etenr AS source_schedule_line,
               eindt AS receipt_date,
               menge AS scheduled_quantity,
               wamng AS issued_quantity,
               wemng AS received_quantity,
               charg AS batch
          FROM eket
          FOR ALL ENTRIES IN @lt_po_schedule_keys
          WHERE ebeln = @lt_po_schedule_keys-source_document
            AND ebelp = @lt_po_schedule_keys-source_item
            AND eindt > @lv_initial_date
            AND eindt <= @lt_po_schedule_keys-through_date
          INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedule_rows.

        LOOP AT lt_po_schedule_rows INTO DATA(ls_sto_schedule_row).
          READ TABLE lt_po_items INTO ls_sto_item
            WITH TABLE KEY source_document =
                             ls_sto_schedule_row-source_document
                           source_item = ls_sto_schedule_row-source_item.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_documents INTO DATA(ls_sto_document)
            WITH TABLE KEY source_document =
              ls_sto_schedule_row-source_document.
          IF sy-subrc <> 0
              OR ls_sto_document-supplying_plant IS INITIAL
              OR ls_sto_document-special_procurement = 'T'
              OR ( ls_sto_document-document_category <> 'F'
                AND ls_sto_document-document_category <> 'L' ).
            CONTINUE.
          ENDIF.
          READ TABLE lt_po_units INTO DATA(ls_sto_unit)
            WITH TABLE KEY material = ls_sto_item-material.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material             = ls_sto_item-material
            plant                = ls_sto_item-plant
            base_unit            = ls_sto_unit-base_unit
            source_document      = ls_sto_schedule_row-source_document
            source_item          = ls_sto_schedule_row-source_item
            source_schedule_line =
              ls_sto_schedule_row-source_schedule_line
            receipt_date         = ls_sto_schedule_row-receipt_date
            scheduled_quantity   = ls_sto_schedule_row-scheduled_quantity
            issued_quantity      = ls_sto_schedule_row-issued_quantity
            received_quantity    = ls_sto_schedule_row-received_quantity
            storage_location     = ls_sto_item-storage_location
            batch                = ls_sto_schedule_row-batch
            delivery_complete    = ls_sto_item-delivery_complete
            order_to_base_num    = ls_sto_item-order_to_base_num
            order_to_base_denom  = ls_sto_item-order_to_base_denom )
            TO lt_schedules.
        ENDLOOP.
      ENDIF.

      DATA(lo_sto_calculator) = NEW zcl_po_sched_qty_calc( ).
      LOOP AT lt_schedules INTO DATA(ls_sto_schedule).
        IF iv_include_sto_in_transit = abap_true.
          DATA(lv_sto_issued_quantity) =
            lo_sto_calculator->calculate_open_issued_qty(
              iv_issued_quantity     = ls_sto_schedule-issued_quantity
              iv_received_quantity   = ls_sto_schedule-received_quantity
              iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
              iv_order_to_base_denom =
                ls_sto_schedule-order_to_base_denom ).
          DATA(lv_sto_issued_base_qty) =
            convert_to_stock_quantity(
              iv_quantity = lv_sto_issued_quantity ).
          IF lv_sto_issued_base_qty > 0.
            APPEND VALUE #(
              material             = ls_sto_schedule-material
              plant                = ls_sto_schedule-plant
              base_unit            = ls_sto_schedule-base_unit
              receipt_date         = ls_sto_schedule-receipt_date
              quantity             = lv_sto_issued_base_qty
              source_type          = 'STO_IN_TRANSIT'
              source_document      = ls_sto_schedule-source_document
              source_item          = ls_sto_schedule-source_item
              storage_location     = ls_sto_schedule-storage_location
              batch                = ls_sto_schedule-batch
              source_schedule_line = ls_sto_schedule-source_schedule_line )
              TO lt_receipts.
          ENDIF.
        ENDIF.
        IF iv_include_unissued_sto = abap_true
            AND ls_sto_schedule-delivery_complete = space.
          DATA(lv_sto_unissued_quantity) =
            lo_sto_calculator->calculate_open_unissued_qty(
              iv_scheduled_quantity  = ls_sto_schedule-scheduled_quantity
              iv_issued_quantity     = ls_sto_schedule-issued_quantity
              iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
              iv_order_to_base_denom =
                ls_sto_schedule-order_to_base_denom ).
          DATA(lv_sto_unissued_base_qty) =
            convert_to_stock_quantity(
              iv_quantity = lv_sto_unissued_quantity ).
          IF lv_sto_unissued_base_qty > 0.
            APPEND VALUE #(
              material             = ls_sto_schedule-material
              plant                = ls_sto_schedule-plant
              base_unit            = ls_sto_schedule-base_unit
              receipt_date         = ls_sto_schedule-receipt_date
              quantity             = lv_sto_unissued_base_qty
              source_type          = 'STO_UNISSUED'
              source_document      = ls_sto_schedule-source_document
              source_item          = ls_sto_schedule-source_item
              storage_location     = ls_sto_schedule-storage_location
              batch                = ls_sto_schedule-batch
              source_schedule_line = ls_sto_schedule-source_schedule_line )
              TO lt_receipts.
          ENDIF.
        ENDIF.
      ENDLOOP.
      CLEAR lt_schedules.
    ENDIF.

    IF iv_include_prod_receipts = abap_true
        OR iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true
        OR iv_include_planned_receipts = abap_true
        OR iv_include_fixed_planned = abap_true.
      IF iv_include_prod_receipts = abap_true.
        SELECT matnr AS material,
               werks AS plant,
               aufnr AS production_order,
               posnr AS production_item,
               psmng AS order_quantity,
               wemng AS received_quantity,
               umrez AS order_to_base_num,
               umren AS order_to_base_denom,
               kdauf AS sales_order,
               lgort AS storage_location,
               charg AS batch
          FROM afpo
          FOR ALL ENTRIES IN @lt_scopes
          WHERE matnr = @lt_scopes-material
            AND werks = @lt_scopes-plant
            AND wepos = 'X'
            AND xloek = @space
            AND elikz = @space
            AND knttp = @space
          INTO CORRESPONDING FIELDS OF TABLE
            @lt_production_items_raw.

        LOOP AT lt_production_items_raw INTO DATA(ls_production_item_raw).
          READ TABLE lt_scopes ASSIGNING <ls_scope>
            WITH TABLE KEY material = ls_production_item_raw-material
                           plant = ls_production_item_raw-plant.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_production_order_keys ASSIGNING
              FIELD-SYMBOL(<ls_production_order_key>)
            WITH TABLE KEY production_order =
              ls_production_item_raw-production_order.
          IF sy-subrc = 0.
            IF <ls_production_order_key>-through_date
                < <ls_scope>-through_date.
              <ls_production_order_key>-through_date =
                <ls_scope>-through_date.
            ENDIF.
          ELSE.
            INSERT VALUE #(
              production_order = ls_production_item_raw-production_order
              through_date     = <ls_scope>-through_date )
              INTO TABLE lt_production_order_keys.
          ENDIF.
        ENDLOOP.

        IF lt_production_order_keys IS NOT INITIAL.
          SELECT aufnr AS production_order,
                 gltrp AS receipt_date
            FROM afko
            FOR ALL ENTRIES IN @lt_production_order_keys
            WHERE aufnr = @lt_production_order_keys-production_order
              AND gltrp > @lv_initial_date
              AND gltrp <= @lt_production_order_keys-through_date
            INTO CORRESPONDING FIELDS OF TABLE
              @lt_production_order_dates_raw.
          LOOP AT lt_production_order_dates_raw
              INTO DATA(ls_production_order_date_raw).
            INSERT ls_production_order_date_raw
              INTO TABLE lt_production_order_dates.
          ENDLOOP.

          SELECT aufnr AS production_order,
                 autyp AS order_category
            FROM aufk
            FOR ALL ENTRIES IN @lt_production_order_keys
            WHERE aufnr = @lt_production_order_keys-production_order
              AND ( autyp = '10' OR autyp = '40' )
              AND phas1 = 'X'
              AND phas2 = @space
              AND phas3 = @space
              AND loekz = @space
            INTO CORRESPONDING FIELDS OF TABLE
              @lt_prod_statuses_raw.
          LOOP AT lt_prod_statuses_raw
              INTO DATA(ls_production_order_status_raw).
            INSERT ls_production_order_status_raw
              INTO TABLE lt_prod_statuses.
          ENDLOOP.

          IF lt_production_items_raw IS NOT INITIAL.
            SELECT matnr AS material,
                   meins AS base_unit
              FROM mara
              FOR ALL ENTRIES IN @lt_production_items_raw
              WHERE matnr = @lt_production_items_raw-material
              INTO CORRESPONDING FIELDS OF TABLE
                @lt_production_units_raw.
            LOOP AT lt_production_units_raw
                INTO DATA(ls_production_unit_raw).
              INSERT ls_production_unit_raw
                INTO TABLE lt_production_units.
            ENDLOOP.
          ENDIF.
        ENDIF.

        LOOP AT lt_production_items_raw INTO ls_production_item_raw.
          IF ls_production_item_raw-sales_order IS NOT INITIAL.
            CONTINUE.
          ENDIF.
          READ TABLE lt_prod_statuses
              INTO DATA(ls_production_order_status)
            WITH TABLE KEY production_order =
              ls_production_item_raw-production_order.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_production_order_dates
              INTO DATA(ls_production_order_date)
            WITH TABLE KEY production_order =
              ls_production_item_raw-production_order.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_scopes ASSIGNING <ls_scope>
            WITH TABLE KEY material = ls_production_item_raw-material
                           plant = ls_production_item_raw-plant.
          IF sy-subrc <> 0
              OR ls_production_order_date-receipt_date
                > <ls_scope>-through_date.
            CONTINUE.
          ENDIF.
          READ TABLE lt_production_units INTO DATA(ls_production_unit)
            WITH TABLE KEY material = ls_production_item_raw-material.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material            = ls_production_item_raw-material
            plant               = ls_production_item_raw-plant
            base_unit           = ls_production_unit-base_unit
            production_order    =
              ls_production_item_raw-production_order
            production_item     = ls_production_item_raw-production_item
            order_category      = ls_production_order_status-order_category
            receipt_date        = ls_production_order_date-receipt_date
            order_quantity      = ls_production_item_raw-order_quantity
            received_quantity   = ls_production_item_raw-received_quantity
            order_to_base_num   =
              ls_production_item_raw-order_to_base_num
            order_to_base_denom =
              ls_production_item_raw-order_to_base_denom
            storage_location    =
              ls_production_item_raw-storage_location
            batch               = ls_production_item_raw-batch )
            TO lt_production_receipts.
        ENDLOOP.

        DATA(lo_production_calculator) = NEW zcl_prod_order_qty_calc( ).
        LOOP AT lt_production_receipts INTO DATA(ls_production_receipt).
          DATA(lv_production_quantity) =
            lo_production_calculator->calculate_open_base_quantity(
              iv_order_quantity      = ls_production_receipt-order_quantity
              iv_received_quantity   = ls_production_receipt-received_quantity
              iv_order_to_base_num   = ls_production_receipt-order_to_base_num
              iv_order_to_base_denom =
                ls_production_receipt-order_to_base_denom ).
          DATA(lv_production_base_quantity) = convert_to_stock_quantity(
            iv_quantity = lv_production_quantity ).
          IF lv_production_base_quantity > 0.
            APPEND VALUE #(
              material         = ls_production_receipt-material
              plant            = ls_production_receipt-plant
              base_unit        = ls_production_receipt-base_unit
              receipt_date     = ls_production_receipt-receipt_date
              quantity         = lv_production_base_quantity
              source_type      = COND #(
                WHEN ls_production_receipt-order_category = '40'
                THEN 'PROCESS_ORDER'
                ELSE 'PRODUCTION' )
              source_document  = ls_production_receipt-production_order
              source_item      = ls_production_receipt-production_item
              storage_location = ls_production_receipt-storage_location
              batch            = ls_production_receipt-batch )
              TO lt_receipts.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF iv_include_pr_receipts = abap_true.
        SELECT matnr AS material,
               werks AS plant,
               banfn AS source_document,
               bnfpo AS source_item,
               pstyp AS item_category,
               reswk AS supplying_plant,
               lgort AS storage_location,
               lfdat AS receipt_date,
               menge AS requested_quantity,
               bsmng AS ordered_quantity,
               meins AS requisition_unit
          FROM eban
          FOR ALL ENTRIES IN @lt_scopes
          WHERE matnr = @lt_scopes-material
            AND werks = @lt_scopes-plant
            AND lfdat > @lv_initial_date
            AND lfdat <= @lt_scopes-through_date
            AND loekz = @space
            AND ebakz = @space
            AND blckd <> '1'
            AND pstyp = '0'
            AND knttp = @space
            AND sobkz = @space
          INTO CORRESPONDING FIELDS OF TABLE @lt_pr_receipts.
      ENDIF.

      IF iv_include_sto_pr_receipts = abap_true.
        SELECT matnr AS material,
               werks AS plant,
               banfn AS source_document,
               bnfpo AS source_item,
               pstyp AS item_category,
               reswk AS supplying_plant,
               lgort AS storage_location,
               lfdat AS receipt_date,
               menge AS requested_quantity,
               bsmng AS ordered_quantity,
               meins AS requisition_unit
          FROM eban
          FOR ALL ENTRIES IN @lt_scopes
          WHERE matnr = @lt_scopes-material
            AND werks = @lt_scopes-plant
            AND lfdat > @lv_initial_date
            AND lfdat <= @lt_scopes-through_date
            AND loekz = @space
            AND ebakz = @space
            AND blckd <> '1'
            AND pstyp = '7'
            AND knttp = @space
            AND sobkz = @space
          INTO CORRESPONDING FIELDS OF TABLE @lt_sto_pr_receipts.
        LOOP AT lt_sto_pr_receipts INTO DATA(ls_sto_pr_receipt).
          APPEND ls_sto_pr_receipt TO lt_pr_receipts.
        ENDLOOP.
      ENDIF.

      IF lt_pr_receipts IS NOT INITIAL.
        SELECT matnr AS material,
               meins AS base_unit
          FROM mara
          FOR ALL ENTRIES IN @lt_pr_receipts
          WHERE matnr = @lt_pr_receipts-material
          INTO CORRESPONDING FIELDS OF TABLE @lt_pr_units_raw.
        LOOP AT lt_pr_units_raw INTO DATA(ls_pr_unit_raw).
          INSERT ls_pr_unit_raw INTO TABLE lt_pr_units.
        ENDLOOP.

        LOOP AT lt_pr_receipts INTO DATA(ls_pr_unit_key_source).
          READ TABLE lt_pr_units TRANSPORTING NO FIELDS
            WITH TABLE KEY material = ls_pr_unit_key_source-material.
          IF sy-subrc = 0.
            INSERT VALUE #(
              material         = ls_pr_unit_key_source-material
              requisition_unit = ls_pr_unit_key_source-requisition_unit )
              INTO TABLE lt_pr_unit_keys.
          ENDIF.
        ENDLOOP.

        IF lt_pr_unit_keys IS NOT INITIAL.
          SELECT matnr AS material,
                 meinh AS requisition_unit,
                 umrez AS unit_to_base_numerator,
                 umren AS unit_to_base_denominator
            FROM marm
            FOR ALL ENTRIES IN @lt_pr_unit_keys
            WHERE matnr = @lt_pr_unit_keys-material
              AND meinh = @lt_pr_unit_keys-requisition_unit
            INTO CORRESPONDING FIELDS OF TABLE
              @lt_pr_unit_conversions_raw.
          LOOP AT lt_pr_unit_conversions_raw
              INTO DATA(ls_pr_unit_conversion_raw).
            INSERT ls_pr_unit_conversion_raw
              INTO TABLE lt_pr_unit_conversions.
          ENDLOOP.
        ENDIF.

        LOOP AT lt_pr_receipts INTO DATA(ls_pr_receipt_raw).
          IF ls_pr_receipt_raw-requested_quantity
              <= ls_pr_receipt_raw-ordered_quantity.
            CONTINUE.
          ENDIF.
          IF ls_pr_receipt_raw-item_category = '7'
              AND ( ls_pr_receipt_raw-supplying_plant IS INITIAL
                OR ls_pr_receipt_raw-supplying_plant =
                  ls_pr_receipt_raw-plant ).
            CONTINUE.
          ENDIF.
          READ TABLE lt_pr_units INTO DATA(ls_pr_base_unit)
            WITH TABLE KEY material = ls_pr_receipt_raw-material.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_pr_receipt_raw-base_unit = ls_pr_base_unit-base_unit.
          READ TABLE lt_pr_unit_conversions
              INTO DATA(ls_pr_conversion)
            WITH TABLE KEY material = ls_pr_receipt_raw-material
                           requisition_unit =
                             ls_pr_receipt_raw-requisition_unit.
          IF sy-subrc = 0.
            ls_pr_receipt_raw-unit_to_base_numerator =
              ls_pr_conversion-unit_to_base_numerator.
            ls_pr_receipt_raw-unit_to_base_denominator =
              ls_pr_conversion-unit_to_base_denominator.
          ENDIF.
          APPEND ls_pr_receipt_raw TO lt_pr_receipts_enriched.
        ENDLOOP.
        lt_pr_receipts = lt_pr_receipts_enriched.
      ENDIF.

      DATA(lo_pr_calculator) = NEW zcl_pr_open_qty_calc( ).
      LOOP AT lt_pr_receipts INTO DATA(ls_pr_receipt).
        DATA(lv_pr_unit_numerator) =
          ls_pr_receipt-unit_to_base_numerator.
        DATA(lv_pr_unit_denominator) =
          ls_pr_receipt-unit_to_base_denominator.
        IF ls_pr_receipt-requisition_unit = ls_pr_receipt-base_unit.
          lv_pr_unit_numerator = 1.
          lv_pr_unit_denominator = 1.
        ENDIF.
        DATA(lv_pr_open_base_quantity) =
          lo_pr_calculator->calculate_open_base_quantity(
            iv_requested_quantity = ls_pr_receipt-requested_quantity
            iv_ordered_quantity   = ls_pr_receipt-ordered_quantity
            iv_unit_to_base_num   = lv_pr_unit_numerator
            iv_unit_to_base_denom = lv_pr_unit_denominator ).
        DATA(lv_pr_quantity) = convert_to_stock_quantity(
          iv_quantity = lv_pr_open_base_quantity ).
        IF lv_pr_quantity > 0.
          APPEND VALUE #(
            material         = ls_pr_receipt-material
            plant            = ls_pr_receipt-plant
            base_unit        = ls_pr_receipt-base_unit
            receipt_date     = ls_pr_receipt-receipt_date
            quantity         = lv_pr_quantity
            source_type      = COND #(
              WHEN ls_pr_receipt-item_category = '7'
              THEN 'STO_PR'
              ELSE 'PR' )
            source_document  = ls_pr_receipt-source_document
            source_item      = ls_pr_receipt-source_item
            source_plant     = ls_pr_receipt-supplying_plant
            storage_location = ls_pr_receipt-storage_location )
            TO lt_receipts.
        ENDIF.
      ENDLOOP.

      IF iv_include_planned_receipts = abap_true
          OR iv_include_fixed_planned = abap_true.
        SELECT matnr AS material,
               pwwrk AS plant,
               plnum AS planned_order,
               auffx AS fixed_indicator,
               plscn AS planning_scenario,
               sobkz AS special_stock_indicator,
               kdauf AS sales_order,
               lgort AS storage_location,
               pedtr AS receipt_date,
               gsmng AS planned_quantity,
               meins AS order_unit
          FROM plaf
          FOR ALL ENTRIES IN @lt_scopes
          WHERE matnr = @lt_scopes-material
            AND pwwrk = @lt_scopes-plant
            AND gsmng > 0
            AND psttr >= @sy-datum
            AND psttr <= @lt_scopes-through_date
            AND pedtr >= @sy-datum
            AND pedtr <= @lt_scopes-through_date
          INTO CORRESPONDING FIELDS OF TABLE @lt_planned_candidates.

        LOOP AT lt_planned_candidates INTO DATA(ls_planned_candidate).
          IF ls_planned_candidate-planning_scenario IS NOT INITIAL
              OR ls_planned_candidate-special_stock_indicator <> space
              OR ls_planned_candidate-sales_order IS NOT INITIAL
              OR ( ls_planned_candidate-fixed_indicator IS INITIAL
                AND iv_include_planned_receipts <> abap_true )
              OR ( ls_planned_candidate-fixed_indicator IS NOT INITIAL
                AND iv_include_fixed_planned <> abap_true ).
            CONTINUE.
          ENDIF.
          APPEND ls_planned_candidate TO lt_planned_receipts.
        ENDLOOP.

        IF lt_planned_receipts IS NOT INITIAL.
          SELECT matnr AS material,
                 meins AS base_unit
            FROM mara
            FOR ALL ENTRIES IN @lt_planned_receipts
            WHERE matnr = @lt_planned_receipts-material
            INTO CORRESPONDING FIELDS OF TABLE @lt_planned_units_raw.
          LOOP AT lt_planned_units_raw INTO DATA(ls_planned_unit_raw).
            INSERT ls_planned_unit_raw INTO TABLE lt_planned_units.
          ENDLOOP.

          LOOP AT lt_planned_receipts INTO DATA(ls_planned_key_source).
            READ TABLE lt_planned_units TRANSPORTING NO FIELDS
              WITH TABLE KEY material = ls_planned_key_source-material.
            IF sy-subrc = 0.
              INSERT VALUE #(
                material   = ls_planned_key_source-material
                order_unit = ls_planned_key_source-order_unit )
                INTO TABLE lt_planned_unit_keys.
            ENDIF.
          ENDLOOP.

          IF lt_planned_unit_keys IS NOT INITIAL.
            SELECT matnr AS material,
                   meinh AS order_unit,
                   umrez AS unit_to_base_numerator,
                   umren AS unit_to_base_denominator
              FROM marm
              FOR ALL ENTRIES IN @lt_planned_unit_keys
              WHERE matnr = @lt_planned_unit_keys-material
                AND meinh = @lt_planned_unit_keys-order_unit
              INTO CORRESPONDING FIELDS OF TABLE
                @lt_plan_uom_raw.
            LOOP AT lt_plan_uom_raw
                INTO DATA(ls_planned_unit_conversion_raw).
              INSERT ls_planned_unit_conversion_raw
                INTO TABLE lt_planned_unit_conversions.
            ENDLOOP.
          ENDIF.

          LOOP AT lt_planned_receipts INTO DATA(ls_planned_receipt_raw).
            READ TABLE lt_planned_units INTO DATA(ls_planned_base_unit)
              WITH TABLE KEY material = ls_planned_receipt_raw-material.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            ls_planned_receipt_raw-base_unit =
              ls_planned_base_unit-base_unit.
            READ TABLE lt_planned_unit_conversions
                INTO DATA(ls_planned_conversion)
              WITH TABLE KEY material = ls_planned_receipt_raw-material
                             order_unit = ls_planned_receipt_raw-order_unit.
            IF sy-subrc = 0.
              ls_planned_receipt_raw-unit_to_base_numerator =
                ls_planned_conversion-unit_to_base_numerator.
              ls_planned_receipt_raw-unit_to_base_denominator =
                ls_planned_conversion-unit_to_base_denominator.
            ENDIF.
            APPEND ls_planned_receipt_raw
              TO lt_planned_receipts_enriched.
          ENDLOOP.
          lt_planned_receipts = lt_planned_receipts_enriched.
        ENDIF.

        DATA(lo_planned_calculator) = NEW zcl_planned_order_qty_calc( ).
        LOOP AT lt_planned_receipts INTO DATA(ls_planned_receipt).
          DATA(lv_planned_unit_numerator) =
            ls_planned_receipt-unit_to_base_numerator.
          DATA(lv_planned_unit_denominator) =
            ls_planned_receipt-unit_to_base_denominator.
          IF ls_planned_receipt-order_unit = ls_planned_receipt-base_unit.
            lv_planned_unit_numerator = 1.
            lv_planned_unit_denominator = 1.
          ENDIF.
          DATA(lv_planned_quantity) =
            lo_planned_calculator->calculate_open_base_quantity(
              iv_planned_quantity   = ls_planned_receipt-planned_quantity
              iv_unit_to_base_num   = lv_planned_unit_numerator
              iv_unit_to_base_denom = lv_planned_unit_denominator ).
          DATA(lv_planned_base_quantity) = convert_to_stock_quantity(
            iv_quantity = lv_planned_quantity ).
          IF lv_planned_base_quantity > 0.
            APPEND VALUE #(
              material         = ls_planned_receipt-material
              plant            = ls_planned_receipt-plant
              base_unit        = ls_planned_receipt-base_unit
              receipt_date     = ls_planned_receipt-receipt_date
              quantity         = lv_planned_base_quantity
              source_type      = COND #(
                WHEN ls_planned_receipt-fixed_indicator IS INITIAL
                THEN 'PLANNED_ORDER'
                ELSE 'FIXED_PLAN_ORDER' )
              source_document  = ls_planned_receipt-planned_order
              storage_location = ls_planned_receipt-storage_location )
              TO lt_receipts.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF iv_include_po_confirmations = abap_true.
      LOOP AT lt_scopes INTO ls_scope.
        lv_confirmation_request_id = |PO_CONF_{ sy-tabix }|.
        APPEND VALUE #(
          request_id   = lv_confirmation_request_id
          material     = ls_scope-material
          plant        = ls_scope-plant
          through_date = ls_scope-through_date )
          TO lt_confirmation_requests.
      ENDLOOP.
      lt_confirmation_results =
        zif_stock_repository~get_po_confirmed_receipts_bulk(
          it_requests = lt_confirmation_requests ).
      LOOP AT lt_confirmation_results INTO DATA(ls_confirmation_result).
        APPEND LINES OF ls_confirmation_result-receipts TO lt_receipts.
      ENDLOOP.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      LOOP AT lt_receipts USING KEY by_scope INTO DATA(ls_receipt)
          WHERE material = ls_request-material
            AND plant = ls_request-plant
            AND receipt_date <= ls_request-through_date.
        APPEND ls_receipt TO ls_result-receipts.
      ENDLOOP.
      SORT ls_result-receipts BY material plant base_unit receipt_date
        source_type source_document source_item source_schedule_line.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    TYPES:
      BEGIN OF ty_stock_row,
        quantity TYPE mard-labst,
      END OF ty_stock_row,
      ty_stock_rows TYPE STANDARD TABLE OF ty_stock_row WITH EMPTY KEY,
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
        WITH EMPTY KEY.
    DATA lv_unrestricted_quantity TYPE decfloat34.
    DATA lv_reserved_quantity TYPE decfloat34.
    DATA lv_available_quantity TYPE decfloat34.
    DATA lv_open_quantity TYPE decfloat34.
    DATA lt_stock_rows TYPE ty_stock_rows.
    DATA lt_reservation_rows TYPE ty_reservation_rows.

    SELECT labst AS quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock_rows.

    LOOP AT lt_stock_rows INTO DATA(ls_stock_row).
      lv_unrestricted_quantity += CONV decfloat34( ls_stock_row-quantity ).
    ENDLOOP.

    SELECT rsnum AS reservation_number,
           rspos AS reservation_item,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    LOOP AT lt_reservation_rows INTO DATA(ls_reservation_row).
      IF line_exists( it_excluded_reservations[
          reservation_number = ls_reservation_row-reservation_number
          reservation_item = ls_reservation_row-reservation_item ] ).
        CONTINUE.
      ENDIF.
      lv_open_quantity = CONV decfloat34(
        ls_reservation_row-required_quantity )
        - CONV decfloat34( ls_reservation_row-withdrawn_quantity ).
      IF lv_open_quantity > 0.
        lv_reserved_quantity += lv_open_quantity.
      ENDIF.
    ENDLOOP.

    IF lv_unrestricted_quantity < 0.
      CLEAR lv_unrestricted_quantity.
    ENDIF.
    lv_available_quantity = lv_unrestricted_quantity.
    IF lv_reserved_quantity > 0.
      lv_available_quantity -= lv_reserved_quantity.
    ENDIF.
    IF lv_available_quantity < 0.
      CLEAR lv_available_quantity.
    ENDIF.
    rv_quantity = convert_to_stock_quantity(
      iv_quantity = lv_available_quantity ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    DATA(lt_results) =
      zif_stock_repository~get_available_stock_date_bulk(
        it_requests                    = VALUE #(
          ( request_id    = 'SINGLE-DATE'
            material      = iv_material
            plant         = iv_plant
            required_date = iv_required_date ) )
        it_excluded_reservations       = it_excluded_reservations
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_subtract_unissued_sto       = iv_subtract_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    READ TABLE lt_results INTO DATA(ls_result)
      WITH KEY request_id = 'SINGLE-DATE'.
    IF sy-subrc = 0.
      rv_quantity = ls_result-available_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_date_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_mard_row,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        storage_location      TYPE mard-lgort,
        unrestricted_quantity TYPE mard-labst,
      END OF ty_mard_row.
    TYPES ty_mard_rows TYPE STANDARD TABLE OF ty_mard_row WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    TYPES:
      BEGIN OF ty_reservation_row,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        required_date      TYPE resb-bdter,
        reserved_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row.
    TYPES ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
      WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    TYPES:
      BEGIN OF ty_outgoing_sto,
        material            TYPE ekpo-matnr,
        plant               TYPE ekko-reswk,
        source_document     TYPE eket-ebeln,
        source_item         TYPE eket-ebelp,
        schedule_line       TYPE eket-etenr,
        receipt_date        TYPE eket-eindt,
        scheduled_quantity  TYPE eket-menge,
        issued_quantity     TYPE eket-wamng,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
      END OF ty_outgoing_sto.
    TYPES ty_outgoing_stos TYPE STANDARD TABLE OF ty_outgoing_sto
      WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    TYPES:
      BEGIN OF ty_outgoing_sto_item,
        source_document     TYPE ekpo-ebeln,
        source_item         TYPE ekpo-ebelp,
        material            TYPE ekpo-matnr,
        receiving_plant     TYPE ekpo-werks,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
      END OF ty_outgoing_sto_item.
    TYPES ty_outgoing_sto_items TYPE STANDARD TABLE OF
      ty_outgoing_sto_item WITH EMPTY KEY.
    TYPES ty_outgoing_sto_item_index TYPE HASHED TABLE OF
      ty_outgoing_sto_item WITH UNIQUE KEY source_document source_item.
    TYPES:
      BEGIN OF ty_outgoing_sto_header,
        source_document     TYPE ekko-ebeln,
        supplying_plant     TYPE ekko-reswk,
        document_category   TYPE ekko-bstyp,
        special_procurement TYPE ekko-bsakz,
      END OF ty_outgoing_sto_header.
    TYPES ty_outgoing_sto_headers TYPE STANDARD TABLE OF
      ty_outgoing_sto_header WITH EMPTY KEY.
    TYPES ty_outgoing_sto_header_index TYPE HASHED TABLE OF
      ty_outgoing_sto_header WITH UNIQUE KEY source_document.
    TYPES:
      BEGIN OF ty_outgoing_sto_scope,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_outgoing_sto_scope.
    TYPES ty_outgoing_sto_scopes TYPE SORTED TABLE OF
      ty_outgoing_sto_scope WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_outgoing_sto_schedule_key,
        source_document TYPE eket-ebeln,
        source_item     TYPE eket-ebelp,
        through_date    TYPE d,
      END OF ty_outgoing_sto_schedule_key.
    TYPES ty_outgoing_sto_schedule_keys TYPE HASHED TABLE OF
      ty_outgoing_sto_schedule_key
      WITH UNIQUE KEY source_document source_item.
    TYPES:
      BEGIN OF ty_outgoing_sto_schedule_row,
        source_document    TYPE eket-ebeln,
        source_item        TYPE eket-ebelp,
        schedule_line      TYPE eket-etenr,
        receipt_date       TYPE eket-eindt,
        scheduled_quantity TYPE eket-menge,
        issued_quantity    TYPE eket-wamng,
      END OF ty_outgoing_sto_schedule_row.
    TYPES ty_outgoing_sto_schedule_rows TYPE STANDARD TABLE OF
      ty_outgoing_sto_schedule_row WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_scope,
        material     TYPE afpo-matnr,
        plant        TYPE afpo-werks,
        through_date TYPE d,
      END OF ty_prod_scope.
    TYPES ty_prod_scopes TYPE SORTED TABLE OF ty_prod_scope
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_prod_item,
        material               TYPE afpo-matnr,
        plant                  TYPE afpo-werks,
        production_order       TYPE afpo-aufnr,
        production_item        TYPE afpo-posnr,
        goods_receipt_expected TYPE afpo-wepos,
        deletion_flag          TYPE afpo-xloek,
        delivery_complete      TYPE afpo-elikz,
        sales_order            TYPE afpo-kdauf,
        account_assignment     TYPE afpo-knttp,
        order_quantity         TYPE afpo-psmng,
        received_quantity      TYPE afpo-wemng,
        order_to_base_num      TYPE afpo-umrez,
        order_to_base_denom    TYPE afpo-umren,
      END OF ty_prod_item.
    TYPES ty_prod_items TYPE STANDARD TABLE OF ty_prod_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_order_key,
        production_order TYPE afko-aufnr,
      END OF ty_prod_order_key.
    TYPES ty_prod_order_keys TYPE SORTED TABLE OF ty_prod_order_key
      WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_prod_order_date,
        production_order TYPE afko-aufnr,
        receipt_date     TYPE afko-gltrp,
      END OF ty_prod_order_date.
    TYPES ty_prod_order_dates TYPE STANDARD TABLE OF ty_prod_order_date
      WITH EMPTY KEY.
    TYPES ty_prod_order_date_index TYPE HASHED TABLE OF ty_prod_order_date
      WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_prod_order_status,
        production_order TYPE aufk-aufnr,
        order_category   TYPE aufk-autyp,
        phase_one        TYPE aufk-phas1,
        phase_two        TYPE aufk-phas2,
        phase_three      TYPE aufk-phas3,
        deletion_flag    TYPE aufk-loekz,
      END OF ty_prod_order_status.
    TYPES ty_prod_order_statuses TYPE STANDARD TABLE OF
      ty_prod_order_status WITH EMPTY KEY.
    TYPES ty_prod_order_status_index TYPE HASHED TABLE OF
      ty_prod_order_status WITH UNIQUE KEY production_order.
    TYPES:
      BEGIN OF ty_prod_receipt,
        material            TYPE afpo-matnr,
        plant               TYPE afpo-werks,
        production_order    TYPE afpo-aufnr,
        production_item     TYPE afpo-posnr,
        receipt_date        TYPE afko-gltrp,
        order_quantity      TYPE afpo-psmng,
        received_quantity   TYPE afpo-wemng,
        order_to_base_num   TYPE afpo-umrez,
        order_to_base_denom TYPE afpo-umren,
      END OF ty_prod_receipt.
    TYPES ty_prod_receipts TYPE STANDARD TABLE OF ty_prod_receipt
      WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    DATA lt_request_ids TYPE ty_request_ids.
    DATA lt_excluded_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_mard_rows TYPE ty_mard_rows.
    DATA lt_reservation_rows TYPE ty_reservation_rows.
    DATA lt_outgoing_stos TYPE ty_outgoing_stos.
    DATA lt_outgoing_sto_items_raw TYPE ty_outgoing_sto_items.
    DATA lt_outgoing_sto_items TYPE ty_outgoing_sto_item_index.
    DATA lt_outgoing_sto_headers_raw TYPE ty_outgoing_sto_headers.
    DATA lt_outgoing_sto_headers TYPE ty_outgoing_sto_header_index.
    DATA lt_outgoing_sto_scopes TYPE ty_outgoing_sto_scopes.
    DATA lt_outgoing_sto_schedule_keys TYPE
      ty_outgoing_sto_schedule_keys.
    DATA lt_outgoing_sto_schedule_rows TYPE
      ty_outgoing_sto_schedule_rows.
    DATA lt_prod_scopes TYPE ty_prod_scopes.
    DATA lt_prod_items_raw TYPE ty_prod_items.
    DATA lt_prod_order_keys TYPE ty_prod_order_keys.
    DATA lt_prod_order_dates_raw TYPE ty_prod_order_dates.
    DATA lt_prod_order_dates TYPE ty_prod_order_date_index.
    DATA lt_prod_order_statuses_raw TYPE ty_prod_order_statuses.
    DATA lt_prod_order_statuses TYPE ty_prod_order_status_index.
    DATA lt_prod_receipts TYPE ty_prod_receipts.
    DATA lt_projected_requests TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_requests.
    DATA lt_projected_results TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_results.
    DATA lv_initial_date TYPE resb-bdter.
    DATA lv_initial_po_date TYPE eket-eindt.
    DATA lv_unrestricted_total TYPE decfloat34.
    DATA lv_reserved_quantity TYPE decfloat34.
    DATA lv_outgoing_sto_quantity TYPE decfloat34.
    DATA lv_prod_receipt_quantity TYPE decfloat34.
    DATA lv_projected_receipt_quantity TYPE decfloat34.
    DATA lv_quantity TYPE mard-labst.
    DATA ls_result TYPE
      zif_stock_repository=>ty_available_stock_date_result.
    DATA lo_outgoing_sto_calc TYPE REF TO zcl_po_sched_qty_calc.
    DATA lo_prod_quantity_calc TYPE REF TO zcl_prod_order_qty_calc.
    FIELD-SYMBOLS <ls_projected_result> TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_result.

    IF ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_subtract_unissued_sto <> abap_true
          AND iv_subtract_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_request-required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-required_date )
        TO lt_projected_requests.
    ENDLOOP.
    lt_excluded_reservations = CORRESPONDING #( it_excluded_reservations ).
    CLEAR: lv_initial_date, lv_initial_po_date.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           labst AS unrestricted_quantity
      FROM mard
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_mard_rows.

    SELECT matnr AS material,
           werks AS plant,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           bdter AS required_date,
           bdmng AS reserved_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( bdter <= @it_requests-required_date
          OR bdter = @lv_initial_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    IF iv_subtract_unissued_sto = abap_true.
      LOOP AT it_requests INTO ls_request.
        READ TABLE lt_outgoing_sto_scopes ASSIGNING
            FIELD-SYMBOL(<ls_outgoing_sto_scope>)
          WITH TABLE KEY material = ls_request-material
                         plant = ls_request-plant.
        IF sy-subrc = 0.
          IF <ls_outgoing_sto_scope>-through_date
              < ls_request-required_date.
            <ls_outgoing_sto_scope>-through_date =
              ls_request-required_date.
          ENDIF.
        ELSE.
          INSERT VALUE #(
            material     = ls_request-material
            plant        = ls_request-plant
            through_date = ls_request-required_date )
            INTO TABLE lt_outgoing_sto_scopes.
        ENDIF.
      ENDLOOP.

      SELECT ebeln AS source_document,
             ebelp AS source_item,
             matnr AS material,
             werks AS receiving_plant,
             umrez AS order_to_base_num,
             umren AS order_to_base_denom
        FROM ekpo
        FOR ALL ENTRIES IN @lt_outgoing_sto_scopes
        WHERE matnr = @lt_outgoing_sto_scopes-material
          AND pstyp = '7'
          AND knttp = @space
          AND loekz = @space
          AND elikz = @space
          AND stapo = @space
          AND retpo = @space
          AND wepos = 'X'
        INTO CORRESPONDING FIELDS OF TABLE @lt_outgoing_sto_items_raw.
      LOOP AT lt_outgoing_sto_items_raw INTO DATA(ls_outgoing_sto_item_raw).
        INSERT ls_outgoing_sto_item_raw INTO TABLE lt_outgoing_sto_items.
      ENDLOOP.

      IF lt_outgoing_sto_items IS NOT INITIAL.
        SELECT ebeln AS source_document,
               reswk AS supplying_plant,
               bstyp AS document_category,
               bsakz AS special_procurement
          FROM ekko
          FOR ALL ENTRIES IN @lt_outgoing_sto_items
          WHERE ebeln = @lt_outgoing_sto_items-source_document
            AND bsakz <> 'T'
            AND ( bstyp = 'F' OR bstyp = 'L' )
          INTO CORRESPONDING FIELDS OF TABLE
            @lt_outgoing_sto_headers_raw.
        LOOP AT lt_outgoing_sto_headers_raw
            INTO DATA(ls_outgoing_sto_header_raw).
          INSERT ls_outgoing_sto_header_raw
            INTO TABLE lt_outgoing_sto_headers.
        ENDLOOP.

        LOOP AT lt_outgoing_sto_items INTO DATA(ls_outgoing_sto_item).
          READ TABLE lt_outgoing_sto_headers
              INTO DATA(ls_outgoing_sto_header)
            WITH TABLE KEY source_document =
              ls_outgoing_sto_item-source_document.
          IF sy-subrc <> 0
              OR ls_outgoing_sto_item-receiving_plant =
                ls_outgoing_sto_header-supplying_plant.
            CONTINUE.
          ENDIF.
          READ TABLE lt_outgoing_sto_scopes
              INTO DATA(ls_outgoing_sto_scope)
            WITH TABLE KEY material = ls_outgoing_sto_item-material
                           plant = ls_outgoing_sto_header-supplying_plant.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          INSERT VALUE #(
            source_document = ls_outgoing_sto_item-source_document
            source_item     = ls_outgoing_sto_item-source_item
            through_date    = ls_outgoing_sto_scope-through_date )
            INTO TABLE lt_outgoing_sto_schedule_keys.
        ENDLOOP.
      ENDIF.

      IF lt_outgoing_sto_schedule_keys IS NOT INITIAL.
        SELECT ebeln AS source_document,
               ebelp AS source_item,
               etenr AS schedule_line,
               eindt AS receipt_date,
               menge AS scheduled_quantity,
               wamng AS issued_quantity
          FROM eket
          FOR ALL ENTRIES IN @lt_outgoing_sto_schedule_keys
          WHERE ebeln = @lt_outgoing_sto_schedule_keys-source_document
            AND ebelp = @lt_outgoing_sto_schedule_keys-source_item
            AND eindt > @lv_initial_po_date
            AND eindt <= @lt_outgoing_sto_schedule_keys-through_date
          INTO CORRESPONDING FIELDS OF TABLE
            @lt_outgoing_sto_schedule_rows.

        LOOP AT lt_outgoing_sto_schedule_rows
            INTO DATA(ls_outgoing_sto_schedule_row).
          READ TABLE lt_outgoing_sto_items
              INTO ls_outgoing_sto_item
            WITH TABLE KEY source_document =
                             ls_outgoing_sto_schedule_row-source_document
                           source_item =
                             ls_outgoing_sto_schedule_row-source_item.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_outgoing_sto_headers
              INTO ls_outgoing_sto_header
            WITH TABLE KEY source_document =
              ls_outgoing_sto_schedule_row-source_document.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material            = ls_outgoing_sto_item-material
            plant               = ls_outgoing_sto_header-supplying_plant
            source_document     =
              ls_outgoing_sto_schedule_row-source_document
            source_item         = ls_outgoing_sto_schedule_row-source_item
            schedule_line       =
              ls_outgoing_sto_schedule_row-schedule_line
            receipt_date        =
              ls_outgoing_sto_schedule_row-receipt_date
            scheduled_quantity  =
              ls_outgoing_sto_schedule_row-scheduled_quantity
            issued_quantity     =
              ls_outgoing_sto_schedule_row-issued_quantity
            order_to_base_num   = ls_outgoing_sto_item-order_to_base_num
            order_to_base_denom = ls_outgoing_sto_item-order_to_base_denom )
            TO lt_outgoing_stos.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF iv_include_prod_receipts = abap_true.
      LOOP AT it_requests INTO ls_request.
        READ TABLE lt_prod_scopes ASSIGNING
            FIELD-SYMBOL(<ls_prod_scope>)
          WITH TABLE KEY material = ls_request-material
                         plant = ls_request-plant.
        IF sy-subrc = 0.
          IF <ls_prod_scope>-through_date < ls_request-required_date.
            <ls_prod_scope>-through_date = ls_request-required_date.
          ENDIF.
        ELSE.
          INSERT VALUE #(
            material     = ls_request-material
            plant        = ls_request-plant
            through_date = ls_request-required_date )
            INTO TABLE lt_prod_scopes.
        ENDIF.
      ENDLOOP.

      SELECT matnr AS material,
             werks AS plant,
             aufnr AS production_order,
             posnr AS production_item,
             wepos AS goods_receipt_expected,
             xloek AS deletion_flag,
             elikz AS delivery_complete,
             kdauf AS sales_order,
             knttp AS account_assignment,
             psmng AS order_quantity,
             wemng AS received_quantity,
             umrez AS order_to_base_num,
             umren AS order_to_base_denom
        FROM afpo
        FOR ALL ENTRIES IN @lt_prod_scopes
        WHERE matnr = @lt_prod_scopes-material
          AND werks = @lt_prod_scopes-plant
        INTO CORRESPONDING FIELDS OF TABLE @lt_prod_items_raw.

      LOOP AT lt_prod_items_raw INTO DATA(ls_prod_item_raw).
        INSERT VALUE #(
          production_order = ls_prod_item_raw-production_order )
          INTO TABLE lt_prod_order_keys.
      ENDLOOP.

      IF lt_prod_order_keys IS NOT INITIAL.
        SELECT aufnr AS production_order,
               gltrp AS receipt_date
          FROM afko
          FOR ALL ENTRIES IN @lt_prod_order_keys
          WHERE aufnr = @lt_prod_order_keys-production_order
          INTO CORRESPONDING FIELDS OF TABLE @lt_prod_order_dates_raw.
        SELECT aufnr AS production_order,
               autyp AS order_category,
               phas1 AS phase_one,
               phas2 AS phase_two,
               phas3 AS phase_three,
               loekz AS deletion_flag
          FROM aufk
          FOR ALL ENTRIES IN @lt_prod_order_keys
          WHERE aufnr = @lt_prod_order_keys-production_order
            AND ( autyp = '10' OR autyp = '40' )
            AND phas1 = 'X'
            AND phas2 = @space
            AND phas3 = @space
            AND loekz = @space
          INTO CORRESPONDING FIELDS OF TABLE
            @lt_prod_order_statuses_raw.

        LOOP AT lt_prod_order_dates_raw INTO DATA(ls_prod_order_date_raw).
          INSERT ls_prod_order_date_raw INTO TABLE lt_prod_order_dates.
        ENDLOOP.
        LOOP AT lt_prod_order_statuses_raw
            INTO DATA(ls_prod_order_status_raw).
          INSERT ls_prod_order_status_raw INTO TABLE
            lt_prod_order_statuses.
        ENDLOOP.

        LOOP AT lt_prod_items_raw INTO ls_prod_item_raw.
          IF ls_prod_item_raw-goods_receipt_expected <> 'X'
              OR ls_prod_item_raw-deletion_flag IS NOT INITIAL
              OR ls_prod_item_raw-delivery_complete IS NOT INITIAL
              OR ls_prod_item_raw-sales_order IS NOT INITIAL
              OR ls_prod_item_raw-account_assignment IS NOT INITIAL.
            CONTINUE.
          ENDIF.
          READ TABLE lt_prod_order_dates INTO DATA(ls_prod_order_date)
            WITH TABLE KEY production_order =
              ls_prod_item_raw-production_order.
          IF sy-subrc <> 0
              OR ls_prod_order_date-receipt_date <= lv_initial_po_date.
            CONTINUE.
          ENDIF.
          READ TABLE lt_prod_order_statuses
              INTO DATA(ls_prod_order_status)
            WITH TABLE KEY production_order =
              ls_prod_item_raw-production_order.
          IF sy-subrc <> 0
              OR ( ls_prod_order_status-order_category <> '10'
                AND ls_prod_order_status-order_category <> '40' )
              OR ls_prod_order_status-phase_one <> 'X'
              OR ls_prod_order_status-phase_two IS NOT INITIAL
              OR ls_prod_order_status-phase_three IS NOT INITIAL
              OR ls_prod_order_status-deletion_flag IS NOT INITIAL.
            CONTINUE.
          ENDIF.
          READ TABLE lt_prod_scopes INTO DATA(ls_prod_scope)
            WITH TABLE KEY material = ls_prod_item_raw-material
                           plant = ls_prod_item_raw-plant.
          IF sy-subrc <> 0
              OR ls_prod_order_date-receipt_date >
                ls_prod_scope-through_date.
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            material            = ls_prod_item_raw-material
            plant               = ls_prod_item_raw-plant
            production_order    = ls_prod_item_raw-production_order
            production_item     = ls_prod_item_raw-production_item
            receipt_date        = ls_prod_order_date-receipt_date
            order_quantity      = ls_prod_item_raw-order_quantity
            received_quantity   = ls_prod_item_raw-received_quantity
            order_to_base_num   = ls_prod_item_raw-order_to_base_num
            order_to_base_denom = ls_prod_item_raw-order_to_base_denom )
            TO lt_prod_receipts.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF iv_include_po_receipts = abap_true
        OR iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true
        OR iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true
        OR iv_include_planned_receipts = abap_true
        OR iv_include_fixed_planned = abap_true
        OR iv_include_sched_agmt_receipts = abap_true.
      lt_projected_results =
        zif_stock_repository~get_projected_receipts_bulk(
          it_requests                    = lt_projected_requests
          iv_include_po_receipts         = iv_include_po_receipts
          iv_include_po_confirmations    = abap_false
          iv_include_sto_in_transit      = iv_include_sto_in_transit
          iv_include_unissued_sto        = iv_include_unissued_sto
          iv_include_prod_receipts       = abap_false
          iv_include_pr_receipts         = iv_include_pr_receipts
          iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
          iv_include_planned_receipts    = iv_include_planned_receipts
          iv_include_fixed_planned       = iv_include_fixed_planned
          iv_include_sched_agmt_receipts =
            iv_include_sched_agmt_receipts ).
      IF lines( lt_projected_results ) <> lines( it_requests ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDIF.

    IF iv_subtract_unissued_sto = abap_true.
      lo_outgoing_sto_calc = NEW zcl_po_sched_qty_calc( ).
    ENDIF.
    IF iv_include_prod_receipts = abap_true.
      lo_prod_quantity_calc = NEW zcl_prod_order_qty_calc( ).
    ENDIF.
    LOOP AT it_requests INTO ls_request.
      CLEAR: lv_unrestricted_total, lv_reserved_quantity,
        lv_outgoing_sto_quantity, lv_prod_receipt_quantity,
        lv_projected_receipt_quantity.

      LOOP AT lt_mard_rows USING KEY by_scope INTO DATA(ls_mard_row)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
        lv_unrestricted_total = lv_unrestricted_total
          + ls_mard_row-unrestricted_quantity.
      ENDLOOP.

      LOOP AT lt_reservation_rows USING KEY by_scope
          INTO DATA(ls_reservation_row)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
        IF ls_reservation_row-required_date > ls_request-required_date
            AND ls_reservation_row-required_date IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        IF line_exists( lt_excluded_reservations[
            reservation_number = ls_reservation_row-reservation_number
            reservation_item = ls_reservation_row-reservation_item ] ).
          CONTINUE.
        ENDIF.
        lv_reserved_quantity = lv_reserved_quantity
          + zcl_stock_avail_qty_calc=>calculate_open_res_qty(
              iv_required_quantity  =
                ls_reservation_row-reserved_quantity
              iv_withdrawn_quantity =
                ls_reservation_row-withdrawn_quantity ).
      ENDLOOP.

      IF iv_subtract_unissued_sto = abap_true.
        LOOP AT lt_outgoing_stos USING KEY by_scope
            INTO DATA(ls_outgoing_sto)
            WHERE material = ls_request-material
              AND plant = ls_request-plant.
          IF ls_outgoing_sto-receipt_date > ls_request-required_date.
            CONTINUE.
          ENDIF.
          lv_outgoing_sto_quantity = lv_outgoing_sto_quantity
            + lo_outgoing_sto_calc->calculate_open_unissued_qty(
                iv_scheduled_quantity  =
                  ls_outgoing_sto-scheduled_quantity
                iv_issued_quantity     = ls_outgoing_sto-issued_quantity
                iv_order_to_base_num   =
                  ls_outgoing_sto-order_to_base_num
                iv_order_to_base_denom =
                  ls_outgoing_sto-order_to_base_denom ).
        ENDLOOP.
        lv_unrestricted_total = lv_unrestricted_total
          - lv_outgoing_sto_quantity.
      ENDIF.

      IF iv_include_prod_receipts = abap_true.
        LOOP AT lt_prod_receipts USING KEY by_scope
            INTO DATA(ls_prod_receipt)
            WHERE material = ls_request-material
              AND plant = ls_request-plant.
          IF ls_prod_receipt-receipt_date > ls_request-required_date.
            CONTINUE.
          ENDIF.
          lv_prod_receipt_quantity = lv_prod_receipt_quantity
            + lo_prod_quantity_calc->calculate_open_base_quantity(
                iv_order_quantity      = ls_prod_receipt-order_quantity
                iv_received_quantity   = ls_prod_receipt-received_quantity
                iv_order_to_base_num   =
                  ls_prod_receipt-order_to_base_num
                iv_order_to_base_denom =
                  ls_prod_receipt-order_to_base_denom ).
        ENDLOOP.
        lv_unrestricted_total = lv_unrestricted_total
          + lv_prod_receipt_quantity.
      ENDIF.

      IF lt_projected_results IS NOT INITIAL.
        READ TABLE lt_projected_results ASSIGNING <ls_projected_result>
          WITH KEY request_id = ls_request-request_id.
        IF sy-subrc <> 0
            OR <ls_projected_result>-material <> ls_request-material
            OR <ls_projected_result>-plant <> ls_request-plant
            OR <ls_projected_result>-through_date <>
              ls_request-required_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        LOOP AT <ls_projected_result>-receipts
            INTO DATA(ls_projected_receipt).
          lv_projected_receipt_quantity = lv_projected_receipt_quantity
            + ls_projected_receipt-quantity.
        ENDLOOP.
        lv_unrestricted_total = lv_unrestricted_total
          + lv_projected_receipt_quantity.
      ENDIF.

      lv_unrestricted_total = lv_unrestricted_total
        - lv_reserved_quantity.
      CLEAR lv_quantity.
      IF lv_unrestricted_total > 0.
        lv_quantity = convert_to_stock_quantity(
          iv_quantity = lv_unrestricted_total ).
      ENDIF.
      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-required_date = ls_request-required_date.
      ls_result-available_quantity = lv_quantity.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock_bulk.
    TYPES:
      BEGIN OF ty_safety_stock_row,
        material TYPE marc-matnr,
        plant    TYPE marc-werks,
        quantity TYPE marc-eisbe,
      END OF ty_safety_stock_row,
      ty_safety_stock_rows TYPE HASHED TABLE OF ty_safety_stock_row
        WITH UNIQUE KEY material plant.
    DATA lt_safety_stock_rows TYPE ty_safety_stock_rows.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           eisbe AS quantity
      FROM marc
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_safety_stock_rows.

    LOOP AT rt_status ASSIGNING FIELD-SYMBOL(<ls_status>).
      READ TABLE lt_safety_stock_rows INTO DATA(ls_safety_stock_row)
        WITH TABLE KEY material = <ls_status>-material
                       plant = <ls_status>-plant.
      IF sy-subrc = 0.
        <ls_status>-quantity = ls_safety_stock_row-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts.
    DATA(lt_results) =
      zif_stock_repository~get_po_confirmed_receipts_bulk(
        it_requests = VALUE #(
          ( request_id   = 'SINGLE-CONFIRMED'
            material     = iv_material
            plant        = iv_plant
            through_date = iv_through_date ) ) ).

    READ TABLE lt_results INTO DATA(ls_result)
      WITH KEY request_id = 'SINGLE-CONFIRMED'.
    IF sy-subrc = 0.
      rt_receipts = ls_result-receipts.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.
    TYPES:
      BEGIN OF ty_scope,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_scope.
    TYPES ty_scopes TYPE SORTED TABLE OF ty_scope
      WITH UNIQUE KEY material plant.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_receipt_position,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        row_number TYPE i,
      END OF ty_receipt_position.
    TYPES ty_receipt_positions TYPE SORTED TABLE OF ty_receipt_position
      WITH UNIQUE KEY material plant row_number.
    TYPES:
      BEGIN OF ty_po_schedule,
        material             TYPE ekpo-matnr,
        plant                TYPE ekpo-werks,
        base_unit            TYPE mara-meins,
        source_document      TYPE eket-ebeln,
        source_item          TYPE eket-ebelp,
        source_schedule_line TYPE eket-etenr,
        receipt_date         TYPE eket-eindt,
        scheduled_quantity   TYPE eket-menge,
        received_quantity    TYPE eket-wemng,
        mrp_reduced_quantity TYPE eket-dabmg,
        order_to_base_num    TYPE ekpo-umrez,
        order_to_base_denom  TYPE ekpo-umren,
        storage_location     TYPE ekpo-lgort,
        batch                TYPE eket-charg,
      END OF ty_po_schedule.
    TYPES ty_po_schedules TYPE STANDARD TABLE OF ty_po_schedule
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_confirmation,
        material            TYPE ekpo-matnr,
        plant               TYPE ekpo-werks,
        base_unit           TYPE mara-meins,
        source_document     TYPE ekes-ebeln,
        source_item         TYPE ekes-ebelp,
        receipt_date        TYPE ekes-eindt,
        confirmed_quantity  TYPE ekes-menge,
        reduced_quantity    TYPE ekes-dabmg,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
        storage_location    TYPE ekpo-lgort,
        batch               TYPE ekes-charg,
      END OF ty_po_confirmation.
    TYPES ty_po_confirmations TYPE STANDARD TABLE OF ty_po_confirmation
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_item_candidate,
        source_document     TYPE ekpo-ebeln,
        source_item         TYPE ekpo-ebelp,
        material            TYPE ekpo-matnr,
        plant               TYPE ekpo-werks,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
        storage_location    TYPE ekpo-lgort,
      END OF ty_po_item_candidate.
    TYPES ty_po_item_candidates TYPE STANDARD TABLE OF
      ty_po_item_candidate WITH EMPTY KEY.
    TYPES ty_po_item_index TYPE HASHED TABLE OF ty_po_item_candidate
      WITH UNIQUE KEY source_document source_item.
    TYPES:
      BEGIN OF ty_po_header_candidate,
        source_document TYPE ekko-ebeln,
      END OF ty_po_header_candidate.
    TYPES ty_po_header_candidates TYPE STANDARD TABLE OF
      ty_po_header_candidate WITH EMPTY KEY.
    TYPES ty_po_header_index TYPE HASHED TABLE OF ty_po_header_candidate
      WITH UNIQUE KEY source_document.
    TYPES:
      BEGIN OF ty_material_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_material_unit.
    TYPES ty_material_units TYPE STANDARD TABLE OF ty_material_unit
      WITH EMPTY KEY.
    TYPES ty_material_unit_index TYPE HASHED TABLE OF ty_material_unit
      WITH UNIQUE KEY material.
    TYPES:
      BEGIN OF ty_po_read_key,
        source_document TYPE eket-ebeln,
        source_item     TYPE eket-ebelp,
        through_date    TYPE d,
      END OF ty_po_read_key.
    TYPES ty_po_read_keys TYPE STANDARD TABLE OF ty_po_read_key
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_eket_schedule_row,
        source_document      TYPE eket-ebeln,
        source_item          TYPE eket-ebelp,
        source_schedule_line TYPE eket-etenr,
        receipt_date         TYPE eket-eindt,
        scheduled_quantity   TYPE eket-menge,
        received_quantity    TYPE eket-wemng,
        mrp_reduced_quantity TYPE eket-dabmg,
        batch                TYPE eket-charg,
      END OF ty_eket_schedule_row.
    TYPES ty_eket_schedule_rows TYPE STANDARD TABLE OF
      ty_eket_schedule_row WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_ekes_confirmation_row,
        source_document    TYPE ekes-ebeln,
        source_item        TYPE ekes-ebelp,
        receipt_date       TYPE ekes-eindt,
        confirmed_quantity TYPE ekes-menge,
        reduced_quantity   TYPE ekes-dabmg,
        batch              TYPE ekes-charg,
      END OF ty_ekes_confirmation_row.
    TYPES ty_ekes_confirmation_rows TYPE STANDARD TABLE OF
      ty_ekes_confirmation_row WITH EMPTY KEY.
    DATA lt_scopes TYPE ty_scopes.
    DATA lt_request_ids TYPE ty_request_ids.
    DATA lt_schedules TYPE ty_po_schedules.
    DATA lt_confirmations TYPE ty_po_confirmations.
    DATA lt_po_items_raw TYPE ty_po_item_candidates.
    DATA lt_po_items TYPE ty_po_item_index.
    DATA lt_po_headers_raw TYPE ty_po_header_candidates.
    DATA lt_po_headers TYPE ty_po_header_index.
    DATA lt_material_units_raw TYPE ty_material_units.
    DATA lt_material_units TYPE ty_material_unit_index.
    DATA lt_po_read_keys TYPE ty_po_read_keys.
    DATA lt_eket_schedule_rows TYPE ty_eket_schedule_rows.
    DATA lt_ekes_confirmation_rows TYPE ty_ekes_confirmation_rows.
    DATA lt_receipts TYPE zif_stock_repository=>ty_projected_receipts.
    DATA lt_receipt_positions TYPE ty_receipt_positions.
    DATA lv_initial_date TYPE d.
    DATA ls_scope TYPE ty_scope.
    DATA ls_receipt TYPE zif_stock_repository=>ty_projected_receipt.
    DATA ls_result TYPE
      zif_stock_repository=>ty_projected_receipt_bulk_result.
    FIELD-SYMBOLS <ls_scope> TYPE ty_scope.
    DATA(lo_calculator) = NEW zcl_po_sched_qty_calc( ).

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_request-through_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_scopes ASSIGNING <ls_scope>
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        IF <ls_scope>-through_date < ls_request-through_date.
          <ls_scope>-through_date = ls_request-through_date.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          INTO TABLE lt_scopes.
      ENDIF.
    ENDLOOP.

    SELECT ebeln AS source_document,
           ebelp AS source_item,
           matnr AS material,
           werks AS plant,
           umrez AS order_to_base_num,
           umren AS order_to_base_denom,
           lgort AS storage_location
      FROM ekpo
      FOR ALL ENTRIES IN @lt_scopes
      WHERE matnr = @lt_scopes-material
        AND werks = @lt_scopes-plant
        AND pstyp = '0'
        AND knttp = @space
        AND loekz = @space
        AND elikz = @space
        AND retpo = @space
        AND wepos = 'X'
        AND insmk = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_po_items_raw.

    LOOP AT lt_po_items_raw INTO DATA(ls_po_item_raw).
      INSERT ls_po_item_raw INTO TABLE lt_po_items.
    ENDLOOP.

    IF lt_po_items IS NOT INITIAL.
      SELECT ebeln AS source_document
        FROM ekko
        FOR ALL ENTRIES IN @lt_po_items
        WHERE ebeln = @lt_po_items-source_document
          AND bstyp = 'F'
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_headers_raw.

      SELECT matnr AS material,
             meins AS base_unit
        FROM mara
        FOR ALL ENTRIES IN @lt_po_items
        WHERE matnr = @lt_po_items-material
        INTO CORRESPONDING FIELDS OF TABLE @lt_material_units_raw.

      LOOP AT lt_po_headers_raw INTO DATA(ls_po_header_raw).
        INSERT ls_po_header_raw INTO TABLE lt_po_headers.
      ENDLOOP.
      LOOP AT lt_material_units_raw INTO DATA(ls_material_unit_raw).
        INSERT ls_material_unit_raw INTO TABLE lt_material_units.
      ENDLOOP.

      LOOP AT lt_po_items INTO DATA(ls_po_item).
        READ TABLE lt_scopes INTO ls_scope
          WITH TABLE KEY material = ls_po_item-material
                         plant = ls_po_item-plant.
        IF sy-subrc = 0.
          APPEND VALUE #(
            source_document = ls_po_item-source_document
            source_item     = ls_po_item-source_item
            through_date    = ls_scope-through_date )
            TO lt_po_read_keys.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_po_read_keys IS NOT INITIAL.
      SELECT ebeln AS source_document,
             ebelp AS source_item,
             etenr AS source_schedule_line,
             eindt AS receipt_date,
             menge AS scheduled_quantity,
             wemng AS received_quantity,
             dabmg AS mrp_reduced_quantity,
             charg AS batch
        FROM eket
        FOR ALL ENTRIES IN @lt_po_read_keys
        WHERE ebeln = @lt_po_read_keys-source_document
          AND ebelp = @lt_po_read_keys-source_item
          AND eindt > @lv_initial_date
          AND eindt <= @lt_po_read_keys-through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_eket_schedule_rows.

      LOOP AT lt_eket_schedule_rows INTO DATA(ls_eket_schedule_row).
        READ TABLE lt_po_items INTO ls_po_item
          WITH TABLE KEY source_document =
                           ls_eket_schedule_row-source_document
                         source_item = ls_eket_schedule_row-source_item.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        READ TABLE lt_po_headers TRANSPORTING NO FIELDS
          WITH TABLE KEY source_document =
            ls_eket_schedule_row-source_document.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        READ TABLE lt_material_units INTO DATA(ls_material_unit)
          WITH TABLE KEY material = ls_po_item-material.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          material             = ls_po_item-material
          plant                = ls_po_item-plant
          base_unit            = ls_material_unit-base_unit
          source_document      = ls_eket_schedule_row-source_document
          source_item          = ls_eket_schedule_row-source_item
          source_schedule_line =
            ls_eket_schedule_row-source_schedule_line
          receipt_date         = ls_eket_schedule_row-receipt_date
          scheduled_quantity   = ls_eket_schedule_row-scheduled_quantity
          received_quantity    = ls_eket_schedule_row-received_quantity
          mrp_reduced_quantity =
            ls_eket_schedule_row-mrp_reduced_quantity
          order_to_base_num    = ls_po_item-order_to_base_num
          order_to_base_denom  = ls_po_item-order_to_base_denom
          storage_location     = ls_po_item-storage_location
          batch                = ls_eket_schedule_row-batch )
          TO lt_schedules.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_schedules INTO DATA(ls_schedule).
      READ TABLE lt_scopes INTO ls_scope
        WITH TABLE KEY material = ls_schedule-material
                       plant = ls_schedule-plant.
      IF sy-subrc <> 0 OR ls_schedule-receipt_date > ls_scope-through_date.
        CONTINUE.
      ENDIF.
      DATA(lv_schedule_quantity) =
        lo_calculator->calc_open_sched_mrp_qty(
          iv_scheduled_quantity   = ls_schedule-scheduled_quantity
          iv_received_quantity    = ls_schedule-received_quantity
          iv_mrp_reduced_quantity = ls_schedule-mrp_reduced_quantity
          iv_order_to_base_num    = ls_schedule-order_to_base_num
          iv_order_to_base_denom  = ls_schedule-order_to_base_denom ).
      DATA(lv_schedule_base_quantity) =
        convert_to_stock_quantity(
          iv_quantity = lv_schedule_quantity ).
      IF lv_schedule_base_quantity > 0.
        APPEND VALUE #(
          material             = ls_schedule-material
          plant                = ls_schedule-plant
          base_unit            = ls_schedule-base_unit
          receipt_date         = ls_schedule-receipt_date
          quantity             = lv_schedule_base_quantity
          source_type          = 'PO'
          source_document      = ls_schedule-source_document
          source_item          = ls_schedule-source_item
          source_schedule_line = ls_schedule-source_schedule_line
          storage_location     = ls_schedule-storage_location
          batch                = ls_schedule-batch )
          TO lt_receipts.
      ENDIF.
    ENDLOOP.

    IF lt_po_read_keys IS NOT INITIAL.
      SELECT ebeln AS source_document,
             ebelp AS source_item,
             eindt AS receipt_date,
             menge AS confirmed_quantity,
             dabmg AS reduced_quantity,
             charg AS batch
        FROM ekes
        FOR ALL ENTRIES IN @lt_po_read_keys
        WHERE ebeln = @lt_po_read_keys-source_document
          AND ebelp = @lt_po_read_keys-source_item
          AND kzdis = 'X'
          AND loekz = @space
          AND eindt > @lv_initial_date
          AND eindt <= @lt_po_read_keys-through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_ekes_confirmation_rows.

      LOOP AT lt_ekes_confirmation_rows INTO DATA(ls_ekes_confirmation_row).
        READ TABLE lt_po_items INTO ls_po_item
          WITH TABLE KEY source_document =
                           ls_ekes_confirmation_row-source_document
                         source_item = ls_ekes_confirmation_row-source_item.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        READ TABLE lt_po_headers TRANSPORTING NO FIELDS
          WITH TABLE KEY source_document =
            ls_ekes_confirmation_row-source_document.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        READ TABLE lt_material_units INTO ls_material_unit
          WITH TABLE KEY material = ls_po_item-material.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          material            = ls_po_item-material
          plant               = ls_po_item-plant
          base_unit           = ls_material_unit-base_unit
          source_document     = ls_ekes_confirmation_row-source_document
          source_item         = ls_ekes_confirmation_row-source_item
          receipt_date        = ls_ekes_confirmation_row-receipt_date
          confirmed_quantity  =
            ls_ekes_confirmation_row-confirmed_quantity
          reduced_quantity    = ls_ekes_confirmation_row-reduced_quantity
          order_to_base_num   = ls_po_item-order_to_base_num
          order_to_base_denom = ls_po_item-order_to_base_denom
          storage_location    = ls_po_item-storage_location
          batch               = ls_ekes_confirmation_row-batch )
          TO lt_confirmations.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_confirmations INTO DATA(ls_confirmation).
      READ TABLE lt_scopes INTO ls_scope
        WITH TABLE KEY material = ls_confirmation-material
                       plant = ls_confirmation-plant.
      IF sy-subrc <> 0
          OR ls_confirmation-receipt_date > ls_scope-through_date.
        CONTINUE.
      ENDIF.
      DATA(lv_confirmation_quantity) =
        lo_calculator->calc_open_conf_base_qty(
          iv_confirmed_quantity  =
            ls_confirmation-confirmed_quantity
          iv_reduced_quantity    = ls_confirmation-reduced_quantity
          iv_order_to_base_num   = ls_confirmation-order_to_base_num
          iv_order_to_base_denom =
            ls_confirmation-order_to_base_denom ).
      DATA(lv_confirmation_base_qty) =
        convert_to_stock_quantity(
          iv_quantity = lv_confirmation_quantity ).
      IF lv_confirmation_base_qty > 0.
        APPEND VALUE #(
          material         = ls_confirmation-material
          plant            = ls_confirmation-plant
          base_unit        = ls_confirmation-base_unit
          receipt_date     = ls_confirmation-receipt_date
          quantity         = lv_confirmation_base_qty
          source_type      = 'PO_CONFIRMATION'
          source_document  = ls_confirmation-source_document
          source_item      = ls_confirmation-source_item
          storage_location = ls_confirmation-storage_location
          batch            = ls_confirmation-batch )
          TO lt_receipts.
      ENDIF.
    ENDLOOP.

    IF lines( it_requests ) > 1.
      LOOP AT lt_receipts INTO DATA(ls_indexed_receipt).
        DATA(lv_receipt_row_number) = sy-tabix.
        INSERT VALUE #(
          material   = ls_indexed_receipt-material
          plant      = ls_indexed_receipt-plant
          row_number = lv_receipt_row_number ) INTO TABLE lt_receipt_positions.
      ENDLOOP.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      IF lt_receipt_positions IS INITIAL.
        LOOP AT lt_receipts INTO ls_receipt
            WHERE material = ls_request-material
              AND plant = ls_request-plant
              AND receipt_date <= ls_request-through_date.
          APPEND ls_receipt TO ls_result-receipts.
        ENDLOOP.
      ELSE.
        LOOP AT lt_receipt_positions INTO DATA(ls_receipt_position)
            WHERE material = ls_request-material
              AND plant = ls_request-plant.
          READ TABLE lt_receipts INTO ls_receipt
            INDEX ls_receipt_position-row_number.
          IF sy-subrc <> 0
              OR ls_receipt-receipt_date > ls_request-through_date.
            CONTINUE.
          ENDIF.
          APPEND ls_receipt TO ls_result-receipts.
        ENDLOOP.
      ENDIF.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    DATA lt_sales_documents TYPE zif_stock_repository=>ty_sales_order_documents.

    APPEND iv_sales_document TO lt_sales_documents.
    rt_reservations = zif_stock_repository~get_order_reservations_bulk(
      it_sales_documents       = lt_sales_documents
      iv_required_through_date = iv_required_through_date ).
  ENDMETHOD.

  METHOD zif_so_reservation_finder~get_open_reservation_numbers.
    DATA lt_sales_documents TYPE zif_so_reservation_finder=>ty_sales_documents.
    DATA lt_reservations TYPE zif_so_reservation_finder=>ty_order_reservations.

    IF iv_sales_document IS INITIAL.
      RETURN.
    ENDIF.

    APPEND iv_sales_document TO lt_sales_documents.
    lt_reservations = zif_so_reservation_finder~get_open_reservations_bulk(
      it_sales_documents = lt_sales_documents
      iv_item_number     = iv_item_number ).
    LOOP AT lt_reservations INTO DATA(ls_reservation)
        WHERE sales_document = iv_sales_document.
      APPEND ls_reservation-reservation_number TO rt_reservation_numbers.
    ENDLOOP.
    SORT rt_reservation_numbers.
  ENDMETHOD.

  METHOD zif_so_reservation_finder~get_open_reservations_bulk.
    TYPES:
      BEGIN OF ty_reservation_item_scope,
        reservation_number TYPE resb-rsnum,
        sales_document     TYPE resb-kdauf,
        item_number        TYPE resb-kdpos,
        movement_type      TYPE resb-bwart,
        special_stock      TYPE resb-sobkz,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_item_scope.
    TYPES ty_candidates TYPE HASHED TABLE OF
      zif_so_reservation_finder=>ty_order_reservation
      WITH UNIQUE KEY sales_document reservation_number.
    DATA lt_candidate_numbers TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA lt_candidates TYPE ty_candidates.
    DATA lt_target_items TYPE STANDARD TABLE OF ty_reservation_item_scope
      WITH EMPTY KEY.
    DATA lt_reservation_items TYPE STANDARD TABLE OF ty_reservation_item_scope
      WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_reservation_number
        COMPONENTS reservation_number.

    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum AS reservation_number,
           kdauf AS sales_document,
           kdpos AS item_number,
           bwart AS movement_type,
           sobkz AS special_stock,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE kdauf = @it_sales_documents-table_line
        AND bwart = '231'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_target_items.

    LOOP AT lt_target_items INTO DATA(ls_target_item).
      IF ls_target_item-required_quantity <= ls_target_item-withdrawn_quantity.
        CONTINUE.
      ENDIF.
      IF iv_item_number IS NOT INITIAL
          AND ls_target_item-item_number <> iv_item_number.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        sales_document     = ls_target_item-sales_document
        reservation_number = ls_target_item-reservation_number )
        INTO TABLE lt_candidates.
      INSERT ls_target_item-reservation_number INTO TABLE lt_candidate_numbers.
    ENDLOOP.

    IF lt_candidate_numbers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum AS reservation_number,
           kdauf AS sales_document,
           kdpos AS item_number,
           bwart AS movement_type,
           sobkz AS special_stock
      FROM resb
      FOR ALL ENTRIES IN @lt_candidate_numbers
      WHERE rsnum = @lt_candidate_numbers-table_line
        AND xloek = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_items.

    LOOP AT lt_candidates INTO DATA(ls_candidate).
      DATA(lv_is_order_only) = abap_true.
      DATA(lv_has_document_item) = abap_false.
      LOOP AT lt_reservation_items USING KEY by_reservation_number
          INTO DATA(ls_reservation_item)
          WHERE reservation_number = ls_candidate-reservation_number.
        lv_has_document_item = abap_true.
        IF ls_reservation_item-sales_document <> ls_candidate-sales_document
            OR ( iv_item_number IS NOT INITIAL
              AND ls_reservation_item-item_number <> iv_item_number )
            OR ls_reservation_item-movement_type <> '231'
            OR ls_reservation_item-special_stock <> space.
          lv_is_order_only = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_is_order_only = abap_true AND lv_has_document_item = abap_true.
        APPEND ls_candidate TO rt_reservations.
      ENDIF.
    ENDLOOP.
    SORT rt_reservations BY sales_document reservation_number.
  ENDMETHOD.

  METHOD zif_so_reservation_finder~get_open_item_reservations.
    TYPES:
      BEGIN OF ty_reservation_item_scope,
        reservation_number TYPE resb-rsnum,
        sales_document     TYPE resb-kdauf,
        item_number        TYPE resb-kdpos,
        movement_type      TYPE resb-bwart,
        special_stock      TYPE resb-sobkz,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_item_scope.
    TYPES ty_candidates TYPE HASHED TABLE OF
      zif_so_reservation_finder=>ty_item_reservation
      WITH UNIQUE KEY sales_document item_number reservation_number.
    DATA lt_candidate_numbers TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA lt_candidates TYPE ty_candidates.
    DATA lt_target_items TYPE STANDARD TABLE OF ty_reservation_item_scope
      WITH EMPTY KEY.
    DATA lt_reservation_items TYPE STANDARD TABLE OF ty_reservation_item_scope
      WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY by_reservation_number
        COMPONENTS reservation_number.

    IF it_sales_order_items IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum AS reservation_number,
           kdauf AS sales_document,
           kdpos AS item_number,
           bwart AS movement_type,
           sobkz AS special_stock,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_sales_order_items
      WHERE kdauf = @it_sales_order_items-sales_document
        AND kdpos = @it_sales_order_items-item_number
        AND bwart = '231'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_target_items.

    LOOP AT lt_target_items INTO DATA(ls_target_item).
      IF ls_target_item-required_quantity <= ls_target_item-withdrawn_quantity.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        sales_document     = ls_target_item-sales_document
        item_number        = ls_target_item-item_number
        reservation_number = ls_target_item-reservation_number )
        INTO TABLE lt_candidates.
      INSERT ls_target_item-reservation_number INTO TABLE lt_candidate_numbers.
    ENDLOOP.

    IF lt_candidate_numbers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum AS reservation_number,
           kdauf AS sales_document,
           kdpos AS item_number,
           bwart AS movement_type,
           sobkz AS special_stock
      FROM resb
      FOR ALL ENTRIES IN @lt_candidate_numbers
      WHERE rsnum = @lt_candidate_numbers-table_line
        AND xloek = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_items.

    LOOP AT lt_candidates INTO DATA(ls_candidate).
      DATA(lv_is_item_only) = abap_true.
      DATA(lv_has_document_item) = abap_false.
      LOOP AT lt_reservation_items USING KEY by_reservation_number
          INTO DATA(ls_reservation_item)
          WHERE reservation_number = ls_candidate-reservation_number.
        lv_has_document_item = abap_true.
        IF ls_reservation_item-sales_document <> ls_candidate-sales_document
            OR ls_reservation_item-item_number <> ls_candidate-item_number
            OR ls_reservation_item-movement_type <> '231'
            OR ls_reservation_item-special_stock <> space.
          lv_is_item_only = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_is_item_only = abap_true AND lv_has_document_item = abap_true.
        APPEND ls_candidate TO rt_reservations.
      ENDIF.
    ENDLOOP.
    SORT rt_reservations BY sales_document item_number reservation_number.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
    TYPES:
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        sales_document     TYPE resb-kdauf,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        item_number        TYPE resb-kdpos,
        schedule_line      TYPE resb-kdein,
        requirement_date   TYPE resb-bdter,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
        WITH EMPTY KEY.
    DATA lt_reservation_rows TYPE ty_reservation_rows.
    DATA lv_initial_required_date TYPE resb-bdter.

    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum AS reservation_number,
           rspos AS reservation_item,
           kdauf AS sales_document,
           matnr AS material,
           werks AS plant,
           kdpos AS item_number,
           kdein AS schedule_line,
           bdter AS requirement_date,
           lgort AS storage_location,
           charg AS batch,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE kdauf = @it_sales_documents-table_line
        AND bwart = '231'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    LOOP AT lt_reservation_rows INTO DATA(ls_reservation_row).
      DATA(lv_open_quantity) =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_reservation_row-required_quantity
          iv_withdrawn_quantity = ls_reservation_row-withdrawn_quantity ).
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        reservation_number = ls_reservation_row-reservation_number
        reservation_item   = ls_reservation_row-reservation_item
        sales_document     = ls_reservation_row-sales_document
        material           = ls_reservation_row-material
        plant              = ls_reservation_row-plant
        item_number        = ls_reservation_row-item_number
        schedule_line      = ls_reservation_row-schedule_line
        requirement_date   = ls_reservation_row-requirement_date
        storage_location   = ls_reservation_row-storage_location
        batch              = ls_reservation_row-batch
        required_quantity  = ls_reservation_row-required_quantity
        withdrawn_quantity = ls_reservation_row-withdrawn_quantity
        open_quantity      = lv_open_quantity )
        TO rt_reservations.
    ENDLOOP.
    SORT rt_reservations BY sales_document item_number material plant
      schedule_line requirement_date storage_location batch
      reservation_number reservation_item.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    DATA(lt_results) = zif_stock_repository~get_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'SINGLE-STATUS'
          material   = iv_material
          plant      = iv_plant ) ) ).

    READ TABLE lt_results INTO DATA(ls_result)
      WITH KEY request_id = 'SINGLE-STATUS'.
    IF sy-subrc = 0.
      rs_status = ls_result-stock_status.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_bulk.
    TYPES:
      BEGIN OF ty_mard_row,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        unrestricted_quantity       TYPE mard-labst,
        quality_inspection_quantity TYPE mard-insme,
        blocked_quantity            TYPE mard-speme,
      END OF ty_mard_row,
      ty_mard_rows TYPE STANDARD TABLE OF ty_mard_row WITH EMPTY KEY,
      BEGIN OF ty_stock_total,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        unrestricted_quantity       TYPE decfloat34,
        quality_inspection_quantity TYPE decfloat34,
        blocked_quantity            TYPE decfloat34,
      END OF ty_stock_total,
      ty_stock_totals TYPE HASHED TABLE OF ty_stock_total
        WITH UNIQUE KEY material plant,
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
        WITH EMPTY KEY,
      BEGIN OF ty_reservation_total,
        material          TYPE resb-matnr,
        plant             TYPE resb-werks,
        reserved_quantity TYPE decfloat34,
      END OF ty_reservation_total,
      ty_reservation_totals TYPE HASHED TABLE OF ty_reservation_total
        WITH UNIQUE KEY material plant,
      BEGIN OF ty_safety_stock,
        material              TYPE marc-matnr,
        plant                 TYPE marc-werks,
        safety_stock_quantity TYPE marc-eisbe,
      END OF ty_safety_stock,
      ty_safety_stocks TYPE HASHED TABLE OF ty_safety_stock
        WITH UNIQUE KEY material plant.
    DATA lt_mard_rows TYPE ty_mard_rows.
    DATA lt_stock_totals TYPE ty_stock_totals.
    DATA lt_reservation_rows TYPE ty_reservation_rows.
    DATA lt_reservation_totals TYPE ty_reservation_totals.
    DATA lt_safety_stocks TYPE ty_safety_stocks.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           labst AS unrestricted_quantity,
           insme AS quality_inspection_quantity,
           speme AS blocked_quantity
      FROM mard
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_mard_rows.

    LOOP AT lt_mard_rows INTO DATA(ls_mard_row).
      READ TABLE lt_stock_totals ASSIGNING FIELD-SYMBOL(<ls_stock_total>)
        WITH TABLE KEY material = ls_mard_row-material
                       plant = ls_mard_row-plant.
      IF sy-subrc = 0.
        <ls_stock_total>-unrestricted_quantity +=
          ls_mard_row-unrestricted_quantity.
        <ls_stock_total>-quality_inspection_quantity +=
          ls_mard_row-quality_inspection_quantity.
        <ls_stock_total>-blocked_quantity += ls_mard_row-blocked_quantity.
      ELSE.
        INSERT VALUE #(
          material                    = ls_mard_row-material
          plant                       = ls_mard_row-plant
          unrestricted_quantity       = ls_mard_row-unrestricted_quantity
          quality_inspection_quantity =
            ls_mard_row-quality_inspection_quantity
          blocked_quantity            = ls_mard_row-blocked_quantity )
          INTO TABLE lt_stock_totals.
      ENDIF.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    LOOP AT lt_reservation_rows INTO DATA(ls_reservation_row).
      DATA(lv_open_reservation_quantity) =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_reservation_row-required_quantity
          iv_withdrawn_quantity = ls_reservation_row-withdrawn_quantity ).
      IF lv_open_reservation_quantity <= 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_reservation_totals
        ASSIGNING FIELD-SYMBOL(<ls_reservation_total>)
        WITH TABLE KEY material = ls_reservation_row-material
                       plant = ls_reservation_row-plant.
      IF sy-subrc = 0.
        <ls_reservation_total>-reserved_quantity +=
          lv_open_reservation_quantity.
      ELSE.
        INSERT VALUE #(
          material          = ls_reservation_row-material
          plant             = ls_reservation_row-plant
          reserved_quantity = lv_open_reservation_quantity )
          INTO TABLE lt_reservation_totals.
      ENDIF.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           eisbe AS safety_stock_quantity
      FROM marc
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_safety_stocks.

    DATA(lo_stock_quantity_calculator) = NEW zcl_stock_avail_qty_calc( ).
    LOOP AT it_requests INTO DATA(ls_request).
      DATA(ls_status) = VALUE zif_stock_repository=>ty_stock_status( ).
      READ TABLE lt_stock_totals INTO DATA(ls_stock_total)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        ls_status-unrestricted_quantity = convert_to_stock_quantity(
          iv_quantity = ls_stock_total-unrestricted_quantity ).
        ls_status-quality_inspection_quantity =
          convert_to_stock_quantity(
            iv_quantity = ls_stock_total-quality_inspection_quantity ).
        ls_status-blocked_quantity = convert_to_stock_quantity(
          iv_quantity = ls_stock_total-blocked_quantity ).
      ENDIF.

      READ TABLE lt_reservation_totals INTO DATA(ls_reservation_total)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        ls_status-reserved_quantity = convert_to_stock_quantity(
          iv_quantity = ls_reservation_total-reserved_quantity ).
      ENDIF.

      READ TABLE lt_safety_stocks INTO DATA(ls_safety_stock)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        ls_status-safety_stock_quantity =
          ls_safety_stock-safety_stock_quantity.
      ENDIF.

      ls_status-available_unrestricted_qty =
        lo_stock_quantity_calculator->calculate(
          iv_unrestricted_quantity = ls_status-unrestricted_quantity
          iv_reserved_quantity     = ls_status-reserved_quantity ).
      ls_status-available_after_safety_qty =
        lo_stock_quantity_calculator->calculate_with_safety_stock(
          iv_available_quantity    =
            ls_status-available_unrestricted_qty
          iv_safety_stock_quantity = ls_status-safety_stock_quantity ).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        stock_status = ls_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_location_stock_status_bulk.
    TYPES:
      BEGIN OF ty_mard_row,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        unrestricted_quantity       TYPE mard-labst,
        quality_inspection_quantity TYPE mard-insme,
        blocked_quantity            TYPE mard-speme,
      END OF ty_mard_row,
      ty_mard_rows TYPE STANDARD TABLE OF ty_mard_row WITH EMPTY KEY,
      BEGIN OF ty_stock_total,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        unrestricted_quantity       TYPE mard-labst,
        quality_inspection_quantity TYPE mard-insme,
        blocked_quantity            TYPE mard-speme,
      END OF ty_stock_total,
      ty_stock_totals TYPE SORTED TABLE OF ty_stock_total
        WITH UNIQUE KEY material plant storage_location,
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        storage_location   TYPE resb-lgort,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE SORTED TABLE OF ty_reservation_row
        WITH NON-UNIQUE KEY material plant storage_location.
    DATA lt_mard_rows TYPE ty_mard_rows.
    DATA lt_stock_totals TYPE ty_stock_totals.
    DATA lt_reservation_rows TYPE ty_reservation_rows.
    DATA lt_excluded_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_stock TYPE zcl_stock_location_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_location_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA ls_result TYPE zif_stock_repository=>ty_stock_location_bulk_result.
    DATA lv_available_quantity TYPE mard-labst.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_excluded_reservations = CORRESPONDING #( it_excluded_reservations ).

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           labst AS unrestricted_quantity,
           insme AS quality_inspection_quantity,
           speme AS blocked_quantity
      FROM mard
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_mard_rows.

    LOOP AT lt_mard_rows INTO DATA(ls_mard_row).
      READ TABLE lt_stock_totals ASSIGNING FIELD-SYMBOL(<ls_stock_total>)
        WITH TABLE KEY material = ls_mard_row-material
                       plant = ls_mard_row-plant
                       storage_location = ls_mard_row-storage_location.
      IF sy-subrc = 0.
        <ls_stock_total>-unrestricted_quantity +=
          ls_mard_row-unrestricted_quantity.
        <ls_stock_total>-quality_inspection_quantity +=
          ls_mard_row-quality_inspection_quantity.
        <ls_stock_total>-blocked_quantity += ls_mard_row-blocked_quantity.
      ELSE.
        INSERT VALUE #(
          material                    = ls_mard_row-material
          plant                       = ls_mard_row-plant
          storage_location            = ls_mard_row-storage_location
          unrestricted_quantity       = ls_mard_row-unrestricted_quantity
          quality_inspection_quantity =
            ls_mard_row-quality_inspection_quantity
          blocked_quantity            = ls_mard_row-blocked_quantity )
          INTO TABLE lt_stock_totals.
      ENDIF.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           lgort AS storage_location,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    DATA(lo_location_qty_calc) =
      NEW zcl_stock_location_qty_calc( ).
    LOOP AT it_requests INTO DATA(ls_request).
      CLEAR: lt_stock, lt_reservations, lt_available_stock.
      LOOP AT lt_stock_totals INTO DATA(ls_stock_total)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        APPEND VALUE #(
          storage_location = ls_stock_total-storage_location
          quantity         = ls_stock_total-unrestricted_quantity )
          TO lt_stock.
      ENDLOOP.
      LOOP AT lt_reservation_rows INTO DATA(ls_reservation_row)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        DATA(lv_open_reservation_quantity) =
          zcl_stock_avail_qty_calc=>calculate_open_res_qty(
            iv_required_quantity  = ls_reservation_row-required_quantity
            iv_withdrawn_quantity = ls_reservation_row-withdrawn_quantity ).
        IF lv_open_reservation_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF line_exists( lt_excluded_reservations[
            reservation_number = ls_reservation_row-reservation_number
            reservation_item = ls_reservation_row-reservation_item ] ).
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          storage_location  = ls_reservation_row-storage_location
          required_quantity = lv_open_reservation_quantity )
          TO lt_reservations.
      ENDLOOP.
      lt_available_stock = lo_location_qty_calc->calculate(
        it_stock        = lt_stock
        it_reservations = lt_reservations ).

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      LOOP AT lt_stock_totals INTO ls_stock_total
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        CLEAR lv_available_quantity.
        READ TABLE lt_available_stock INTO DATA(ls_available_stock)
          WITH KEY storage_location = ls_stock_total-storage_location.
        IF sy-subrc = 0.
          lv_available_quantity = ls_available_stock-available_quantity.
        ENDIF.
        APPEND VALUE #(
          storage_location           = ls_stock_total-storage_location
          unrestricted_quantity      = ls_stock_total-unrestricted_quantity
          available_unrestricted_qty = lv_available_quantity
          quality_inspection_qty     =
            ls_stock_total-quality_inspection_quantity
          blocked_quantity           = ls_stock_total-blocked_quantity )
          TO ls_result-locations.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    DATA lt_stock TYPE zcl_stock_location_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_location_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_location_stocks.

    SELECT lgort AS storage_location,
           SUM( labst ) AS unrestricted_quantity,
           SUM( insme ) AS quality_inspection_qty,
           SUM( speme ) AS blocked_quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @rt_status.

    LOOP AT rt_status INTO DATA(ls_stock_status).
      APPEND VALUE #(
        storage_location = ls_stock_status-storage_location
        quantity         = ls_stock_status-unrestricted_quantity )
        TO lt_stock.
    ENDLOOP.

    SELECT lgort AS storage_location,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    lt_available_stock = NEW zcl_stock_location_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).
    LOOP AT rt_status ASSIGNING FIELD-SYMBOL(<ls_stock_status>).
      READ TABLE lt_available_stock INTO DATA(ls_available_stock)
        WITH KEY storage_location = <ls_stock_status>-storage_location.
      IF sy-subrc = 0.
        <ls_stock_status>-available_unrestricted_qty =
          ls_available_stock-available_quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    DATA lt_stock TYPE zcl_stock_location_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_location_qty_calc=>ty_reservations.

    SELECT lgort AS storage_location, SUM( labst ) AS quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock.

    SELECT lgort AS storage_location,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    rt_stock = NEW zcl_stock_location_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    DATA(lt_batch_status) = me->zif_stock_repository~get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_batch_status INTO DATA(ls_batch_status).
      IF ls_batch_status-available_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        storage_location   = ls_batch_status-storage_location
        batch              = ls_batch_status-batch
        expiration_date    = ls_batch_status-expiration_date
        available_quantity = ls_batch_status-available_quantity ) TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_batch_stock_status_bulk.
    TYPES:
      BEGIN OF ty_mchb_row,
        material         TYPE mchb-matnr,
        plant            TYPE mchb-werks,
        storage_location TYPE mchb-lgort,
        batch            TYPE mchb-charg,
        unrestricted_qty TYPE mchb-clabs,
        quality_qty      TYPE mchb-cinsm,
        blocked_qty      TYPE mchb-cspem,
      END OF ty_mchb_row,
      ty_mchb_rows TYPE STANDARD TABLE OF ty_mchb_row WITH EMPTY KEY,
      BEGIN OF ty_stock_total,
        material         TYPE mchb-matnr,
        plant            TYPE mchb-werks,
        storage_location TYPE mchb-lgort,
        batch            TYPE mchb-charg,
        valuation_type   TYPE mcha-bwtar,
        batch_managed    TYPE marc-xchar,
        expiration_date  TYPE mcha-vfdat,
        expiry_source    TYPE c LENGTH 1,
        unrestricted_qty TYPE mchb-clabs,
        quality_qty      TYPE mchb-cinsm,
        blocked_qty      TYPE mchb-cspem,
      END OF ty_stock_total,
      ty_stock_totals TYPE SORTED TABLE OF ty_stock_total
        WITH UNIQUE KEY material plant storage_location batch,
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        valuation_type     TYPE resb-bwtar,
        required_date      TYPE resb-bdter,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE SORTED TABLE OF ty_reservation_row
        WITH NON-UNIQUE KEY material plant storage_location batch,
      BEGIN OF ty_plant_batch,
        material        TYPE mcha-matnr,
        plant           TYPE mcha-werks,
        batch           TYPE mcha-charg,
        valuation_type  TYPE mcha-bwtar,
        expiration_date TYPE mcha-vfdat,
      END OF ty_plant_batch,
      ty_plant_batches TYPE HASHED TABLE OF ty_plant_batch
        WITH UNIQUE KEY material plant batch,
      BEGIN OF ty_material_plant,
        material      TYPE marc-matnr,
        plant         TYPE marc-werks,
        batch_managed TYPE marc-xchar,
      END OF ty_material_plant,
      ty_material_plants TYPE HASHED TABLE OF ty_material_plant
        WITH UNIQUE KEY material plant,
      BEGIN OF ty_global_batch,
        material        TYPE mch1-matnr,
        batch           TYPE mch1-charg,
        expiration_date TYPE mch1-vfdat,
      END OF ty_global_batch,
      ty_global_batches TYPE HASHED TABLE OF ty_global_batch
        WITH UNIQUE KEY material batch.
    DATA lt_mchb_rows TYPE ty_mchb_rows.
    DATA lt_stock_totals TYPE ty_stock_totals.
    DATA lt_reservation_rows TYPE ty_reservation_rows.
    DATA lt_excluded_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_matched_exclusions TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_plant_batches TYPE ty_plant_batches.
    DATA lt_material_plants TYPE ty_material_plants.
    DATA lt_global_batches TYPE ty_global_batches.
    DATA lt_stock TYPE zcl_stock_batch_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_batch_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA ls_result TYPE zif_stock_repository=>ty_batch_status_bulk_result.
    DATA ls_availability_result TYPE
      zcl_stock_batch_qty_calc=>ty_calculation_result.
    DATA lv_available_quantity TYPE mchb-clabs.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_excluded_reservations
        INTO DATA(ls_excluded_reservation).
      INSERT ls_excluded_reservation INTO TABLE lt_excluded_reservations.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           clabs AS unrestricted_qty,
           cinsm AS quality_qty,
           cspem AS blocked_qty
      FROM mchb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_mchb_rows.

    LOOP AT lt_mchb_rows INTO DATA(ls_mchb_row).
      READ TABLE lt_stock_totals ASSIGNING FIELD-SYMBOL(<ls_stock_total>)
        WITH TABLE KEY material = ls_mchb_row-material
                       plant = ls_mchb_row-plant
                       storage_location = ls_mchb_row-storage_location
                       batch = ls_mchb_row-batch.
      IF sy-subrc = 0.
        <ls_stock_total>-unrestricted_qty += ls_mchb_row-unrestricted_qty.
        <ls_stock_total>-quality_qty += ls_mchb_row-quality_qty.
        <ls_stock_total>-blocked_qty += ls_mchb_row-blocked_qty.
      ELSE.
        INSERT VALUE #(
          material         = ls_mchb_row-material
          plant            = ls_mchb_row-plant
          storage_location = ls_mchb_row-storage_location
          batch            = ls_mchb_row-batch
          unrestricted_qty = ls_mchb_row-unrestricted_qty
          quality_qty      = ls_mchb_row-quality_qty
          blocked_qty      = ls_mchb_row-blocked_qty )
          INTO TABLE lt_stock_totals.
      ENDIF.
    ENDLOOP.

    IF lt_stock_totals IS NOT INITIAL.
      SELECT matnr AS material,
             werks AS plant,
             charg AS batch,
             bwtar AS valuation_type,
             vfdat AS expiration_date
        FROM mcha
        FOR ALL ENTRIES IN @lt_stock_totals
        WHERE matnr = @lt_stock_totals-material
          AND werks = @lt_stock_totals-plant
          AND charg = @lt_stock_totals-batch
        INTO CORRESPONDING FIELDS OF TABLE @lt_plant_batches.

      SELECT matnr AS material,
             werks AS plant,
             xchar AS batch_managed
        FROM marc
        FOR ALL ENTRIES IN @lt_stock_totals
        WHERE matnr = @lt_stock_totals-material
          AND werks = @lt_stock_totals-plant
        INTO CORRESPONDING FIELDS OF TABLE @lt_material_plants.

      SELECT matnr AS material,
             charg AS batch,
             vfdat AS expiration_date
        FROM mch1
        FOR ALL ENTRIES IN @lt_stock_totals
        WHERE matnr = @lt_stock_totals-material
          AND charg = @lt_stock_totals-batch
        INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.
    ENDIF.

    LOOP AT lt_stock_totals ASSIGNING <ls_stock_total>.
      READ TABLE lt_plant_batches INTO DATA(ls_plant_batch)
        WITH TABLE KEY material = <ls_stock_total>-material
                       plant = <ls_stock_total>-plant
                       batch = <ls_stock_total>-batch.
      IF sy-subrc = 0.
        IF ls_plant_batch-expiration_date IS NOT INITIAL.
          <ls_stock_total>-expiration_date =
            ls_plant_batch-expiration_date.
          <ls_stock_total>-expiry_source =
            zif_stock_repository=>c_expiry_source_plant.
        ENDIF.
        IF ls_plant_batch-valuation_type IS NOT INITIAL.
          <ls_stock_total>-valuation_type =
            ls_plant_batch-valuation_type.
        ENDIF.
      ENDIF.
      READ TABLE lt_material_plants INTO DATA(ls_material_plant)
        WITH TABLE KEY material = <ls_stock_total>-material
                       plant = <ls_stock_total>-plant.
      IF sy-subrc = 0.
        <ls_stock_total>-batch_managed =
          ls_material_plant-batch_managed.
        IF <ls_stock_total>-valuation_type IS INITIAL
            AND <ls_stock_total>-batch_managed IS INITIAL.
          <ls_stock_total>-valuation_type = <ls_stock_total>-batch.
        ENDIF.
      ENDIF.
      IF <ls_stock_total>-expiration_date IS INITIAL.
        READ TABLE lt_global_batches INTO DATA(ls_global_batch)
          WITH TABLE KEY material = <ls_stock_total>-material
                         batch = <ls_stock_total>-batch.
        IF sy-subrc = 0.
          IF ls_global_batch-expiration_date IS NOT INITIAL.
            <ls_stock_total>-expiration_date =
              ls_global_batch-expiration_date.
            <ls_stock_total>-expiry_source =
              zif_stock_repository=>c_expiry_source_global.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SELECT rsnum AS reservation_number,
           rspos AS reservation_item,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           bwtar AS valuation_type,
           bdter AS required_date,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_rows.

    DATA(lo_batch_qty_calc) = NEW zcl_stock_batch_qty_calc( ).
    LOOP AT it_requests INTO DATA(ls_request).
      CLEAR: lt_stock, lt_reservations, lt_available_stock,
        lt_matched_exclusions, ls_result.
      LOOP AT lt_stock_totals INTO DATA(ls_stock_total)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        APPEND VALUE #(
          storage_location = ls_stock_total-storage_location
          batch            = ls_stock_total-batch
          valuation_type   = ls_stock_total-valuation_type
          expiration_date  = ls_stock_total-expiration_date
          expiry_source    = ls_stock_total-expiry_source
          quantity         = ls_stock_total-unrestricted_qty )
          TO lt_stock.
      ENDLOOP.
      LOOP AT lt_reservation_rows INTO DATA(ls_reservation_row)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        DATA(lv_open_reservation_quantity) =
          zcl_stock_avail_qty_calc=>calculate_open_res_qty(
            iv_required_quantity  = ls_reservation_row-required_quantity
            iv_withdrawn_quantity = ls_reservation_row-withdrawn_quantity ).
        IF lv_open_reservation_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF line_exists( lt_excluded_reservations[
            reservation_number = ls_reservation_row-reservation_number
            reservation_item = ls_reservation_row-reservation_item ] ).
          ls_result-excluded_open_resv_quantity +=
            lv_open_reservation_quantity.
          INSERT VALUE #(
            reservation_number = ls_reservation_row-reservation_number
            reservation_item   = ls_reservation_row-reservation_item )
            INTO TABLE lt_matched_exclusions.
          ADD 1 TO ls_result-excluded_open_resv_row_count.
          CONTINUE.
        ENDIF.
        ls_result-open_reservation_quantity +=
          lv_open_reservation_quantity.
        ADD 1 TO ls_result-open_reservation_row_count.
        APPEND VALUE #(
          reservation_number = ls_reservation_row-reservation_number
          reservation_item   = ls_reservation_row-reservation_item
          required_date      = ls_reservation_row-required_date
          storage_location   = ls_reservation_row-storage_location
          batch              = ls_reservation_row-batch
          valuation_type     = ls_reservation_row-valuation_type
          required_quantity  = ls_reservation_row-required_quantity
          withdrawn_quantity = ls_reservation_row-withdrawn_quantity )
          TO lt_reservations.
      ENDLOOP.
      LOOP AT lt_excluded_reservations INTO ls_excluded_reservation.
        IF line_exists( lt_matched_exclusions[
            reservation_number =
              ls_excluded_reservation-reservation_number
            reservation_item = ls_excluded_reservation-reservation_item ] ).
          CONTINUE.
        ENDIF.
        APPEND ls_excluded_reservation
          TO ls_result-unmatched_excl_reservations.
      ENDLOOP.
      SORT ls_result-unmatched_excl_reservations
        BY reservation_number reservation_item.
      ls_result-unmatched_open_resv_excl_count =
        lines( ls_result-unmatched_excl_reservations ).
      ls_availability_result = lo_batch_qty_calc->calculate_with_summary(
        it_stock        = lt_stock
        it_reservations = lt_reservations ).
      lt_available_stock = ls_availability_result-stocks.
      ls_result-uncovered_open_resv_quantity =
        ls_availability_result-uncovered_reservation_quantity.
      ls_result-matched_allocation_quantity =
        ls_availability_result-matched_allocation_quantity.
      ls_result-fallback_allocation_quantity =
        ls_availability_result-fallback_allocation_quantity.
      ls_result-matched_allocation_row_count =
        ls_availability_result-matched_allocation_row_count.
      ls_result-fallback_allocation_row_count =
        ls_availability_result-fallback_allocation_row_count.
      ls_result-fully_allocated_resv_count =
        ls_availability_result-fully_allocated_resv_count.
      ls_result-partially_allocated_resv_count =
        ls_availability_result-partially_allocated_resv_count.
      ls_result-unallocated_resv_count =
        ls_availability_result-unallocated_resv_count.
      ls_result-fully_alloc_resv_open_qty =
        ls_availability_result-fully_alloc_resv_open_qty.
      ls_result-part_alloc_resv_open_qty =
        ls_availability_result-part_alloc_resv_open_qty.
      ls_result-unalloc_resv_open_qty =
        ls_availability_result-unalloc_resv_open_qty.
      ls_result-uncovered_open_resv_keys =
        ls_availability_result-uncovered_reservation_keys.
      ls_result-uncovered_open_reservations =
        ls_availability_result-uncovered_reservations.
      ls_result-resv_allocation_summaries =
        ls_availability_result-resv_allocation_summaries.
      ls_result-allocation_details =
        ls_availability_result-allocation_details.
      ls_result-uncovered_open_resv_row_count =
        lines( ls_result-uncovered_open_reservations ).
      LOOP AT ls_result-uncovered_open_reservations
          INTO DATA(ls_uncovered_summary).
        IF ls_uncovered_summary-required_date IS INITIAL.
          CONTINUE.
        ENDIF.
        IF ls_result-first_uncovered_required_date IS INITIAL
            OR ls_uncovered_summary-required_date
              < ls_result-first_uncovered_required_date.
          ls_result-first_uncovered_required_date =
            ls_uncovered_summary-required_date.
          ls_result-first_uncovered_resv_number =
            ls_uncovered_summary-reservation_number.
          ls_result-first_uncovered_resv_item =
            ls_uncovered_summary-reservation_item.
        ELSEIF ls_uncovered_summary-required_date
            = ls_result-first_uncovered_required_date.
          IF ls_uncovered_summary-reservation_number
                < ls_result-first_uncovered_resv_number
              OR ( ls_uncovered_summary-reservation_number
                    = ls_result-first_uncovered_resv_number
                AND ls_uncovered_summary-reservation_item
                    < ls_result-first_uncovered_resv_item ).
            ls_result-first_uncovered_required_date =
              ls_uncovered_summary-required_date.
            ls_result-first_uncovered_resv_number =
              ls_uncovered_summary-reservation_number.
            ls_result-first_uncovered_resv_item =
              ls_uncovered_summary-reservation_item.
          ENDIF.
        ENDIF.
      ENDLOOP.

      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      LOOP AT lt_stock_totals INTO ls_stock_total
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        CLEAR lv_available_quantity.
        READ TABLE lt_available_stock INTO DATA(ls_available_stock)
          WITH KEY storage_location = ls_stock_total-storage_location
                   batch = ls_stock_total-batch.
        IF sy-subrc = 0.
          lv_available_quantity = ls_available_stock-available_quantity.
        ENDIF.
        APPEND VALUE #(
          storage_location            = ls_stock_total-storage_location
          batch                       = ls_stock_total-batch
          valuation_type              = ls_stock_total-valuation_type
          batch_managed               = ls_stock_total-batch_managed
          expiration_date             = ls_stock_total-expiration_date
          expiration_date_source      =
            ls_stock_total-expiry_source
          unrestricted_quantity       = ls_stock_total-unrestricted_qty
          available_quantity          = lv_available_quantity
          quality_inspection_quantity = ls_stock_total-quality_qty
          blocked_quantity            = ls_stock_total-blocked_qty )
          TO ls_result-batches.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    TYPES:
      BEGIN OF ty_batch_category_quantity,
        storage_location            TYPE mchb-lgort,
        batch                       TYPE mchb-charg,
        unrestricted_quantity       TYPE mchb-clabs,
        quality_inspection_quantity TYPE mchb-cinsm,
        blocked_quantity            TYPE mchb-cspem,
      END OF ty_batch_category_quantity,
      ty_batch_category_quantities TYPE STANDARD TABLE OF
        ty_batch_category_quantity WITH EMPTY KEY.
    DATA lt_stock TYPE zcl_stock_batch_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_batch_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lt_plant_batches TYPE STANDARD TABLE OF mcha WITH DEFAULT KEY.
    DATA lt_global_batches TYPE STANDARD TABLE OF mch1 WITH DEFAULT KEY.
    DATA lt_category_quantities TYPE ty_batch_category_quantities.
    DATA ls_category_quantity TYPE ty_batch_category_quantity.
    DATA lv_batch_managed TYPE marc-xchar.
    DATA lv_available_quantity TYPE mchb-clabs.

    SELECT lgort AS storage_location,
           charg AS batch,
           SUM( clabs ) AS unrestricted_quantity,
           SUM( cinsm ) AS quality_inspection_quantity,
           SUM( cspem ) AS blocked_quantity
      FROM mchb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort, charg
      INTO CORRESPONDING FIELDS OF TABLE @lt_category_quantities.

    LOOP AT lt_category_quantities INTO ls_category_quantity.
      APPEND VALUE #(
        storage_location = ls_category_quantity-storage_location
        batch            = ls_category_quantity-batch
        quantity         = ls_category_quantity-unrestricted_quantity )
        TO lt_stock.
    ENDLOOP.

    SELECT charg, vfdat, bwtar
      FROM mcha
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_plant_batches.

    SELECT SINGLE xchar
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_batch_managed.

    SELECT charg, vfdat
      FROM mch1
      WHERE matnr = @iv_material
      INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.

    LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      READ TABLE lt_plant_batches INTO DATA(ls_plant_batch)
        WITH KEY charg = <ls_stock>-batch.
      IF sy-subrc = 0.
        IF ls_plant_batch-vfdat IS NOT INITIAL.
          <ls_stock>-expiration_date = ls_plant_batch-vfdat.
        ENDIF.
        IF ls_plant_batch-bwtar IS NOT INITIAL.
          <ls_stock>-valuation_type = ls_plant_batch-bwtar.
        ELSEIF lv_batch_managed IS INITIAL.
          <ls_stock>-valuation_type = <ls_stock>-batch.
        ENDIF.
      ELSE.
        IF lv_batch_managed IS INITIAL.
          <ls_stock>-valuation_type = <ls_stock>-batch.
        ENDIF.
        READ TABLE lt_global_batches INTO DATA(ls_global_batch)
          WITH KEY charg = <ls_stock>-batch.
        IF sy-subrc = 0.
          <ls_stock>-expiration_date = ls_global_batch-vfdat.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SELECT lgort AS storage_location,
           charg AS batch,
           bwtar AS valuation_type,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    lt_available_stock = NEW zcl_stock_batch_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      CLEAR lv_available_quantity.
      READ TABLE lt_category_quantities INTO ls_category_quantity
        WITH KEY storage_location = ls_stock-storage_location
                 batch            = ls_stock-batch.
      READ TABLE lt_available_stock INTO DATA(ls_available_stock)
        WITH KEY storage_location = ls_stock-storage_location
                 batch            = ls_stock-batch.
      IF sy-subrc = 0.
        lv_available_quantity = ls_available_stock-available_quantity.
      ENDIF.
      APPEND VALUE #(
        storage_location            = ls_stock-storage_location
        batch                       = ls_stock-batch
        valuation_type              = ls_stock-valuation_type
        batch_managed               = lv_batch_managed
        expiration_date             = ls_stock-expiration_date
        unrestricted_quantity       = ls_stock-quantity
        available_quantity          = lv_available_quantity
        quality_inspection_quantity =
          ls_category_quantity-quality_inspection_quantity
        blocked_quantity            = ls_category_quantity-blocked_quantity )
        TO rt_status.
    ENDLOOP.
    SORT rt_status BY storage_location batch.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_reservations.
    TYPES:
      BEGIN OF ty_reservation_row,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        required_date      TYPE resb-bdter,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
        WITH EMPTY KEY.
    DATA lt_rows TYPE ty_reservation_rows.
    DATA lv_initial_required_date TYPE resb-bdter.

    SELECT rsnum AS reservation_number,
           rspos AS reservation_item,
           bdter AS required_date,
           lgort AS storage_location,
           charg AS batch,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_rows.

    LOOP AT lt_rows INTO DATA(ls_row).
      DATA(lv_open_quantity) = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
        iv_required_quantity  = ls_row-required_quantity
        iv_withdrawn_quantity = ls_row-withdrawn_quantity ).
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        reservation_number = ls_row-reservation_number
        reservation_item   = ls_row-reservation_item
        required_date      = ls_row-required_date
        storage_location   = ls_row-storage_location
        batch              = ls_row-batch
        open_quantity      = lv_open_quantity ) TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_res_bulk.
    TYPES:
      BEGIN OF ty_reservation_row,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        required_date      TYPE resb-bdter,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_row,
      ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
        WITH EMPTY KEY
        WITH NON-UNIQUE SORTED KEY by_scope COMPONENTS material plant.
    DATA lt_rows TYPE ty_reservation_rows.
    DATA lv_initial_required_date TYPE resb-bdter.
    FIELD-SYMBOLS <ls_result> TYPE
      zif_stock_repository=>ty_stock_reservation_bulk_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           bdter AS required_date,
           lgort AS storage_location,
           charg AS batch,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_rows.

    LOOP AT rt_status ASSIGNING <ls_result>.
      LOOP AT lt_rows USING KEY by_scope INTO DATA(ls_row)
          WHERE material = <ls_result>-material
            AND plant = <ls_result>-plant.
        DATA(lv_open_quantity) = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_row-required_quantity
          iv_withdrawn_quantity = ls_row-withdrawn_quantity ).
        IF lv_open_quantity <= 0.
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          reservation_number = ls_row-reservation_number
          reservation_item   = ls_row-reservation_item
          required_date      = ls_row-required_date
          storage_location   = ls_row-storage_location
          batch              = ls_row-batch
          required_quantity  = ls_row-required_quantity
          withdrawn_quantity = ls_row-withdrawn_quantity
          open_quantity      = lv_open_quantity )
          TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_to_stock_quantity.
    TRY.
        rv_quantity = CONV mard-labst( iv_quantity ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF iv_quantity <> 0 AND rv_quantity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
