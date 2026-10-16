CLASS ltcl_alloc_yield_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_rank.
    DATA mt_line TYPE zcl_alloc_yield_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order   TYPE string
        iv_percent TYPE i.

    METHODS ranks_orders FOR TESTING.
    METHODS picks_best   FOR TESTING.
    METHODS picks_worst  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_rank( ).

    add( iv_order = 'O1' iv_percent = 95 ).
    add( iv_order = 'O2' iv_percent = 99 ).
    add( iv_order = 'O3' iv_percent = 90 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_yield_rank=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-percent = iv_percent.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_orders.
    DATA lt_ranked TYPE zcl_alloc_yield_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-percent exp = 99 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-percent exp = 90 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = 99 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 90 ).
  ENDMETHOD.

ENDCLASS.
