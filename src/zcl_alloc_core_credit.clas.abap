CLASS zcl_alloc_core_credit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_core,
             material        TYPE matnr,
             returned        TYPE i,
             credit_per_unit TYPE i,
           END OF ty_core.
    TYPES ty_core_tt TYPE STANDARD TABLE OF ty_core WITH DEFAULT KEY.

    METHODS credit
      IMPORTING
        iv_returned        TYPE i
        iv_credit_per_unit TYPE i
      RETURNING
        VALUE(rv_credit)   TYPE i.

    METHODS credit_of
      IMPORTING
        is_core          TYPE ty_core
      RETURNING
        VALUE(rv_credit) TYPE i.

    METHODS total
      IMPORTING
        it_cores         TYPE ty_core_tt
      RETURNING
        VALUE(rv_credit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_core_credit IMPLEMENTATION.

  METHOD credit.
    " A negative returned quantity or credit rate contributes nothing.
    IF iv_returned <= 0 OR iv_credit_per_unit <= 0.
      RETURN.
    ENDIF.

    rv_credit = iv_returned * iv_credit_per_unit.
  ENDMETHOD.

  METHOD credit_of.
    rv_credit = credit( iv_returned        = is_core-returned
                        iv_credit_per_unit = is_core-credit_per_unit ).
  ENDMETHOD.

  METHOD total.
    LOOP AT it_cores INTO DATA(ls_core).
      rv_credit = rv_credit + credit_of( ls_core ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
