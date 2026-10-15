CLASS ltcl_alloc_bom_rollup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_rollup.
    DATA mt_line TYPE zcl_alloc_bom_rollup=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_group TYPE string
        iv_qty   TYPE i.

    METHODS rolls_up      FOR TESTING.
    METHODS counts_groups FOR TESTING.
    METHODS picks_largest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_rollup IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_rollup( ).

    add( iv_group = 'G1' iv_qty = 2 ).
    add( iv_group = 'G2' iv_qty = 3 ).
    add( iv_group = 'G1' iv_qty = 1 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_rollup=>ty_line.

    ls_line-group = iv_group.
    ls_line-qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD rolls_up.
    DATA lt_group TYPE zcl_alloc_bom_rollup=>ty_group_tt.

    lt_group = mo_cut->rollup( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_group ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_group[ 1 ]-group exp = 'G1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_group[ 1 ]-total exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_group[ 2 ]-total exp = 3 ).
  ENDMETHOD.

  METHOD counts_groups.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
