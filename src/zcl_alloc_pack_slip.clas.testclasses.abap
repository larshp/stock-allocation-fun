CLASS ltcl_alloc_pack_slip DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pack_slip.
    DATA mt_lin TYPE zcl_alloc_pack_slip=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_mat     TYPE string
        iv_ordered TYPE i
        iv_picked  TYPE i.

    METHODS full_line    FOR TESTING.
    METHODS partial_line FOR TESTING.
    METHODS none_line    FOR TESTING.
    METHODS over_picked  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pack_slip IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pack_slip( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_pack_slip=>ty_line.

    ls_line-material = iv_mat.
    ls_line-ordered = iv_ordered.
    ls_line-picked = iv_picked.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD full_line.
    DATA lt_slip TYPE zcl_alloc_pack_slip=>ty_slip_tt.

    add( iv_mat = 'M1' iv_ordered = 10 iv_picked = 10 ).

    lt_slip = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_slip[ 1 ]-status exp = 'FULL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_slip[ 1 ]-backorder exp = 0 ).
  ENDMETHOD.

  METHOD partial_line.
    DATA lt_slip TYPE zcl_alloc_pack_slip=>ty_slip_tt.

    add( iv_mat = 'M1' iv_ordered = 10 iv_picked = 4 ).

    lt_slip = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_slip[ 1 ]-status exp = 'PARTIAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_slip[ 1 ]-backorder exp = 6 ).
  ENDMETHOD.

  METHOD none_line.
    DATA lt_slip TYPE zcl_alloc_pack_slip=>ty_slip_tt.

    add( iv_mat = 'M1' iv_ordered = 10 iv_picked = 0 ).

    lt_slip = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_slip[ 1 ]-status exp = 'NONE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_slip[ 1 ]-backorder exp = 10 ).
  ENDMETHOD.

  METHOD over_picked.
    DATA lt_slip TYPE zcl_alloc_pack_slip=>ty_slip_tt.

    add( iv_mat = 'M1' iv_ordered = 10 iv_picked = 12 ).

    lt_slip = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_slip[ 1 ]-status exp = 'FULL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_slip[ 1 ]-backorder exp = 0 ).
  ENDMETHOD.

ENDCLASS.
