CLASS ltcl_alloc_abc_rollup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_rollup.
    DATA mt_line TYPE zcl_alloc_abc_rollup=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_group TYPE string
        iv_cost  TYPE i.

    METHODS rolls_up      FOR TESTING.
    METHODS counts_groups FOR TESTING.
    METHODS picks_largest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_rollup IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_rollup( ).

    add( iv_group = 'A' iv_cost = 600 ).
    add( iv_group = 'B' iv_cost = 300 ).
    add( iv_group = 'A' iv_cost = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_abc_rollup=>ty_line.

    ls_line-group = iv_group.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD rolls_up.
    DATA lt_groups TYPE zcl_alloc_abc_rollup=>ty_group_tt.

    lt_groups = mo_cut->rollup( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-total exp = 700 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 2 ]-total exp = 300 ).
  ENDMETHOD.

  METHOD counts_groups.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 700 ).
  ENDMETHOD.

ENDCLASS.
