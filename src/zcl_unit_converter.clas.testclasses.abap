CLASS lcl_unit_factor_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_factor_reader.
    DATA ms_result TYPE zif_unit_factor_reader=>ty_result.
    DATA mv_calls TYPE i.
    DATA mv_material TYPE zif_unit_converter=>ty_material.
    DATA mv_source_unit TYPE zif_unit_converter=>ty_unit.
ENDCLASS.

CLASS lcl_unit_factor_reader IMPLEMENTATION.
  METHOD zif_unit_factor_reader~read.
    mv_calls = mv_calls + 1.
    mv_material = iv_material.
    mv_source_unit = iv_source_unit.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_unit_converter DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_unit_factor_reader.
    DATA mo_cut TYPE REF TO zcl_unit_converter.

    METHODS setup.
    METHODS bypasses_matching_base_unit FOR TESTING.
    METHODS applies_material_factor FOR TESTING.
    METHODS rounds_to_stock_precision FOR TESTING.
    METHODS rejects_rounded_zero FOR TESTING.
    METHODS rejects_missing_factor FOR TESTING.
    METHODS rejects_invalid_found_flag FOR TESTING.
    METHODS rejects_zero_denominator FOR TESTING.
    METHODS rejects_missing_identity FOR TESTING.
    METHODS rejects_excessive_source FOR TESTING.
    METHODS rejects_imprecise_source FOR TESTING.
    METHODS rejects_fractional_factor FOR TESTING.
    METHODS rejects_oversized_factor FOR TESTING.
    METHODS rejects_not_found_payload FOR TESTING.
    METHODS rejects_oversized_result FOR TESTING.
    METHODS requires_reader_for_alt_unit FOR TESTING.
    METHODS bypasses_missing_reader FOR TESTING.
ENDCLASS.

CLASS ltcl_unit_converter IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_cut = NEW #( mo_reader ).
  ENDMETHOD.

  METHOD bypasses_matching_base_unit.
    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 3
      iv_source_unit = 'EA'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-quantity
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD applies_material_factor.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 10
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 2
      iv_source_unit = 'BOX'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-quantity
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_source_unit
      exp = 'BOX' ).
  ENDMETHOD.

  METHOD rounds_to_stock_precision.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 1
      denominator = 3 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-quantity
      exp = CONV decfloat34( '0.333' ) ).
  ENDMETHOD.

  METHOD rejects_rounded_zero.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 1
      denominator = 10000 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Converted base quantity is not positive' ).
  ENDMETHOD.

  METHOD rejects_missing_factor.
    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'BOX'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'No material-specific unit conversion is maintained' ).
  ENDMETHOD.

  METHOD rejects_invalid_found_flag.
    mo_reader->ms_result = VALUE #(
      is_found    = 'Y'
      numerator   = 10
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'BOX'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion lookup returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_zero_denominator.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 1
      denominator = 0 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'BOX'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion factor is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_identity.
    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = ''
      iv_quantity    = 1
      iv_source_unit = 'EA'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion input is invalid' ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mv_calls ).
  ENDMETHOD.

  METHOD rejects_excessive_source.
    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '10000000000'
      iv_source_unit = 'EA'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion input is invalid' ).
  ENDMETHOD.

  METHOD rejects_imprecise_source.
    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '1.0001'
      iv_source_unit = 'EA'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion input is invalid' ).
  ENDMETHOD.

  METHOD rejects_fractional_factor.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = '1.5'
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion factor is invalid' ).
  ENDMETHOD.

  METHOD rejects_oversized_factor.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 100000
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion factor is invalid' ).
  ENDMETHOD.

  METHOD rejects_not_found_payload.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_false
      numerator   = 10
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion lookup returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_oversized_result.
    mo_reader->ms_result = VALUE #(
      is_found    = abap_true
      numerator   = 2
      denominator = 1 ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '9999999999.999'
      iv_source_unit = 'ALT'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Converted base quantity exceeds supported precision' ).
  ENDMETHOD.

  METHOD requires_reader_for_alt_unit.
    DATA lo_reader TYPE REF TO zif_unit_factor_reader.
    mo_cut = NEW #( lo_reader ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'BOX'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Unit conversion factor reader is required' ).
  ENDMETHOD.

  METHOD bypasses_missing_reader.
    DATA lo_reader TYPE REF TO zif_unit_factor_reader.
    mo_cut = NEW #( lo_reader ).

    DATA(ls_result) = mo_cut->zif_unit_converter~to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = 1
      iv_source_unit = 'EA'
      iv_base_unit   = 'EA' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-quantity
      exp = 1 ).
  ENDMETHOD.
ENDCLASS.
