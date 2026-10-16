CLASS zcl_alloc_prep_row DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS format
      IMPORTING
        iv_order       TYPE string
        iv_cost        TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS is_costly
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prep_row IMPLEMENTATION.

  METHOD format.
    " A report row reads the order and its cost.
    rv_text = |{ iv_order }={ iv_cost }|.
  ENDMETHOD.

  METHOD is_costly.
    " The row is costly once its cost passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD is_zero.
    " The row cost is nil at zero.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
