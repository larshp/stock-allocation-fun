CLASS zcl_alloc_env_fee DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             quantity TYPE i,
             unit_fee TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS fee
      IMPORTING
        iv_quantity   TYPE i
        iv_unit_fee   TYPE i
      RETURNING
        VALUE(rv_fee) TYPE i.

    METHODS total
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_fee) TYPE i.

    METHODS is_exempt
      IMPORTING
        iv_goods_type TYPE string
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_env_fee IMPLEMENTATION.

  METHOD fee.
    " The environmental fee is a per-unit charge on what is disposed of.
    IF iv_quantity <= 0 OR iv_unit_fee <= 0.
      RETURN.
    ENDIF.

    rv_fee = iv_quantity * iv_unit_fee.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_fee = rv_fee + fee( iv_quantity = ls_line-quantity
                             iv_unit_fee = ls_line-unit_fee ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt.
    " Reusable and already recycled goods carry no environmental fee.
    rv_ok = xsdbool( iv_goods_type = 'REUSABLE'
                     OR iv_goods_type = 'RECYCLED' ).
  ENDMETHOD.

ENDCLASS.
