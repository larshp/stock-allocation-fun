CLASS ltcl_alloc_row_number DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_row_number.
    DATA mt_line TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS empty_lines   FOR TESTING.
    METHODS numbers_rows  FOR TESTING.
    METHODS copies_amounts FOR TESTING.
    METHODS single_line   FOR TESTING.
    METHODS keeps_order   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_row_number IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_row_number( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD empty_lines.
    DATA(lt_rows) = mo_cut->apply( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( lt_rows ) exp = 0 ).
  ENDMETHOD.

  METHOD numbers_rows.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 20 ).
    add( iv_id = 'R3' iv_qty = 30 ).

    DATA(lt_rows) = mo_cut->apply( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-row_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-row_no exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-row_no exp = 3 ).
  ENDMETHOD.

  METHOD copies_amounts.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 25 ).

    DATA(lt_rows) = mo_cut->apply( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-amount exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-amount exp = 25 ).
  ENDMETHOD.

  METHOD single_line.
    add( iv_id = 'ONLY' iv_qty = 7 ).

    DATA(lt_rows) = mo_cut->apply( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-row_no exp = 1 ).
  ENDMETHOD.

  METHOD keeps_order.
    add( iv_id = 'R1' iv_qty = 1 ).
    add( iv_id = 'R2' iv_qty = 2 ).

    DATA(lt_rows) = mo_cut->apply( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-line_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-line_id exp = 'R2' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( lt_rows ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
