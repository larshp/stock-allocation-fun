CLASS ltcl_alloc_trailer_count DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trailer_count.

    METHODS setup.

    METHODS exact_fill       FOR TESTING.
    METHODS partial_fill     FOR TESTING.
    METHODS full_count       FOR TESTING.
    METHODS last_partial     FOR TESTING.
    METHODS last_exact       FOR TESTING.
    METHODS zero_pallets     FOR TESTING.
    METHODS zero_per_trailer FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_trailer_count IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trailer_count( ).
  ENDMETHOD.

  METHOD exact_fill.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trailers( iv_pallets = 60 iv_per_trailer = 30 )
      exp = 2 ).
  ENDMETHOD.

  METHOD partial_fill.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trailers( iv_pallets = 61 iv_per_trailer = 30 )
      exp = 3 ).
  ENDMETHOD.

  METHOD full_count.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->full_trailers( iv_pallets = 61 iv_per_trailer = 30 )
      exp = 2 ).
  ENDMETHOD.

  METHOD last_partial.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->last_trailer( iv_pallets = 61 iv_per_trailer = 30 )
      exp = 1 ).
  ENDMETHOD.

  METHOD last_exact.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->last_trailer( iv_pallets = 60 iv_per_trailer = 30 )
      exp = 30 ).
  ENDMETHOD.

  METHOD zero_pallets.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trailers( iv_pallets = 0 iv_per_trailer = 30 )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_per_trailer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trailers( iv_pallets = 10 iv_per_trailer = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
