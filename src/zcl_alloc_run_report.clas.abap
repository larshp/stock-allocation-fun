CLASS zcl_alloc_run_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_overview,
             run_id        TYPE zstock_run_id,
             matnr         TYPE matnr,
             werks         TYPE werks_d,
             status        TYPE zstockrun-status,
             item_count    TYPE i,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
             coverage_pct  TYPE i,
           END OF ty_overview.
    TYPES ty_overview_tt TYPE STANDARD TABLE OF ty_overview WITH DEFAULT KEY.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_field,
             fieldname TYPE c LENGTH 30,
             text      TYPE c LENGTH 40,
             rollname  TYPE c LENGTH 30,
             outputlen TYPE i,
             decimals  TYPE i,
             just      TYPE c LENGTH 1,
           END OF ty_field.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        io_header TYPE REF TO zcl_alloc_run_header OPTIONAL.

    METHODS overview
      RETURNING
        VALUE(rt_overview) TYPE ty_overview_tt.

    METHODS overview_of_run
      IMPORTING
        iv_run_id          TYPE zstock_run_id
      RETURNING
        VALUE(rt_overview) TYPE ty_overview_tt.

    METHODS to_lines
      IMPORTING
        it_overview     TYPE ty_overview_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS field_catalog
      RETURNING
        VALUE(rt_fields) TYPE ty_field_tt.

  PRIVATE SECTION.
    DATA mo_header TYPE REF TO zcl_alloc_run_header.

    METHODS to_overview
      IMPORTING
        it_header          TYPE zcl_alloc_run_header=>ty_header_tt
      RETURNING
        VALUE(rt_overview) TYPE ty_overview_tt.

ENDCLASS.


CLASS zcl_alloc_run_report IMPLEMENTATION.

  METHOD constructor.
    IF io_header IS SUPPLIED.
      mo_header = io_header.
    ENDIF.
    IF mo_header IS NOT BOUND.
      mo_header = NEW zcl_alloc_run_header( ).
    ENDIF.
  ENDMETHOD.

  METHOD overview.
    rt_overview = to_overview( mo_header->read_all( ) ).
  ENDMETHOD.

  METHOD overview_of_run.
    rt_overview = to_overview( mo_header->read_run( iv_run_id ) ).
  ENDMETHOD.

  METHOD to_lines.
    DATA lv_header TYPE string.
    DATA lv_line   TYPE string.

    " the header is derived from the catalog so the two cannot drift apart
    LOOP AT field_catalog( ) INTO DATA(ls_field).
      IF lv_header IS NOT INITIAL.
        lv_header = lv_header && |;|.
      ENDIF.
      lv_header = lv_header && |{ ls_field-fieldname }|.
    ENDLOOP.

    APPEND lv_header TO rt_lines.

    LOOP AT it_overview INTO DATA(ls_overview).
      CLEAR lv_line.
      lv_line = lv_line && |{ ls_overview-run_id };|.
      lv_line = lv_line && |{ ls_overview-matnr };|.
      lv_line = lv_line && |{ ls_overview-werks };|.
      lv_line = lv_line && |{ ls_overview-status };|.
      lv_line = lv_line && |{ ls_overview-item_count };|.
      lv_line = lv_line && |{ ls_overview-requested_qty };|.
      lv_line = lv_line && |{ ls_overview-allocated_qty };|.
      lv_line = lv_line && |{ ls_overview-shortage_qty };|.
      lv_line = lv_line && |{ ls_overview-coverage_pct }|.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD field_catalog.
    APPEND VALUE #( fieldname = 'RUN_ID'
                    text      = 'Run'
                    rollname  = 'ZSTOCK_RUN_ID'
                    outputlen = 20
                    just      = 'L' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'MATNR'
                    text      = 'Material'
                    rollname  = 'MATNR'
                    outputlen = 18
                    just      = 'L' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'WERKS'
                    text      = 'Plant'
                    rollname  = 'WERKS_D'
                    outputlen = 4
                    just      = 'L' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'STATUS'
                    text      = 'Status'
                    rollname  = 'ZSTOCKRUN-STATUS'
                    outputlen = 1
                    just      = 'C' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'ITEMS'
                    text      = 'Items'
                    outputlen = 6
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'REQUESTED'
                    text      = 'Requested qty'
                    rollname  = 'MENGE_D'
                    outputlen = 15
                    decimals  = 3
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'ALLOCATED'
                    text      = 'Allocated qty'
                    rollname  = 'MENGE_D'
                    outputlen = 15
                    decimals  = 3
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'SHORTAGE'
                    text      = 'Shortage qty'
                    rollname  = 'MENGE_D'
                    outputlen = 15
                    decimals  = 3
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'COVERAGE'
                    text      = 'Coverage %'
                    outputlen = 8
                    just      = 'R' ) TO rt_fields.
  ENDMETHOD.

  METHOD to_overview.
    DATA ls_overview TYPE ty_overview.

    LOOP AT it_header INTO DATA(ls_header).
      CLEAR ls_overview.
      ls_overview-run_id = ls_header-run_id.
      ls_overview-matnr = ls_header-matnr.
      ls_overview-werks = ls_header-werks.
      ls_overview-status = ls_header-status.
      ls_overview-item_count = ls_header-item_count.
      ls_overview-requested_qty = ls_header-req_qty.
      ls_overview-allocated_qty = ls_header-alloc_qty.
      ls_overview-shortage_qty = ls_header-short_qty.

      IF ls_header-req_qty > 0.
        ls_overview-coverage_pct = ls_header-alloc_qty * 100 DIV ls_header-req_qty.
      ELSE.
        ls_overview-coverage_pct = 100.
      ENDIF.

      APPEND ls_overview TO rt_overview.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
