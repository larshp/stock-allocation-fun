CLASS zcl_stock_allocation_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_compare.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS append_reason
      IMPORTING
        iv_reason  TYPE string
      CHANGING
        cv_reasons TYPE string.
    METHODS has_reason
      IMPORTING
        iv_reason       TYPE zif_stock_allocation_compare=>ty_change_reason
        iv_reasons      TYPE string
      RETURNING
        VALUE(rv_match) TYPE abap_bool.
ENDCLASS.

CLASS zcl_stock_allocation_compare IMPLEMENTATION.
  METHOD zif_stock_allocation_compare~compare.
    TYPES:
      BEGIN OF ty_key,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        order_id        TYPE zif_stock_allocation=>ty_order_id,
      END OF ty_key.
    TYPES tt_indexed_demands TYPE HASHED TABLE OF
      zif_stock_allocation=>ty_demand
      WITH UNIQUE KEY allocation_unit order_id.
    TYPES tt_keys TYPE SORTED TABLE OF ty_key
      WITH UNIQUE KEY allocation_unit order_id.
    DATA lt_old TYPE tt_indexed_demands.
    DATA lt_new TYPE tt_indexed_demands.
    DATA lt_keys TYPE tt_keys.
    DATA lt_all_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA ls_change TYPE zif_stock_allocation_compare=>ty_change.
    DATA lv_limit_start TYPE i.
    DATA ls_normalized TYPE zif_stock_allocation=>ty_demand.
    DATA lv_old_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_new_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_old_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_new_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_old_coverage_available TYPE abap_bool.
    DATA lv_new_coverage_available TYPE abap_bool.
    DATA lv_old_status TYPE zif_stock_allocation=>ty_allocation_status.
    DATA lv_new_status TYPE zif_stock_allocation=>ty_allocation_status.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_old> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_new> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_key> TYPE ty_key.

    CLEAR: es_summary, ev_total_rows.
    lv_old_status = to_upper( iv_old_status ).
    lv_new_status = to_upper( iv_new_status ).
    IF lv_old_status IS NOT INITIAL
        AND lv_old_status <> 'F'
        AND lv_old_status <> 'P'
        AND lv_old_status <> 'U'.
      raise_error( iv_message = 'Comparison old allocation status is invalid' ).
    ENDIF.
    IF lv_new_status IS NOT INITIAL
        AND lv_new_status <> 'F'
        AND lv_new_status <> 'P'
        AND lv_new_status <> 'U'.
      raise_error( iv_message = 'Comparison new allocation status is invalid' ).
    ENDIF.
    IF iv_change_type IS NOT INITIAL
        AND iv_change_type <> 'A'
        AND iv_change_type <> 'R'
        AND iv_change_type <> 'C'
        AND iv_change_type <> 'U'.
      raise_error( iv_message = 'Comparison change type is invalid' ).
    ENDIF.
    IF iv_offset < 0 OR iv_max_rows < 0.
      raise_error( iv_message = 'Comparison pagination is invalid' ).
    ENDIF.
    IF iv_reason IS NOT INITIAL
        AND iv_reason <> 'added'
        AND iv_reason <> 'removed'
        AND iv_reason <> 'requested_on'
        AND iv_reason <> 'allocation_strategy'
        AND iv_reason <> 'sales_document'
        AND iv_reason <> 'sales_document_type'
        AND iv_reason <> 'sales_item'
        AND iv_reason <> 'schedule_line'
        AND iv_reason <> 'order_unit'
        AND iv_reason <> 'priority'
        AND iv_reason <> 'status'
        AND iv_reason <> 'requested'
        AND iv_reason <> 'allocated'
        AND iv_reason <> 'shortage'
        AND iv_reason <> 'coverage'
        AND iv_reason <> 'shortage_pct'
        AND iv_reason <> 'reservation_id'
        AND iv_reason <> 'reservation_date'
        AND iv_reason <> 'reservation_movement_type'
        AND iv_reason <> 'reservation_unit'.
      raise_error( iv_message = 'Comparison change reason is invalid' ).
    ENDIF.

    LOOP AT it_old ASSIGNING <ls_demand>.
      ls_normalized = <ls_demand>.
      ls_normalized-allocation_strategy =
        to_upper( ls_normalized-allocation_strategy ).
      ls_normalized-allocation_status =
        to_upper( ls_normalized-allocation_status ).
      ls_normalized-allocation_unit = to_upper( ls_normalized-allocation_unit ).
      ls_normalized-order_unit = to_upper( ls_normalized-order_unit ).
      ls_normalized-reservation_unit = to_upper( ls_normalized-reservation_unit ).
      INSERT ls_normalized INTO TABLE lt_old.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Comparison old snapshot has duplicate keys' ).
      ENDIF.
      INSERT VALUE #(
        allocation_unit = ls_normalized-allocation_unit
        order_id        = ls_normalized-order_id ) INTO TABLE lt_keys.
    ENDLOOP.
    LOOP AT it_new ASSIGNING <ls_demand>.
      ls_normalized = <ls_demand>.
      ls_normalized-allocation_strategy =
        to_upper( ls_normalized-allocation_strategy ).
      ls_normalized-allocation_status =
        to_upper( ls_normalized-allocation_status ).
      ls_normalized-allocation_unit = to_upper( ls_normalized-allocation_unit ).
      ls_normalized-order_unit = to_upper( ls_normalized-order_unit ).
      ls_normalized-reservation_unit = to_upper( ls_normalized-reservation_unit ).
      INSERT ls_normalized INTO TABLE lt_new.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Comparison new snapshot has duplicate keys' ).
      ENDIF.
      INSERT VALUE #(
        allocation_unit = ls_normalized-allocation_unit
        order_id        = ls_normalized-order_id ) INTO TABLE lt_keys.
    ENDLOOP.

    LOOP AT lt_keys ASSIGNING <ls_key>.
      UNASSIGN: <ls_old>, <ls_new>.
      READ TABLE lt_old ASSIGNING <ls_old>
        WITH TABLE KEY allocation_unit = <ls_key>-allocation_unit
                       order_id        = <ls_key>-order_id.
      READ TABLE lt_new ASSIGNING <ls_new>
        WITH TABLE KEY allocation_unit = <ls_key>-allocation_unit
                       order_id        = <ls_key>-order_id.
      CLEAR ls_change.
      CLEAR: lv_old_coverage, lv_new_coverage,
             lv_old_shortage_pct, lv_new_shortage_pct,
             lv_old_coverage_available, lv_new_coverage_available.
      ls_change-allocation_unit = <ls_key>-allocation_unit.
      ls_change-order_id = <ls_key>-order_id.

      IF <ls_old> IS NOT ASSIGNED.
        ls_change-change_type = 'A'.
        ls_change-change_reasons = 'added'.
      ELSEIF <ls_new> IS NOT ASSIGNED.
        ls_change-change_type = 'R'.
        ls_change-change_reasons = 'removed'.
      ELSE.
        IF <ls_old>-requested_on <> <ls_new>-requested_on.
          append_reason( EXPORTING iv_reason = 'requested_on'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocation_strategy <> <ls_new>-allocation_strategy.
          append_reason( EXPORTING iv_reason = 'allocation_strategy'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_document <> <ls_new>-sales_document.
          append_reason( EXPORTING iv_reason = 'sales_document'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_document_type <> <ls_new>-sales_document_type.
          append_reason( EXPORTING iv_reason = 'sales_document_type'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_item <> <ls_new>-sales_item.
          append_reason( EXPORTING iv_reason = 'sales_item'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-schedule_line <> <ls_new>-schedule_line.
          append_reason( EXPORTING iv_reason = 'schedule_line'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-order_unit <> <ls_new>-order_unit.
          append_reason( EXPORTING iv_reason = 'order_unit'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-priority <> <ls_new>-priority.
          append_reason( EXPORTING iv_reason = 'priority'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocation_status <> <ls_new>-allocation_status.
          append_reason( EXPORTING iv_reason = 'status'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-requested <> <ls_new>-requested.
          append_reason( EXPORTING iv_reason = 'requested'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocated <> <ls_new>-allocated.
          append_reason( EXPORTING iv_reason = 'allocated'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-requested > 0.
          lv_old_coverage_available = abap_true.
          lv_old_coverage = <ls_old>-allocated * 100 / <ls_old>-requested.
          lv_old_shortage_pct = <ls_old>-shortage * 100 /
            <ls_old>-requested.
        ENDIF.
        IF <ls_new>-requested > 0.
          lv_new_coverage_available = abap_true.
          lv_new_coverage = <ls_new>-allocated * 100 / <ls_new>-requested.
          lv_new_shortage_pct = <ls_new>-shortage * 100 /
            <ls_new>-requested.
        ENDIF.
        IF lv_old_coverage_available <> lv_new_coverage_available
            OR ( lv_old_coverage_available = abap_true
            AND lv_new_coverage_available = abap_true
            AND lv_old_coverage <> lv_new_coverage ).
          append_reason( EXPORTING iv_reason = 'coverage'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF lv_old_coverage_available <> lv_new_coverage_available
            OR ( lv_old_coverage_available = abap_true
            AND lv_new_coverage_available = abap_true
            AND lv_old_shortage_pct <> lv_new_shortage_pct ).
          append_reason( EXPORTING iv_reason = 'shortage_pct'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-shortage <> <ls_new>-shortage.
          append_reason( EXPORTING iv_reason = 'shortage'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_id <> <ls_new>-reservation_id.
          append_reason( EXPORTING iv_reason = 'reservation_id'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_date <> <ls_new>-reservation_date.
          append_reason( EXPORTING iv_reason = 'reservation_date'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_movement_type
            <> <ls_new>-reservation_movement_type.
          append_reason( EXPORTING iv_reason = 'reservation_movement_type'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_unit <> <ls_new>-reservation_unit.
          append_reason( EXPORTING iv_reason = 'reservation_unit'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF ls_change-change_reasons IS NOT INITIAL.
          ls_change-change_type = 'C'.
        ELSEIF iv_include_unchanged = abap_true.
          ls_change-change_type = 'U'.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF <ls_old> IS ASSIGNED.
        ls_change-old_allocation_strategy = <ls_old>-allocation_strategy.
        ls_change-old_sales_document = <ls_old>-sales_document.
        ls_change-old_sales_document_type = <ls_old>-sales_document_type.
        ls_change-old_sales_item = <ls_old>-sales_item.
        ls_change-old_schedule_line = <ls_old>-schedule_line.
        ls_change-old_order_unit = <ls_old>-order_unit.
        ls_change-old_requested_on = <ls_old>-requested_on.
        ls_change-old_priority = <ls_old>-priority.
        ls_change-old_status = <ls_old>-allocation_status.
        ls_change-old_requested = <ls_old>-requested.
        ls_change-old_allocated = <ls_old>-allocated.
        ls_change-old_shortage = <ls_old>-shortage.
        ls_change-old_reservation_id = <ls_old>-reservation_id.
        ls_change-old_reservation_date = <ls_old>-reservation_date.
        ls_change-old_reservation_movement_type =
          <ls_old>-reservation_movement_type.
        ls_change-old_reservation_unit = <ls_old>-reservation_unit.
      ENDIF.
      IF <ls_new> IS ASSIGNED.
        ls_change-new_allocation_strategy = <ls_new>-allocation_strategy.
        ls_change-new_sales_document = <ls_new>-sales_document.
        ls_change-new_sales_document_type = <ls_new>-sales_document_type.
        ls_change-new_sales_item = <ls_new>-sales_item.
        ls_change-new_schedule_line = <ls_new>-schedule_line.
        ls_change-new_order_unit = <ls_new>-order_unit.
        ls_change-new_requested_on = <ls_new>-requested_on.
        ls_change-new_priority = <ls_new>-priority.
        ls_change-new_status = <ls_new>-allocation_status.
        ls_change-new_requested = <ls_new>-requested.
        ls_change-new_allocated = <ls_new>-allocated.
        ls_change-new_shortage = <ls_new>-shortage.
        ls_change-new_reservation_id = <ls_new>-reservation_id.
        ls_change-new_reservation_date = <ls_new>-reservation_date.
        ls_change-new_reservation_movement_type =
          <ls_new>-reservation_movement_type.
        ls_change-new_reservation_unit = <ls_new>-reservation_unit.
      ENDIF.
      ls_change-delta_requested = ls_change-new_requested
        - ls_change-old_requested.
      ls_change-delta_allocated = ls_change-new_allocated
        - ls_change-old_allocated.
      ls_change-delta_shortage = ls_change-new_shortage
        - ls_change-old_shortage.
      IF ls_change-old_requested > 0.
        ls_change-old_coverage_available = abap_true.
        ls_change-old_coverage = ls_change-old_allocated * 100 /
          ls_change-old_requested.
        ls_change-old_shortage_pct_available = abap_true.
        ls_change-old_shortage_pct = ls_change-old_shortage * 100 /
          ls_change-old_requested.
      ENDIF.
      IF ls_change-new_requested > 0.
        ls_change-new_coverage_available = abap_true.
        ls_change-new_coverage = ls_change-new_allocated * 100 /
          ls_change-new_requested.
        ls_change-new_shortage_pct_available = abap_true.
        ls_change-new_shortage_pct = ls_change-new_shortage * 100 /
          ls_change-new_requested.
      ENDIF.
      IF ls_change-old_coverage_available = abap_true
          AND ls_change-new_coverage_available = abap_true.
        ls_change-coverage_delta_available = abap_true.
        ls_change-coverage_delta = ls_change-new_coverage
          - ls_change-old_coverage.
      ENDIF.
      IF ls_change-old_shortage_pct_available = abap_true
          AND ls_change-new_shortage_pct_available = abap_true.
        ls_change-shortage_pct_delta_available = abap_true.
        ls_change-shortage_pct_delta = ls_change-new_shortage_pct
          - ls_change-old_shortage_pct.
      ENDIF.
          IF ( iv_change_type IS INITIAL
          OR ls_change-change_type = iv_change_type )
          AND ( iv_reason IS INITIAL
          OR has_reason(
            iv_reason  = iv_reason
            iv_reasons = ls_change-change_reasons ) = abap_true )
          AND ( lv_old_status IS INITIAL
          OR ls_change-old_status = lv_old_status )
          AND ( lv_new_status IS INITIAL
          OR ls_change-new_status = lv_new_status ).
        APPEND ls_change TO lt_all_changes.
        es_summary-total_rows = es_summary-total_rows + 1.
        CASE ls_change-change_type.
          WHEN 'A'.
            es_summary-added_rows = es_summary-added_rows + 1.
          WHEN 'R'.
            es_summary-removed_rows = es_summary-removed_rows + 1.
          WHEN 'C'.
            es_summary-changed_rows = es_summary-changed_rows + 1.
          WHEN 'U'.
            es_summary-unchanged_rows = es_summary-unchanged_rows + 1.
        ENDCASE.
        IF es_summary-unit IS INITIAL.
          es_summary-unit = ls_change-allocation_unit.
        ELSEIF es_summary-unit <> ls_change-allocation_unit.
          es_summary-mixed_units = abap_true.
          CLEAR es_summary-unit.
          CLEAR: es_summary-old_requested,
                 es_summary-new_requested,
                 es_summary-delta_requested,
                 es_summary-old_allocated,
                 es_summary-new_allocated,
                 es_summary-delta_allocated,
                 es_summary-old_shortage,
                 es_summary-new_shortage,
                 es_summary-delta_shortage.
        ENDIF.
        IF es_summary-mixed_units = abap_false.
          es_summary-old_requested = es_summary-old_requested
            + ls_change-old_requested.
          es_summary-new_requested = es_summary-new_requested
            + ls_change-new_requested.
          es_summary-delta_requested = es_summary-delta_requested
            + ls_change-delta_requested.
          es_summary-old_allocated = es_summary-old_allocated
            + ls_change-old_allocated.
          es_summary-new_allocated = es_summary-new_allocated
            + ls_change-new_allocated.
          es_summary-delta_allocated = es_summary-delta_allocated
            + ls_change-delta_allocated.
          es_summary-old_shortage = es_summary-old_shortage
            + ls_change-old_shortage.
          es_summary-new_shortage = es_summary-new_shortage
            + ls_change-new_shortage.
          es_summary-delta_shortage = es_summary-delta_shortage
            + ls_change-delta_shortage.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF es_summary-mixed_units = abap_false.
      IF es_summary-old_requested > 0.
        es_summary-old_coverage_available = abap_true.
        es_summary-old_coverage = es_summary-old_allocated * 100 /
          es_summary-old_requested.
        es_summary-old_shortage_pct_available = abap_true.
        es_summary-old_shortage_pct = es_summary-old_shortage * 100 /
          es_summary-old_requested.
      ENDIF.
      IF es_summary-new_requested > 0.
        es_summary-new_coverage_available = abap_true.
        es_summary-new_coverage = es_summary-new_allocated * 100 /
          es_summary-new_requested.
        es_summary-new_shortage_pct_available = abap_true.
        es_summary-new_shortage_pct = es_summary-new_shortage * 100 /
          es_summary-new_requested.
      ENDIF.
      IF es_summary-old_coverage_available = abap_true
          AND es_summary-new_coverage_available = abap_true.
        es_summary-coverage_delta_available = abap_true.
        es_summary-coverage_delta = es_summary-new_coverage
          - es_summary-old_coverage.
      ENDIF.
      IF es_summary-old_shortage_pct_available = abap_true
          AND es_summary-new_shortage_pct_available = abap_true.
        es_summary-shortage_pct_delta_available = abap_true.
        es_summary-shortage_pct_delta = es_summary-new_shortage_pct
          - es_summary-old_shortage_pct.
      ENDIF.
    ENDIF.
    ev_total_rows = es_summary-total_rows.
    rt_changes = lt_all_changes.
    IF iv_offset > 0.
      IF iv_offset >= lines( rt_changes ).
        CLEAR rt_changes.
      ELSE.
        DELETE rt_changes FROM 1 TO iv_offset.
      ENDIF.
    ENDIF.
    IF iv_max_rows > 0 AND lines( rt_changes ) > iv_max_rows.
      lv_limit_start = iv_max_rows + 1.
      DELETE rt_changes FROM lv_limit_start.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_shortage.
    TYPES:
      BEGIN OF ty_sort_line,
        shortage        TYPE zif_stock_allocation=>ty_quantity,
        requested_on    TYPE d,
        change_rank     TYPE i,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        order_id        TYPE zif_stock_allocation=>ty_order_id,
        change          TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      IF <ls_change>-change_type <> 'R'.
        APPEND VALUE #(
          shortage        = <ls_change>-new_shortage
          requested_on    = <ls_change>-new_requested_on
          change_rank     = COND #( WHEN <ls_change>-change_type = 'C'
                                    THEN 1
                                    WHEN <ls_change>-change_type = 'A'
                                    THEN 2
                                    WHEN <ls_change>-change_type = 'U'
                                    THEN 3
                                    ELSE 4 )
          allocation_unit = <ls_change>-allocation_unit
          order_id        = <ls_change>-order_id
          change          = <ls_change> ) TO lt_sort_lines.
      ELSE.
        APPEND VALUE #(
          shortage        = <ls_change>-old_shortage
          requested_on    = <ls_change>-old_requested_on
          change_rank     = COND #( WHEN <ls_change>-change_type = 'R'
                                    THEN 1 ELSE 2 )
          allocation_unit = <ls_change>-allocation_unit
          order_id        = <ls_change>-order_id
          change          = <ls_change> ) TO lt_sort_lines.
      ENDIF.
    ENDLOOP.
    SORT lt_sort_lines BY shortage DESCENDING requested_on change_rank
                          allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_shortage_worsening.
    TYPES:
      BEGIN OF ty_sort_line,
        shortage_delta           TYPE zif_stock_allocation=>ty_quantity,
        shortage                 TYPE zif_stock_allocation=>ty_quantity,
        requested_date_available TYPE abap_bool,
        requested_on             TYPE d,
        change_rank              TYPE i,
        allocation_unit          TYPE zif_stock_allocation=>ty_unit,
        order_id                 TYPE zif_stock_allocation=>ty_order_id,
        change                   TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      IF <ls_change>-change_type <> 'R'.
        APPEND VALUE #(
          shortage_delta           = <ls_change>-delta_shortage
          shortage                 = <ls_change>-new_shortage
          requested_date_available = xsdbool(
            <ls_change>-new_requested_on IS NOT INITIAL )
          requested_on             = <ls_change>-new_requested_on
          change_rank              = COND #( WHEN <ls_change>-change_type = 'C'
                                             THEN 1
                                             WHEN <ls_change>-change_type = 'A'
                                             THEN 2
                                             WHEN <ls_change>-change_type = 'U'
                                             THEN 3
                                             ELSE 4 )
          allocation_unit          = <ls_change>-allocation_unit
          order_id                 = <ls_change>-order_id
          change                   = <ls_change> ) TO lt_sort_lines.
      ELSE.
        APPEND VALUE #(
          shortage_delta           = <ls_change>-delta_shortage
          shortage                 = <ls_change>-old_shortage
          requested_date_available = xsdbool(
            <ls_change>-old_requested_on IS NOT INITIAL )
          requested_on             = <ls_change>-old_requested_on
          change_rank              = 1
          allocation_unit          = <ls_change>-allocation_unit
          order_id                 = <ls_change>-order_id
          change                   = <ls_change> ) TO lt_sort_lines.
      ENDIF.
    ENDLOOP.
    SORT lt_sort_lines BY shortage_delta DESCENDING shortage DESCENDING
                          requested_date_available DESCENDING requested_on
                          change_rank allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_requested_delta.
    TYPES:
      BEGIN OF ty_sort_line,
        requested_delta          TYPE zif_stock_allocation=>ty_quantity,
        requested                TYPE zif_stock_allocation=>ty_quantity,
        shortage                 TYPE zif_stock_allocation=>ty_quantity,
        requested_date_available TYPE abap_bool,
        requested_on             TYPE d,
        change_rank              TYPE i,
        allocation_unit          TYPE zif_stock_allocation=>ty_unit,
        order_id                 TYPE zif_stock_allocation=>ty_order_id,
        change                   TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_requested TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_requested_on TYPE d.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      IF <ls_change>-change_type = 'R'.
        lv_requested = <ls_change>-old_requested.
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ELSE.
        lv_requested = <ls_change>-new_requested.
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ENDIF.
      APPEND VALUE #(
        requested_delta          = <ls_change>-delta_requested
        requested                = lv_requested
        shortage                 = lv_shortage
        requested_date_available = xsdbool(
          lv_requested_on IS NOT INITIAL )
        requested_on             = lv_requested_on
        change_rank              = COND #( WHEN <ls_change>-change_type = 'C'
                                             THEN 1
                                             WHEN <ls_change>-change_type = 'A'
                                             THEN 2
                                             WHEN <ls_change>-change_type = 'R'
                                             THEN 3
                                             ELSE 4 )
        allocation_unit          = <ls_change>-allocation_unit
        order_id                 = <ls_change>-order_id
        change                   = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY requested_delta DESCENDING requested DESCENDING
                          shortage DESCENDING
                          requested_date_available DESCENDING requested_on
                          change_rank allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_requested_date.
    TYPES:
      BEGIN OF ty_sort_line,
        requested_date_available TYPE abap_bool,
        requested_on             TYPE d,
        shortage                 TYPE zif_stock_allocation=>ty_quantity,
        change_rank              TYPE i,
        allocation_unit          TYPE zif_stock_allocation=>ty_unit,
        order_id                 TYPE zif_stock_allocation=>ty_order_id,
        change                   TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      IF <ls_change>-change_type <> 'R'.
        APPEND VALUE #(
          requested_date_available = xsdbool(
            <ls_change>-new_requested_on IS NOT INITIAL )
          requested_on             = <ls_change>-new_requested_on
          shortage                 = <ls_change>-new_shortage
          change_rank              = COND #( WHEN <ls_change>-change_type = 'C'
                                             THEN 1
                                             WHEN <ls_change>-change_type = 'A'
                                             THEN 2
                                             WHEN <ls_change>-change_type = 'U'
                                             THEN 3
                                             ELSE 4 )
          allocation_unit          = <ls_change>-allocation_unit
          order_id                 = <ls_change>-order_id
          change                   = <ls_change> ) TO lt_sort_lines.
      ELSE.
        APPEND VALUE #(
          requested_date_available = xsdbool(
            <ls_change>-old_requested_on IS NOT INITIAL )
          requested_on             = <ls_change>-old_requested_on
          shortage                 = <ls_change>-old_shortage
          change_rank              = 1
          allocation_unit          = <ls_change>-allocation_unit
          order_id                 = <ls_change>-order_id
          change                   = <ls_change> ) TO lt_sort_lines.
      ENDIF.
    ENDLOOP.
    SORT lt_sort_lines BY requested_date_available DESCENDING
                          requested_on shortage DESCENDING change_rank
                          allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_coverage.
    TYPES:
      BEGIN OF ty_sort_line,
        coverage_available TYPE abap_bool,
        coverage           TYPE zif_allocation_audit=>ty_coverage,
        shortage           TYPE zif_stock_allocation=>ty_quantity,
        requested_on       TYPE d,
        change_rank        TYPE i,
        allocation_unit    TYPE zif_stock_allocation=>ty_unit,
        order_id           TYPE zif_stock_allocation=>ty_order_id,
        change             TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_requested TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_requested_on TYPE d.
    DATA lv_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_coverage_available TYPE abap_bool.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      CLEAR: lv_requested, lv_allocated, lv_shortage, lv_requested_on,
             lv_coverage, lv_coverage_available.
      IF <ls_change>-change_type <> 'R'.
        lv_requested = <ls_change>-new_requested.
        lv_allocated = <ls_change>-new_allocated.
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ELSE.
        lv_requested = <ls_change>-old_requested.
        lv_allocated = <ls_change>-old_allocated.
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ENDIF.
      IF lv_requested > 0.
        lv_coverage_available = abap_true.
        lv_coverage = lv_allocated * 100 / lv_requested.
      ENDIF.
      APPEND VALUE #(
        coverage_available = lv_coverage_available
        coverage           = lv_coverage
        shortage           = lv_shortage
        requested_on       = lv_requested_on
        change_rank        = COND #( WHEN <ls_change>-change_type = 'C'
                                     THEN 1
                                     WHEN <ls_change>-change_type = 'A'
                                     THEN 2
                                     WHEN <ls_change>-change_type = 'R'
                                     THEN 3
                                     ELSE 4 )
        allocation_unit    = <ls_change>-allocation_unit
        order_id           = <ls_change>-order_id
        change             = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY coverage_available DESCENDING coverage
                          shortage DESCENDING requested_on change_rank
                          allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_status_regression.
    TYPES:
      BEGIN OF ty_sort_line,
        status_delta_available   TYPE abap_bool,
        status_deterioration     TYPE i,
        status_rank              TYPE i,
        shortage                 TYPE zif_stock_allocation=>ty_quantity,
        requested_date_available TYPE abap_bool,
        requested_on             TYPE d,
        change_rank              TYPE i,
        allocation_unit          TYPE zif_stock_allocation=>ty_unit,
        order_id                 TYPE zif_stock_allocation=>ty_order_id,
        change                   TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_old_rank TYPE i.
    DATA lv_new_rank TYPE i.
    DATA lv_status_rank TYPE i.
    DATA lv_status_deterioration TYPE i.
    DATA lv_status_delta_available TYPE abap_bool.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_requested_on TYPE d.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      CLEAR: lv_old_rank, lv_new_rank, lv_status_rank,
             lv_status_deterioration, lv_status_delta_available,
             lv_shortage, lv_requested_on.
      CASE <ls_change>-old_status.
        WHEN 'F'.
          lv_old_rank = 0.
        WHEN 'P'.
          lv_old_rank = 1.
        WHEN 'U'.
          lv_old_rank = 2.
        WHEN OTHERS.
          CLEAR lv_old_rank.
      ENDCASE.
      CASE <ls_change>-new_status.
        WHEN 'F'.
          lv_new_rank = 0.
        WHEN 'P'.
          lv_new_rank = 1.
        WHEN 'U'.
          lv_new_rank = 2.
        WHEN OTHERS.
          CLEAR lv_new_rank.
      ENDCASE.
      IF ( <ls_change>-old_status = 'F'
          OR <ls_change>-old_status = 'P'
          OR <ls_change>-old_status = 'U' )
          AND ( <ls_change>-new_status = 'F'
          OR <ls_change>-new_status = 'P'
          OR <ls_change>-new_status = 'U' ).
        lv_status_delta_available = abap_true.
        lv_status_deterioration = lv_new_rank - lv_old_rank.
      ENDIF.
      IF <ls_change>-change_type = 'R'.
        lv_status_rank = lv_old_rank.
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ELSE.
        lv_status_rank = lv_new_rank.
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ENDIF.
      APPEND VALUE #(
        status_delta_available   = lv_status_delta_available
        status_deterioration     = lv_status_deterioration
        status_rank              = lv_status_rank
        shortage                 = lv_shortage
        requested_date_available = xsdbool(
          lv_requested_on IS NOT INITIAL )
        requested_on             = lv_requested_on
        change_rank              = COND #( WHEN <ls_change>-change_type = 'C'
                                            THEN 1
                                            WHEN <ls_change>-change_type = 'A'
                                            THEN 2
                                            WHEN <ls_change>-change_type = 'R'
                                            THEN 3
                                            ELSE 4 )
        allocation_unit          = <ls_change>-allocation_unit
        order_id                 = <ls_change>-order_id
        change                   = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY status_delta_available DESCENDING
                          status_deterioration DESCENDING status_rank DESCENDING
                          shortage DESCENDING
                          requested_date_available DESCENDING requested_on
                          change_rank allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_shortage_percentage.
    TYPES:
      BEGIN OF ty_sort_line,
        shortage_pct_available TYPE abap_bool,
        shortage_pct           TYPE zif_allocation_audit=>ty_coverage,
        shortage               TYPE zif_stock_allocation=>ty_quantity,
        requested_on           TYPE d,
        change_rank            TYPE i,
        allocation_unit        TYPE zif_stock_allocation=>ty_unit,
        order_id               TYPE zif_stock_allocation=>ty_order_id,
        change                 TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_requested TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_requested_on TYPE d.
    DATA lv_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_shortage_pct_available TYPE abap_bool.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      CLEAR: lv_requested, lv_shortage, lv_requested_on,
             lv_shortage_pct, lv_shortage_pct_available.
      IF <ls_change>-change_type <> 'R'.
        lv_requested = <ls_change>-new_requested.
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ELSE.
        lv_requested = <ls_change>-old_requested.
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ENDIF.
      IF lv_requested > 0.
        lv_shortage_pct_available = abap_true.
        lv_shortage_pct = lv_shortage * 100 / lv_requested.
      ENDIF.
      APPEND VALUE #(
        shortage_pct_available = lv_shortage_pct_available
        shortage_pct           = lv_shortage_pct
        shortage               = lv_shortage
        requested_on           = lv_requested_on
        change_rank            = COND #( WHEN <ls_change>-change_type = 'C'
                                         THEN 1
                                         WHEN <ls_change>-change_type = 'A'
                                         THEN 2
                                         WHEN <ls_change>-change_type = 'R'
                                         THEN 3
                                         ELSE 4 )
        allocation_unit        = <ls_change>-allocation_unit
        order_id               = <ls_change>-order_id
        change                 = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY shortage_pct_available DESCENDING shortage_pct DESCENDING
                          shortage DESCENDING requested_on change_rank
                          allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_coverage_worsening.
    TYPES:
      BEGIN OF ty_sort_line,
        coverage_delta_available TYPE abap_bool,
        coverage_deterioration   TYPE zif_allocation_audit=>ty_coverage,
        coverage_available       TYPE abap_bool,
        coverage                 TYPE zif_allocation_audit=>ty_coverage,
        shortage                 TYPE zif_stock_allocation=>ty_quantity,
        requested_date_available TYPE abap_bool,
        requested_on             TYPE d,
        change_rank              TYPE i,
        allocation_unit          TYPE zif_stock_allocation=>ty_unit,
        order_id                 TYPE zif_stock_allocation=>ty_order_id,
        change                   TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_old_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_new_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_coverage_deterioration TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_coverage_delta_available TYPE abap_bool.
    DATA lv_coverage_available TYPE abap_bool.
    DATA lv_requested_on TYPE d.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      CLEAR: lv_old_coverage, lv_new_coverage, lv_coverage,
             lv_coverage_deterioration, lv_coverage_delta_available,
             lv_coverage_available, lv_requested_on, lv_shortage.
      IF <ls_change>-old_coverage_available = abap_true.
        lv_old_coverage = <ls_change>-old_coverage.
      ELSEIF <ls_change>-old_requested > 0.
        lv_old_coverage = <ls_change>-old_allocated * 100 /
          <ls_change>-old_requested.
      ENDIF.
      IF <ls_change>-new_coverage_available = abap_true.
        lv_new_coverage = <ls_change>-new_coverage.
      ELSEIF <ls_change>-new_requested > 0.
        lv_new_coverage = <ls_change>-new_allocated * 100 /
          <ls_change>-new_requested.
      ENDIF.
      IF <ls_change>-coverage_delta_available = abap_true.
        lv_coverage_delta_available = abap_true.
        lv_coverage_deterioration = 0 - <ls_change>-coverage_delta.
      ELSEIF <ls_change>-old_requested > 0
          AND <ls_change>-new_requested > 0.
        lv_coverage_delta_available = abap_true.
        lv_coverage_deterioration = lv_old_coverage - lv_new_coverage.
      ENDIF.
      IF <ls_change>-change_type = 'R'.
        lv_coverage = lv_old_coverage.
        lv_coverage_available = xsdbool(
          <ls_change>-old_requested > 0 ).
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ELSE.
        lv_coverage = lv_new_coverage.
        lv_coverage_available = xsdbool(
          <ls_change>-new_requested > 0 ).
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ENDIF.
      APPEND VALUE #(
        coverage_delta_available = lv_coverage_delta_available
        coverage_deterioration   = lv_coverage_deterioration
        coverage_available       = lv_coverage_available
        coverage                 = lv_coverage
        shortage                 = lv_shortage
        requested_date_available = xsdbool(
          lv_requested_on IS NOT INITIAL )
        requested_on             = lv_requested_on
        change_rank              = COND #( WHEN <ls_change>-change_type = 'C'
                                           THEN 1
                                           WHEN <ls_change>-change_type = 'A'
                                           THEN 2
                                           WHEN <ls_change>-change_type = 'R'
                                           THEN 3
                                           ELSE 4 )
        allocation_unit          = <ls_change>-allocation_unit
        order_id                 = <ls_change>-order_id
        change                   = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY coverage_delta_available DESCENDING
                          coverage_deterioration DESCENDING
                          coverage_available DESCENDING coverage ASCENDING
                          shortage DESCENDING requested_date_available DESCENDING
                          requested_on change_rank allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~sort_by_spct_worsening.
    TYPES:
      BEGIN OF ty_sort_line,
        shortage_pct_delta_available TYPE abap_bool,
        shortage_pct_deterioration   TYPE zif_allocation_audit=>ty_coverage,
        shortage_pct_available       TYPE abap_bool,
        shortage_pct                 TYPE zif_allocation_audit=>ty_coverage,
        shortage                     TYPE zif_stock_allocation=>ty_quantity,
        requested_date_available     TYPE abap_bool,
        requested_on                 TYPE d,
        change_rank                  TYPE i,
        allocation_unit              TYPE zif_stock_allocation=>ty_unit,
        order_id                     TYPE zif_stock_allocation=>ty_order_id,
        change                       TYPE zif_stock_allocation_compare=>ty_change,
      END OF ty_sort_line.
    DATA lt_sort_lines TYPE STANDARD TABLE OF ty_sort_line WITH EMPTY KEY.
    DATA lv_old_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_new_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_shortage_pct_deterioration TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_spct_delta_available TYPE abap_bool.
    DATA lv_shortage_pct_available TYPE abap_bool.
    DATA lv_requested_on TYPE d.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.
    FIELD-SYMBOLS <ls_sort_line> TYPE ty_sort_line.

    LOOP AT it_changes ASSIGNING <ls_change>.
      CLEAR: lv_old_shortage_pct, lv_new_shortage_pct, lv_shortage_pct,
             lv_shortage_pct_deterioration,
             lv_spct_delta_available, lv_shortage_pct_available,
             lv_requested_on, lv_shortage.
      IF <ls_change>-old_shortage_pct_available = abap_true.
        lv_old_shortage_pct = <ls_change>-old_shortage_pct.
      ELSEIF <ls_change>-old_requested > 0.
        lv_old_shortage_pct = <ls_change>-old_shortage * 100 /
          <ls_change>-old_requested.
      ENDIF.
      IF <ls_change>-new_shortage_pct_available = abap_true.
        lv_new_shortage_pct = <ls_change>-new_shortage_pct.
      ELSEIF <ls_change>-new_requested > 0.
        lv_new_shortage_pct = <ls_change>-new_shortage * 100 /
          <ls_change>-new_requested.
      ENDIF.
      IF <ls_change>-shortage_pct_delta_available = abap_true.
        lv_spct_delta_available = abap_true.
        lv_shortage_pct_deterioration = <ls_change>-shortage_pct_delta.
      ELSEIF <ls_change>-old_requested > 0
          AND <ls_change>-new_requested > 0.
        lv_spct_delta_available = abap_true.
        lv_shortage_pct_deterioration = lv_new_shortage_pct
          - lv_old_shortage_pct.
      ENDIF.
      IF <ls_change>-change_type = 'R'.
        lv_shortage_pct = lv_old_shortage_pct.
        lv_shortage_pct_available = xsdbool(
          <ls_change>-old_requested > 0 ).
        lv_shortage = <ls_change>-old_shortage.
        lv_requested_on = <ls_change>-old_requested_on.
      ELSE.
        lv_shortage_pct = lv_new_shortage_pct.
        lv_shortage_pct_available = xsdbool(
          <ls_change>-new_requested > 0 ).
        lv_shortage = <ls_change>-new_shortage.
        lv_requested_on = <ls_change>-new_requested_on.
      ENDIF.
      APPEND VALUE #(
        shortage_pct_delta_available = lv_spct_delta_available
        shortage_pct_deterioration   = lv_shortage_pct_deterioration
        shortage_pct_available       = lv_shortage_pct_available
        shortage_pct                 = lv_shortage_pct
        shortage                     = lv_shortage
        requested_date_available     = xsdbool(
          lv_requested_on IS NOT INITIAL )
        requested_on                 = lv_requested_on
        change_rank                  = COND #( WHEN <ls_change>-change_type = 'C'
                                               THEN 1
                                               WHEN <ls_change>-change_type = 'A'
                                               THEN 2
                                               WHEN <ls_change>-change_type = 'R'
                                               THEN 3
                                               ELSE 4 )
        allocation_unit              = <ls_change>-allocation_unit
        order_id                     = <ls_change>-order_id
        change                       = <ls_change> ) TO lt_sort_lines.
    ENDLOOP.
    SORT lt_sort_lines BY shortage_pct_delta_available DESCENDING
                          shortage_pct_deterioration DESCENDING
                          shortage_pct_available DESCENDING shortage_pct DESCENDING
                          shortage DESCENDING requested_date_available DESCENDING
                          requested_on change_rank allocation_unit order_id.
    LOOP AT lt_sort_lines ASSIGNING <ls_sort_line>.
      APPEND <ls_sort_line>-change TO rt_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~reconcile.
    FIELD-SYMBOLS <ls_snapshot> TYPE zif_stock_allocation=>ty_demand.
    DATA lv_status TYPE zif_stock_allocation=>ty_allocation_status.
    DATA lv_invalid_status TYPE abap_bool.
    DATA lv_invalid_snapshot TYPE abap_bool.
    DATA lv_invalid_unit TYPE abap_bool.

    CLEAR rs_reconciliation.
    LOOP AT it_snapshot ASSIGNING <ls_snapshot>.
      lv_status = to_upper( <ls_snapshot>-allocation_status ).
      IF is_audit-unit IS NOT INITIAL
          AND to_upper( <ls_snapshot>-allocation_unit )
            <> to_upper( is_audit-unit ).
        lv_invalid_unit = abap_true.
      ENDIF.
      rs_reconciliation-snapshot_rows =
        rs_reconciliation-snapshot_rows + 1.
      CASE lv_status.
        WHEN 'F'.
          rs_reconciliation-snapshot_full_count =
            rs_reconciliation-snapshot_full_count + 1.
          IF <ls_snapshot>-allocated <> <ls_snapshot>-requested
              OR <ls_snapshot>-shortage <> 0.
            lv_invalid_snapshot = abap_true.
          ENDIF.
        WHEN 'P'.
          rs_reconciliation-snapshot_partial_count =
            rs_reconciliation-snapshot_partial_count + 1.
          IF <ls_snapshot>-allocated <= 0
              OR <ls_snapshot>-allocated >= <ls_snapshot>-requested
              OR <ls_snapshot>-shortage <= 0.
            lv_invalid_snapshot = abap_true.
          ENDIF.
        WHEN 'U'.
          rs_reconciliation-snapshot_unallocated_count =
            rs_reconciliation-snapshot_unallocated_count + 1.
          IF <ls_snapshot>-allocated <> 0
              OR <ls_snapshot>-shortage <> <ls_snapshot>-requested.
            lv_invalid_snapshot = abap_true.
          ENDIF.
        WHEN OTHERS.
          lv_invalid_status = abap_true.
      ENDCASE.
      IF <ls_snapshot>-requested <= 0
          OR <ls_snapshot>-allocated < 0
          OR <ls_snapshot>-shortage < 0
          OR <ls_snapshot>-allocated > <ls_snapshot>-requested
          OR <ls_snapshot>-shortage <> <ls_snapshot>-requested
            - <ls_snapshot>-allocated.
        lv_invalid_snapshot = abap_true.
      ENDIF.
      rs_reconciliation-snapshot_requested =
        rs_reconciliation-snapshot_requested + <ls_snapshot>-requested.
      rs_reconciliation-snapshot_allocated =
        rs_reconciliation-snapshot_allocated + <ls_snapshot>-allocated.
      rs_reconciliation-snapshot_shortage =
        rs_reconciliation-snapshot_shortage + <ls_snapshot>-shortage.
    ENDLOOP.

    IF lv_invalid_status = abap_true.
      append_reason( EXPORTING iv_reason = 'status'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF lv_invalid_snapshot = abap_true.
      append_reason( EXPORTING iv_reason = 'snapshot'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF lv_invalid_unit = abap_true.
      append_reason( EXPORTING iv_reason = 'unit'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_rows <> is_audit-demand_count.
      append_reason( EXPORTING iv_reason = 'demand_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_full_count <> is_audit-full_count.
      append_reason( EXPORTING iv_reason = 'full_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_partial_count <> is_audit-partial_count.
      append_reason( EXPORTING iv_reason = 'partial_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_unallocated_count
        <> is_audit-unallocated_count.
      append_reason( EXPORTING iv_reason = 'unallocated_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_requested <> is_audit-requested.
      append_reason( EXPORTING iv_reason = 'requested'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_allocated <> is_audit-allocated.
      append_reason( EXPORTING iv_reason = 'allocated'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_shortage <> is_audit-shortage.
      append_reason( EXPORTING iv_reason = 'shortage'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-mismatch_fields IS INITIAL.
      rs_reconciliation-status = 'OK'.
    ELSE.
      rs_reconciliation-status = 'MISMATCH'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_reconciliation_transition.
    IF iv_old_status = 'OK' AND iv_new_status = 'OK'.
      rv_transition = 'both_ok'.
    ELSEIF iv_old_status = 'MISMATCH'
        AND iv_new_status = 'OK'.
      rv_transition = 'recovered'.
    ELSEIF iv_old_status = 'OK'
        AND iv_new_status = 'MISMATCH'.
      rv_transition = 'regressed'.
    ELSEIF iv_old_status = 'MISMATCH'
        AND iv_new_status = 'MISMATCH'.
      rv_transition = 'both_mismatch'.
    ELSE.
      rv_transition = 'unavailable'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_running_age.
    DATA lv_seconds TYPE i.

    CLEAR rs_age.
    IF to_upper( is_run-status ) <> 'R'
        OR is_run-finish_date IS NOT INITIAL
        OR is_run-start_date IS INITIAL
        OR is_run-start_time IS INITIAL.
      RETURN.
    ENDIF.

    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = sy-datum
        time1    = sy-uzeit
        date2    = is_run-start_date
        time2    = is_run-start_time
      IMPORTING
        res_secs = lv_seconds ).
    IF lv_seconds < 0.
      RETURN.
    ENDIF.

    rs_age-available = abap_true.
    rs_age-seconds = lv_seconds.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_running_age_trend.
    rv_trend = 'unavailable'.
    IF is_old_age-available = abap_false
        OR is_new_age-available = abap_false.
      RETURN.
    ENDIF.
    IF is_new_age-seconds > is_old_age-seconds.
      rv_trend = 'older'.
    ELSEIF is_new_age-seconds < is_old_age-seconds.
      rv_trend = 'younger'.
    ELSE.
      rv_trend = 'unchanged'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_audit_metadata_reasons.
    IF to_upper( iv_old_run-status ) <> to_upper( iv_new_run-status ).
      append_reason( EXPORTING iv_reason = 'status'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF to_upper( iv_old_run-strategy ) <> to_upper( iv_new_run-strategy ).
      append_reason( EXPORTING iv_reason = 'strategy'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF to_upper( iv_old_run-unit ) <> to_upper( iv_new_run-unit ).
      append_reason( EXPORTING iv_reason = 'unit'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-movement_type <> iv_new_run-movement_type.
      append_reason( EXPORTING iv_reason = 'movement_type'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-min_shelf_life <> iv_new_run-min_shelf_life.
      append_reason( EXPORTING iv_reason = 'shelf_life'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-requested_on_from <> iv_new_run-requested_on_from
        OR iv_old_run-requested_on_to <> iv_new_run-requested_on_to.
      append_reason( EXPORTING iv_reason = 'horizon'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-start_date <> iv_new_run-start_date
        OR iv_old_run-start_time <> iv_new_run-start_time
        OR iv_old_run-finish_date <> iv_new_run-finish_date
        OR iv_old_run-finish_time <> iv_new_run-finish_time.
      append_reason( EXPORTING iv_reason = 'timestamps'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-message <> iv_new_run-message.
      append_reason( EXPORTING iv_reason = 'message'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD append_reason.
    IF cv_reasons IS INITIAL.
      cv_reasons = iv_reason.
    ELSE.
      CONCATENATE cv_reasons iv_reason INTO cv_reasons SEPARATED BY '|'.
    ENDIF.
  ENDMETHOD.

  METHOD has_reason.
    DATA lv_needle TYPE string.
    DATA lv_reasons TYPE string.

    CONCATENATE '|' iv_reason '|' INTO lv_needle.
    CONCATENATE '|' iv_reasons '|' INTO lv_reasons.
    IF lv_reasons CS lv_needle.
      rv_match = abap_true.
    ELSE.
      rv_match = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
