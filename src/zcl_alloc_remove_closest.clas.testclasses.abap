CLASS ltcl_alloc_remove_closest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_remove_closest.
    DATA mt_stk TYPE zcl_alloc_remove_closest=>ty_stock_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_qty  TYPE menge_d
        iv_dist TYPE i.

    METHODS picks_closest FOR TESTING.
    METHODS skips_empty   FOR TESTING.
    METHODS none_in_stock FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_remove_closest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_remove_closest( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stock TYPE zcl_alloc_remove_closest=>ty_stock.

    ls_stock-bin_id = iv_bin.
    ls_stock-quantity = iv_qty.
    ls_stock-distance = iv_dist.
    APPEND ls_stock TO mt_stk.
  ENDMETHOD.

  METHOD picks_closest.
    add( iv_bin = 'A-01' iv_qty = 10 iv_dist = 50 ).
    add( iv_bin = 'A-02' iv_qty = 10 iv_dist = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closest( it_stock = mt_stk ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD skips_empty.
    add( iv_bin = 'A-01' iv_qty = 0 iv_dist = 5 ).
    add( iv_bin = 'A-02' iv_qty = 10 iv_dist = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closest( it_stock = mt_stk ) exp = 'A-02' ).
  ENDMETHOD.

  METHOD none_in_stock.
    add( iv_bin = 'A-01' iv_qty = 0 iv_dist = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closest( it_stock = mt_stk ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
