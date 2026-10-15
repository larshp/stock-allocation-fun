CLASS ltcl_alloc_wip_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_summary.
    DATA mt_line TYPE zcl_alloc_wip_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_value TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_orders  FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_summary( ).

    add( iv_order = 'O1' iv_value = 600 ).
    add( iv_order = 'O2' iv_value = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_wip_summary=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_wip_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-order_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 900 ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 900 ).
  ENDMETHOD.

ENDCLASS.
