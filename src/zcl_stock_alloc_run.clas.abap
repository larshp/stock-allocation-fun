CLASS zcl_stock_alloc_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_request,
             matnr TYPE matnr,
             werks TYPE werks_d,
           END OF ty_request.
    TYPES ty_request_tt TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_material_result,
             matnr   TYPE matnr,
             werks   TYPE werks_d,
             results TYPE zcl_stock_allocator=>ty_result_tt,
           END OF ty_material_result.
    TYPES ty_material_result_tt TYPE STANDARD TABLE OF ty_material_result
      WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stats,
             materials          TYPE i,
             requirements       TYPE i,
             requested_qty      TYPE menge_d,
             allocated_qty      TYPE menge_d,
             shortage_qty       TYPE menge_d,
             materials_shortage TYPE i,
             skipped            TYPE i,
           END OF ty_stats.

    TYPES: BEGIN OF ty_shortage,
             matnr          TYPE matnr,
             werks          TYPE werks_d,
             requirement_id TYPE c LENGTH 20,
             shortage_qty   TYPE menge_d,
           END OF ty_shortage.
    TYPES ty_shortage_tt TYPE STANDARD TABLE OF ty_shortage WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_run_result,
             materials TYPE ty_material_result_tt,
             stats     TYPE ty_stats,
             shortages TYPE ty_shortage_tt,
           END OF ty_run_result.

    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zcl_stock_allocation_service OPTIONAL.

    METHODS run
      IMPORTING
        it_requests      TYPE ty_request_tt
      RETURNING
        VALUE(rs_result) TYPE ty_run_result.

    METHODS run_in_packages
      IMPORTING
        it_requests      TYPE ty_request_tt
        iv_package_size  TYPE i DEFAULT 100
      RETURNING
        VALUE(rs_result) TYPE ty_run_result.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zcl_stock_allocation_service.

    METHODS add_shortages
      IMPORTING
        is_material  TYPE ty_material_result
      CHANGING
        ct_shortages TYPE ty_shortage_tt
        cs_stats     TYPE ty_stats.

    METHODS is_valid_request
      IMPORTING
        is_request      TYPE ty_request
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_stock_alloc_run IMPLEMENTATION.

  METHOD constructor.
    IF io_service IS SUPPLIED.
      mo_service = io_service.
    ENDIF.
    IF mo_service IS NOT BOUND.
      mo_service = NEW zcl_stock_allocation_service( ).
    ENDIF.
  ENDMETHOD.

  METHOD run.
    DATA ls_material TYPE ty_material_result.

    LOOP AT it_requests INTO DATA(ls_request).
      IF is_valid_request( ls_request ) = abap_false.
        " an empty material or plant cannot be allocated, count and skip it
        rs_result-stats-skipped = rs_result-stats-skipped + 1.
        CONTINUE.
      ENDIF.

      CLEAR ls_material.
      ls_material-matnr = ls_request-matnr.
      ls_material-werks = ls_request-werks.
      ls_material-results = mo_service->allocate( iv_matnr = ls_request-matnr
                                                  iv_werks = ls_request-werks ).

      rs_result-stats-materials = rs_result-stats-materials + 1.
      APPEND ls_material TO rs_result-materials.

      add_shortages( EXPORTING is_material  = ls_material
                     CHANGING  ct_shortages = rs_result-shortages
                               cs_stats     = rs_result-stats ).
    ENDLOOP.
  ENDMETHOD.

  METHOD run_in_packages.
    DATA lt_package TYPE ty_request_tt.
    DATA ls_package TYPE ty_run_result.
    DATA ls_request TYPE ty_request.
    DATA lv_index   TYPE i.
    DATA lv_from    TYPE i.
    DATA lv_to      TYPE i.
    DATA lv_total   TYPE i.

    IF iv_package_size <= 0.
      rs_result = run( it_requests ).
      RETURN.
    ENDIF.

    lv_total = lines( it_requests ).
    lv_from = 1.

    WHILE lv_from <= lv_total.
      lv_to = lv_from + iv_package_size - 1.
      IF lv_to > lv_total.
        lv_to = lv_total.
      ENDIF.

      CLEAR lt_package.
      CLEAR lv_index.

      LOOP AT it_requests INTO ls_request.
        lv_index = lv_index + 1.
        IF lv_index < lv_from.
          CONTINUE.
        ENDIF.
        IF lv_index > lv_to.
          EXIT.
        ENDIF.
        APPEND ls_request TO lt_package.
      ENDLOOP.

      CLEAR ls_package.
      ls_package = run( lt_package ).

      APPEND LINES OF ls_package-materials TO rs_result-materials.
      APPEND LINES OF ls_package-shortages TO rs_result-shortages.

      rs_result-stats-materials = rs_result-stats-materials
        + ls_package-stats-materials.
      rs_result-stats-requirements = rs_result-stats-requirements
        + ls_package-stats-requirements.
      rs_result-stats-requested_qty = rs_result-stats-requested_qty
        + ls_package-stats-requested_qty.
      rs_result-stats-allocated_qty = rs_result-stats-allocated_qty
        + ls_package-stats-allocated_qty.
      rs_result-stats-shortage_qty = rs_result-stats-shortage_qty
        + ls_package-stats-shortage_qty.
      rs_result-stats-materials_shortage = rs_result-stats-materials_shortage
        + ls_package-stats-materials_shortage.
      rs_result-stats-skipped = rs_result-stats-skipped
        + ls_package-stats-skipped.

      lv_from = lv_to + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_valid_request.
    rv_valid = abap_true.

    IF is_request-matnr IS INITIAL OR is_request-werks IS INITIAL.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD add_shortages.
    DATA lv_material_shortage TYPE menge_d.

    LOOP AT is_material-results INTO DATA(ls_result).
      cs_stats-requirements = cs_stats-requirements + 1.
      cs_stats-requested_qty = cs_stats-requested_qty + ls_result-requested_qty.
      cs_stats-allocated_qty = cs_stats-allocated_qty + ls_result-allocated_qty.
      cs_stats-shortage_qty = cs_stats-shortage_qty + ls_result-shortage_qty.
      lv_material_shortage = lv_material_shortage + ls_result-shortage_qty.

      IF ls_result-shortage_qty > 0.
        APPEND VALUE #( matnr          = is_material-matnr
                        werks          = is_material-werks
                        requirement_id = ls_result-requirement_id
                        shortage_qty   = ls_result-shortage_qty ) TO ct_shortages.
      ENDIF.
    ENDLOOP.

    IF lv_material_shortage > 0.
      cs_stats-materials_shortage = cs_stats-materials_shortage + 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
