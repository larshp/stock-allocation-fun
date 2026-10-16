CLASS ltcl_alloc_return_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_audit.

    METHODS setup.

    METHODS records_entries FOR TESTING.
    METHODS ignores_blank   FOR TESTING.
    METHODS counts_entries  FOR TESTING.
    METHODS last_action     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_audit( ).
  ENDMETHOD.

  METHOD records_entries.
    DATA lt_entries TYPE zcl_alloc_return_audit=>ty_entry_tt.

    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'CREATE'
                                 iv_user = 'U1' ).
    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'APPROVE'
                                 iv_user = 'U2' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entries[ 2 ]-user_name exp = 'U2' ).
  ENDMETHOD.

  METHOD ignores_blank.
    DATA lt_entries TYPE zcl_alloc_return_audit=>ty_entry_tt.

    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'CREATE'
                                 iv_user = 'U1' ).
    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = ''
                                 iv_user = 'U2' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 1 ).
  ENDMETHOD.

  METHOD counts_entries.
    DATA lt_entries TYPE zcl_alloc_return_audit=>ty_entry_tt.

    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'CREATE'
                                 iv_user = 'U1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->entries( lt_entries ) exp = 1 ).
  ENDMETHOD.

  METHOD last_action.
    DATA lt_entries TYPE zcl_alloc_return_audit=>ty_entry_tt.

    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'CREATE'
                                 iv_user = 'U1' ).
    lt_entries = mo_cut->record( it_entries = lt_entries iv_action = 'APPROVE'
                                 iv_user = 'U2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->last_action( lt_entries ) exp = 'APPROVE' ).
  ENDMETHOD.

ENDCLASS.
