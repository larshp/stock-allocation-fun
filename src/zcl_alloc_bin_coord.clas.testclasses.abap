CLASS ltcl_alloc_bin_coord DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_coord.

    METHODS setup.

    METHODS same_aisle_yes  FOR TESTING.
    METHODS same_aisle_no   FOR TESTING.
    METHODS aisle_wins      FOR TESTING.
    METHODS rack_breaks_tie FOR TESTING.
    METHODS level_breaks    FOR TESTING.
    METHODS equal_coord     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_coord IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_coord( ).
  ENDMETHOD.

  METHOD same_aisle_yes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->same_aisle( is_a = VALUE #( aisle = 3 rack = 1 level = 1 )
                                is_b = VALUE #( aisle = 3 rack = 9 level = 9 ) )
      exp = abap_true ).
  ENDMETHOD.

  METHOD same_aisle_no.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->same_aisle( is_a = VALUE #( aisle = 3 )
                                is_b = VALUE #( aisle = 4 ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD aisle_wins.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( is_a = VALUE #( aisle = 1 rack = 9 level = 9 )
                             is_b = VALUE #( aisle = 2 rack = 1 level = 1 ) )
      exp = -1 ).
  ENDMETHOD.

  METHOD rack_breaks_tie.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( is_a = VALUE #( aisle = 2 rack = 3 level = 1 )
                             is_b = VALUE #( aisle = 2 rack = 1 level = 9 ) )
      exp = 1 ).
  ENDMETHOD.

  METHOD level_breaks.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( is_a = VALUE #( aisle = 2 rack = 3 level = 1 )
                             is_b = VALUE #( aisle = 2 rack = 3 level = 2 ) )
      exp = -1 ).
  ENDMETHOD.

  METHOD equal_coord.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( is_a = VALUE #( aisle = 2 rack = 3 level = 1 )
                             is_b = VALUE #( aisle = 2 rack = 3 level = 1 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
