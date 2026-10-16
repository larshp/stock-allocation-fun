CLASS ltcl_alloc_pareto_threshold DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pareto_threshold.
    DATA mt_val TYPE zcl_alloc_pareto_threshold=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS counts_vital FOR TESTING.
    METHODS vital_rule   FOR TESTING.
    METHODS marks_threshold FOR TESTING.
    METHODS empty_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pareto_threshold IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pareto_threshold( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD counts_vital.
    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_vital( it_values = mt_val iv_threshold_percent = 80 )
      exp = 2 ).
  ENDMETHOD.

  METHOD vital_rule.
    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_vital( iv_rank = 1 it_values = mt_val
                              iv_threshold_percent = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_vital( iv_rank = 3 it_values = mt_val
                              iv_threshold_percent = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD marks_threshold.
    add( 50 ).
    add( 30 ).
    add( 15 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->threshold( it_values = mt_val iv_threshold_percent = 80 )
      exp = 30 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_vital( it_values = mt_val iv_threshold_percent = 80 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->threshold( it_values = mt_val iv_threshold_percent = 80 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
