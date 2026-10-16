CLASS ltcl_alloc_prep_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_report.
    DATA mt_line TYPE zcl_alloc_prep_report=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i.

    METHODS builds_report FOR TESTING.
    METHODS counts_orders FOR TESTING.
    METHODS sums_total    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_report( ).

    add( iv_order = 'O1' iv_cost = 100 ).
    add( iv_order = 'O2' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_report=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_report.
    DATA ls_report TYPE zcl_alloc_prep_report=>ty_report.

    ls_report = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_report-order_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-total exp = 400 ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 400 ).
  ENDMETHOD.

ENDCLASS.
