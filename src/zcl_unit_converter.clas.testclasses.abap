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
    METHODS rejects_missing_factor FOR TESTING.
    METHODS rejects_zero_denominator FOR TESTING.
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
  ENDMETHOD.
ENDCLASS.
