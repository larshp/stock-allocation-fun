CLASS ltcl_alloc_wip_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_rank.
    DATA mt_line TYPE zcl_alloc_wip_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_value TYPE i.

    METHODS ranks_orders  FOR TESTING.
    METHODS picks_largest FOR TESTING.
    METHODS counts_orders FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_rank( ).

    add( iv_order = 'O1' iv_value = 600 ).
    add( iv_order = 'O2' iv_value = 900 ).
    add( iv_order = 'O3' iv_value = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_wip_rank=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_orders.
    DATA lt_ranked TYPE zcl_alloc_wip_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-value exp = 900 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-value exp = 300 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_line ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
