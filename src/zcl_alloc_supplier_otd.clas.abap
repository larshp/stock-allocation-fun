CLASS zcl_alloc_supplier_otd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_on_time     TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS rate_percent
      IMPORTING
        iv_on_time        TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_met
      IMPORTING
        iv_rate_percent TYPE i
        iv_target       TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_supplier_otd IMPLEMENTATION.

  METHOD rate.
    " The on-time rate is the on-time share of the deliveries in per mille.
    IF iv_total <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_on_time * 1000 DIV iv_total.
  ENDMETHOD.

  METHOD rate_percent.
    " The percentage rate is the on-time share of the deliveries.
    IF iv_total <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_on_time * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_met.
    " The on-time target is met once the rate reaches it.
    rv_ok = xsdbool( iv_rate_percent >= iv_target ).
  ENDMETHOD.

ENDCLASS.
