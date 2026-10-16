CLASS ltcl_alloc_shipment DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shipment.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_lgort      TYPE lgort_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_shipment=>ty_item.

    METHODS empty_list     FOR TESTING.
    METHODS one_shipment   FOR TESTING.
    METHODS two_shipments  FOR TESTING.
    METHODS sums_positions FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_shipment IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shipment( ).
  ENDMETHOD.

  METHOD item.
    rs_row-lgort = iv_lgort.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_shipment=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_items ) ).
  ENDMETHOD.

  METHOD one_shipment.
    DATA lt_items TYPE zcl_alloc_shipment=>ty_item_tt.

    APPEND item( iv_lgort = '0001' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_lgort = '0001' iv_quantity = '4' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-shipment exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '7' ).
  ENDMETHOD.

  METHOD two_shipments.
    DATA lt_items TYPE zcl_alloc_shipment=>ty_item_tt.

    APPEND item( iv_lgort = '0002' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_lgort = '0001' iv_quantity = '4' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lgort exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-shipment exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-shipment exp = 2 ).
  ENDMETHOD.

  METHOD sums_positions.
    DATA lt_items TYPE zcl_alloc_shipment=>ty_item_tt.

    APPEND item( iv_lgort = '0001' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_lgort = '0001' iv_quantity = '4' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-positions exp = 2 ).
  ENDMETHOD.

ENDCLASS.
