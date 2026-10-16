CLASS zcl_alloc_wip_material DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS material_cost
      IMPORTING
        iv_issued      TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_issued
      IMPORTING
        iv_issued    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS balance
      IMPORTING
        iv_issued         TYPE i
        iv_consumed       TYPE i
      RETURNING
        VALUE(rv_balance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wip_material IMPLEMENTATION.

  METHOD material_cost.
    " The material cost is the quantity issued at its unit cost.
    rv_cost = iv_issued * iv_unit_cost.
  ENDMETHOD.

  METHOD is_issued.
    " Material has been issued once any quantity has gone out.
    rv_ok = xsdbool( iv_issued > 0 ).
  ENDMETHOD.

  METHOD balance.
    " The balance is what is left of the issued material.
    IF iv_consumed >= iv_issued.
      RETURN.
    ENDIF.

    rv_balance = iv_issued - iv_consumed.
  ENDMETHOD.

ENDCLASS.
