CLASS ltcl_alloc_query DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_query.
    DATA mt_prm TYPE zcl_alloc_query=>ty_param_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS empty_params   FOR TESTING.
    METHODS single_param   FOR TESTING.
    METHODS two_params     FOR TESTING.
    METHODS keeps_plain    FOR TESTING.
    METHODS encodes_space  FOR TESTING.
    METHODS encodes_amp    FOR TESTING.
    METHODS encodes_in_build FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_query IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_query( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_param TYPE zcl_alloc_query=>ty_param.

    ls_param-name = iv_name.
    ls_param-value = iv_value.
    APPEND ls_param TO mt_prm.
  ENDMETHOD.

  METHOD empty_params.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_prm ) exp = '' ).
  ENDMETHOD.

  METHOD single_param.
    add( iv_name = 'q' iv_value = 'box' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_prm ) exp = 'q=box' ).
  ENDMETHOD.

  METHOD two_params.
    add( iv_name = 'a' iv_value = '1' ).
    add( iv_name = 'b' iv_value = '2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_prm ) exp = 'a=1&b=2' ).
  ENDMETHOD.

  METHOD keeps_plain.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->encode( 'PLANT_1000' ) exp = 'PLANT_1000' ).
  ENDMETHOD.

  METHOD encodes_space.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->encode( 'a b' ) exp = 'a%20b' ).
  ENDMETHOD.

  METHOD encodes_amp.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->encode( 'a&b' ) exp = 'a%26b' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->encode( 'a=b' ) exp = 'a%3Db' ).
  ENDMETHOD.

  METHOD encodes_in_build.
    add( iv_name = 'q' iv_value = 'a b' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_prm ) exp = 'q=a%20b' ).
  ENDMETHOD.

ENDCLASS.
