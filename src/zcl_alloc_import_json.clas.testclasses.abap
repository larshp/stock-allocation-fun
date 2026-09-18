CLASS ltcl_alloc_import_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_import_json.

    METHODS setup.

    METHODS parses_pairs    FOR TESTING.
    METHODS ignores_spaces  FOR TESTING.
    METHODS empty_object    FOR TESTING.
    METHODS unquoted_number FOR TESTING.
    METHODS counts_pairs    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_import_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_import_json( ).
  ENDMETHOD.

  METHOD parses_pairs.
    DATA lt_pairs TYPE zcl_alloc_import_json=>ty_pair_tt.

    lt_pairs = mo_cut->parse( '{"a":"1","b":"2"}' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pairs ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 1 ]-key exp = 'a' ).
    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 1 ]-value exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 2 ]-key exp = 'b' ).
  ENDMETHOD.

  METHOD ignores_spaces.
    DATA lt_pairs TYPE zcl_alloc_import_json=>ty_pair_tt.

    lt_pairs = mo_cut->parse( '{ "plants" : "1000" }' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pairs ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 1 ]-key exp = 'plants' ).
    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 1 ]-value exp = '1000' ).
  ENDMETHOD.

  METHOD empty_object.
    DATA lt_pairs TYPE zcl_alloc_import_json=>ty_pair_tt.

    lt_pairs = mo_cut->parse( '{}' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pairs ) exp = 0 ).
  ENDMETHOD.

  METHOD unquoted_number.
    DATA lt_pairs TYPE zcl_alloc_import_json=>ty_pair_tt.

    lt_pairs = mo_cut->parse( '{"n":5}' ).

    cl_abap_unit_assert=>assert_equals( act = lt_pairs[ 1 ]-value exp = '5' ).
  ENDMETHOD.

  METHOD counts_pairs.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count_of( '{"a":"1","b":"2","c":"3"}' )
                                        exp = 3 ).
  ENDMETHOD.

ENDCLASS.
