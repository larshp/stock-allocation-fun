CLASS ltcl_alloc_lead_avg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lead_avg.
    DATA mt_val TYPE zcl_alloc_lead_avg=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_average FOR TESTING.
    METHODS finds_min        FOR TESTING.
    METHODS finds_max        FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lead_avg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lead_avg( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD computes_average.
    add( 4 ).
    add( 6 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_val ) exp = 5 ).
  ENDMETHOD.

  METHOD finds_min.
    add( 4 ).
    add( 6 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->min_days( mt_val ) exp = 4 ).
  ENDMETHOD.

  METHOD finds_max.
    add( 4 ).
    add( 6 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->max_days( mt_val ) exp = 6 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_val ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->min_days( mt_val ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
