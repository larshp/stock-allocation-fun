CLASS ltcl_alloc_lead_variability DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lead_variability.
    DATA mt_val TYPE zcl_alloc_lead_variability=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_average FOR TESTING.
    METHODS computes_std_dev FOR TESTING.
    METHODS stable_rule      FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lead_variability IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lead_variability( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD computes_average.
    add( 4 ).
    add( 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_val ) exp = 5 ).
  ENDMETHOD.

  METHOD computes_std_dev.
    add( 4 ).
    add( 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->std_dev( mt_val ) exp = 1 ).
  ENDMETHOD.

  METHOD stable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stable( iv_std_dev = 1 iv_threshold = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stable( iv_std_dev = 3 iv_threshold = 2 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_val ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->std_dev( mt_val ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
