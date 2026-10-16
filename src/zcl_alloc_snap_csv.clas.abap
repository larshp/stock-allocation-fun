CLASS zcl_alloc_snap_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_lines        TYPE zcl_alloc_snapshot=>ty_diff_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_snap_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'BEFORE_QTY' TO lt_fields.
    APPEND 'AFTER_QTY' TO lt_fields.
    APPEND 'DELTA_QTY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_lines INTO DATA(ls_diff).
      CLEAR lt_fields.
      APPEND |{ ls_diff-requirement_id }| TO lt_fields.
      APPEND |{ ls_diff-before_qty }| TO lt_fields.
      APPEND |{ ls_diff-after_qty }| TO lt_fields.
      APPEND |{ ls_diff-delta_qty }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
