CLASS zcl_allocation_store DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

  PRIVATE SECTION.

    "! DELETE reports 4 when the run had not been saved before, which is the
    "! normal case and not a failure.
    CONSTANTS c_subrc_nothing_found TYPE sy-subrc VALUE 4.

ENDCLASS.


CLASS zcl_allocation_store IMPLEMENTATION.

  METHOD zif_allocation_store~save.

    DATA lt_row       TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_timestamp TYPE zstock_alloc_res-created_at.

    DELETE FROM zstock_alloc_res WHERE run_id = @iv_run_id.
    IF sy-subrc <> 0 AND sy-subrc <> c_subrc_nothing_found.
      RAISE EXCEPTION NEW zcx_allocation(
        textid    = zcx_allocation=>save_failed
        mv_run_id = |{ iv_run_id }| ).
    ENDIF.

    IF it_allocation IS INITIAL.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD lv_timestamp.

    LOOP AT it_allocation INTO DATA(ls_allocation).
      APPEND VALUE #(
        mandt      = sy-mandt
        run_id     = iv_run_id
        demand_id  = ls_allocation-demand_id
        matnr      = iv_matnr
        werks      = iv_werks
        req_date   = ls_allocation-req_date
        requested  = ls_allocation-requested
        confirmed  = ls_allocation-confirmed
        shortfall  = ls_allocation-shortfall
        created_by = sy-uname
        created_at = lv_timestamp ) TO lt_row.
    ENDLOOP.

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid    = zcx_allocation=>save_failed
        mv_run_id = |{ iv_run_id }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_allocation_store~read.

    SELECT demand_id,
           req_date,
           requested,
           confirmed,
           shortfall
      FROM zstock_alloc_res
      WHERE run_id = @iv_run_id
      ORDER BY demand_id
      INTO TABLE @rt_allocation.
    IF sy-subrc <> 0.
      CLEAR rt_allocation.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
