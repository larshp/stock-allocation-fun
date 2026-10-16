CLASS ltcl_alloc_demand DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_demand.
    DATA mt_per TYPE zcl_alloc_demand=>ty_periods_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS sums_total     FOR TESTING.
    METHODS counts_periods FOR TESTING.
    METHODS averages       FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_demand IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_demand( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_per.
  ENDMETHOD.

  METHOD sums_total.
    add( 10 ).
    add( 0 ).
    add( 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_per ) exp = 30 ).
  ENDMETHOD.

  METHOD counts_periods.
    add( 10 ).
    add( 0 ).
    add( 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->period_count( mt_per ) exp = 2 ).
  ENDMETHOD.

  METHOD averages.
    add( 10 ).
    add( 0 ).
    add( 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_per ) exp = 15 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_per ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_per ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
