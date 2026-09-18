CLASS ltcl_alloc_deeplink DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_deeplink.
    DATA mt_prm TYPE zcl_alloc_query=>ty_param_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS base_without_params FOR TESTING.
    METHODS base_with_param     FOR TESTING.
    METHODS base_with_two       FOR TESTING.
    METHODS absolute_detected   FOR TESTING.
    METHODS relative_detected   FOR TESTING.
    METHODS short_link          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_deeplink IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_deeplink( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_param TYPE zcl_alloc_query=>ty_param.

    ls_param-name = iv_name.
    ls_param-value = iv_value.
    APPEND ls_param TO mt_prm.
  ENDMETHOD.

  METHOD base_without_params.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_base = '/sap/bc/alloc' it_params = mt_prm )
      exp = '/sap/bc/alloc' ).
  ENDMETHOD.

  METHOD base_with_param.
    add( iv_name = 'q' iv_value = 'box' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_base = '/sap/bc/alloc' it_params = mt_prm )
      exp = '/sap/bc/alloc?q=box' ).
  ENDMETHOD.

  METHOD base_with_two.
    add( iv_name = 'a' iv_value = '1' ).
    add( iv_name = 'b' iv_value = '2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_base = '/x' it_params = mt_prm )
      exp = '/x?a=1&b=2' ).
  ENDMETHOD.

  METHOD absolute_detected.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_absolute( 'http://host/x' ) exp = abap_true ).
  ENDMETHOD.

  METHOD relative_detected.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_absolute( '/sap/bc/alloc' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_absolute( 'ftp://host' ) exp = abap_false ).
  ENDMETHOD.

  METHOD short_link.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_absolute( '' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_absolute( 'htt' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
