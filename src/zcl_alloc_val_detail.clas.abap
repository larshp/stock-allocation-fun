CLASS zcl_alloc_val_detail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material  TYPE matnr,
             quantity  TYPE i,
             unit_cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS detail
      IMPORTING
        it_lines         TYPE ty_line_tt
        iv_material      TYPE matnr
      RETURNING
        VALUE(rt_values) TYPE ty_values_tt.

    METHODS for_material
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_material     TYPE matnr
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS line_count
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_detail IMPLEMENTATION.

  METHOD detail.
    DATA lv_value TYPE i.

    " The detail lists the value of every line of the wanted material.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-material <> iv_material.
        CONTINUE.
      ENDIF.

      lv_value = ls_line-quantity * ls_line-unit_cost.
      APPEND lv_value TO rt_values.
    ENDLOOP.
  ENDMETHOD.

  METHOD for_material.
    DATA lv_value TYPE i.

    " The material total adds the value of its lines.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-material <> iv_material.
        CONTINUE.
      ENDIF.

      lv_value = ls_line-quantity * ls_line-unit_cost.
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_values ).
  ENDMETHOD.

ENDCLASS.
