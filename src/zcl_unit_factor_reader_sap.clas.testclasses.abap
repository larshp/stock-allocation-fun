CLASS ltcl_unit_factor_reader_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_unit_factor_reader_sap.

    METHODS setup.
    METHODS rejects_missing_material FOR TESTING.
    METHODS rejects_missing_unit FOR TESTING.
ENDCLASS.

CLASS ltcl_unit_factor_reader_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD rejects_missing_material.
    DATA(ls_result) = mo_cut->zif_unit_factor_reader~read(
      iv_material    = ''
      iv_source_unit = 'BOX' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_found ).
    cl_abap_unit_assert=>assert_initial( ls_result-numerator ).
    cl_abap_unit_assert=>assert_initial( ls_result-denominator ).
  ENDMETHOD.

  METHOD rejects_missing_unit.
    DATA(ls_result) = mo_cut->zif_unit_factor_reader~read(
      iv_material    = 'MAT-1'
      iv_source_unit = '' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_found ).
    cl_abap_unit_assert=>assert_initial( ls_result-numerator ).
    cl_abap_unit_assert=>assert_initial( ls_result-denominator ).
  ENDMETHOD.
ENDCLASS.
