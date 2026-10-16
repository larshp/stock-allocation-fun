CLASS ltcl_alloc_flags DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_flags.

    METHODS setup.

    METHODS sets_and_reads     FOR TESTING.
    METHODS defaults_disabled  FOR TESTING.
    METHODS overwrites_flag    FOR TESTING.
    METHODS lists_enabled_only FOR TESTING.
    METHODS counts_flags       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_flags IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_flags( ).
  ENDMETHOD.

  METHOD sets_and_reads.
    mo_cut->set( iv_name = 'NEW_ENGINE' iv_enabled = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_enabled( 'NEW_ENGINE' )
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD defaults_disabled.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_enabled( 'UNKNOWN' )
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
  ENDMETHOD.

  METHOD overwrites_flag.
    mo_cut->set( iv_name = 'NEW_ENGINE' iv_enabled = abap_true ).
    mo_cut->set( iv_name = 'NEW_ENGINE' iv_enabled = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_enabled( 'NEW_ENGINE' )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD lists_enabled_only.
    DATA lt_enabled TYPE zcl_alloc_flags=>ty_flag_tt.

    mo_cut->set( iv_name = 'A_FLAG' iv_enabled = abap_true ).
    mo_cut->set( iv_name = 'B_FLAG' iv_enabled = abap_false ).
    mo_cut->set( iv_name = 'C_FLAG' iv_enabled = abap_true ).

    lt_enabled = mo_cut->enabled_flags( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_enabled ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_enabled[ 1 ]-name exp = 'A_FLAG' ).
    cl_abap_unit_assert=>assert_equals( act = lt_enabled[ 2 ]-name exp = 'C_FLAG' ).
  ENDMETHOD.

  METHOD counts_flags.
    mo_cut->set( iv_name = 'A_FLAG' iv_enabled = abap_true ).
    mo_cut->set( iv_name = 'B_FLAG' iv_enabled = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
