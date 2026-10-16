CLASS zcl_alloc_yield_target DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS target
      IMPORTING
        iv_total          TYPE i
        iv_target_percent TYPE i
      RETURNING
        VALUE(rv_target)  TYPE i.

    METHODS is_met
      IMPORTING
        iv_good      TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_good       TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_target IMPLEMENTATION.

  METHOD target.
    " The target quantity is the total at the target percentage.
    rv_target = iv_total * iv_target_percent DIV 100.
  ENDMETHOD.

  METHOD is_met.
    " The target is met once the good quantity reaches it.
    rv_ok = xsdbool( iv_good >= iv_target ).
  ENDMETHOD.

  METHOD gap.
    " The gap is the shortfall against the target.
    IF iv_good >= iv_target.
      RETURN.
    ENDIF.

    rv_gap = iv_target - iv_good.
  ENDMETHOD.

ENDCLASS.
