CLASS ltcl_alloc_storage_type DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_storage_type.
    DATA mt_rul TYPE zcl_alloc_storage_type=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_group TYPE string
        iv_type  TYPE string.

    METHODS first_match    FOR TESTING.
    METHODS unknown_group  FOR TESTING.
    METHODS empty_rules    FOR TESTING.
    METHODS has_rule_yes   FOR TESTING.
    METHODS has_rule_no    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_storage_type IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_storage_type( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_storage_type=>ty_rule.

    ls_rule-mat_group = iv_group.
    ls_rule-storage_type = iv_type.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD first_match.
    add( iv_group = 'FAST' iv_type = '001' ).
    add( iv_group = 'BULK' iv_type = '002' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_rules = mt_rul iv_mat_group = 'BULK' )
      exp = '002' ).
  ENDMETHOD.

  METHOD unknown_group.
    add( iv_group = 'FAST' iv_type = '001' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_rules = mt_rul iv_mat_group = 'COLD' )
      exp = '' ).
  ENDMETHOD.

  METHOD empty_rules.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_rules = mt_rul iv_mat_group = 'FAST' )
      exp = '' ).
  ENDMETHOD.

  METHOD has_rule_yes.
    add( iv_group = 'FAST' iv_type = '001' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_rule( it_rules = mt_rul iv_mat_group = 'FAST' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD has_rule_no.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_rule( it_rules = mt_rul iv_mat_group = 'FAST' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
