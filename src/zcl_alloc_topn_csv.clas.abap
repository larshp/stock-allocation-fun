CLASS zcl_alloc_topn_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_lines        TYPE zcl_alloc_top_n=>ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_topn_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'RANK' TO lt_fields.
    APPEND 'MATNR' TO lt_fields.
    APPEND 'QUANTITY' TO lt_fields.
    APPEND 'SHARE_PCT' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_lines INTO DATA(ls_top).
      CLEAR lt_fields.
      APPEND |{ ls_top-rank }| TO lt_fields.
      APPEND |{ ls_top-matnr }| TO lt_fields.
      APPEND |{ ls_top-quantity }| TO lt_fields.
      APPEND |{ ls_top-share_pct }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
