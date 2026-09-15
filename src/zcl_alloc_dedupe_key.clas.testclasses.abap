CLASS ltcl_alloc_dedupe_key DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dedupe_key.

    METHODS setup.

    METHODS joins_parts       FOR TESTING.
    METHODS skips_empty_parts FOR TESTING.
    METHODS splits_back       FOR TESTING.
    METHODS counts_parts      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_dedupe_key IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dedupe_key( ).
  ENDMETHOD.

  METHOD joins_parts.
    DATA lt_parts TYPE zcl_alloc_dedupe_key=>ty_parts_tt.

    APPEND |MATNR| TO lt_parts.
    APPEND |1000| TO lt_parts.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_parts ) exp = 'MATNR|1000' ).
  ENDMETHOD.

  METHOD skips_empty_parts.
    DATA lt_parts TYPE zcl_alloc_dedupe_key=>ty_parts_tt.
    DATA lv_empty TYPE string.

    APPEND |A| TO lt_parts.

    lv_empty = ''.
    APPEND lv_empty TO lt_parts.

    APPEND |B| TO lt_parts.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_parts ) exp = 'A|B' ).
  ENDMETHOD.

  METHOD splits_back.
    DATA lt_parts TYPE zcl_alloc_dedupe_key=>ty_parts_tt.

    lt_parts = mo_cut->parts_of( 'A|B|C' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 3 ] exp = 'C' ).
  ENDMETHOD.

  METHOD counts_parts.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count_of( 'A|B' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count_of( '' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
