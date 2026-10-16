CLASS zcl_alloc_cap_convert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_factor,
             uom    TYPE string,
             factor TYPE i,
           END OF ty_factor.
    TYPES ty_factor_tt TYPE STANDARD TABLE OF ty_factor WITH DEFAULT KEY.

    METHODS factor_for
      IMPORTING
        iv_uom           TYPE string
        it_factors       TYPE ty_factor_tt
      RETURNING
        VALUE(rv_factor) TYPE i.

    METHODS to_base
      IMPORTING
        iv_quantity    TYPE i
        iv_uom         TYPE string
        it_factors     TYPE ty_factor_tt
      RETURNING
        VALUE(rv_base) TYPE i.

    METHODS to_uom
      IMPORTING
        iv_base            TYPE i
        iv_uom             TYPE string
        it_factors         TYPE ty_factor_tt
      RETURNING
        VALUE(rv_quantity) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cap_convert IMPLEMENTATION.

  METHOD factor_for.
    " The base unit is the implicit default, so an unknown unit converts 1:1
    " instead of failing.
    rv_factor = 1.

    LOOP AT it_factors INTO DATA(ls_factor).
      IF ls_factor-uom = iv_uom.
        IF ls_factor-factor > 0.
          rv_factor = ls_factor-factor.
        ENDIF.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD to_base.
    rv_base = iv_quantity * factor_for( iv_uom     = iv_uom
                                        it_factors = it_factors ).
  ENDMETHOD.

  METHOD to_uom.
    DATA lv_factor TYPE i.

    lv_factor = factor_for( iv_uom = iv_uom it_factors = it_factors ).
    IF lv_factor <= 0.
      RETURN.
    ENDIF.

    rv_quantity = iv_base DIV lv_factor.
  ENDMETHOD.

ENDCLASS.
