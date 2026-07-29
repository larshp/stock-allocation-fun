CLASS zcl_allocation_log_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_log.
ENDCLASS.

CLASS zcl_allocation_log_sap IMPLEMENTATION.
  METHOD zif_allocation_log~record_run.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations     = it_allocations
      iv_stock_qty       = iv_stock_qty
      iv_allocatable_qty = iv_allocatable_qty
      iv_reserve         = iv_reserve
      iv_unit            = iv_unit ).

    DATA(ls_header) = VALUE bal_s_log(
      object    = 'ZSTOCKALLOC'
      subobject = 'RUN'
      extnumber = |{ iv_material }/{ iv_plant }/{ iv_storage_location }|
      aldate    = sy-datum
      altime    = sy-uzeit
      aluser    = sy-uname ).
    DATA lv_handle TYPE balloghndl.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_header
      IMPORTING
        e_log_handle            = lv_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA lv_message_type TYPE symsgty VALUE 'S'.
    IF ls_summary-shortage_qty > 0.
      lv_message_type = 'W'.
    ENDIF.
    DATA lt_texts TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA(lv_context_text) = |Version { iv_version_no }; strategy { iv_strategy }; |
                          && |window { iv_start_date }-{ iv_cutoff_date }; |
                          && |stock { ls_summary-stock_qty }; allocatable { ls_summary-allocatable_qty }; |
                          && |reserve { ls_summary-reserve_qty } { ls_summary-unit }|.
    DATA(lv_demand_text) = |Demand { ls_summary-demand_count }; requested { ls_summary-requested_qty }; |
                         && |allocated { ls_summary-allocated_qty }|.
    APPEND lv_context_text TO lt_texts.
    IF iv_run_note IS NOT INITIAL.
      APPEND |Execution note: { iv_run_note }| TO lt_texts.
    ENDIF.
    APPEND lv_demand_text TO lt_texts.
    APPEND |Shortage { ls_summary-shortage_qty } across { ls_summary-shortage_count } demands; |
        && |earliest { ls_summary-earliest_shortage_date }; unused { ls_summary-unused_qty }| TO lt_texts.
    APPEND |Fill { ls_summary-quantity_fill_pct }%; service { ls_summary-service_level_pct }%| TO lt_texts.
    APPEND |Utilization { ls_summary-stock_utilization_pct }%; fairness { ls_summary-fairness_pct }%| TO lt_texts.
    LOOP AT lt_texts INTO DATA(lv_text).
      CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
        EXPORTING
          i_log_handle = lv_handle
          i_msgty      = lv_message_type
          i_text       = lv_text
        EXCEPTIONS
          OTHERS       = 1.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA lt_handles TYPE bal_t_logh.
    APPEND lv_handle TO lt_handles.
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_handles
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    rv_recorded = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.
