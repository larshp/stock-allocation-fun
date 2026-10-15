CLASS ltcl_alloc_gov_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_audit.
    DATA mt_entry TYPE zcl_alloc_gov_audit=>ty_entry_tt.

    METHODS setup.

    METHODS formats_entry  FOR TESTING.
    METHODS counts_entries FOR TESTING.
    METHODS complete_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_audit( ).

    APPEND 'ANNA: POST' TO mt_entry.
    APPEND 'BERT: RELEASE' TO mt_entry.
  ENDMETHOD.

  METHOD formats_entry.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->entry( iv_action = 'POST' iv_user = 'ANNA' )
      exp = 'ANNA: POST' ).
  ENDMETHOD.

  METHOD counts_entries.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->entry_count( mt_entry ) exp = 2 ).
  ENDMETHOD.

  METHOD complete_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_entries = mt_entry iv_expected = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_entries = mt_entry iv_expected = 3 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
