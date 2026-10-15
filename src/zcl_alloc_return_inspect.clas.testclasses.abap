CLASS ltcl_alloc_return_inspect DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_inspect.

    METHODS setup.

    METHODS result
      IMPORTING
        iv_material      TYPE matnr
        iv_result        TYPE string
      RETURNING
        VALUE(rs_result) TYPE zcl_alloc_return_inspect=>ty_result.

    METHODS records_result  FOR TESTING.
    METHODS last_wins       FOR TESTING.
    METHODS unknown_missing FOR TESTING.
    METHODS finds_gaps      FOR TESTING.
    METHODS clears          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_inspect IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_inspect( ).
  ENDMETHOD.

  METHOD result.
    rs_result-material = iv_material.
    rs_result-result = iv_result.
  ENDMETHOD.

  METHOD records_result.
    DATA ls_result TYPE zcl_alloc_return_inspect=>ty_result.

    ls_result = result( iv_material = 'M1' iv_result = 'OK' ).
    mo_cut->record( ls_result ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->result_of( 'M1' ) exp = 'OK' ).
  ENDMETHOD.

  METHOD last_wins.
    DATA ls_result TYPE zcl_alloc_return_inspect=>ty_result.

    ls_result = result( iv_material = 'M1' iv_result = 'OK' ).
    mo_cut->record( ls_result ).
    ls_result = result( iv_material = 'M1' iv_result = 'DAMAGED' ).
    mo_cut->record( ls_result ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->result_of( 'M1' ) exp = 'DAMAGED' ).
  ENDMETHOD.

  METHOD unknown_missing.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->result_of( 'M1' ) exp = '' ).
  ENDMETHOD.

  METHOD finds_gaps.
    DATA lt_expected TYPE zcl_alloc_return_inspect=>ty_result_tt.
    DATA lt_missing  TYPE zcl_alloc_return_inspect=>ty_result_tt.
    DATA ls_result   TYPE zcl_alloc_return_inspect=>ty_result.

    ls_result = result( iv_material = 'M1' iv_result = 'OK' ).
    mo_cut->record( ls_result ).

    ls_result = result( iv_material = 'M1' iv_result = 'OK' ).
    APPEND ls_result TO lt_expected.
    ls_result = result( iv_material = 'M2' iv_result = '' ).
    APPEND ls_result TO lt_expected.
    ls_result = result( iv_material = 'M3' iv_result = '' ).
    APPEND ls_result TO lt_expected.

    lt_missing = mo_cut->missing( lt_expected ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_missing[ 1 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD clears.
    DATA ls_result TYPE zcl_alloc_return_inspect=>ty_result.

    ls_result = result( iv_material = 'M1' iv_result = 'OK' ).
    mo_cut->record( ls_result ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->result_of( 'M1' ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
