CLASS ltcl_alloc_recon_break DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_break.
    DATA mt_line TYPE zcl_alloc_recon_break=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_diff TYPE i.

    METHODS counts_breaks FOR TESTING.
    METHODS broken_rule   FOR TESTING.
    METHODS picks_worst   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_break IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_break( ).

    add( iv_key = 'K1' iv_diff = 0 ).
    add( iv_key = 'K2' iv_diff = 100 ).
    add( iv_key = 'K3' iv_diff = -50 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_break=>ty_line.

    ls_line-key = iv_key.
    ls_line-diff = iv_diff.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD counts_breaks.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->break_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD broken_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_broken( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_broken( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
