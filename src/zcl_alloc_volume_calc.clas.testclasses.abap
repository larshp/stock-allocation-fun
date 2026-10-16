CLASS ltcl_alloc_volume_calc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_volume_calc.

    METHODS setup.

    METHODS volume_of_box   FOR TESTING.
    METHODS volume_zero_dim FOR TESTING.
    METHODS total_over_items FOR TESTING.
    METHODS skips_zero_qty  FOR TESTING.
    METHODS empty_items     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_volume_calc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_volume_calc( ).
  ENDMETHOD.

  METHOD volume_of_box.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->volume_of( is_dim = VALUE #( len = 2 wid = 3 hgt = 4 ) )
      exp = 24 ).
  ENDMETHOD.

  METHOD volume_zero_dim.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->volume_of( is_dim = VALUE #( len = 0 wid = 3 hgt = 4 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD total_over_items.
    DATA lt_items TYPE zcl_alloc_volume_calc=>ty_item_tt.

    APPEND VALUE #( dim      = VALUE #( len = 2 wid = 3 hgt = 4 )
                    quantity = 2 ) TO lt_items.
    APPEND VALUE #( dim      = VALUE #( len = 1 wid = 1 hgt = 10 )
                    quantity = 1 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_volume( it_items = lt_items ) exp = 58 ).
  ENDMETHOD.

  METHOD skips_zero_qty.
    DATA lt_items TYPE zcl_alloc_volume_calc=>ty_item_tt.

    APPEND VALUE #( dim      = VALUE #( len = 2 wid = 3 hgt = 4 )
                    quantity = 0 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_volume( it_items = lt_items ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_items.
    DATA lt_items TYPE zcl_alloc_volume_calc=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_volume( it_items = lt_items ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
