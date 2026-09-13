CLASS zcl_alloc_abc_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_lines        TYPE zcl_alloc_abc=>ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_abc_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'MATNR' TO lt_fields.
    APPEND 'QUANTITY' TO lt_fields.
    APPEND 'SHARE_PCT' TO lt_fields.
    APPEND 'CUM_PCT' TO lt_fields.
    APPEND 'CLASS' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_lines INTO DATA(ls_class).
      CLEAR lt_fields.
      APPEND |{ ls_class-matnr }| TO lt_fields.
      APPEND |{ ls_class-quantity }| TO lt_fields.
      APPEND |{ ls_class-share_pct }| TO lt_fields.
      APPEND |{ ls_class-cum_pct }| TO lt_fields.
      APPEND |{ ls_class-class }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
