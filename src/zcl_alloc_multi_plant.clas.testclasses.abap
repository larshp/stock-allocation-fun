CLASS ltcl_alloc_multi_plant DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_multi_plant.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_multi_plant=>ty_item.

    METHODS empty_list     FOR TESTING.
    METHODS one_plant      FOR TESTING.
    METHODS two_plants     FOR TESTING.
    METHODS groups_plant   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_multi_plant IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_multi_plant( ).
  ENDMETHOD.

  METHOD item.
    rs_row-werks = iv_werks.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_multi_plant=>ty_item_tt.

    DATA(rs_result) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-plants exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-total exp = '0' ).
  ENDMETHOD.

  METHOD one_plant.
    DATA lt_items TYPE zcl_alloc_multi_plant=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_quantity = '10' ) TO lt_items.

    DATA(rs_result) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-plants exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-total exp = '10' ).
  ENDMETHOD.

  METHOD two_plants.
    DATA lt_items TYPE zcl_alloc_multi_plant=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_werks = '2000' iv_quantity = '5' ) TO lt_items.

    DATA(rs_result) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-plants exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-total exp = '15' ).
  ENDMETHOD.

  METHOD groups_plant.
    DATA lt_items TYPE zcl_alloc_multi_plant=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_werks = '1000' iv_quantity = '4' ) TO lt_items.

    DATA(rs_result) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-plants exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-quantity
                                        exp = '14' ).
  ENDMETHOD.

ENDCLASS.
