CLASS ltcl_alloc_auth DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_auth.

    METHODS setup.

    METHODS grants_exact        FOR TESTING.
    METHODS wildcard_grant      FOR TESTING.
    METHODS other_object_denied FOR TESTING.
    METHODS unknown_activity    FOR TESTING.
    METHODS counts_grants       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_auth IMPLEMENTATION.

  METHOD setup.
    DATA lt_grants TYPE zcl_alloc_auth=>ty_grant_tt.

    APPEND VALUE #( object = 'ZALLOC' actvt = '01' ) TO lt_grants.
    APPEND VALUE #( object = 'ZSTOCKRUN' actvt = '*' ) TO lt_grants.

    mo_cut = NEW zcl_alloc_auth( lt_grants ).
  ENDMETHOD.

  METHOD grants_exact.
    DATA lv_ok TYPE abap_bool.

    lv_ok = mo_cut->is_authorized( iv_object = 'ZALLOC' iv_actvt = '01' ).

    cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_true ).
  ENDMETHOD.

  METHOD wildcard_grant.
    DATA lv_ok TYPE abap_bool.

    lv_ok = mo_cut->is_authorized( iv_object = 'ZSTOCKRUN' iv_actvt = '03' ).

    cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_true ).
  ENDMETHOD.

  METHOD other_object_denied.
    DATA lv_ok TYPE abap_bool.

    lv_ok = mo_cut->is_authorized( iv_object = 'ZOTHER' iv_actvt = '01' ).

    cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_false ).
  ENDMETHOD.

  METHOD unknown_activity.
    DATA lv_ok TYPE abap_bool.

    lv_ok = mo_cut->is_authorized( iv_object = 'ZALLOC' iv_actvt = '02' ).

    cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_false ).
  ENDMETHOD.

  METHOD counts_grants.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
