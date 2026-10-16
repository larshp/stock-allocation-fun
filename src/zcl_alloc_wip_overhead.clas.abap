CLASS zcl_alloc_wip_overhead DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS overhead
      IMPORTING
        iv_base            TYPE i
        iv_percent         TYPE i
      RETURNING
        VALUE(rv_overhead) TYPE i.

    METHODS absorbed
      IMPORTING
        iv_planned         TYPE i
        iv_percent         TYPE i
      RETURNING
        VALUE(rv_absorbed) TYPE i.

    METHODS balance
      IMPORTING
        iv_planned        TYPE i
        iv_absorbed       TYPE i
      RETURNING
        VALUE(rv_balance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wip_overhead IMPLEMENTATION.

  METHOD overhead.
    " The overhead is the base at its overhead percentage.
    rv_overhead = iv_base * iv_percent DIV 100.
  ENDMETHOD.

  METHOD absorbed.
    " The absorbed overhead is the planned amount at its percentage.
    rv_absorbed = iv_planned * iv_percent DIV 100.
  ENDMETHOD.

  METHOD balance.
    " The balance is what is left of the plan once absorbed.
    IF iv_absorbed >= iv_planned.
      RETURN.
    ENDIF.

    rv_balance = iv_planned - iv_absorbed.
  ENDMETHOD.

ENDCLASS.
