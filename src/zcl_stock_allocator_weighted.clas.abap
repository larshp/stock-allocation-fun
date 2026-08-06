CLASS zcl_stock_allocator_weighted DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocator_weighted IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    DATA lt_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lv_active_count TYPE i.
    DATA lv_total_weight TYPE i.
    DATA lv_weight TYPE i.
    DATA lv_outstanding TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_round_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_share TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_grant TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_progress TYPE abap_bool.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    IF iv_available < 0.
      raise_error( iv_message = 'Available stock is invalid' ).
    ENDIF.

    LOOP AT ct_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL OR <ls_demand>-requested <= 0.
        raise_error( iv_message = 'Allocation demand is invalid' ).
      ENDIF.
      INSERT <ls_demand>-order_id INTO TABLE lt_order_ids.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation demand keys are duplicated' ).
      ENDIF.
      CLEAR: <ls_demand>-allocated,
             <ls_demand>-shortage,
             <ls_demand>-allocation_status,
             <ls_demand>-reservation_id,
             <ls_demand>-reservation_date,
             <ls_demand>-reservation_movement_type,
             <ls_demand>-reservation_unit.
    ENDLOOP.

    SORT ct_demands BY priority DESCENDING requested_on ASCENDING
                       order_id ASCENDING.
    rv_remaining = iv_available.
    WHILE rv_remaining > 0.
      CLEAR: lv_active_count, lv_total_weight, lv_progress.
      LOOP AT ct_demands ASSIGNING <ls_demand>.
        lv_outstanding = <ls_demand>-requested - <ls_demand>-allocated.
        IF lv_outstanding > 0.
          lv_active_count = lv_active_count + 1.
          lv_weight = <ls_demand>-priority + 1.
          IF lv_weight < 1.
            lv_weight = 1.
          ENDIF.
          lv_total_weight = lv_total_weight + lv_weight.
        ENDIF.
      ENDLOOP.
      IF lv_active_count = 0 OR lv_total_weight <= 0.
        EXIT.
      ENDIF.

      lv_round_remaining = rv_remaining.
      LOOP AT ct_demands ASSIGNING <ls_demand>.
        IF rv_remaining <= 0.
          EXIT.
        ENDIF.
        lv_outstanding = <ls_demand>-requested - <ls_demand>-allocated.
        IF lv_outstanding <= 0.
          CONTINUE.
        ENDIF.
        lv_weight = <ls_demand>-priority + 1.
        IF lv_weight < 1.
          lv_weight = 1.
        ENDIF.
        lv_share = lv_round_remaining * lv_weight / lv_total_weight.
        lv_grant = lv_share.
        IF lv_outstanding < lv_grant.
          lv_grant = lv_outstanding.
        ENDIF.
        IF rv_remaining < lv_grant.
          lv_grant = rv_remaining.
        ENDIF.
        IF lv_grant <= 0.
          CONTINUE.
        ENDIF.
        <ls_demand>-allocated = <ls_demand>-allocated + lv_grant.
        rv_remaining = rv_remaining - lv_grant.
        lv_progress = abap_true.
      ENDLOOP.
      IF lv_progress = abap_false.
        EXIT.
      ENDIF.
    ENDWHILE.

    LOOP AT ct_demands ASSIGNING <ls_demand>.
      <ls_demand>-shortage = <ls_demand>-requested
        - <ls_demand>-allocated.
      IF <ls_demand>-allocated = <ls_demand>-requested.
        <ls_demand>-allocation_status = 'F'.
      ELSEIF <ls_demand>-allocated > 0.
        <ls_demand>-allocation_status = 'P'.
      ELSE.
        <ls_demand>-allocation_status = 'U'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
