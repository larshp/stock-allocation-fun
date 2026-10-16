CLASS zcl_alloc_receipt_net DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS receipt_total
      IMPORTING
        it_receipts     TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS demand_total
      IMPORTING
        it_demands      TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS net
      IMPORTING
        it_receipts   TYPE ty_values_tt
        it_demands    TYPE ty_values_tt
      RETURNING
        VALUE(rv_net) TYPE i.

ENDCLASS.


CLASS zcl_alloc_receipt_net IMPLEMENTATION.

  METHOD receipt_total.
    LOOP AT it_receipts INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD demand_total.
    LOOP AT it_demands INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD net.
    DATA lv_receipts TYPE i.
    DATA lv_demands  TYPE i.

    " The net position nets the receipts against the demands.
    lv_receipts = receipt_total( it_receipts ).
    lv_demands = demand_total( it_demands ).

    rv_net = lv_receipts - lv_demands.
  ENDMETHOD.

ENDCLASS.
