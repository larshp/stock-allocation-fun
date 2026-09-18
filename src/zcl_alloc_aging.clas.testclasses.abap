CLASS ltcl_alloc_aging DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aging.

    METHODS setup.

    METHODS not_overdue     FOR TESTING.
    METHODS first_bucket    FOR TESTING.
    METHODS second_bucket   FOR TESTING.
    METHODS third_bucket    FOR TESTING.
    METHODS oldest_bucket   FOR TESTING.
    METHODS boundaries      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_aging IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aging( ).
  ENDMETHOD.

  METHOD not_overdue.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( -5 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 0 ) exp = 0 ).
  ENDMETHOD.

  METHOD first_bucket.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 1 ) exp = 1 ).
  ENDMETHOD.

  METHOD second_bucket.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 45 ) exp = 2 ).
  ENDMETHOD.

  METHOD third_bucket.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 61 ) exp = 3 ).
  ENDMETHOD.

  METHOD oldest_bucket.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 120 ) exp = 4 ).
  ENDMETHOD.

  METHOD boundaries.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 30 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 31 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 90 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( 91 ) exp = 4 ).
  ENDMETHOD.

ENDCLASS.
