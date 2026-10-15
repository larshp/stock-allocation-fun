CLASS ltcl_alloc_prov_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_age.
    DATA mt_bucket TYPE zcl_alloc_prov_age=>ty_bucket_tt.
    DATA mt_value TYPE zcl_alloc_prov_age=>ty_values_tt.

    METHODS setup.

    METHODS add_bucket
      IMPORTING
        iv_age_from TYPE i
        iv_percent  TYPE i.

    METHODS pick_bucket     FOR TESTING.
    METHODS computes_provision FOR TESTING.
    METHODS sums_values     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_age( ).

    add_bucket( iv_age_from = 0 iv_percent = 0 ).
    add_bucket( iv_age_from = 90 iv_percent = 25 ).
    add_bucket( iv_age_from = 180 iv_percent = 50 ).
  ENDMETHOD.

  METHOD add_bucket.
    DATA ls_bucket TYPE zcl_alloc_prov_age=>ty_bucket.

    ls_bucket-age_from = iv_age_from.
    ls_bucket-percent = iv_percent.
    APPEND ls_bucket TO mt_bucket.
  ENDMETHOD.

  METHOD pick_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent_of( it_buckets = mt_bucket iv_age_days = 100 )
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent_of( it_buckets = mt_bucket iv_age_days = 30 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent_of( it_buckets = mt_bucket iv_age_days = 200 )
      exp = 50 ).
  ENDMETHOD.

  METHOD computes_provision.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->provision( it_buckets = mt_bucket iv_value = 1000
                               iv_age_days = 100 )
      exp = 250 ).
  ENDMETHOD.

  METHOD sums_values.
    APPEND 250 TO mt_value.
    APPEND 500 TO mt_value.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_value ) exp = 750 ).
  ENDMETHOD.

ENDCLASS.
