CLASS ltcl_alloc_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_werks      TYPE werks_d
        iv_available  TYPE menge_d
        iv_cost       TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_cost=>ty_item.

    METHODS input
      IMPORTING
        it_items      TYPE zcl_alloc_cost=>ty_item_tt
        iv_required   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_cost=>ty_input.

    METHODS empty_items   FOR TESTING.
    METHODS single_source FOR TESTING.
    METHODS cheapest_first FOR TESTING.
    METHODS insufficient  FOR TESTING.
    METHODS exact_fill    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost( ).
  ENDMETHOD.

  METHOD item.
    rs_row-werks = iv_werks.
    rs_row-available = iv_available.
    rs_row-unit_cost = iv_cost.
  ENDMETHOD.

  METHOD input.
    rs_row-items = it_items.
    rs_row-required = iv_required.
  ENDMETHOD.

  METHOD empty_items.
    DATA lt_items TYPE zcl_alloc_cost=>ty_item_tt.

    DATA(rs_result) = mo_cut->select( input( it_items    = lt_items
                                             iv_required = '10' ) ).

    cl_abap_unit_assert=>assert_initial( act = rs_result-lines ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining exp = '10' ).
  ENDMETHOD.

  METHOD single_source.
    DATA lt_items TYPE zcl_alloc_cost=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_available = '20' iv_cost = '2' )
      TO lt_items.

    DATA(rs_result) = mo_cut->select( input( it_items    = lt_items
                                             iv_required = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-total_cost exp = '20' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining exp = '0' ).
  ENDMETHOD.

  METHOD cheapest_first.
    DATA lt_items TYPE zcl_alloc_cost=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_available = '20' iv_cost = '5' )
      TO lt_items.
    APPEND item( iv_werks = '2000' iv_available = '20' iv_cost = '1' )
      TO lt_items.

    DATA(rs_result) = mo_cut->select( input( it_items    = lt_items
                                             iv_required = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-werks
                                        exp = '2000' ).
  ENDMETHOD.

  METHOD insufficient.
    DATA lt_items TYPE zcl_alloc_cost=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_available = '4' iv_cost = '1' )
      TO lt_items.
    APPEND item( iv_werks = '2000' iv_available = '3' iv_cost = '2' )
      TO lt_items.

    DATA(rs_result) = mo_cut->select( input( it_items    = lt_items
                                             iv_required = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-total_cost exp = '10' ).
  ENDMETHOD.

  METHOD exact_fill.
    DATA lt_items TYPE zcl_alloc_cost=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_available = '10' iv_cost = '2' )
      TO lt_items.

    DATA(rs_result) = mo_cut->select( input( it_items    = lt_items
                                             iv_required = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-taken
                                        exp = '10' ).
  ENDMETHOD.

ENDCLASS.
