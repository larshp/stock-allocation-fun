CLASS zcl_alloc_net_req DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS net
      IMPORTING
        iv_gross      TYPE i
        iv_on_hand    TYPE i
        iv_scheduled  TYPE i
      RETURNING
        VALUE(rv_net) TYPE i.

    METHODS shortfall
      IMPORTING
        iv_gross            TYPE i
        iv_on_hand          TYPE i
        iv_scheduled        TYPE i
        iv_safety           TYPE i
      RETURNING
        VALUE(rv_shortfall) TYPE i.

    METHODS is_covered
      IMPORTING
        iv_gross     TYPE i
        iv_on_hand   TYPE i
        iv_scheduled TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_net_req IMPLEMENTATION.

  METHOD net.
    DATA lv_available TYPE i.

    " The net requirement is what the stock and the receipts do not cover.
    lv_available = iv_on_hand + iv_scheduled.
    IF lv_available >= iv_gross.
      RETURN.
    ENDIF.

    rv_net = iv_gross - lv_available.
  ENDMETHOD.

  METHOD shortfall.
    DATA lv_available TYPE i.
    DATA lv_demand    TYPE i.

    " The shortfall also protects the safety stock on top of the requirement.
    lv_available = iv_on_hand + iv_scheduled.
    lv_demand = iv_gross + iv_safety.

    IF lv_available >= lv_demand.
      RETURN.
    ENDIF.

    rv_shortfall = lv_demand - lv_available.
  ENDMETHOD.

  METHOD is_covered.
    " The requirement is covered once stock and receipts reach it.
    rv_ok = xsdbool( iv_on_hand + iv_scheduled >= iv_gross ).
  ENDMETHOD.

ENDCLASS.
