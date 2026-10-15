CLASS ltcl_alloc_remove_largest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_remove_largest.
    DATA mt_stk TYPE zcl_alloc_remove_largest=>ty_stock_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin TYPE string
        iv_qty TYPE menge_d.

    METHODS picks_largest FOR TESTING.
    METHODS skips_empty   FOR TESTING.
    METHODS none_in_stock FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_remove_largest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_remove_largest( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stock TYPE zcl_alloc_remove_largest=>ty_stock.

    ls_stock-bin_id = iv_bin.
    ls_stock-quantity = iv_qty.
    APPEND ls_stock TO mt_stk.
  ENDMETHOD.

  METHOD picks_largest.
    add( iv_bin = 'A-01' iv_qty = 10 ).
    add( iv_bin = 'A-02' iv_qty = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( it_stock = mt_stk ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD skips_empty.
    add( iv_bin = 'A-01' iv_qty = 0 ).
    add( iv_bin = 'A-02' iv_qty = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( it_stock = mt_stk ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD none_in_stock.
    add( iv_bin = 'A-01' iv_qty = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( it_stock = mt_stk ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
