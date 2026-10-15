CLASS ltcl_alloc_demand_bucket DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_demand_bucket.
    DATA mt_per TYPE zcl_alloc_demand_bucket=>ty_period_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_period TYPE i
        iv_value  TYPE i.

    METHODS groups_periods FOR TESTING.
    METHODS sums_period    FOR TESTING.
    METHODS counts_period  FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_demand_bucket IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_demand_bucket( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_period TYPE zcl_alloc_demand_bucket=>ty_period.

    ls_period-period = iv_period.
    ls_period-value = iv_value.
    APPEND ls_period TO mt_per.
  ENDMETHOD.

  METHOD groups_periods.
    DATA lt_buckets TYPE zcl_alloc_demand_bucket=>ty_bucket_tt.

    add( iv_period = 2 iv_value = 20 ).
    add( iv_period = 1 iv_value = 10 ).
    add( iv_period = 1 iv_value = 5 ).

    lt_buckets = mo_cut->bucket_of( mt_per ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-bucket exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-total exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 2 ]-total exp = 20 ).
  ENDMETHOD.

  METHOD sums_period.
    add( iv_period = 1 iv_value = 10 ).
    add( iv_period = 1 iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_in( it_periods = mt_per iv_period = 1 )
      exp = 15 ).
  ENDMETHOD.

  METHOD counts_period.
    add( iv_period = 1 iv_value = 10 ).
    add( iv_period = 1 iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_periods = mt_per iv_period = 1 )
      exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_buckets TYPE zcl_alloc_demand_bucket=>ty_bucket_tt.

    lt_buckets = mo_cut->bucket_of( mt_per ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
