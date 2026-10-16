CLASS zcl_alloc_stdcost_reval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS revalue
      IMPORTING
        iv_qty             TYPE i
        iv_new_unit_cost   TYPE i
      RETURNING
        VALUE(rv_revalued) TYPE i.

    METHODS is_increased
      IMPORTING
        iv_old       TYPE i
        iv_new       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_old          TYPE i
        iv_new          TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_reval IMPLEMENTATION.

  METHOD revalue.
    " The revalued cost is the quantity at the new unit cost.
    rv_revalued = iv_qty * iv_new_unit_cost.
  ENDMETHOD.

  METHOD is_increased.
    " The cost has increased once the new one is higher.
    rv_ok = xsdbool( iv_new > iv_old ).
  ENDMETHOD.

  METHOD delta.
    " The revaluation delta is the new cost less the old one.
    rv_delta = iv_new - iv_old.
  ENDMETHOD.

ENDCLASS.
