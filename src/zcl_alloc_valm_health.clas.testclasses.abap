CLASS ltcl_alloc_valm_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_health.
    DATA mt_values TYPE zcl_alloc_valm_health=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS healthy_rule FOR TESTING.
    METHODS counts_issues FOR TESTING.
    METHODS computes_score FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_health( ).

    add( iv_value = 1500 ).
    add( iv_value = 800 ).
    add( iv_value = 2000 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_values.
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_alert_count = 2 iv_max_alerts = 3 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_alert_count = 5 iv_max_alerts = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_issues.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->issue_count( it_values = mt_values iv_threshold = 1000 )
      exp = 2 ).
  ENDMETHOD.

  METHOD computes_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_alert_count = 2 iv_line_count = 10 )
      exp = 80 ).
  ENDMETHOD.

ENDCLASS.
