CLASS zcl_stock_allocator_best DEFINITION
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

CLASS zcl_stock_allocator_best IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    DATA lt_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lt_work TYPE zif_stock_allocation=>tt_demands.
    DATA lt_ordered TYPE zif_stock_allocation=>tt_demands.
    DATA ls_best TYPE zif_stock_allocation=>ty_demand.
    DATA ls_selected TYPE zif_stock_allocation=>ty_demand.
    DATA lv_best_index TYPE i.
    DATA lv_best_found TYPE abap_bool.
    DATA lv_best_rank TYPE i.
    DATA lv_candidate_rank TYPE i.
    DATA lv_candidate_index TYPE i.
    DATA lv_candidate_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_next_fit TYPE abap_bool.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_next> TYPE zif_stock_allocation=>ty_demand.

    IF iv_available < 0.
      raise_error( iv_message = 'Available stock is invalid' ).
    ENDIF.

    lt_work = ct_demands.
    LOOP AT lt_work ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL
          OR <ls_demand>-requested <= 0
          OR <ls_demand>-priority < 0
          OR <ls_demand>-priority > zif_stock_allocation=>c_max_priority.
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

    rv_remaining = iv_available.
    WHILE lt_work IS NOT INITIAL.
      CLEAR: lv_best_index, lv_best_found, lv_best_rank, ls_best.
      LOOP AT lt_work ASSIGNING <ls_demand>.
        IF <ls_demand>-requested <= rv_remaining.
          lv_candidate_index = sy-tabix.
          lv_candidate_remaining = rv_remaining
            - <ls_demand>-requested.
          IF lv_candidate_remaining = 0.
            lv_candidate_rank = 0.
          ELSE.
            CLEAR lv_next_fit.
            LOOP AT lt_work ASSIGNING <ls_next>.
              IF sy-tabix <> lv_candidate_index
                  AND <ls_next>-requested <= lv_candidate_remaining.
                lv_next_fit = abap_true.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF lv_next_fit = abap_true.
              lv_candidate_rank = 1.
            ELSE.
              lv_candidate_rank = 2.
            ENDIF.
          ENDIF.
          IF lv_best_found = abap_false
              OR lv_candidate_rank < lv_best_rank
              OR ( lv_candidate_rank = lv_best_rank
                AND ( <ls_demand>-requested > ls_best-requested
                  OR ( <ls_demand>-requested = ls_best-requested
                    AND ( <ls_demand>-priority > ls_best-priority
                      OR ( <ls_demand>-priority = ls_best-priority
                        AND ( <ls_demand>-requested_on < ls_best-requested_on
                          OR ( <ls_demand>-requested_on = ls_best-requested_on
                            AND <ls_demand>-order_id < ls_best-order_id ) ) ) ) ) ) ).
            lv_best_index = lv_candidate_index.
            ls_best = <ls_demand>.
            lv_best_rank = lv_candidate_rank.
            lv_best_found = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_best_found = abap_false.
        LOOP AT lt_work ASSIGNING <ls_demand>.
          IF lv_best_found = abap_false
              OR <ls_demand>-requested < ls_best-requested
              OR ( <ls_demand>-requested = ls_best-requested
                AND ( <ls_demand>-priority > ls_best-priority
                  OR ( <ls_demand>-priority = ls_best-priority
                    AND ( <ls_demand>-requested_on < ls_best-requested_on
                      OR ( <ls_demand>-requested_on = ls_best-requested_on
                        AND <ls_demand>-order_id < ls_best-order_id ) ) ) ) ).
            lv_best_index = sy-tabix.
            ls_best = <ls_demand>.
            lv_best_found = abap_true.
          ENDIF.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_work INDEX lv_best_index INTO ls_selected.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Best-fit demand selection failed' ).
      ENDIF.
      IF ls_selected-requested <= rv_remaining.
        ls_selected-allocated = ls_selected-requested.
      ELSE.
        ls_selected-allocated = rv_remaining.
      ENDIF.
      rv_remaining = rv_remaining - ls_selected-allocated.
      ls_selected-shortage = ls_selected-requested
        - ls_selected-allocated.
      IF ls_selected-allocated = ls_selected-requested.
        ls_selected-allocation_status = 'F'.
      ELSEIF ls_selected-allocated > 0.
        ls_selected-allocation_status = 'P'.
      ELSE.
        ls_selected-allocation_status = 'U'.
      ENDIF.
      APPEND ls_selected TO lt_ordered.
      DELETE lt_work INDEX lv_best_index.
    ENDWHILE.

    ct_demands = lt_ordered.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
