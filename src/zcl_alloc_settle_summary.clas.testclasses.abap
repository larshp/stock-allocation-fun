CLASS ltcl_alloc_settle_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_summary.
    DATA mt_line TYPE zcl_alloc_settle_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item   TYPE string
        iv_amount TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_items   FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_summary( ).

    add( iv_item = 'I1' iv_amount = 100 ).
    add( iv_item = 'I2' iv_amount = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_settle_summary=>ty_line.

    ls_line-item = iv_item.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_settle_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-item_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 400 ).
  ENDMETHOD.

  METHOD counts_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->item_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 400 ).
  ENDMETHOD.

ENDCLASS.
