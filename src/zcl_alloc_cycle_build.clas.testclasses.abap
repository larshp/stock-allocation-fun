CLASS ltcl_alloc_cycle_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_build.
    DATA mt_line TYPE zcl_alloc_cycle_build=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_order TYPE i.

    METHODS builds_steps FOR TESTING.
    METHODS counts_steps FOR TESTING.
    METHODS picks_first  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_build( ).

    add( iv_name = 'A' iv_order = 2 ).
    add( iv_name = 'B' iv_order = 1 ).
    add( iv_name = 'C' iv_order = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cycle_build=>ty_line.

    ls_line-name = iv_name.
    ls_line-order = iv_order.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_steps.
    DATA lt_lines TYPE zcl_alloc_cycle_build=>ty_line_tt.

    lt_lines = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-name exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-name exp = 'C' ).
  ENDMETHOD.

  METHOD counts_steps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step_count( mt_line ) exp = 3 ).
  ENDMETHOD.

  METHOD picks_first.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_step( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
