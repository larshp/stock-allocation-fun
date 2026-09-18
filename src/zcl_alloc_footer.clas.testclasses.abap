CLASS ltcl_alloc_footer DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_footer.
    DATA mt_line TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS empty_lines   FOR TESTING.
    METHODS sums_total    FOR TESTING.
    METHODS counts_lines  FOR TESTING.
    METHODS keeps_caption FOR TESTING.
    METHODS nets_negative FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_footer IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_footer( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD empty_lines.
    DATA(ls_result) = mo_cut->build( it_lines   = mt_line
                                     iv_caption = 'Totals' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines exp = 0 ).
  ENDMETHOD.

  METHOD sums_total.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 20 ).
    add( iv_id = 'R3' iv_qty = 30 ).

    DATA(ls_result) = mo_cut->build( it_lines   = mt_line
                                     iv_caption = 'Totals' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total exp = 60 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 20 ).

    DATA(ls_result) = mo_cut->build( it_lines   = mt_line
                                     iv_caption = 'Totals' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-lines exp = 2 ).
  ENDMETHOD.

  METHOD keeps_caption.
    add( iv_id = 'R1' iv_qty = 1 ).

    DATA(ls_result) = mo_cut->build( it_lines   = mt_line
                                     iv_caption = 'Sum of allocations' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-caption exp = 'Sum of allocations' ).
  ENDMETHOD.

  METHOD nets_negative.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = -5 ).

    DATA(ls_result) = mo_cut->build( it_lines   = mt_line
                                     iv_caption = 'Totals' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines exp = 2 ).
  ENDMETHOD.

ENDCLASS.
