CLASS zcl_alloc_copro_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             product     TYPE string,
             qty         TYPE i,
             unit_weight TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS weighted
      IMPORTING
        iv_value        TYPE i
        iv_weight       TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS weight_of
      IMPORTING
        iv_qty           TYPE i
        iv_unit_weight   TYPE i
      RETURNING
        VALUE(rv_weight) TYPE i.

    METHODS total_weight
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_weight) TYPE i.

ENDCLASS.


CLASS zcl_alloc_copro_weight IMPLEMENTATION.

  METHOD weighted.
    " The weighted value is the value at its weighting factor.
    rv_value = iv_value * iv_weight.
  ENDMETHOD.

  METHOD weight_of.
    " The weight is the quantity at its unit weight.
    rv_weight = iv_qty * iv_unit_weight.
  ENDMETHOD.

  METHOD total_weight.
    " The total adds the weight of every product line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_weight = rv_weight + ls_line-qty * ls_line-unit_weight.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
