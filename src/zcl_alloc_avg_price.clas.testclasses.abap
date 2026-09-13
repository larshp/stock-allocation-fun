CLASS ltcl_alloc_avg_price DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_avg_price.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_quantity   TYPE menge_d
        iv_price      TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_avg_price=>ty_item.

    METHODS empty_list       FOR TESTING.
    METHODS single_item      FOR TESTING.
    METHODS weighted_average FOR TESTING.
    METHODS ignores_zero_qty FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_avg_price IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_avg_price( ).
  ENDMETHOD.

  METHOD item.
    rs_row-quantity = iv_quantity.
    rs_row-price = iv_price.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_avg_price=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->calculate( lt_items )
                                        exp = '0' ).
  ENDMETHOD.

  METHOD single_item.
    DATA lt_items TYPE zcl_alloc_avg_price=>ty_item_tt.

    APPEND item( iv_quantity = '10' iv_price = '2' ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->calculate( lt_items )
                                        exp = '2' ).
  ENDMETHOD.

  METHOD weighted_average.
    DATA lt_items TYPE zcl_alloc_avg_price=>ty_item_tt.

    APPEND item( iv_quantity = '10' iv_price = '2' ) TO lt_items.
    APPEND item( iv_quantity = '30' iv_price = '4' ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->calculate( lt_items )
                                        exp = '3.5' ).
  ENDMETHOD.

  METHOD ignores_zero_qty.
    DATA lt_items TYPE zcl_alloc_avg_price=>ty_item_tt.

    APPEND item( iv_quantity = '0' iv_price = '99' ) TO lt_items.
    APPEND item( iv_quantity = '10' iv_price = '2' ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->calculate( lt_items )
                                        exp = '2' ).
  ENDMETHOD.

ENDCLASS.
