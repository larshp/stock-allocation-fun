CLASS zcl_mard_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    INTERFACES zif_so_reservation_finder.
ENDCLASS.

CLASS zcl_mard_stock_repository IMPLEMENTATION.

  METHOD zif_stock_repository~get_projected_receipts.
    TYPES:
      BEGIN OF ty_schedule,
        source_document      TYPE eket-ebeln,
        source_item          TYPE eket-ebelp,
        source_schedule_line TYPE eket-etenr,
        receipt_date         TYPE eket-eindt,
        scheduled_quantity   TYPE eket-menge,
        issued_quantity      TYPE eket-wamng,
        received_quantity    TYPE eket-wemng,
        delivery_complete    TYPE ekpo-elikz,
        order_to_base_num    TYPE ekpo-umrez,
        order_to_base_denom  TYPE ekpo-umren,
      END OF ty_schedule.
    TYPES:
      BEGIN OF ty_production_receipt,
        production_order    TYPE afpo-aufnr,
        production_item     TYPE afpo-posnr,
        receipt_date        TYPE afko-gltrp,
        order_quantity      TYPE afpo-psmng,
        received_quantity   TYPE afpo-wemng,
        order_to_base_num   TYPE afpo-umrez,
        order_to_base_denom TYPE afpo-umren,
      END OF ty_production_receipt.
    TYPES:
      BEGIN OF ty_pr_receipt,
        source_document          TYPE eban-banfn,
        source_item              TYPE eban-bnfpo,
        item_category            TYPE eban-pstyp,
        supplying_plant          TYPE eban-reswk,
        receipt_date             TYPE eban-lfdat,
        requested_quantity       TYPE eban-menge,
        ordered_quantity         TYPE eban-bsmng,
        requisition_unit         TYPE eban-meins,
        base_unit                TYPE mara-meins,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_pr_receipt.
    TYPES:
      BEGIN OF ty_planned_receipt,
        planned_order            TYPE plaf-plnum,
        receipt_date             TYPE plaf-pedtr,
        planned_quantity         TYPE plaf-gsmng,
        order_unit               TYPE plaf-meins,
        base_unit                TYPE mara-meins,
        unit_to_base_numerator   TYPE marm-umrez,
        unit_to_base_denominator TYPE marm-umren,
      END OF ty_planned_receipt.
    DATA lt_schedules TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.
    DATA lt_production_receipts TYPE STANDARD TABLE OF
      ty_production_receipt WITH EMPTY KEY.
    DATA lt_pr_receipts TYPE STANDARD TABLE OF ty_pr_receipt WITH EMPTY KEY.
    DATA lt_planned_receipts TYPE STANDARD TABLE OF ty_planned_receipt
      WITH EMPTY KEY.
    DATA lv_base_unit TYPE mara-meins.
    DATA lv_initial_date TYPE d.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_through_date IS INITIAL
        OR ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
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
          AND iv_include_planned_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_include_po_receipts <> abap_true
        AND iv_include_sto_in_transit <> abap_true
        AND iv_include_unissued_sto <> abap_true
        AND iv_include_prod_receipts <> abap_true
        AND iv_include_pr_receipts <> abap_true
        AND iv_include_sto_pr_receipts <> abap_true
        AND iv_include_planned_receipts <> abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE meins
      FROM mara
      WHERE matnr = @iv_material
      INTO @lv_base_unit.
    IF lv_base_unit IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_include_po_receipts = abap_true.
      SELECT eket~ebeln AS source_document,
             eket~ebelp AS source_item,
             eket~etenr AS source_schedule_line,
             eket~eindt AS receipt_date,
             eket~menge AS scheduled_quantity,
             eket~wamng AS issued_quantity,
             eket~wemng AS received_quantity,
             ekpo~elikz AS delivery_complete,
             ekpo~umrez AS order_to_base_num,
             ekpo~umren AS order_to_base_denom
        FROM eket
        INNER JOIN ekpo
          ON ekpo~ebeln = eket~ebeln
         AND ekpo~ebelp = eket~ebelp
        WHERE ekpo~matnr = @iv_material
          AND ekpo~werks = @iv_plant
          AND ekpo~pstyp = '0'
          AND ekpo~knttp = @space
          AND ekpo~loekz = @space
          AND ekpo~elikz = @space
          AND ekpo~retpo = @space
          AND ekpo~wepos = 'X'
          AND ekpo~insmk = @space
          AND eket~eindt > @lv_initial_date
          AND eket~eindt <= @iv_through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_schedules.

      DATA(lo_po_calculator) = NEW zcl_po_sched_qty_calc( ).
      LOOP AT lt_schedules INTO DATA(ls_po_schedule).
        DATA(lv_po_quantity) = lo_po_calculator->calculate_open_base_quantity(
          iv_scheduled_quantity  = ls_po_schedule-scheduled_quantity
          iv_received_quantity   = ls_po_schedule-received_quantity
          iv_order_to_base_num   = ls_po_schedule-order_to_base_num
          iv_order_to_base_denom = ls_po_schedule-order_to_base_denom ).
        DATA(lv_po_base_quantity) = CONV mard-labst( lv_po_quantity ).
        IF lv_po_base_quantity > 0.
          APPEND VALUE #(
            material             = iv_material
            plant                = iv_plant
            base_unit            = lv_base_unit
            receipt_date         = ls_po_schedule-receipt_date
            quantity             = lv_po_base_quantity
            source_type          = 'PO'
            source_document      = ls_po_schedule-source_document
            source_item          = ls_po_schedule-source_item
            source_schedule_line = ls_po_schedule-source_schedule_line )
            TO rt_receipts.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true.
      CLEAR lt_schedules.
      SELECT eket~ebeln AS source_document,
             eket~ebelp AS source_item,
             eket~etenr AS source_schedule_line,
             eket~eindt AS receipt_date,
             eket~menge AS scheduled_quantity,
             eket~wamng AS issued_quantity,
             eket~wemng AS received_quantity,
             ekpo~elikz AS delivery_complete,
             ekpo~umrez AS order_to_base_num,
             ekpo~umren AS order_to_base_denom
        FROM eket
        INNER JOIN ekpo
          ON ekpo~ebeln = eket~ebeln
         AND ekpo~ebelp = eket~ebelp
        INNER JOIN ekko
          ON ekko~ebeln = ekpo~ebeln
        WHERE ekpo~matnr = @iv_material
          AND ekpo~werks = @iv_plant
          AND ekpo~pstyp = '7'
          AND ekko~reswk <> @space
          AND ekko~bsakz <> 'T'
          AND ( ekko~bstyp = 'F' OR ekko~bstyp = 'L' )
          AND ekpo~knttp = @space
          AND ekpo~loekz = @space
          AND ekpo~stapo = @space
          AND ekpo~retpo = @space
          AND ekpo~wepos = 'X'
          AND ekpo~insmk = @space
          AND eket~eindt > @lv_initial_date
          AND eket~eindt <= @iv_through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_schedules.

      DATA(lo_sto_calculator) = NEW zcl_po_sched_qty_calc( ).
      LOOP AT lt_schedules INTO DATA(ls_sto_schedule).
        IF iv_include_sto_in_transit = abap_true.
          DATA(lv_issued_quantity) =
            lo_sto_calculator->calculate_open_issued_qty(
              iv_issued_quantity     = ls_sto_schedule-issued_quantity
              iv_received_quantity   = ls_sto_schedule-received_quantity
              iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
              iv_order_to_base_denom =
                ls_sto_schedule-order_to_base_denom ).
          DATA(lv_issued_base_quantity) =
            CONV mard-labst( lv_issued_quantity ).
          IF lv_issued_base_quantity > 0.
            APPEND VALUE #(
              material             = iv_material
              plant                = iv_plant
              base_unit            = lv_base_unit
              receipt_date         = ls_sto_schedule-receipt_date
              quantity             = lv_issued_base_quantity
              source_type          = 'STO_IN_TRANSIT'
              source_document      = ls_sto_schedule-source_document
              source_item          = ls_sto_schedule-source_item
              source_schedule_line = ls_sto_schedule-source_schedule_line )
              TO rt_receipts.
          ENDIF.
        ENDIF.
        IF iv_include_unissued_sto = abap_true
            AND ls_sto_schedule-delivery_complete = space.
          DATA(lv_unissued_quantity) =
            lo_sto_calculator->calculate_open_unissued_qty(
              iv_scheduled_quantity  = ls_sto_schedule-scheduled_quantity
              iv_issued_quantity     = ls_sto_schedule-issued_quantity
              iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
              iv_order_to_base_denom =
                ls_sto_schedule-order_to_base_denom ).
          DATA(lv_unissued_base_quantity) =
            CONV mard-labst( lv_unissued_quantity ).
          IF lv_unissued_base_quantity > 0.
            APPEND VALUE #(
              material             = iv_material
              plant                = iv_plant
              base_unit            = lv_base_unit
              receipt_date         = ls_sto_schedule-receipt_date
              quantity             = lv_unissued_base_quantity
              source_type          = 'STO_UNISSUED'
              source_document      = ls_sto_schedule-source_document
              source_item          = ls_sto_schedule-source_item
              source_schedule_line = ls_sto_schedule-source_schedule_line )
              TO rt_receipts.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_include_prod_receipts = abap_true.
      SELECT afpo~aufnr AS production_order,
             afpo~posnr AS production_item,
             afko~gltrp AS receipt_date,
             afpo~psmng AS order_quantity,
             afpo~wemng AS received_quantity,
             afpo~umrez AS order_to_base_num,
             afpo~umren AS order_to_base_denom
        FROM afpo
        INNER JOIN afko
          ON afko~aufnr = afpo~aufnr
        INNER JOIN aufk
          ON aufk~aufnr = afpo~aufnr
        WHERE afpo~matnr = @iv_material
          AND afpo~werks = @iv_plant
          AND afpo~wepos = 'X'
          AND afpo~xloek = @space
          AND afpo~elikz = @space
          AND afpo~kdauf = @space
          AND afpo~knttp = @space
          AND aufk~autyp = '10'
          AND aufk~phas1 = 'X'
          AND aufk~phas2 = @space
          AND aufk~phas3 = @space
          AND aufk~loekz = @space
          AND afko~gltrp > @lv_initial_date
          AND afko~gltrp <= @iv_through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_production_receipts.

      DATA(lo_production_calculator) = NEW zcl_prod_order_qty_calc( ).
      LOOP AT lt_production_receipts INTO DATA(ls_production_receipt).
        DATA(lv_production_quantity) =
          lo_production_calculator->calculate_open_base_quantity(
            iv_order_quantity      = ls_production_receipt-order_quantity
            iv_received_quantity   = ls_production_receipt-received_quantity
            iv_order_to_base_num   = ls_production_receipt-order_to_base_num
            iv_order_to_base_denom = ls_production_receipt-order_to_base_denom ).
        DATA(lv_production_base_quantity) =
          CONV mard-labst( lv_production_quantity ).
        IF lv_production_base_quantity > 0.
          APPEND VALUE #(
            material        = iv_material
            plant           = iv_plant
            base_unit       = lv_base_unit
            receipt_date    = ls_production_receipt-receipt_date
            quantity        = lv_production_base_quantity
            source_type     = 'PRODUCTION'
            source_document = ls_production_receipt-production_order
            source_item     = ls_production_receipt-production_item )
            TO rt_receipts.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true.
      IF iv_include_pr_receipts = abap_true.
        SELECT eban~banfn AS source_document,
               eban~bnfpo AS source_item,
               eban~pstyp AS item_category,
               eban~reswk AS supplying_plant,
               eban~lfdat AS receipt_date,
               eban~menge AS requested_quantity,
               eban~bsmng AS ordered_quantity,
               eban~meins AS requisition_unit,
               mara~meins AS base_unit,
               marm~umrez AS unit_to_base_numerator,
               marm~umren AS unit_to_base_denominator
          FROM eban
          INNER JOIN mara
            ON mara~matnr = eban~matnr
          LEFT OUTER JOIN marm
            ON marm~matnr = eban~matnr
           AND marm~meinh = eban~meins
          WHERE eban~matnr = @iv_material
            AND eban~werks = @iv_plant
            AND eban~lfdat > @lv_initial_date
            AND eban~lfdat <= @iv_through_date
            AND eban~loekz = @space
            AND eban~ebakz = @space
            AND eban~blckd <> '1'
            AND eban~pstyp = '0'
            AND eban~knttp = @space
            AND eban~sobkz = @space
            AND eban~menge > eban~bsmng
          INTO CORRESPONDING FIELDS OF TABLE @lt_pr_receipts.
      ENDIF.

      IF iv_include_sto_pr_receipts = abap_true.
        SELECT eban~banfn AS source_document,
               eban~bnfpo AS source_item,
               eban~pstyp AS item_category,
               eban~reswk AS supplying_plant,
               eban~lfdat AS receipt_date,
               eban~menge AS requested_quantity,
               eban~bsmng AS ordered_quantity,
               eban~meins AS requisition_unit,
               mara~meins AS base_unit,
               marm~umrez AS unit_to_base_numerator,
               marm~umren AS unit_to_base_denominator
          FROM eban
          INNER JOIN mara
            ON mara~matnr = eban~matnr
          LEFT OUTER JOIN marm
            ON marm~matnr = eban~matnr
           AND marm~meinh = eban~meins
          WHERE eban~matnr = @iv_material
            AND eban~werks = @iv_plant
            AND eban~reswk <> @space
            AND eban~reswk <> eban~werks
            AND eban~lfdat > @lv_initial_date
            AND eban~lfdat <= @iv_through_date
            AND eban~loekz = @space
            AND eban~ebakz = @space
            AND eban~blckd <> '1'
            AND eban~pstyp = '7'
            AND eban~knttp = @space
            AND eban~sobkz = @space
            AND eban~menge > eban~bsmng
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_pr_receipts.
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
        DATA(lv_pr_quantity) = CONV mard-labst(
          lv_pr_open_base_quantity ).
        IF lv_pr_quantity > 0.
          APPEND VALUE #(
            material        = iv_material
            plant           = iv_plant
            base_unit       = ls_pr_receipt-base_unit
            receipt_date    = ls_pr_receipt-receipt_date
            quantity        = lv_pr_quantity
            source_type     = COND #(
              WHEN ls_pr_receipt-item_category = '7'
              THEN 'STO_PR'
              ELSE 'PR' )
            source_document = ls_pr_receipt-source_document
            source_item     = ls_pr_receipt-source_item
            source_plant    = ls_pr_receipt-supplying_plant )
            TO rt_receipts.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_include_planned_receipts = abap_true.
      SELECT plaf~plnum AS planned_order,
             plaf~pedtr AS receipt_date,
             plaf~gsmng AS planned_quantity,
             plaf~meins AS order_unit,
             mara~meins AS base_unit,
             marm~umrez AS unit_to_base_numerator,
             marm~umren AS unit_to_base_denominator
        FROM plaf
        INNER JOIN mara
          ON mara~matnr = plaf~matnr
        LEFT OUTER JOIN marm
          ON marm~matnr = plaf~matnr
         AND marm~meinh = plaf~meins
        WHERE plaf~matnr = @iv_material
          AND plaf~pwwrk = @iv_plant
          AND plaf~auffx = @space
          AND plaf~plscn = @space
          AND plaf~sobkz = @space
          AND plaf~kdauf = @space
          AND plaf~gsmng > 0
          AND plaf~psttr >= @sy-datum
          AND plaf~psttr <= @iv_through_date
          AND plaf~pedtr >= @sy-datum
          AND plaf~pedtr <= @iv_through_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_planned_receipts.

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
        DATA(lv_planned_base_quantity) = CONV mard-labst(
          lv_planned_quantity ).
        IF lv_planned_base_quantity > 0.
          APPEND VALUE #(
            material        = iv_material
            plant           = iv_plant
            base_unit       = ls_planned_receipt-base_unit
            receipt_date    = ls_planned_receipt-receipt_date
            quantity        = lv_planned_base_quantity
            source_type     = 'PLANNED_ORDER'
            source_document = ls_planned_receipt-planned_order )
            TO rt_receipts.
        ENDIF.
      ENDLOOP.
    ENDIF.

    SORT rt_receipts BY material plant base_unit receipt_date source_type
      source_document source_item source_schedule_line.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    DATA lv_unrestricted_quantity TYPE mard-labst.
    DATA lv_reserved_quantity TYPE resb-bdmng.
    DATA lv_withdrawn_quantity TYPE resb-enmng.

    SELECT SUM( labst )
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_unrestricted_quantity.

    SELECT SUM( bdmng ), SUM( enmng )
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO ( @lv_reserved_quantity, @lv_withdrawn_quantity ).

    lv_reserved_quantity = lv_reserved_quantity
      - lv_withdrawn_quantity.
    rv_quantity = NEW zcl_stock_avail_qty_calc( )->calculate(
      iv_unrestricted_quantity = lv_unrestricted_quantity
      iv_reserved_quantity     = lv_reserved_quantity ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    TYPES:
      BEGIN OF ty_po_schedule,
        scheduled_quantity  TYPE eket-menge,
        issued_quantity     TYPE eket-wamng,
        received_quantity   TYPE eket-wemng,
        delivery_complete   TYPE ekpo-elikz,
        order_to_base_num   TYPE ekpo-umrez,
        order_to_base_denom TYPE ekpo-umren,
      END OF ty_po_schedule.
    DATA lt_po_schedules TYPE STANDARD TABLE OF ty_po_schedule
      WITH EMPTY KEY.
    DATA lv_unrestricted_quantity TYPE mard-labst.
    DATA lv_reserved_quantity TYPE resb-bdmng.
    DATA lv_withdrawn_quantity TYPE resb-enmng.
    DATA lv_initial_date TYPE resb-bdter.
    DATA lv_initial_po_date TYPE eket-eindt.
    DATA lv_inbound_quantity TYPE decfloat34.
    DATA lv_sto_in_transit_quantity TYPE decfloat34.
    DATA lv_unissued_sto_quantity TYPE decfloat34.
    DATA lv_outgoing_sto_quantity TYPE decfloat34.
    DATA lv_prod_receipt_quantity TYPE decfloat34.
    DATA lv_projected_receipt_quantity TYPE mard-labst.
    TYPES:
      BEGIN OF ty_prod_receipt,
        order_quantity      TYPE afpo-psmng,
        received_quantity   TYPE afpo-wemng,
        order_to_base_num   TYPE afpo-umrez,
        order_to_base_denom TYPE afpo-umren,
      END OF ty_prod_receipt.
    DATA lt_prod_receipts TYPE STANDARD TABLE OF ty_prod_receipt
      WITH EMPTY KEY.

    IF iv_include_pr_receipts <> abap_true
        AND iv_include_pr_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_include_sto_pr_receipts <> abap_true
        AND iv_include_sto_pr_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_include_planned_receipts <> abap_true
        AND iv_include_planned_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    CLEAR lv_initial_date.
    CLEAR lv_initial_po_date.
    SELECT SUM( labst )
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_unrestricted_quantity.

    SELECT SUM( bdmng ), SUM( enmng )
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( bdter <= @iv_required_date OR bdter = @lv_initial_date )
      INTO ( @lv_reserved_quantity, @lv_withdrawn_quantity ).

    IF iv_include_po_receipts = abap_true.
      DATA(lo_po_quantity_calc) = NEW zcl_po_sched_qty_calc( ).
      SELECT eket~menge AS scheduled_quantity,
             eket~wemng AS received_quantity,
             ekpo~umrez AS order_to_base_num,
             ekpo~umren AS order_to_base_denom
        FROM eket
        INNER JOIN ekpo
          ON ekpo~ebeln = eket~ebeln
         AND ekpo~ebelp = eket~ebelp
        WHERE ekpo~matnr = @iv_material
          AND ekpo~werks = @iv_plant
          AND ekpo~pstyp = '0'
          AND ekpo~knttp = @space
          AND ekpo~loekz = @space
          AND ekpo~elikz = @space
          AND ekpo~retpo = @space
          AND ekpo~wepos = 'X'
          AND ekpo~insmk = @space
          AND eket~eindt > @lv_initial_po_date
          AND eket~eindt <= @iv_required_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedules.

      LOOP AT lt_po_schedules INTO DATA(ls_po_schedule).
        lv_inbound_quantity = lv_inbound_quantity
          + lo_po_quantity_calc->calculate_open_base_quantity(
              iv_scheduled_quantity  = ls_po_schedule-scheduled_quantity
              iv_received_quantity   = ls_po_schedule-received_quantity
              iv_order_to_base_num   = ls_po_schedule-order_to_base_num
              iv_order_to_base_denom = ls_po_schedule-order_to_base_denom ).
      ENDLOOP.

      lv_unrestricted_quantity = lv_unrestricted_quantity
        + CONV mard-labst( lv_inbound_quantity ).
    ENDIF.

    IF iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true.
      CLEAR lv_sto_in_transit_quantity.
      CLEAR lv_unissued_sto_quantity.
      DATA(lo_sto_quantity_calc) = NEW zcl_po_sched_qty_calc( ).
      SELECT eket~menge AS scheduled_quantity,
             eket~wamng AS issued_quantity,
             eket~wemng AS received_quantity,
             ekpo~elikz AS delivery_complete,
             ekpo~umrez AS order_to_base_num,
             ekpo~umren AS order_to_base_denom
        FROM eket
        INNER JOIN ekpo
          ON ekpo~ebeln = eket~ebeln
         AND ekpo~ebelp = eket~ebelp
        INNER JOIN ekko
          ON ekko~ebeln = ekpo~ebeln
        WHERE ekpo~matnr = @iv_material
          AND ekpo~werks = @iv_plant
          AND ekpo~pstyp = '7'
          AND ekko~reswk <> @space
          AND ekko~bsakz <> 'T'
          AND ( ekko~bstyp = 'F' OR ekko~bstyp = 'L' )
          AND ekpo~knttp = @space
          AND ekpo~loekz = @space
          AND ekpo~stapo = @space
          AND ekpo~retpo = @space
          AND ekpo~wepos = 'X'
          AND ekpo~insmk = @space
          AND eket~eindt > @lv_initial_po_date
          AND eket~eindt <= @iv_required_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedules.

      LOOP AT lt_po_schedules INTO DATA(ls_sto_schedule).
        IF iv_include_sto_in_transit = abap_true.
          lv_sto_in_transit_quantity = lv_sto_in_transit_quantity
            + lo_sto_quantity_calc->calculate_open_issued_qty(
                iv_issued_quantity     = ls_sto_schedule-issued_quantity
                iv_received_quantity   = ls_sto_schedule-received_quantity
                iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
                iv_order_to_base_denom =
                  ls_sto_schedule-order_to_base_denom ).
        ENDIF.
        IF iv_include_unissued_sto = abap_true
            AND ls_sto_schedule-delivery_complete = space.
          lv_unissued_sto_quantity = lv_unissued_sto_quantity
            + lo_sto_quantity_calc->calculate_open_unissued_qty(
                iv_scheduled_quantity  =
                  ls_sto_schedule-scheduled_quantity
                iv_issued_quantity     = ls_sto_schedule-issued_quantity
                iv_order_to_base_num   = ls_sto_schedule-order_to_base_num
                iv_order_to_base_denom =
                  ls_sto_schedule-order_to_base_denom ).
        ENDIF.
      ENDLOOP.

      lv_unrestricted_quantity = lv_unrestricted_quantity
        + CONV mard-labst(
            lv_sto_in_transit_quantity + lv_unissued_sto_quantity ).
    ENDIF.

    IF iv_subtract_unissued_sto = abap_true.
      CLEAR lv_outgoing_sto_quantity.
      DATA(lo_outgoing_sto_calc) = NEW zcl_po_sched_qty_calc( ).
      SELECT eket~menge AS scheduled_quantity,
             eket~wamng AS issued_quantity,
             ekpo~umrez AS order_to_base_num,
             ekpo~umren AS order_to_base_denom
        FROM eket
        INNER JOIN ekpo
          ON ekpo~ebeln = eket~ebeln
         AND ekpo~ebelp = eket~ebelp
        INNER JOIN ekko
          ON ekko~ebeln = ekpo~ebeln
        WHERE ekpo~matnr = @iv_material
          AND ekko~reswk = @iv_plant
          AND ekpo~werks <> @iv_plant
          AND ekpo~pstyp = '7'
          AND ekko~bsakz <> 'T'
          AND ( ekko~bstyp = 'F' OR ekko~bstyp = 'L' )
          AND ekpo~knttp = @space
          AND ekpo~loekz = @space
          AND ekpo~elikz = @space
          AND ekpo~stapo = @space
          AND ekpo~retpo = @space
          AND ekpo~wepos = 'X'
          AND eket~eindt > @lv_initial_po_date
          AND eket~eindt <= @iv_required_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_po_schedules.

      LOOP AT lt_po_schedules INTO DATA(ls_outgoing_sto).
        lv_outgoing_sto_quantity = lv_outgoing_sto_quantity
          + lo_outgoing_sto_calc->calculate_open_unissued_qty(
              iv_scheduled_quantity  =
                ls_outgoing_sto-scheduled_quantity
              iv_issued_quantity     = ls_outgoing_sto-issued_quantity
              iv_order_to_base_num   = ls_outgoing_sto-order_to_base_num
              iv_order_to_base_denom =
                ls_outgoing_sto-order_to_base_denom ).
      ENDLOOP.

      lv_unrestricted_quantity = lv_unrestricted_quantity
        - CONV mard-labst( lv_outgoing_sto_quantity ).
    ENDIF.

    IF iv_include_prod_receipts = abap_true.
      CLEAR lv_prod_receipt_quantity.
      DATA(lo_prod_quantity_calc) = NEW zcl_prod_order_qty_calc( ).
      SELECT afpo~psmng AS order_quantity,
             afpo~wemng AS received_quantity,
             afpo~umrez AS order_to_base_num,
             afpo~umren AS order_to_base_denom
        FROM afpo
        INNER JOIN afko
          ON afko~aufnr = afpo~aufnr
        INNER JOIN aufk
          ON aufk~aufnr = afpo~aufnr
        WHERE afpo~matnr = @iv_material
          AND afpo~werks = @iv_plant
          AND afpo~wepos = 'X'
          AND afpo~xloek = @space
          AND afpo~elikz = @space
          AND afpo~kdauf = @space
          AND afpo~knttp = @space
          AND aufk~autyp = '10'
          AND aufk~phas1 = 'X'
          AND aufk~phas2 = @space
          AND aufk~phas3 = @space
          AND aufk~loekz = @space
          AND afko~gltrp > @lv_initial_po_date
          AND afko~gltrp <= @iv_required_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_prod_receipts.

      LOOP AT lt_prod_receipts INTO DATA(ls_prod_receipt).
        lv_prod_receipt_quantity = lv_prod_receipt_quantity
          + lo_prod_quantity_calc->calculate_open_base_quantity(
              iv_order_quantity      = ls_prod_receipt-order_quantity
              iv_received_quantity   = ls_prod_receipt-received_quantity
              iv_order_to_base_num   = ls_prod_receipt-order_to_base_num
              iv_order_to_base_denom = ls_prod_receipt-order_to_base_denom ).
      ENDLOOP.

      lv_unrestricted_quantity = lv_unrestricted_quantity
        + CONV mard-labst( lv_prod_receipt_quantity ).
    ENDIF.

    IF iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true
        OR iv_include_planned_receipts = abap_true.
      CLEAR lv_projected_receipt_quantity.
      DATA(lt_projected_receipts) =
        zif_stock_repository~get_projected_receipts(
        iv_material                 = iv_material
        iv_plant                    = iv_plant
        iv_through_date             = iv_required_date
        iv_include_pr_receipts      = iv_include_pr_receipts
        iv_include_sto_pr_receipts  = iv_include_sto_pr_receipts
        iv_include_planned_receipts = iv_include_planned_receipts ).
      LOOP AT lt_projected_receipts INTO DATA(ls_projected_receipt).
        lv_projected_receipt_quantity = lv_projected_receipt_quantity
          + ls_projected_receipt-quantity.
      ENDLOOP.
      lv_unrestricted_quantity = lv_unrestricted_quantity
        + lv_projected_receipt_quantity.
    ENDIF.

    lv_reserved_quantity = lv_reserved_quantity
      - lv_withdrawn_quantity.
    rv_quantity = NEW zcl_stock_avail_qty_calc( )->calculate(
      iv_unrestricted_quantity = lv_unrestricted_quantity
      iv_reserved_quantity     = lv_reserved_quantity ).
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    DATA lt_sales_documents TYPE zif_stock_repository=>ty_sales_order_documents.

    APPEND iv_sales_document TO lt_sales_documents.
    rt_reservations = zif_stock_repository~get_order_reservations_bulk(
      it_sales_documents = lt_sales_documents ).
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
      WITH EMPTY KEY.

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
      LOOP AT lt_reservation_items INTO DATA(ls_reservation_item)
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
      WITH EMPTY KEY.

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
      LOOP AT lt_reservation_items INTO DATA(ls_reservation_item)
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
      BEGIN OF ty_reservation_total,
        sales_document     TYPE resb-kdauf,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        item_number        TYPE resb-kdpos,
        schedule_line      TYPE resb-kdein,
        requirement_date   TYPE resb-bdter,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
      END OF ty_reservation_total.
    DATA lt_reservation_totals TYPE STANDARD TABLE OF
      ty_reservation_total WITH EMPTY KEY.

    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    SELECT kdauf AS sales_document,
           matnr AS material,
           werks AS plant,
           kdpos AS item_number,
           kdein AS schedule_line,
           bdter AS requirement_date,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE kdauf = @it_sales_documents-table_line
        AND bwart = '231'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY kdauf, matnr, werks, kdpos, kdein, bdter
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservation_totals.

    LOOP AT lt_reservation_totals INTO DATA(ls_reservation_total).
      DATA(lv_open_quantity) = ls_reservation_total-required_quantity
        - ls_reservation_total-withdrawn_quantity.
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        sales_document   = ls_reservation_total-sales_document
        material         = ls_reservation_total-material
        plant            = ls_reservation_total-plant
        item_number      = ls_reservation_total-item_number
        schedule_line    = ls_reservation_total-schedule_line
        requirement_date = ls_reservation_total-requirement_date
        open_quantity    = lv_open_quantity ) TO rt_reservations.
    ENDLOOP.
    SORT rt_reservations BY sales_document item_number material plant
      schedule_line requirement_date.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    DATA lv_required_quantity TYPE resb-bdmng.
    DATA lv_withdrawn_quantity TYPE resb-enmng.
    DATA lo_stock_quantity_calculator TYPE REF TO zcl_stock_avail_qty_calc.

    SELECT SUM( labst ) AS unrestricted_quantity,
           SUM( insme ) AS quality_inspection_quantity,
           SUM( speme ) AS blocked_quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF @rs_status.

    SELECT SUM( bdmng ), SUM( enmng )
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      INTO ( @lv_required_quantity, @lv_withdrawn_quantity ).

    rs_status-reserved_quantity = lv_required_quantity
      - lv_withdrawn_quantity.
    IF rs_status-reserved_quantity < 0.
      CLEAR rs_status-reserved_quantity.
    ENDIF.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rs_status-safety_stock_quantity.
    lo_stock_quantity_calculator = NEW zcl_stock_avail_qty_calc( ).
    rs_status-available_unrestricted_qty =
      lo_stock_quantity_calculator->calculate(
        iv_unrestricted_quantity = rs_status-unrestricted_quantity
        iv_reserved_quantity     = rs_status-reserved_quantity ).
    rs_status-available_after_safety_qty =
      lo_stock_quantity_calculator->calculate_with_safety_stock(
        iv_available_quantity    = rs_status-available_unrestricted_qty
        iv_safety_stock_quantity = rs_status-safety_stock_quantity ).
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
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort
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

    SELECT lgort, SUM( labst ) AS quantity
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock.

    SELECT lgort,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort
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

  METHOD zif_stock_repository~get_stock_status_by_batch.
    DATA lt_stock TYPE zcl_stock_batch_qty_calc=>ty_stocks.
    DATA lt_reservations TYPE zcl_stock_batch_qty_calc=>ty_reservations.
    DATA lt_available_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lt_plant_batches TYPE STANDARD TABLE OF mcha WITH DEFAULT KEY.
    DATA lt_global_batches TYPE STANDARD TABLE OF mch1 WITH DEFAULT KEY.
    DATA lv_available_quantity TYPE mchb-clabs.

    SELECT lgort, charg, SUM( clabs ) AS quantity
      FROM mchb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      GROUP BY lgort, charg
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock.

    SELECT charg, vfdat
      FROM mcha
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_plant_batches.

    SELECT charg, vfdat
      FROM mch1
      WHERE matnr = @iv_material
      INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.

    LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      READ TABLE lt_plant_batches INTO DATA(ls_plant_batch)
        WITH KEY charg = <ls_stock>-batch.
      IF sy-subrc = 0 AND ls_plant_batch-vfdat IS NOT INITIAL.
        <ls_stock>-expiration_date = ls_plant_batch-vfdat.
      ELSE.
        READ TABLE lt_global_batches INTO DATA(ls_global_batch)
          WITH KEY charg = <ls_stock>-batch.
        IF sy-subrc = 0.
          <ls_stock>-expiration_date = ls_global_batch-vfdat.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SELECT lgort, charg,
           SUM( bdmng ) AS required_quantity,
           SUM( enmng ) AS withdrawn_quantity
      FROM resb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
      GROUP BY lgort, charg
      INTO CORRESPONDING FIELDS OF TABLE @lt_reservations.

    lt_available_stock = NEW zcl_stock_batch_qty_calc( )->calculate(
      it_stock        = lt_stock
      it_reservations = lt_reservations ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      CLEAR lv_available_quantity.
      READ TABLE lt_available_stock INTO DATA(ls_available_stock)
        WITH KEY storage_location = ls_stock-storage_location
                 batch            = ls_stock-batch.
      IF sy-subrc = 0.
        lv_available_quantity = ls_available_stock-available_quantity.
      ENDIF.
      APPEND VALUE #(
        storage_location      = ls_stock-storage_location
        batch                 = ls_stock-batch
        expiration_date       = ls_stock-expiration_date
        unrestricted_quantity = ls_stock-quantity
        available_quantity    = lv_available_quantity ) TO rt_status.
    ENDLOOP.
    SORT rt_status BY storage_location batch.
  ENDMETHOD.

ENDCLASS.
