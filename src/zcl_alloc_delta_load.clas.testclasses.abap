CLASS ltcl_alloc_delta_load DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_delta_load.

    METHODS setup.

    METHODS detects_all_categories FOR TESTING.
    METHODS empty_incoming        FOR TESTING.
    METHODS identical             FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_delta_load IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_delta_load( ).
  ENDMETHOD.

  METHOD detects_all_categories.
    DATA lt_existing TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lt_incoming TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lv_id       TYPE zcl_alloc_delta_load=>ty_id.
    DATA ls_delta    TYPE zcl_alloc_delta_load=>ty_delta.

    lv_id = 'A'.
    APPEND lv_id TO lt_existing.

    lv_id = 'B'.
    APPEND lv_id TO lt_existing.

    lv_id = 'B'.
    APPEND lv_id TO lt_incoming.

    lv_id = 'C'.
    APPEND lv_id TO lt_incoming.

    ls_delta = mo_cut->compare( it_existing = lt_existing it_incoming = lt_incoming ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-added ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_delta-added[ 1 ] exp = 'C' ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-removed ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_delta-removed[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-kept ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_delta-kept[ 1 ] exp = 'B' ).
  ENDMETHOD.

  METHOD empty_incoming.
    DATA lt_existing TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lt_incoming TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lv_id       TYPE zcl_alloc_delta_load=>ty_id.
    DATA ls_delta    TYPE zcl_alloc_delta_load=>ty_delta.

    lv_id = 'A'.
    APPEND lv_id TO lt_existing.

    ls_delta = mo_cut->compare( it_existing = lt_existing it_incoming = lt_incoming ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-removed ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-added ) exp = 0 ).
  ENDMETHOD.

  METHOD identical.
    DATA lt_existing TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lt_incoming TYPE zcl_alloc_delta_load=>ty_id_tt.
    DATA lv_id       TYPE zcl_alloc_delta_load=>ty_id.
    DATA ls_delta    TYPE zcl_alloc_delta_load=>ty_delta.

    lv_id = 'A'.
    APPEND lv_id TO lt_existing.
    APPEND lv_id TO lt_incoming.

    ls_delta = mo_cut->compare( it_existing = lt_existing it_incoming = lt_incoming ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-kept ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-added ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_delta-removed ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
