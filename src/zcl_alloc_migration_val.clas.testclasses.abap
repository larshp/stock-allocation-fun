CLASS ltcl_alloc_migration_val DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_migration_val.
    DATA mt_rule TYPE zcl_alloc_migration_val=>ty_rule_tt.
    DATA mt_row  TYPE zcl_alloc_migration_map=>ty_record_tt.

    METHODS setup.

    METHODS add_rule
      IMPORTING
        iv_name     TYPE string
        iv_required TYPE abap_bool.

    METHODS add_row
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS clean_rows_valid FOR TESTING.
    METHODS missing_required FOR TESTING.
    METHODS optional_missing FOR TESTING.
    METHODS empty_value      FOR TESTING.
    METHODS reports_index    FOR TESTING.
    METHODS no_rules_valid   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_migration_val IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_migration_val( ).
  ENDMETHOD.

  METHOD add_rule.
    DATA ls_rule TYPE zcl_alloc_migration_val=>ty_rule.

    ls_rule-field_name = iv_name.
    ls_rule-is_required = iv_required.
    APPEND ls_rule TO mt_rule.
  ENDMETHOD.

  METHOD add_row.
    DATA ls_row TYPE zcl_alloc_migration_map=>ty_record.

    ls_row-field_name = iv_name.
    ls_row-field_value = iv_value.
    APPEND ls_row TO mt_row.
  ENDMETHOD.

  METHOD clean_rows_valid.
    add_rule( iv_name = 'MATERIAL' iv_required = abap_true ).
    add_row( iv_name = 'MATERIAL' iv_value = 'M-1' ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( lt_issues ) exp = abap_true ).
  ENDMETHOD.

  METHOD missing_required.
    add_rule( iv_name = 'PLANT' iv_required = abap_true ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-issue exp = 'missing' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name exp = 'PLANT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( lt_issues ) exp = abap_false ).
  ENDMETHOD.

  METHOD optional_missing.
    add_rule( iv_name = 'NOTE' iv_required = abap_false ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_value.
    add_rule( iv_name = 'MATERIAL' iv_required = abap_true ).
    add_row( iv_name = 'MATERIAL' iv_value = '' ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-issue exp = 'empty' ).
  ENDMETHOD.

  METHOD reports_index.
    add_rule( iv_name = 'PLANT' iv_required = abap_true ).
    add_row( iv_name = 'MATERIAL' iv_value = 'M-1' ).
    add_row( iv_name = 'PLANT' iv_value = '' ).
    add_row( iv_name = 'PLANT' iv_value = '1000' ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-record_index exp = 2 ).
  ENDMETHOD.

  METHOD no_rules_valid.
    add_row( iv_name = 'MATERIAL' iv_value = 'M-1' ).

    DATA(lt_issues) = mo_cut->validate( it_rules = mt_rule
                                        it_rows  = mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
