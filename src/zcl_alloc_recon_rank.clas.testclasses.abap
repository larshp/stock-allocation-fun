CLASS ltcl_alloc_recon_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_rank.
    DATA mt_line TYPE zcl_alloc_recon_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_diff TYPE i.

    METHODS ranks_diffs FOR TESTING.
    METHODS picks_worst FOR TESTING.
    METHODS picks_best  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_rank( ).

    add( iv_key = 'K1' iv_diff = 100 ).
    add( iv_key = 'K2' iv_diff = -50 ).
    add( iv_key = 'K3' iv_diff = 0 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_rank=>ty_line.

    ls_line-key = iv_key.
    ls_line-diff = iv_diff.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_diffs.
    DATA lt_rank TYPE zcl_alloc_recon_rank=>ty_rank_tt.

    lt_rank = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_rank[ 1 ]-magnitude exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rank[ 3 ]-magnitude exp = 0 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 100 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
