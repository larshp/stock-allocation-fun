CLASS ltcl_alloc_yield_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_summary.
    DATA mt_line TYPE zcl_alloc_yield_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order   TYPE string
        iv_percent TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_orders  FOR TESTING.
    METHODS reads_average  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_summary( ).

    add( iv_order = 'O1' iv_percent = 90 ).
    add( iv_order = 'O2' iv_percent = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_yield_summary=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-percent = iv_percent.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_yield_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-order_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-average exp = 95 ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD reads_average.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_line ) exp = 95 ).
  ENDMETHOD.

ENDCLASS.
