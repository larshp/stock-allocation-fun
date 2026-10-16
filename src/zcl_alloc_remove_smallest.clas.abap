CLASS zcl_alloc_remove_smallest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stock,
             bin_id   TYPE string,
             quantity TYPE menge_d,
           END OF ty_stock.
    TYPES ty_stock_tt TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.

    METHODS smallest_sufficient
      IMPORTING
        it_stock      TYPE ty_stock_tt
        iv_required   TYPE menge_d
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_remove_smallest IMPLEMENTATION.

  METHOD smallest_sufficient.
    DATA lv_best  TYPE menge_d.
    DATA lv_found TYPE abap_bool.

    " Picking the smallest bin that still covers the requirement leaves the large
    " bins intact for large orders.
    LOOP AT it_stock INTO DATA(ls_stock).
      IF ls_stock-quantity < iv_required OR ls_stock-quantity <= 0.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_false OR ls_stock-quantity < lv_best.
        lv_found = abap_true.
        lv_best = ls_stock-quantity.
        rv_bin = ls_stock-bin_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
