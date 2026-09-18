CLASS ltcl_alloc_volume DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_volume.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_rows         TYPE i
        iv_fields       TYPE i
        iv_bytes        TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_volume=>ty_input.

    METHODS empty_input_zero  FOR TESTING.
    METHODS computes_totals   FOR TESTING.
    METHODS kb_and_mb_rounded FOR TESTING.
    METHODS package_from_target FOR TESTING.
    METHODS package_capped    FOR TESTING.
    METHODS zero_target_all   FOR TESTING.
    METHODS zero_bytes_all    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_volume IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_volume( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-row_count = iv_rows.
    rs_input-field_count = iv_fields.
    rs_input-bytes_per_field = iv_bytes.
  ENDMETHOD.

  METHOD empty_input_zero.
    DATA(ls_input) = make_input( iv_rows = 0 iv_fields = 10 iv_bytes = 4 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_bytes exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 0 ).
  ENDMETHOD.

  METHOD computes_totals.
    DATA(ls_input) = make_input( iv_rows = 1000 iv_fields = 10 iv_bytes = 4 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_bytes exp = 40000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_kb exp = 39 ).
    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_mb exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 1000 ).
  ENDMETHOD.

  METHOD kb_and_mb_rounded.
    DATA(ls_input) = make_input( iv_rows = 1000 iv_fields = 1 iv_bytes = 1024 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_bytes exp = 1024000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_kb exp = 1000 ).
  ENDMETHOD.

  METHOD package_from_target.
    DATA(ls_input) = make_input( iv_rows = 100000 iv_fields = 10 iv_bytes = 4 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 26214 ).
  ENDMETHOD.

  METHOD package_capped.
    DATA(ls_input) = make_input( iv_rows = 100 iv_fields = 10 iv_bytes = 4 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 100 ).
  ENDMETHOD.

  METHOD zero_target_all.
    DATA(ls_input) = make_input( iv_rows = 50 iv_fields = 2 iv_bytes = 8 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 50 ).
  ENDMETHOD.

  METHOD zero_bytes_all.
    DATA(ls_input) = make_input( iv_rows = 50 iv_fields = 0 iv_bytes = 0 ).
    DATA(ls_estimate) = mo_cut->estimate( is_input     = ls_input
                                          iv_target_mb = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_estimate-total_bytes exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_estimate-records_per_package exp = 50 ).
  ENDMETHOD.

ENDCLASS.
