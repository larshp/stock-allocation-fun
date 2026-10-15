CLASS ltcl_alloc_sample_size DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sample_size.
    DATA mt_rul TYPE zcl_alloc_sample_size=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_from   TYPE i
        iv_sample TYPE i.

    METHODS picks_largest_for FOR TESTING.
    METHODS below_smallest  FOR TESTING.
    METHODS unsorted_rules  FOR TESTING.
    METHODS zero_lot        FOR TESTING.
    METHODS covers_flag     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sample_size IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sample_size( ).
    add( iv_from = 1 iv_sample = 5 ).
    add( iv_from = 100 iv_sample = 20 ).
    add( iv_from = 1000 iv_sample = 50 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_sample_size=>ty_rule.

    ls_rule-from_lot = iv_from.
    ls_rule-sample = iv_sample.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD picks_largest_for.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sample_size( it_rules = mt_rul iv_lot_size = 500 )
      exp = 20 ).
  ENDMETHOD.

  METHOD below_smallest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sample_size( it_rules = mt_rul iv_lot_size = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD unsorted_rules.
    DATA lt_rules TYPE zcl_alloc_sample_size=>ty_rule_tt.
    DATA ls_rule  TYPE zcl_alloc_sample_size=>ty_rule.

    ls_rule-from_lot = 1000.
    ls_rule-sample = 50.
    APPEND ls_rule TO lt_rules.

    ls_rule-from_lot = 1.
    ls_rule-sample = 5.
    APPEND ls_rule TO lt_rules.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sample_size( it_rules = lt_rules iv_lot_size = 2000 )
      exp = 50 ).
  ENDMETHOD.

  METHOD zero_lot.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sample_size( it_rules = mt_rul iv_lot_size = -5 )
      exp = 0 ).
  ENDMETHOD.

  METHOD covers_flag.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_lot( it_rules = mt_rul iv_lot_size = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_lot( it_rules = mt_rul iv_lot_size = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
