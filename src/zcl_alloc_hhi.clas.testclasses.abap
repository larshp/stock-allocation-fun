CLASS ltcl_alloc_hhi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hhi.
    DATA mt_itm TYPE zcl_alloc_pareto=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d.

    METHODS add_equal
      IMPORTING
        iv_count TYPE i
        iv_each  TYPE menge_d.

    METHODS empty_items  FOR TESTING.
    METHODS duopoly      FOR TESTING.
    METHODS monopoly     FOR TESTING.
    METHODS three_shares FOR TESTING.
    METHODS many_equal   FOR TESTING.
    METHODS bands        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hhi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hhi( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_pareto=>ty_item.

    ls_item-item_id = iv_id.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD add_equal.
    DATA lv_i TYPE i.

    WHILE lv_i < iv_count.
      lv_i = lv_i + 1.
      add( iv_id = 'X' iv_qty = iv_each ).
    ENDWHILE.
  ENDMETHOD.

  METHOD empty_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_itm ) exp = 0 ).
  ENDMETHOD.

  METHOD duopoly.
    add( iv_id = 'A' iv_qty = 50 ).
    add( iv_id = 'B' iv_qty = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_itm ) exp = 5000 ).
  ENDMETHOD.

  METHOD monopoly.
    add( iv_id = 'ONLY' iv_qty = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_itm ) exp = 10000 ).
  ENDMETHOD.

  METHOD three_shares.
    add( iv_id = 'A' iv_qty = 60 ).
    add( iv_id = 'B' iv_qty = 30 ).
    add( iv_id = 'C' iv_qty = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_itm ) exp = 4600 ).
  ENDMETHOD.

  METHOD many_equal.
    add_equal( iv_count = 5 iv_each = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_itm ) exp = 2000 ).
  ENDMETHOD.

  METHOD bands.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->band_of( 1000 ) exp = 'low' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_of( 1500 ) exp = 'moderate' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->band_of( 2499 ) exp = 'moderate' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->band_of( 2500 ) exp = 'high' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->band_of( 10000 ) exp = 'high' ).
  ENDMETHOD.

ENDCLASS.
