CLASS ltcl_alloc_cap_convert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cap_convert.
    DATA mt_fac TYPE zcl_alloc_cap_convert=>ty_factor_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_uom    TYPE string
        iv_factor TYPE i.

    METHODS factor_found   FOR TESTING.
    METHODS factor_default FOR TESTING.
    METHODS factor_missing FOR TESTING.
    METHODS to_base_mul    FOR TESTING.
    METHODS to_uom_div     FOR TESTING.
    METHODS to_uom_rounds  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cap_convert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cap_convert( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_fac TYPE zcl_alloc_cap_convert=>ty_factor.

    ls_fac-uom = iv_uom.
    ls_fac-factor = iv_factor.
    APPEND ls_fac TO mt_fac.
  ENDMETHOD.

  METHOD factor_found.
    add( iv_uom = 'CAR' iv_factor = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor_for( iv_uom = 'CAR' it_factors = mt_fac )
      exp = 12 ).
  ENDMETHOD.

  METHOD factor_default.
    add( iv_uom = 'PLT' iv_factor = 60 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor_for( iv_uom = 'PCE' it_factors = mt_fac )
      exp = 1 ).
  ENDMETHOD.

  METHOD factor_missing.
    add( iv_uom = 'BAD' iv_factor = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor_for( iv_uom = 'BAD' it_factors = mt_fac )
      exp = 1 ).
  ENDMETHOD.

  METHOD to_base_mul.
    add( iv_uom = 'CAR' iv_factor = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base( iv_quantity = 5 iv_uom = 'CAR'
                             it_factors = mt_fac )
      exp = 60 ).
  ENDMETHOD.

  METHOD to_uom_div.
    add( iv_uom = 'CAR' iv_factor = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_uom( iv_base = 60 iv_uom = 'CAR'
                            it_factors = mt_fac )
      exp = 5 ).
  ENDMETHOD.

  METHOD to_uom_rounds.
    add( iv_uom = 'CAR' iv_factor = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_uom( iv_base = 70 iv_uom = 'CAR'
                            it_factors = mt_fac )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
