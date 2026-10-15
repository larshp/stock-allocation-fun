CLASS ltcl_alloc_weight_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_weight_total.

    METHODS setup.

    METHODS sums_weighted FOR TESTING.
    METHODS skips_zero    FOR TESTING.
    METHODS empty_parts   FOR TESTING.
    METHODS gross_with_ta FOR TESTING.
    METHODS gross_no_parts FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_weight_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_weight_total( ).
  ENDMETHOD.

  METHOD sums_weighted.
    DATA lt_parts TYPE zcl_alloc_weight_total=>ty_part_tt.

    APPEND VALUE #( weight = 2 quantity = 3 ) TO lt_parts.
    APPEND VALUE #( weight = 5 quantity = 2 ) TO lt_parts.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( it_parts = lt_parts ) exp = 16 ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_parts TYPE zcl_alloc_weight_total=>ty_part_tt.

    APPEND VALUE #( weight = 2 quantity = 0 ) TO lt_parts.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( it_parts = lt_parts ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_parts.
    DATA lt_parts TYPE zcl_alloc_weight_total=>ty_part_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( it_parts = lt_parts ) exp = 0 ).
  ENDMETHOD.

  METHOD gross_with_ta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gross( iv_net = 100 iv_tare = 2 iv_parts = 5 )
      exp = 110 ).
  ENDMETHOD.

  METHOD gross_no_parts.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gross( iv_net = 100 iv_tare = 2 iv_parts = 0 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
