CLASS ltcl_alloc_commit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_commit.

    METHODS setup.

    METHODS commits_count   FOR TESTING.
    METHODS commits_zero    FOR TESTING.
    METHODS rollback_reason FOR TESTING.
    METHODS rollback_default FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_commit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_commit( ).
  ENDMETHOD.

  METHOD commits_count.
    DATA(rs_result) = mo_cut->commit( 3 ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-committed
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-rolled_back
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Committed 3 tasks' ).
  ENDMETHOD.

  METHOD commits_zero.
    DATA(rs_result) = mo_cut->commit( 0 ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Committed 0 tasks' ).
  ENDMETHOD.

  METHOD rollback_reason.
    DATA(rs_result) = mo_cut->rollback( 'Stock changed' ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-rolled_back
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Stock changed' ).
  ENDMETHOD.

  METHOD rollback_default.
    DATA(rs_result) = mo_cut->rollback( '' ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Rolled back' ).
  ENDMETHOD.

ENDCLASS.
