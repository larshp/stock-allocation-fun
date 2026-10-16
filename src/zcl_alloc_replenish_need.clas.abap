CLASS zcl_alloc_replenish_need DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS need
      IMPORTING
        iv_required    TYPE i
        iv_available   TYPE i
      RETURNING
        VALUE(rv_need) TYPE i.

    METHODS is_needed
      IMPORTING
        iv_required  TYPE i
        iv_available TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS shortfall
      IMPORTING
        iv_required         TYPE i
        iv_available        TYPE i
        iv_safety           TYPE i
      RETURNING
        VALUE(rv_shortfall) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_need IMPLEMENTATION.

  METHOD need.
    " The replenishment need is the uncovered demand, never negative.
    IF iv_available >= iv_required.
      RETURN.
    ENDIF.

    rv_need = iv_required - iv_available.
  ENDMETHOD.

  METHOD is_needed.
    " Replenishment is needed once the stock falls short of the requirement.
    rv_ok = xsdbool( iv_available < iv_required ).
  ENDMETHOD.

  METHOD shortfall.
    " The shortfall also protects the safety stock on top of the requirement.
    DATA lv_demand TYPE i.

    lv_demand = iv_required + iv_safety.

    IF iv_available >= lv_demand.
      RETURN.
    ENDIF.

    rv_shortfall = lv_demand - iv_available.
  ENDMETHOD.

ENDCLASS.
