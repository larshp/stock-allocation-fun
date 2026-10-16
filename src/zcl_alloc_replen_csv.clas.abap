CLASS zcl_alloc_replen_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_alloc_replenishment=>ty_result
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_replen_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'MATNR' TO lt_fields.
    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'SHORTAGE' TO lt_fields.
    APPEND 'ORDER_QTY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_result-proposals INTO DATA(ls_proposal).
      CLEAR lt_fields.
      APPEND |{ ls_proposal-matnr }| TO lt_fields.
      APPEND |{ ls_proposal-requirement_id }| TO lt_fields.
      APPEND |{ ls_proposal-shortage_qty }| TO lt_fields.
      APPEND |{ ls_proposal-order_qty }| TO lt_fields.
      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
