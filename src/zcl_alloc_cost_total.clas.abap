CLASS zcl_alloc_cost_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_component,
             name   TYPE string,
             amount TYPE i,
           END OF ty_component.
    TYPES ty_component_tt TYPE STANDARD TABLE OF ty_component WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_complete
      IMPORTING
        it_components TYPE ty_component_tt
        iv_total      TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS share
      IMPORTING
        iv_amount       TYPE i
        iv_total        TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cost_total IMPLEMENTATION.

  METHOD total.
    " The total is the sum of every component.
    LOOP AT it_components INTO DATA(ls_component).
      rv_total = rv_total + ls_component-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_complete.
    DATA lv_total TYPE i.

    " The split is complete once the components add up to the whole.
    lv_total = total( it_components ).
    rv_ok = xsdbool( lv_total = iv_total ).
  ENDMETHOD.

  METHOD share.
    " The share of one component is related to the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_share = iv_amount * 100 DIV iv_total.
  ENDMETHOD.

ENDCLASS.
