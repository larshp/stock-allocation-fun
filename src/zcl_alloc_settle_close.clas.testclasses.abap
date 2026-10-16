CLASS ltcl_alloc_settle_close DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_close.
    DATA mt_line TYPE zcl_alloc_settle_close=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order  TYPE string
        iv_closed TYPE abap_bool.

    METHODS closes_all   FOR TESTING.
    METHODS closed_rule  FOR TESTING.
    METHODS counts_open  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_close IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_close( ).

    add( iv_order = 'O1' iv_closed = abap_true ).
    add( iv_order = 'O2' iv_closed = abap_false ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_settle_close=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-closed = iv_closed.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD closes_all.
    DATA lt_out TYPE zcl_alloc_settle_close=>ty_line_tt.

    lt_out = mo_cut->close_out( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_out[ 2 ]-closed exp = abap_true ).
  ENDMETHOD.

  METHOD closed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_closed( it_lines = mt_line iv_order = 'O1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_closed( it_lines = mt_line iv_order = 'O2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->open_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
