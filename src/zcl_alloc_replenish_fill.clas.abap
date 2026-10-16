CLASS zcl_alloc_replenish_fill DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_delivered   TYPE i
        iv_requested   TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS is_met
      IMPORTING
        iv_rate      TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS shortfall
      IMPORTING
        iv_delivered        TYPE i
        iv_requested        TYPE i
      RETURNING
        VALUE(rv_shortfall) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_fill IMPLEMENTATION.

  METHOD rate.
    " The fill rate is the delivered part of the request, in percent.
    IF iv_requested <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_delivered * 100 DIV iv_requested.
    IF rv_rate > 100.
      rv_rate = 100.
    ENDIF.
  ENDMETHOD.

  METHOD is_met.
    " The rate meets the target once it reaches it.
    rv_ok = xsdbool( iv_rate >= iv_target ).
  ENDMETHOD.

  METHOD shortfall.
    " The shortfall is the part of the request that was not delivered.
    IF iv_delivered >= iv_requested.
      RETURN.
    ENDIF.

    rv_shortfall = iv_requested - iv_delivered.
  ENDMETHOD.

ENDCLASS.
