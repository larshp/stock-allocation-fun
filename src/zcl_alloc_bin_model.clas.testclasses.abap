CLASS ltcl_alloc_bin_model DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_model.

    METHODS setup.

    METHODS free_space_reads FOR TESTING.
    METHODS free_space_floor FOR TESTING.
    METHODS free_space_zero  FOR TESTING.
    METHODS full_when_used   FOR TESTING.
    METHODS not_full         FOR TESTING.
    METHODS can_hold_fits    FOR TESTING.
    METHODS cannot_hold      FOR TESTING.
    METHODS add_stock_fits   FOR TESTING.
    METHODS add_stock_clamps FOR TESTING.
    METHODS add_stock_zero   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_model IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_model( ).
  ENDMETHOD.

  METHOD free_space_reads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->free_space( is_bin = VALUE #( capacity = 100 used = 40 ) )
      exp = 60 ).
  ENDMETHOD.

  METHOD free_space_floor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->free_space( is_bin = VALUE #( capacity = 100 used = 140 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD free_space_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->free_space( is_bin = VALUE #( capacity = 0 used = 0 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD full_when_used.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( is_bin = VALUE #( capacity = 100 used = 100 ) )
      exp = abap_true ).
  ENDMETHOD.

  METHOD not_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( is_bin = VALUE #( capacity = 100 used = 40 ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD can_hold_fits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_hold( is_bin = VALUE #( capacity = 100 used = 40 )
                              iv_qty = 60 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD cannot_hold.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_hold( is_bin = VALUE #( capacity = 100 used = 40 )
                              iv_qty = 61 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD add_stock_fits.
    DATA ls_bin TYPE zcl_alloc_bin_model=>ty_bin.

    ls_bin = mo_cut->add_stock( is_bin = VALUE #( capacity = 100 used = 40 )
                                iv_qty = 30 ).

    cl_abap_unit_assert=>assert_equals( act = ls_bin-used exp = 70 ).
  ENDMETHOD.

  METHOD add_stock_clamps.
    DATA ls_bin TYPE zcl_alloc_bin_model=>ty_bin.

    ls_bin = mo_cut->add_stock( is_bin = VALUE #( capacity = 100 used = 40 )
                                iv_qty = 90 ).

    cl_abap_unit_assert=>assert_equals( act = ls_bin-used exp = 100 ).
  ENDMETHOD.

  METHOD add_stock_zero.
    DATA ls_bin TYPE zcl_alloc_bin_model=>ty_bin.

    ls_bin = mo_cut->add_stock( is_bin = VALUE #( capacity = 100 used = 40 )
                                iv_qty = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_bin-used exp = 40 ).
  ENDMETHOD.

ENDCLASS.
