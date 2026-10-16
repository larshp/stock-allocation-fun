CLASS ltcl_alloc_highlight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_highlight.
    DATA mt_rul TYPE zcl_alloc_highlight=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id    TYPE string
        iv_limit TYPE menge_d
        iv_sev   TYPE string.

    METHODS no_rules      FOR TESTING.
    METHODS below_all     FOR TESTING.
    METHODS fires_two     FOR TESTING.
    METHODS fires_all     FOR TESTING.
    METHODS at_threshold  FOR TESTING.
    METHODS worst_is_error FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_highlight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_highlight( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_highlight=>ty_rule.

    ls_rule-rule_id = iv_id.
    ls_rule-threshold = iv_limit.
    ls_rule-severity = iv_sev.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD no_rules.
    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst_severity( lt_hits ) exp = '' ).
  ENDMETHOD.

  METHOD below_all.
    add( iv_id = 'R1' iv_limit = 10 iv_sev = 'info' ).
    add( iv_id = 'R2' iv_limit = 50 iv_sev = 'warning' ).

    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
  ENDMETHOD.

  METHOD fires_two.
    add( iv_id = 'R1' iv_limit = 10 iv_sev = 'info' ).
    add( iv_id = 'R2' iv_limit = 50 iv_sev = 'warning' ).
    add( iv_id = 'R3' iv_limit = 90 iv_sev = 'error' ).

    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-rule_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 2 ]-rule_id exp = 'R2' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst_severity( lt_hits ) exp = 'warning' ).
  ENDMETHOD.

  METHOD fires_all.
    add( iv_id = 'R1' iv_limit = 10 iv_sev = 'info' ).
    add( iv_id = 'R2' iv_limit = 50 iv_sev = 'warning' ).
    add( iv_id = 'R3' iv_limit = 90 iv_sev = 'error' ).

    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 95 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst_severity( lt_hits ) exp = 'error' ).
  ENDMETHOD.

  METHOD at_threshold.
    add( iv_id = 'R1' iv_limit = 60 iv_sev = 'warning' ).

    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
  ENDMETHOD.

  METHOD worst_is_error.
    add( iv_id = 'R1' iv_limit = 1 iv_sev = 'error' ).
    add( iv_id = 'R2' iv_limit = 1 iv_sev = 'info' ).

    DATA(lt_hits) = mo_cut->apply( it_rules = mt_rul iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst_severity( lt_hits ) exp = 'error' ).
  ENDMETHOD.

ENDCLASS.
