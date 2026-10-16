CLASS ltcl_alloc_replenish_text DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_text.
    DATA mt_run TYPE zcl_alloc_replenish_text=>ty_run_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name     TYPE string
        iv_quantity TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_runs    FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_text IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_text( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_run TYPE zcl_alloc_replenish_text=>ty_run.

    ls_run-name = iv_name.
    ls_run-quantity = iv_quantity.
    APPEND ls_run TO mt_run.
  ENDMETHOD.

  METHOD builds_summary.
    add( iv_name = 'A' iv_quantity = 10 ).
    add( iv_name = 'B' iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_run ) exp = '2 runs, 15 units' ).
  ENDMETHOD.

  METHOD counts_runs.
    add( iv_name = 'A' iv_quantity = 10 ).
    add( iv_name = 'B' iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_run ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_run ) exp = '0 runs, 0 units' ).
  ENDMETHOD.

ENDCLASS.
