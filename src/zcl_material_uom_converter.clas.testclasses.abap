CLASS lcl_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_material_data
      IMPORTING
        iv_base_unit TYPE mara-meins.
    METHODS set_alt_unit_ratio
      IMPORTING
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
    DATA mv_alternative_unit TYPE marm-meinh.
ENDCLASS.

CLASS lcl_uom_repo_double IMPLEMENTATION.
  METHOD set_material_data.
    mv_base_unit = iv_base_unit.
  ENDMETHOD.

  METHOD set_alt_unit_ratio.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_material_uom_converter DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_uom_repo_double.
    DATA mo_cut TYPE REF TO zif_material_uom_converter.
    METHODS setup.
    METHODS converts_alternative_unit FOR TESTING.
    METHODS keeps_base_unit_quantity FOR TESTING.
    METHODS rejects_missing_factor FOR TESTING.
    METHODS converts_from_material_ratio FOR TESTING.
    METHODS rejects_unknown_material_unit FOR TESTING.
    METHODS keeps_material_base_unit FOR TESTING.
    METHODS returns_material_unit_ratio FOR TESTING.
    METHODS converts_to_alternative_unit FOR TESTING.
    METHODS rejects_unknown_target_unit FOR TESTING.
ENDCLASS.

CLASS ltcl_material_uom_converter IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_uom_repo_double( ).
    mo_cut = NEW zcl_material_uom_converter(
      io_repository = mo_repository ).
  ENDMETHOD.

  METHOD converts_alternative_unit.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '2.000'
      iv_source_unit = 'BOX'
      iv_numerator   = 12
      iv_denominator = 1 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.

  METHOD keeps_base_unit_quantity.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '1.250'
      iv_source_unit = 'EA'
      iv_numerator   = 0
      iv_denominator = 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.250' )
      act = ls_result-base_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_factor.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_to_base(
      iv_material    = 'MAT-1'
      iv_quantity    = '2.000'
      iv_source_unit = 'BOX'
      iv_numerator   = 12
      iv_denominator = 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.

  METHOD converts_from_material_ratio.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).
    mo_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 3
      iv_denominator      = 2 ).

    DATA(ls_result) = mo_cut->convert_material_unit(
      iv_material    = 'MAT-1'
      iv_quantity    = '2.000'
      iv_source_unit = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.

  METHOD rejects_unknown_material_unit.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_material_unit(
      iv_material    = 'MAT-1'
      iv_quantity    = '2.000'
      iv_source_unit = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.

  METHOD keeps_material_base_unit.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_material_unit(
      iv_material    = 'MAT-1'
      iv_quantity    = '1.250'
      iv_source_unit = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.250' )
      act = ls_result-base_quantity ).
  ENDMETHOD.

  METHOD returns_material_unit_ratio.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).
    mo_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 3
      iv_denominator      = 2 ).

    DATA(ls_ratio) = mo_cut->get_material_unit_ratio(
      iv_material         = 'MAT-1'
      iv_alternative_unit = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_ratio-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_ratio-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_ratio-numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_ratio-denominator ).
  ENDMETHOD.

  METHOD converts_to_alternative_unit.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).
    mo_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 3
      iv_denominator      = 2 ).

    DATA(ls_result) = mo_cut->convert_from_base(
      iv_material      = 'MAT-1'
      iv_base_quantity = '3.000'
      iv_target_unit   = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-alternative_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-alternative_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.

  METHOD rejects_unknown_target_unit.
    mo_repository->set_material_data(
      iv_base_unit = 'EA' ).

    DATA(ls_result) = mo_cut->convert_from_base(
      iv_material      = 'MAT-1'
      iv_base_quantity = '12.000'
      iv_target_unit   = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
  ENDMETHOD.
ENDCLASS.
