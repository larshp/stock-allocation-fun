CLASS ltcl_alloc_return_aging DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_aging.
    DATA mt_age TYPE zcl_alloc_return_aging=>ty_ages_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_age TYPE i.

    METHODS buckets_days  FOR TESTING.
    METHODS groups_bands  FOR TESTING.
    METHODS counts_in     FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_aging IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_aging( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_age TO mt_age.
  ENDMETHOD.

  METHOD buckets_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 10 ) exp = '0-30' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 40 ) exp = '31-60' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 90 ) exp = '61-90' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 100 ) exp = '90+' ).
  ENDMETHOD.

  METHOD groups_bands.
    DATA lt_buckets TYPE zcl_alloc_return_aging=>ty_bucket_tt.

    add( 10 ).
    add( 40 ).
    add( 40 ).
    add( 100 ).

    lt_buckets = mo_cut->bucket_of( mt_age ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 1 ]-bucket exp = '0-30' ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 2 ]-bucket exp = '31-60' ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 2 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 3 ]-bucket exp = '90+' ).
  ENDMETHOD.

  METHOD counts_in.
    add( 10 ).
    add( 40 ).
    add( 40 ).
    add( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_ages = mt_age iv_bucket = '31-60' )
      exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_buckets TYPE zcl_alloc_return_aging=>ty_bucket_tt.

    lt_buckets = mo_cut->bucket_of( mt_age ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
