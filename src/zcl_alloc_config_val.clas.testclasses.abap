CLASS ltcl_alloc_config_val DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_config_val.

    METHODS setup.

    METHODS valid_entries       FOR TESTING.
    METHODS reports_empty_key   FOR TESTING.
    METHODS reports_empty_value FOR TESTING.
    METHODS reports_duplicate   FOR TESTING.
    METHODS counts_issues       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_config_val IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_config_val( ).
  ENDMETHOD.

  METHOD valid_entries.
    DATA lt_entries TYPE zcl_alloc_config_val=>ty_entry_tt.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_entries.
    APPEND VALUE #( key = 'B' value = '2' ) TO lt_entries.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( lt_entries ) exp = abap_true ).
  ENDMETHOD.

  METHOD reports_empty_key.
    DATA lt_entries TYPE zcl_alloc_config_val=>ty_entry_tt.
    DATA lt_issues  TYPE zcl_alloc_config_val=>ty_issue_tt.

    APPEND VALUE #( key = '' value = '1' ) TO lt_entries.

    lt_issues = mo_cut->validate( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Key is empty' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( lt_entries ) exp = abap_false ).
  ENDMETHOD.

  METHOD reports_empty_value.
    DATA lt_entries TYPE zcl_alloc_config_val=>ty_entry_tt.
    DATA lt_issues  TYPE zcl_alloc_config_val=>ty_issue_tt.

    APPEND VALUE #( key = 'A' value = '' ) TO lt_entries.

    lt_issues = mo_cut->validate( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Value is empty' ).
  ENDMETHOD.

  METHOD reports_duplicate.
    DATA lt_entries TYPE zcl_alloc_config_val=>ty_entry_tt.
    DATA lt_issues  TYPE zcl_alloc_config_val=>ty_issue_tt.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_entries.
    APPEND VALUE #( key = 'A' value = '2' ) TO lt_entries.

    lt_issues = mo_cut->validate( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Duplicate key' ).
  ENDMETHOD.

  METHOD counts_issues.
    DATA lt_entries TYPE zcl_alloc_config_val=>ty_entry_tt.
    DATA lt_issues  TYPE zcl_alloc_config_val=>ty_issue_tt.

    APPEND VALUE #( key = '' value = '1' ) TO lt_entries.
    APPEND VALUE #( key = 'B' value = '' ) TO lt_entries.
    APPEND VALUE #( key = 'B' value = '2' ) TO lt_entries.

    lt_issues = mo_cut->validate( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
