CLASS ltcl_alloc_replenish_pareto DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_pareto.
    DATA mt_val TYPE zcl_alloc_replenish_pareto=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS running_percent FOR TESTING.
    METHODS counts_vital    FOR TESTING.
    METHODS classic_cut     FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_pareto IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_pareto( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD running_percent.
    DATA lt_pct TYPE zcl_alloc_replenish_pareto=>ty_values_tt.

    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    lt_pct = mo_cut->cumulative_percent( mt_val ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pct ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 1 ] exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 2 ] exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pct[ 4 ] exp = 100 ).
  ENDMETHOD.

  METHOD counts_vital.
    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vital_few( it_values = mt_val iv_threshold_percent = 80 )
      exp = 2 ).
  ENDMETHOD.

  METHOD classic_cut.
    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pareto( mt_val ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pareto( mt_val ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->cumulative_percent( mt_val ) ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
