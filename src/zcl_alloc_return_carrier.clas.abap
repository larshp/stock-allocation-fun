CLASS zcl_alloc_return_carrier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_carrier,
             carrier  TYPE string,
             capacity TYPE i,
             cost     TYPE i,
           END OF ty_carrier.
    TYPES ty_carrier_tt TYPE STANDARD TABLE OF ty_carrier WITH DEFAULT KEY.

    METHODS select
      IMPORTING
        it_carriers       TYPE ty_carrier_tt
        iv_quantity       TYPE i
      RETURNING
        VALUE(rv_carrier) TYPE string.

    METHODS cheapest
      IMPORTING
        it_carriers       TYPE ty_carrier_tt
      RETURNING
        VALUE(rv_carrier) TYPE string.

    METHODS fits
      IMPORTING
        is_carrier   TYPE ty_carrier
        iv_quantity  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_carrier IMPLEMENTATION.

  METHOD fits.
    rv_ok = xsdbool( is_carrier-carrier IS NOT INITIAL
                     AND iv_quantity > 0
                     AND is_carrier-capacity >= iv_quantity ).
  ENDMETHOD.

  METHOD select.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    " Only carriers that can take the whole shipment are considered, and the
    " cheapest of those wins; a tie keeps the first carrier seen.
    LOOP AT it_carriers INTO DATA(ls_carrier).
      IF fits( is_carrier  = ls_carrier
               iv_quantity = iv_quantity ) = abap_false.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_false OR ls_carrier-cost < lv_best.
        lv_found = abap_true.
        lv_best = ls_carrier-cost.
        rv_carrier = ls_carrier-carrier.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cheapest.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_carriers INTO DATA(ls_carrier).
      IF ls_carrier-carrier IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_false OR ls_carrier-cost < lv_best.
        lv_found = abap_true.
        lv_best = ls_carrier-cost.
        rv_carrier = ls_carrier-carrier.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
