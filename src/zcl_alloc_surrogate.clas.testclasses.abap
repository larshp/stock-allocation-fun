CLASS ltcl_alloc_surrogate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_surrogate.

    METHODS setup.

    METHODS creates_sid    FOR TESTING.
    METHODS reuses_sid     FOR TESTING.
    METHODS unknown_lookup FOR TESTING.
    METHODS counts_entries FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_surrogate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_surrogate( ).
  ENDMETHOD.

  METHOD creates_sid.
    DATA lv_sid TYPE zcl_alloc_surrogate=>ty_sid.

    lv_sid = mo_cut->get_or_create( 'MATNR|1000' ).

    cl_abap_unit_assert=>assert_equals( act = lv_sid exp = 'SID-1' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD reuses_sid.
    DATA lv_first  TYPE zcl_alloc_surrogate=>ty_sid.
    DATA lv_second TYPE zcl_alloc_surrogate=>ty_sid.

    lv_first = mo_cut->get_or_create( 'MATNR|1000' ).
    lv_second = mo_cut->get_or_create( 'MATNR|1000' ).

    cl_abap_unit_assert=>assert_equals( act = lv_second exp = lv_first ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).

    lv_second = mo_cut->get_or_create( 'MATNR|2000' ).

    cl_abap_unit_assert=>assert_equals( act = lv_second exp = 'SID-2' ).
  ENDMETHOD.

  METHOD unknown_lookup.
    DATA lv_sid TYPE zcl_alloc_surrogate=>ty_sid.

    lv_sid = mo_cut->lookup( 'NOPE' ).

    cl_abap_unit_assert=>assert_equals( act = lv_sid exp = '' ).
  ENDMETHOD.

  METHOD counts_entries.
    DATA lv_sid TYPE zcl_alloc_surrogate=>ty_sid.

    lv_sid = mo_cut->get_or_create( 'A' ).
    lv_sid = mo_cut->get_or_create( 'B' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
