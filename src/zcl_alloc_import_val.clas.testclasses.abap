CLASS ltcl_alloc_import_val DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_import_val.

    METHODS setup.

    METHODS valid_rows      FOR TESTING.
    METHODS reports_empty   FOR TESTING.
    METHODS reports_missing FOR TESTING.
    METHODS counts_issues   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_import_val IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_import_val( ).
  ENDMETHOD.

  METHOD valid_rows.
    DATA lt_rows     TYPE zcl_alloc_import_val=>ty_row_tt.
    DATA lt_required TYPE zcl_alloc_import_val=>ty_name_tt.
    DATA lv_name     TYPE zcl_alloc_import_val=>ty_name.
    DATA lv_valid    TYPE abap_bool.

    APPEND VALUE #( key = 'PLANT' value = '1000' ) TO lt_rows.

    lv_name = 'PLANT'.
    APPEND lv_name TO lt_required.

    lv_valid = mo_cut->is_valid( it_rows = lt_rows it_required = lt_required ).

    cl_abap_unit_assert=>assert_equals( act = lv_valid exp = abap_true ).
  ENDMETHOD.

  METHOD reports_empty.
    DATA lt_rows     TYPE zcl_alloc_import_val=>ty_row_tt.
    DATA lt_required TYPE zcl_alloc_import_val=>ty_name_tt.
    DATA lt_issues   TYPE zcl_alloc_import_val=>ty_issue_tt.

    APPEND VALUE #( key = 'PLANT' value = '' ) TO lt_rows.

    lt_issues = mo_cut->validate( it_rows = lt_rows it_required = lt_required ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Empty value' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-row_no exp = 1 ).
  ENDMETHOD.

  METHOD reports_missing.
    DATA lt_rows     TYPE zcl_alloc_import_val=>ty_row_tt.
    DATA lt_required TYPE zcl_alloc_import_val=>ty_name_tt.
    DATA lv_name     TYPE zcl_alloc_import_val=>ty_name.
    DATA lt_issues   TYPE zcl_alloc_import_val=>ty_issue_tt.

    APPEND VALUE #( key = 'PLANT' value = '1000' ) TO lt_rows.

    lv_name = 'LGORT'.
    APPEND lv_name TO lt_required.

    lt_issues = mo_cut->validate( it_rows = lt_rows it_required = lt_required ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Missing field' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-row_no exp = 0 ).
  ENDMETHOD.

  METHOD counts_issues.
    DATA lt_rows     TYPE zcl_alloc_import_val=>ty_row_tt.
    DATA lt_required TYPE zcl_alloc_import_val=>ty_name_tt.
    DATA lv_name     TYPE zcl_alloc_import_val=>ty_name.
    DATA lt_issues   TYPE zcl_alloc_import_val=>ty_issue_tt.

    APPEND VALUE #( key = 'PLANT' value = '' ) TO lt_rows.
    APPEND VALUE #( key = 'LGORT' value = '0001' ) TO lt_rows.

    lv_name = 'MAX'.
    APPEND lv_name TO lt_required.

    lt_issues = mo_cut->validate( it_rows = lt_rows it_required = lt_required ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
