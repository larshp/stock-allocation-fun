CLASS ltcl_alloc_remove_smallest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_remove_smallest.
    DATA mt_stk TYPE zcl_alloc_remove_smallest=>ty_stock_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin TYPE string
        iv_qty TYPE menge_d.

    METHODS picks_tightest  FOR TESTING.
    METHODS skips_too_small FOR TESTING.
    METHODS nothing_enough  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_remove_smallest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_remove_smallest( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stock TYPE zcl_alloc_remove_smallest=>ty_stock.

    ls_stock-bin_id = iv_bin.
    ls_stock-quantity = iv_qty.
    APPEND ls_stock TO mt_stk.
  ENDMETHOD.

  METHOD picks_tightest.
    add( iv_bin = 'A-01' iv_qty = 50 ).
    add( iv_bin = 'A-02' iv_qty = 20 ).
    add( iv_bin = 'A-03' iv_qty = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->smallest_sufficient( it_stock    = mt_stk
                                         iv_required = 15 )
      exp = 'A-02' ).
  ENDMETHOD.

  METHOD skips_too_small.
    add( iv_bin = 'A-01' iv_qty = 10 ).
    add( iv_bin = 'A-02' iv_qty = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->smallest_sufficient( it_stock    = mt_stk
                                         iv_required = 15 )
      exp = 'A-02' ).
  ENDMETHOD.

  METHOD nothing_enough.
    add( iv_bin = 'A-01' iv_qty = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->smallest_sufficient( it_stock    = mt_stk
                                         iv_required = 15 )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
