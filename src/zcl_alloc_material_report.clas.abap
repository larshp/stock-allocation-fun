CLASS zcl_alloc_material_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_material_line,
             matnr         TYPE matnr,
             werks         TYPE werks_d,
             run_count     TYPE i,
             item_count    TYPE i,
             positions     TYPE i,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
             coverage_pct  TYPE i,
           END OF ty_material_line.
    TYPES ty_material_line_tt TYPE STANDARD TABLE OF ty_material_line
      WITH DEFAULT KEY.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        io_header TYPE REF TO zcl_alloc_run_header OPTIONAL
        io_log    TYPE REF TO zcl_alloc_log_reader OPTIONAL.

    METHODS overview
      RETURNING
        VALUE(rt_overview) TYPE ty_material_line_tt.

    METHODS overview_of_material
      IMPORTING
        iv_matnr           TYPE matnr
      RETURNING
        VALUE(rt_overview) TYPE ty_material_line_tt.

    METHODS to_lines
      IMPORTING
        it_overview     TYPE ty_material_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS field_catalog
      RETURNING
        VALUE(rt_fields) TYPE zcl_alloc_run_report=>ty_field_tt.

  PRIVATE SECTION.
    DATA mo_header TYPE REF TO zcl_alloc_run_header.
    DATA mo_log    TYPE REF TO zcl_alloc_log_reader.

    METHODS build_overview
      IMPORTING
        it_header          TYPE zcl_alloc_run_header=>ty_header_tt
        it_log             TYPE zcl_alloc_log_reader=>ty_log_tt
      RETURNING
        VALUE(rt_overview) TYPE ty_material_line_tt.

    METHODS add_log_positions
      IMPORTING
        it_overview        TYPE ty_material_line_tt
        it_log             TYPE zcl_alloc_log_reader=>ty_log_tt
      RETURNING
        VALUE(rt_overview) TYPE ty_material_line_tt.

    METHODS add_positions
      IMPORTING
        it_overview        TYPE ty_material_line_tt
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
        iv_positions       TYPE i
      RETURNING
        VALUE(rt_overview) TYPE ty_material_line_tt.

    METHODS coverage_of
      IMPORTING
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_material_report IMPLEMENTATION.

  METHOD constructor.
    IF io_header IS SUPPLIED.
      mo_header = io_header.
    ENDIF.
    IF mo_header IS NOT BOUND.
      mo_header = NEW zcl_alloc_run_header( ).
    ENDIF.

    IF io_log IS SUPPLIED.
      mo_log = io_log.
    ENDIF.
    IF mo_log IS NOT BOUND.
      mo_log = NEW zcl_alloc_log_reader( ).
    ENDIF.
  ENDMETHOD.

  METHOD overview.
    rt_overview = build_overview( it_header = mo_header->read_all( )
                                  it_log    = mo_log->read_all( ) ).
  ENDMETHOD.

  METHOD overview_of_material.
    LOOP AT overview( ) INTO DATA(ls_line).
      IF ls_line-matnr = iv_matnr.
        APPEND ls_line TO rt_overview.
      ENDIF.
    ENDLOOP.
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
      lv_line = lv_line && |{ ls_overview-matnr };|.
      lv_line = lv_line && |{ ls_overview-werks };|.
      lv_line = lv_line && |{ ls_overview-run_count };|.
      lv_line = lv_line && |{ ls_overview-item_count };|.
      lv_line = lv_line && |{ ls_overview-positions };|.
      lv_line = lv_line && |{ ls_overview-requested_qty };|.
      lv_line = lv_line && |{ ls_overview-allocated_qty };|.
      lv_line = lv_line && |{ ls_overview-shortage_qty };|.
      lv_line = lv_line && |{ ls_overview-coverage_pct }|.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD field_catalog.
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
    APPEND VALUE #( fieldname = 'RUNS'
                    text      = 'Runs'
                    outputlen = 5
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'ITEMS'
                    text      = 'Items'
                    outputlen = 6
                    just      = 'R' ) TO rt_fields.
    APPEND VALUE #( fieldname = 'POSITIONS'
                    text      = 'Positions'
                    outputlen = 9
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

  METHOD build_overview.
    DATA ls_header     TYPE zstockrun.
    DATA ls_line       TYPE ty_material_line.
    DATA lv_last_matnr TYPE matnr.
    DATA lv_last_werks TYPE werks_d.
    DATA lv_last_run   TYPE zstock_run_id.
    DATA lt_header     TYPE zcl_alloc_run_header=>ty_header_tt.

    lt_header = it_header.
    SORT lt_header BY matnr werks run_id.

    LOOP AT lt_header INTO ls_header.
      IF ls_header-status = zcl_alloc_run_header=>c_status_reversed.
        CONTINUE.
      ENDIF.

      IF ls_header-matnr <> lv_last_matnr
          OR ls_header-werks <> lv_last_werks.
        IF lv_last_matnr IS NOT INITIAL OR lv_last_werks IS NOT INITIAL.
          APPEND ls_line TO rt_overview.
        ENDIF.
        CLEAR ls_line.
        CLEAR lv_last_run.
        ls_line-matnr = ls_header-matnr.
        ls_line-werks = ls_header-werks.
        lv_last_matnr = ls_header-matnr.
        lv_last_werks = ls_header-werks.
      ENDIF.

      IF ls_header-run_id <> lv_last_run.
        ls_line-run_count = ls_line-run_count + 1.
        lv_last_run = ls_header-run_id.
      ENDIF.

      ls_line-item_count = ls_line-item_count + ls_header-item_count.
      ls_line-requested_qty = ls_line-requested_qty + ls_header-req_qty.
      ls_line-allocated_qty = ls_line-allocated_qty + ls_header-alloc_qty.
      ls_line-shortage_qty = ls_line-shortage_qty + ls_header-short_qty.
    ENDLOOP.

    IF lv_last_matnr IS NOT INITIAL OR lv_last_werks IS NOT INITIAL.
      APPEND ls_line TO rt_overview.
    ENDIF.

    rt_overview = add_log_positions( it_overview = rt_overview
                                     it_log      = it_log ).

    LOOP AT rt_overview ASSIGNING FIELD-SYMBOL(<ls_overview>).
      <ls_overview>-coverage_pct = coverage_of(
        iv_requested = <ls_overview>-requested_qty
        iv_allocated = <ls_overview>-allocated_qty ).
    ENDLOOP.
  ENDMETHOD.

  METHOD add_log_positions.
    DATA lv_last_matnr TYPE matnr.
    DATA lv_last_werks TYPE werks_d.
    DATA lv_positions  TYPE i.
    DATA lt_log        TYPE zcl_alloc_log_reader=>ty_log_tt.

    rt_overview = it_overview.
    lt_log = it_log.
    SORT lt_log BY matnr werks.

    LOOP AT lt_log INTO DATA(ls_log).
      IF ls_log-matnr <> lv_last_matnr
          OR ls_log-werks <> lv_last_werks.
        IF lv_last_matnr IS NOT INITIAL OR lv_last_werks IS NOT INITIAL.
          rt_overview = add_positions( it_overview  = rt_overview
                                       iv_matnr     = lv_last_matnr
                                       iv_werks     = lv_last_werks
                                       iv_positions = lv_positions ).
        ENDIF.
        lv_last_matnr = ls_log-matnr.
        lv_last_werks = ls_log-werks.
        lv_positions = 0.
      ENDIF.
      lv_positions = lv_positions + 1.
    ENDLOOP.

    IF lv_last_matnr IS NOT INITIAL OR lv_last_werks IS NOT INITIAL.
      rt_overview = add_positions( it_overview  = rt_overview
                                   iv_matnr     = lv_last_matnr
                                   iv_werks     = lv_last_werks
                                   iv_positions = lv_positions ).
    ENDIF.
  ENDMETHOD.

  METHOD add_positions.
    rt_overview = it_overview.

    READ TABLE rt_overview ASSIGNING FIELD-SYMBOL(<ls_line>)
      WITH KEY matnr = iv_matnr
               werks = iv_werks.
    IF sy-subrc = 0.
      <ls_line>-positions = <ls_line>-positions + iv_positions.
    ENDIF.
  ENDMETHOD.

  METHOD coverage_of.
    IF iv_requested <= 0.
      rv_pct = 100.
      RETURN.
    ENDIF.

    rv_pct = iv_allocated * 100 DIV iv_requested.
  ENDMETHOD.

ENDCLASS.
