CLASS zcl_alloc_bom_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component   TYPE string,
             qty         TYPE i,
             unit_weight TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

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

    METHODS is_heavy
      IMPORTING
        iv_weight    TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_bom_weight IMPLEMENTATION.

  METHOD weight_of.
    " The weight is the quantity at its unit weight.
    rv_weight = iv_qty * iv_unit_weight.
  ENDMETHOD.

  METHOD total_weight.
    " The total adds the weight of every component line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_weight = rv_weight + ls_line-qty * ls_line-unit_weight.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_heavy.
    " The component is heavy once its weight passes the limit.
    rv_ok = xsdbool( iv_weight > iv_limit ).
  ENDMETHOD.

ENDCLASS.
