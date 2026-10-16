CLASS ltcl_alloc_pack_pattern DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pack_pattern.

    METHODS setup.

    METHODS exact_fit      FOR TESTING.
    METHODS partial_carton FOR TESTING.
    METHODS zero_quantity  FOR TESTING.
    METHODS zero_per_box   FOR TESTING.
    METHODS remainder_read FOR TESTING.
    METHODS full_read      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pack_pattern IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pack_pattern( ).
  ENDMETHOD.

  METHOD exact_fit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons( iv_quantity = 12 iv_per_carton = 4 )
      exp = 3 ).
  ENDMETHOD.

  METHOD partial_carton.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons( iv_quantity = 13 iv_per_carton = 4 )
      exp = 4 ).
  ENDMETHOD.

  METHOD zero_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons( iv_quantity = 0 iv_per_carton = 4 )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_per_box.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons( iv_quantity = 13 iv_per_carton = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD remainder_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remainder( iv_quantity = 13 iv_per_carton = 4 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remainder( iv_quantity = 12 iv_per_carton = 4 )
      exp = 0 ).
  ENDMETHOD.

  METHOD full_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->full_cartons( iv_quantity = 13 iv_per_carton = 4 )
      exp = 3 ).
  ENDMETHOD.

ENDCLASS.
