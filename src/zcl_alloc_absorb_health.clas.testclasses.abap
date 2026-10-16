CLASS ltcl_alloc_absorb_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_health.
    DATA mt_value TYPE zcl_alloc_absorb_health=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS healthy_rule FOR TESTING.
    METHODS counts_issues FOR TESTING.
    METHODS reads_score  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_health( ).

    add( iv_value = 500 ).
    add( iv_value = 500 ).
    add( iv_value = 600 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_absorbed = 600 iv_actual = 500 iv_tolerance = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_absorbed = 600 iv_actual = 500 iv_tolerance = 50 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_issues.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->issue_count( it_values = mt_value iv_actual = 500 )
      exp = 1 ).
  ENDMETHOD.

  METHOD reads_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_absorbed = 600 iv_actual = 500 )
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_absorbed = 500 iv_actual = 500 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
