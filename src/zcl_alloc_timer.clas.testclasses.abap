CLASS ltcl_alloc_timer DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_timer.

    METHODS setup.

    METHODS starts_clean        FOR TESTING.
    METHODS accumulates_ms      FOR TESTING.
    METHODS ignores_when_stopped FOR TESTING.
    METHODS running_message     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_timer IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_timer( ).
  ENDMETHOD.

  METHOD starts_clean.
    DATA(ls_summary) = mo_cut->summary( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_running( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->elapsed( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-started exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-message exp = 'Not started' ).
  ENDMETHOD.

  METHOD accumulates_ms.
    mo_cut->start( ).
    mo_cut->add_ms( 120 ).
    mo_cut->add_ms( 30 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_running( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->elapsed( ) exp = 150 ).
  ENDMETHOD.

  METHOD ignores_when_stopped.
    DATA(ls_summary) = mo_cut->summary( ).

    mo_cut->start( ).
    mo_cut->add_ms( 100 ).
    mo_cut->stop( ).
    mo_cut->add_ms( 900 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->elapsed( ) exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_running( ) exp = abap_false ).

    ls_summary = mo_cut->summary( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-stopped exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-message exp = 'Elapsed 100 ms' ).
  ENDMETHOD.

  METHOD running_message.
    DATA(ls_summary) = mo_cut->summary( ).

    mo_cut->start( ).
    ls_summary = mo_cut->summary( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-started exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-message exp = 'Running' ).
  ENDMETHOD.

ENDCLASS.
