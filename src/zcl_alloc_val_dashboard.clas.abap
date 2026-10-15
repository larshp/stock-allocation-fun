CLASS zcl_alloc_val_dashboard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_dash,
             line_count    TYPE i,
             total_value   TYPE i,
             average_value TYPE i,
           END OF ty_dash.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rs_dash) TYPE ty_dash.

    METHODS is_healthy
      IMPORTING
        iv_line_count TYPE i
        iv_min_lines  TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS highlight
      IMPORTING
        iv_total_value TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_flag) TYPE string.

ENDCLASS.


CLASS zcl_alloc_val_dashboard IMPLEMENTATION.

  METHOD build.
    DATA lv_total TYPE i.

    " The dashboard shows how much stock there is and what it is worth.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_total = lv_total + ls_line-value.
    ENDLOOP.

    rs_dash-line_count = lines( it_lines ).
    rs_dash-total_value = lv_total.

    IF rs_dash-line_count > 0.
      rs_dash-average_value = lv_total DIV rs_dash-line_count.
    ENDIF.
  ENDMETHOD.

  METHOD is_healthy.
    " The valuation is healthy once enough lines carry it.
    rv_ok = xsdbool( iv_line_count >= iv_min_lines ).
  ENDMETHOD.

  METHOD highlight.
    " A total past the threshold is flagged as high.
    IF iv_total_value >= iv_threshold.
      rv_flag = 'HIGH'.
    ELSE.
      rv_flag = 'NORMAL'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
