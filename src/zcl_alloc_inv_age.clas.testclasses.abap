CLASS ltcl_alloc_inv_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_inv_age.

    METHODS setup.

    METHODS lists_buckets FOR TESTING.
    METHODS picks_bucket  FOR TESTING.
    METHODS aged_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_inv_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_inv_age( ).
  ENDMETHOD.

  METHOD lists_buckets.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->buckets( ) ) exp = 4 ).
  ENDMETHOD.

  METHOD picks_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( 10 ) exp = 'FRESH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( 60 ) exp = 'RECENT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( 120 ) exp = 'AGING' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( 400 ) exp = 'OBSOLETE' ).
  ENDMETHOD.

  METHOD aged_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_aged( iv_age_days = 120 iv_threshold = 90 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_aged( iv_age_days = 60 iv_threshold = 90 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
