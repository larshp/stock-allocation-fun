CLASS ltcl_alloc_replenish_approve DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_approve.
    DATA mt_line TYPE zcl_alloc_replenish_approve=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_approved TYPE abap_bool.

    METHODS approves_lines FOR TESTING.
    METHODS reads_approval  FOR TESTING.
    METHODS counts_pending  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_approve IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_approve( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_replenish_approve=>ty_line.

    ls_line-material = iv_material.
    ls_line-approved = iv_approved.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD approves_lines.
    DATA lt_line TYPE zcl_alloc_replenish_approve=>ty_line_tt.

    add( iv_material = 'M1' iv_approved = abap_false ).
    add( iv_material = 'M2' iv_approved = abap_false ).

    lt_line = mo_cut->approve( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_line[ 1 ]-approved exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_line[ 2 ]-approved exp = abap_true ).
  ENDMETHOD.

  METHOD reads_approval.
    add( iv_material = 'M1' iv_approved = abap_true ).
    add( iv_material = 'M2' iv_approved = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = mt_line iv_material = 'M1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = mt_line iv_material = 'M2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    add( iv_material = 'M1' iv_approved = abap_true ).
    add( iv_material = 'M2' iv_approved = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
