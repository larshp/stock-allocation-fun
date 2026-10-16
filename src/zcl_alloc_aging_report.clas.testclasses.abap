CLASS ltcl_alloc_aging_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aging_report.
    DATA mt_item TYPE zcl_alloc_aging_report=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_age_days TYPE i
        iv_value    TYPE i.

    METHODS builds_report FOR TESTING.
    METHODS counts_bucket FOR TESTING.
    METHODS sums_value    FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_aging_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aging_report( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_aging_report=>ty_item.

    ls_item-material = iv_material.
    ls_item-age_days = iv_age_days.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD builds_report.
    DATA lt_buckets TYPE zcl_alloc_aging_report=>ty_bucket_tt.

    add( iv_material = 'M1' iv_age_days = 10 iv_value = 100 ).
    add( iv_material = 'M2' iv_age_days = 60 iv_value = 50 ).
    add( iv_material = 'M3' iv_age_days = 400 iv_value = 30 ).

    lt_buckets = mo_cut->build( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-bucket exp = 'FRESH' ).
    cl_abap_unit_assert=>assert_equals( act = lt_buckets[ 1 ]-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 1 ]-total_value exp = 100 ).
  ENDMETHOD.

  METHOD counts_bucket.
    add( iv_material = 'M1' iv_age_days = 10 iv_value = 100 ).
    add( iv_material = 'M2' iv_age_days = 60 iv_value = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in_bucket( it_items = mt_item iv_bucket = 'FRESH' )
      exp = 1 ).
  ENDMETHOD.

  METHOD sums_value.
    add( iv_material = 'M1' iv_age_days = 10 iv_value = 100 ).
    add( iv_material = 'M2' iv_age_days = 60 iv_value = 50 ).
    add( iv_material = 'M3' iv_age_days = 400 iv_value = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_item ) exp = 180 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->build( mt_item ) ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
