CLASS ltcl_alloc_bulk_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bulk_check.

    METHODS setup.

    METHODS accepts_good_ids  FOR TESTING.
    METHODS reports_empty     FOR TESTING.
    METHODS reports_short     FOR TESTING.
    METHODS reports_duplicate FOR TESTING.
    METHODS counts_issues     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bulk_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bulk_check( ).
  ENDMETHOD.

  METHOD accepts_good_ids.
    DATA lt_ids TYPE zcl_alloc_bulk_check=>ty_id_tt.
    DATA lv_id  TYPE zcl_alloc_bulk_check=>ty_id.

    lv_id = 'RUN-1'.
    APPEND lv_id TO lt_ids.

    lv_id = 'RUN-2'.
    APPEND lv_id TO lt_ids.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_loadable( lt_ids ) exp = abap_true ).
  ENDMETHOD.

  METHOD reports_empty.
    DATA lt_ids    TYPE zcl_alloc_bulk_check=>ty_id_tt.
    DATA lv_id     TYPE zcl_alloc_bulk_check=>ty_id.
    DATA lt_issues TYPE zcl_alloc_bulk_check=>ty_issue_tt.

    lv_id = ''.
    APPEND lv_id TO lt_ids.

    lt_issues = mo_cut->check( lt_ids ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Empty id' ).
  ENDMETHOD.

  METHOD reports_short.
    DATA lt_ids    TYPE zcl_alloc_bulk_check=>ty_id_tt.
    DATA lv_id     TYPE zcl_alloc_bulk_check=>ty_id.
    DATA lt_issues TYPE zcl_alloc_bulk_check=>ty_issue_tt.

    lv_id = 'AB'.
    APPEND lv_id TO lt_ids.

    lt_issues = mo_cut->check( lt_ids ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Id too short' ).
  ENDMETHOD.

  METHOD reports_duplicate.
    DATA lt_ids    TYPE zcl_alloc_bulk_check=>ty_id_tt.
    DATA lv_id     TYPE zcl_alloc_bulk_check=>ty_id.
    DATA lt_issues TYPE zcl_alloc_bulk_check=>ty_issue_tt.

    lv_id = 'RUN-1'.
    APPEND lv_id TO lt_ids.
    APPEND lv_id TO lt_ids.

    lt_issues = mo_cut->check( lt_ids ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-reason exp = 'Duplicate id' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-row_no exp = 2 ).
  ENDMETHOD.

  METHOD counts_issues.
    DATA lt_ids    TYPE zcl_alloc_bulk_check=>ty_id_tt.
    DATA lv_id     TYPE zcl_alloc_bulk_check=>ty_id.
    DATA lt_issues TYPE zcl_alloc_bulk_check=>ty_issue_tt.

    lv_id = 'AB'.
    APPEND lv_id TO lt_ids.

    lv_id = 'RUN-1'.
    APPEND lv_id TO lt_ids.

    lv_id = ''.
    APPEND lv_id TO lt_ids.

    lt_issues = mo_cut->check( lt_ids ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
