CLASS zcl_alloc_diff3_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_lines        TYPE zcl_alloc_diff3=>ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_diff3_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'ID' TO lt_fields.
    APPEND 'BASE_QTY' TO lt_fields.
    APPEND 'LEFT_QTY' TO lt_fields.
    APPEND 'RIGHT_QTY' TO lt_fields.
    APPEND 'STATUS' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR lt_fields.
      APPEND |{ ls_line-id }| TO lt_fields.
      APPEND |{ ls_line-base_qty }| TO lt_fields.
      APPEND |{ ls_line-left_qty }| TO lt_fields.
      APPEND |{ ls_line-right_qty }| TO lt_fields.
      APPEND |{ ls_line-status }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
