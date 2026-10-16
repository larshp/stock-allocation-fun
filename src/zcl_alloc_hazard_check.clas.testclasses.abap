CLASS ltcl_alloc_hazard_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hazard_check.
    DATA mt_rul TYPE zcl_alloc_hazard_check=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_hazard  TYPE string
        iv_storage TYPE string
        iv_allowed TYPE abap_bool.

    METHODS allows_pairing FOR TESTING.
    METHODS forbids_pair  FOR TESTING.
    METHODS no_rule_safe  FOR TESTING.
    METHODS conflict_yes FOR TESTING.
    METHODS conflict_no  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hazard_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hazard_check( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_hazard_check=>ty_rule.

    ls_rule-hazard_class = iv_hazard.
    ls_rule-storage_class = iv_storage.
    ls_rule-allowed = iv_allowed.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD allows_pairing.
    add( iv_hazard = 'H1' iv_storage = 'S1' iv_allowed = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->allowed( it_rules = mt_rul iv_hazard_class = 'H1'
                             iv_storage_class = 'S1' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD forbids_pair.
    add( iv_hazard = 'H1' iv_storage = 'S1' iv_allowed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->allowed( it_rules = mt_rul iv_hazard_class = 'H1'
                             iv_storage_class = 'S1' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD no_rule_safe.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->allowed( it_rules = mt_rul iv_hazard_class = 'H9'
                             iv_storage_class = 'S9' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD conflict_yes.
    add( iv_hazard = 'H1' iv_storage = 'S1' iv_allowed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->conflict( it_rules = mt_rul iv_hazard_class = 'H1'
                              iv_storage_class = 'S1' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD conflict_no.
    add( iv_hazard = 'H1' iv_storage = 'S1' iv_allowed = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->conflict( it_rules = mt_rul iv_hazard_class = 'H9'
                              iv_storage_class = 'S9' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
