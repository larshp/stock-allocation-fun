CLASS ltcl_alloc_bin_distance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_distance.

    METHODS setup.

    METHODS manhattan_sums  FOR TESTING.
    METHODS manhattan_same  FOR TESTING.
    METHODS chebyshev_max   FOR TESTING.
    METHODS aisle_gap_abs   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_distance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_distance( ).
  ENDMETHOD.

  METHOD manhattan_sums.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->manhattan(
              is_a = VALUE #( aisle = 1 rack = 2 level = 3 )
              is_b = VALUE #( aisle = 4 rack = 6 level = 3 ) )
      exp = 7 ).
  ENDMETHOD.

  METHOD manhattan_same.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->manhattan(
              is_a = VALUE #( aisle = 2 rack = 2 level = 2 )
              is_b = VALUE #( aisle = 2 rack = 2 level = 2 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD chebyshev_max.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->chebyshev(
              is_a = VALUE #( aisle = 1 rack = 2 level = 3 )
              is_b = VALUE #( aisle = 4 rack = 6 level = 3 ) )
      exp = 4 ).
  ENDMETHOD.

  METHOD aisle_gap_abs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->aisle_gap(
              is_a = VALUE #( aisle = 9 )
              is_b = VALUE #( aisle = 4 ) )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
