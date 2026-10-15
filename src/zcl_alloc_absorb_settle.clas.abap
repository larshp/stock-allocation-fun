CLASS zcl_alloc_absorb_settle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS settle
      IMPORTING
        iv_absorbed      TYPE i
        iv_actual        TYPE i
      RETURNING
        VALUE(rv_settle) TYPE i.

    METHODS residual
      IMPORTING
        iv_absorbed        TYPE i
        iv_actual          TYPE i
      RETURNING
        VALUE(rv_residual) TYPE i.

    METHODS is_settled
      IMPORTING
        iv_residual  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_absorb_settle IMPLEMENTATION.

  METHOD settle.
    " Settlement closes the smaller of the absorbed and actual amounts.
    IF iv_absorbed < iv_actual.
      rv_settle = iv_absorbed.
    ELSE.
      rv_settle = iv_actual.
    ENDIF.
  ENDMETHOD.

  METHOD residual.
    " The residual is the difference left open after settlement.
    rv_residual = iv_absorbed - iv_actual.
    IF rv_residual < 0.
      rv_residual = -1 * rv_residual.
    ENDIF.
  ENDMETHOD.

  METHOD is_settled.
    " The absorption is settled once nothing is left open.
    rv_ok = xsdbool( iv_residual = 0 ).
  ENDMETHOD.

ENDCLASS.
