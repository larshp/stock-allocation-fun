CLASS ltcl_alloc_retention DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_retention.

    METHODS setup.

    METHODS not_expired_within  FOR TESTING.
    METHODS expired_at_limit    FOR TESTING.
    METHODS days_left_countdown FOR TESTING.
    METHODS zero_days_expires   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_retention IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_retention( iv_retention_days = 30 ).
  ENDMETHOD.

  METHOD not_expired_within.
    DATA lv_expired TYPE abap_bool.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_retention_days( ) exp = 30 ).

    lv_expired = mo_cut->is_expired( iv_archived_on = '20260101' iv_reference = '20260120' ).

    cl_abap_unit_assert=>assert_equals( act = lv_expired exp = abap_false ).
  ENDMETHOD.

  METHOD expired_at_limit.
    DATA lv_expired TYPE abap_bool.

    lv_expired = mo_cut->is_expired( iv_archived_on = '20260101' iv_reference = '20260131' ).

    cl_abap_unit_assert=>assert_equals( act = lv_expired exp = abap_true ).
  ENDMETHOD.

  METHOD days_left_countdown.
    DATA lv_days TYPE i.

    lv_days = mo_cut->days_left( iv_archived_on = '20260101' iv_reference = '20260111' ).

    cl_abap_unit_assert=>assert_equals( act = lv_days exp = 20 ).

    lv_days = mo_cut->days_left( iv_archived_on = '20260101' iv_reference = '20260215' ).

    cl_abap_unit_assert=>assert_equals( act = lv_days exp = 0 ).
  ENDMETHOD.

  METHOD zero_days_expires.
    DATA lo_same_day TYPE REF TO zcl_alloc_retention.
    DATA lv_expired  TYPE abap_bool.

    lo_same_day = NEW zcl_alloc_retention( iv_retention_days = 0 ).

    lv_expired = lo_same_day->is_expired( iv_archived_on = '20260101' iv_reference = '20260101' ).

    cl_abap_unit_assert=>assert_equals( act = lv_expired exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_same_day->get_retention_days( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
