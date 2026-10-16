CLASS ltcl_alloc_prep_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_rank.
    DATA mt_line TYPE zcl_alloc_prep_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i.

    METHODS ranks_orders FOR TESTING.
    METHODS picks_worst  FOR TESTING.
    METHODS picks_best   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_rank( ).

    add( iv_order = 'O1' iv_cost = 50 ).
    add( iv_order = 'O2' iv_cost = 120 ).
    add( iv_order = 'O3' iv_cost = 80 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_rank=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_orders.
    DATA lt_ranked TYPE zcl_alloc_prep_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-cost exp = 120 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-cost exp = 50 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 120 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = 50 ).
  ENDMETHOD.

ENDCLASS.
