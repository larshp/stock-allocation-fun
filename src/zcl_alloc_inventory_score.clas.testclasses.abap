CLASS ltcl_alloc_inventory_score DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_inventory_score.

    METHODS setup.

    METHODS computes_score FOR TESTING.
    METHODS good_rule      FOR TESTING.
    METHODS computes_gap   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_inventory_score IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_inventory_score( ).
  ENDMETHOD.

  METHOD computes_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_availability_percent = 100
                           iv_accuracy_percent     = 100
                           iv_turnover_percent     = 100 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_availability_percent = 80
                           iv_accuracy_percent     = 90
                           iv_turnover_percent     = 70 )
      exp = 80 ).
  ENDMETHOD.

  METHOD good_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_good( iv_score = 80 iv_threshold = 75 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_good( iv_score = 60 iv_threshold = 75 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_score = 70 iv_target = 80 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_score = 90 iv_target = 80 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
