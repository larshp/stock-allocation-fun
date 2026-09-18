CLASS ltcl_alloc_idem_key DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_idem_key.
    DATA mt_part TYPE zcl_alloc_idem_key=>ty_parts_tt.

    METHODS setup.

    METHODS unescaped_scope    FOR TESTING.
    METHODS skips_empty_parts  FOR TESTING.
    METHODS valid_key          FOR TESTING.
    METHODS invalid_when_empty FOR TESTING.
    METHODS invalid_no_hash    FOR TESTING.
    METHODS invalid_hash_first FOR TESTING.
    METHODS invalid_tail_only  FOR TESTING.
    METHODS scope_extracted    FOR TESTING.
    METHODS built_key_is_valid FOR TESTING.
    METHODS repeatable         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_idem_key IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_idem_key( ).

    APPEND 'M1' TO mt_part.
    APPEND '4711' TO mt_part.
  ENDMETHOD.

  METHOD unescaped_scope.
    DATA(lv_key) = mo_cut->build( iv_scope = 'ALLOC' it_parts = mt_part ).

    cl_abap_unit_assert=>assert_equals( act = lv_key exp = 'ALLOC#2#10' ).
  ENDMETHOD.

  METHOD skips_empty_parts.
    DATA lt_parts TYPE zcl_alloc_idem_key=>ty_parts_tt.
    DATA lv_key   TYPE string.

    APPEND 'A' TO lt_parts.
    APPEND '' TO lt_parts.
    APPEND 'BB' TO lt_parts.

    lv_key = mo_cut->build( iv_scope = 'S' it_parts = lt_parts ).

    cl_abap_unit_assert=>assert_equals( act = lv_key exp = 'S#2#5' ).
  ENDMETHOD.

  METHOD valid_key.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 'ALLOC#2#14' ) exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_when_empty.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( '' ) exp = abap_false ).
  ENDMETHOD.

  METHOD invalid_no_hash.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( 'ALLOC' ) exp = abap_false ).
  ENDMETHOD.

  METHOD invalid_hash_first.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( '#2#14' ) exp = abap_false ).
  ENDMETHOD.

  METHOD invalid_tail_only.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( 'A#' ) exp = abap_false ).
  ENDMETHOD.

  METHOD scope_extracted.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scope_of( 'ALLOC#2#14' ) exp = 'ALLOC' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scope_of( 'nohash' ) exp = '' ).
  ENDMETHOD.

  METHOD built_key_is_valid.
    DATA(lv_key) = mo_cut->build( iv_scope = 'ALLOC' it_parts = mt_part ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_valid( lv_key ) exp = abap_true ).
  ENDMETHOD.

  METHOD repeatable.
    DATA(lv_first) = mo_cut->build( iv_scope = 'ALLOC' it_parts = mt_part ).
    DATA(lv_second) = mo_cut->build( iv_scope = 'ALLOC' it_parts = mt_part ).

    cl_abap_unit_assert=>assert_equals( act = lv_second exp = lv_first ).
  ENDMETHOD.

ENDCLASS.
