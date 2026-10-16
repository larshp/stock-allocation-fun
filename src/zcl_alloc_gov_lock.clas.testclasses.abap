CLASS ltcl_alloc_gov_lock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_lock.
    DATA mt_line TYPE zcl_alloc_gov_lock=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key    TYPE string
        iv_locked TYPE abap_bool.

    METHODS locks_item   FOR TESTING.
    METHODS locked_rule  FOR TESTING.
    METHODS counts_locks FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_lock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_lock( ).

    add( iv_key = 'K1' iv_locked = abap_false ).
    add( iv_key = 'K2' iv_locked = abap_true ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_gov_lock=>ty_line.

    ls_line-key = iv_key.
    ls_line-locked = iv_locked.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD locks_item.
    DATA lt_out TYPE zcl_alloc_gov_lock=>ty_line_tt.

    lt_out = mo_cut->lock( it_lines = mt_line iv_key = 'K1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_out[ 1 ]-locked exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_out[ 2 ]-locked exp = abap_true ).
  ENDMETHOD.

  METHOD locked_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_locked( it_lines = mt_line iv_key = 'K2' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_locked( it_lines = mt_line iv_key = 'K1' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_locks.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lock_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
