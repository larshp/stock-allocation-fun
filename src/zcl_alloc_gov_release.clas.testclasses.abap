CLASS ltcl_alloc_gov_release DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_release.
    DATA mt_line TYPE zcl_alloc_gov_release=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_locked TYPE abap_bool.

    METHODS releases_locks FOR TESTING.
    METHODS released_rule  FOR TESTING.
    METHODS counts_remaining FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_release IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_release( ).

    add( iv_locked = abap_true ).
    add( iv_locked = abap_false ).
    add( iv_locked = abap_true ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_gov_release=>ty_line.

    ls_line-locked = iv_locked.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD releases_locks.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->release( iv_locked = 3 iv_count = 1 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->release( iv_locked = 3 iv_count = 5 ) exp = 0 ).
  ENDMETHOD.

  METHOD released_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_released( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_released( 2 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_remaining.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
