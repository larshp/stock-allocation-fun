CLASS zcl_alloc_overchk_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_overs        TYPE zcl_alloc_over_check=>ty_over_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_overchk_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'REQUESTED_QTY' TO lt_fields.
    APPEND 'ALLOCATED_QTY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_overs INTO DATA(ls_over).
      CLEAR lt_fields.
      APPEND |{ ls_over-requirement_id }| TO lt_fields.
      APPEND |{ ls_over-requested_qty }| TO lt_fields.
      APPEND |{ ls_over-allocated_qty }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
