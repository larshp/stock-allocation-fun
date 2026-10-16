CLASS ltcl_alloc_cobj_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_health.
    DATA mt_value TYPE zcl_alloc_cobj_health=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS healthy_rule FOR TESTING.
    METHODS counts_issues FOR TESTING.
    METHODS reads_score  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_health( ).

    add( iv_value = 100 ).
    add( iv_value = 50 ).
    add( iv_value = 90 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_margin = 100 iv_target = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_margin = 50 iv_target = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_issues.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->issue_count( it_margins = mt_value iv_target = 80 )
      exp = 1 ).
  ENDMETHOD.

  METHOD reads_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_margin = 80 iv_target = 80 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_margin = 40 iv_target = 80 )
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_margin = 120 iv_target = 80 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
