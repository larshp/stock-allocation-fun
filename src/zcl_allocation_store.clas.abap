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
        avail_date = ls_allocation-avail_date
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

  METHOD zif_allocation_store~record_reservation.

    UPDATE zstock_alloc_res
      SET reservation = @iv_reservation
      WHERE run_id = @iv_run_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid    = zcx_allocation=>save_failed
        mv_run_id = |{ iv_run_id }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.

    SELECT run_id,
           matnr,
           werks,
           reservation
      FROM zstock_alloc_res
      WHERE werks = @iv_werks
        AND created_at < @iv_created_at
      ORDER BY run_id
      INTO TABLE @rt_run.
    IF sy-subrc <> 0.
      CLEAR rt_run.
      RETURN.
    ENDIF.

    " the table holds one row per demand line and a run covers one material in
    " one plant, so every row of a run answers this the same way
    DELETE ADJACENT DUPLICATES FROM rt_run COMPARING run_id.

  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.

    TYPES:
      BEGIN OF ty_row,
        matnr       TYPE zstock_alloc_res-matnr,
        run_id      TYPE zstock_alloc_res-run_id,
        reservation TYPE zstock_alloc_res-reservation,
        demand_id   TYPE zstock_alloc_res-demand_id,
        req_date    TYPE zstock_alloc_res-req_date,
        avail_date  TYPE zstock_alloc_res-avail_date,
        requested   TYPE zstock_alloc_res-requested,
        confirmed   TYPE zstock_alloc_res-confirmed,
        shortfall   TYPE zstock_alloc_res-shortfall,
        created_at  TYPE zstock_alloc_res-created_at,
      END OF ty_row.
    DATA lt_row    TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA lv_matnr  TYPE zstock_alloc_res-matnr.
    DATA lv_run_id TYPE zstock_alloc_res-run_id.

    " read by plant and pick the newest run per material here rather than in
    " SQL: the pick is a maximum per material, which the WHERE clause cannot
    " express, and the rows of a plant are what housekeeping keeps bounded
    SELECT matnr,
           run_id,
           reservation,
           demand_id,
           req_date,
           avail_date,
           requested,
           confirmed,
           shortfall,
           created_at
      FROM zstock_alloc_res
      WHERE werks = @iv_werks
      ORDER BY matnr, created_at DESCENDING, demand_id
      INTO TABLE @lt_row.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF iv_matnr IS NOT INITIAL.
      DELETE lt_row WHERE matnr <> iv_matnr.
    ENDIF.

    LOOP AT lt_row INTO DATA(ls_row).

      " the first row of a material is its newest run, and only that run's
      " lines still say anything about the material
      IF ls_row-matnr <> lv_matnr.
        lv_matnr  = ls_row-matnr.
        lv_run_id = ls_row-run_id.
      ENDIF.
      IF ls_row-run_id <> lv_run_id.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        matnr       = ls_row-matnr
        run_id      = ls_row-run_id
        reservation = ls_row-reservation
        demand_id   = ls_row-demand_id
        req_date    = ls_row-req_date
        avail_date  = ls_row-avail_date
        requested   = ls_row-requested
        confirmed   = ls_row-confirmed
        shortfall   = ls_row-shortfall ) TO rt_recorded.

    ENDLOOP.

    SORT rt_recorded BY matnr ASCENDING demand_id ASCENDING.

  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.

    DELETE FROM zstock_alloc_res WHERE run_id = @iv_run_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid    = zcx_allocation=>delete_failed
        mv_run_id = |{ iv_run_id }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_allocation_store~read.

    SELECT demand_id,
           req_date,
           avail_date,
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
