CLASS ltcl_alloc_uplift DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_uplift.
    DATA mt_base TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS make_input
      IMPORTING
        iv_pct          TYPE i
        iv_abs          TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_uplift=>ty_input.

    METHODS raises_by_percent FOR TESTING.
    METHODS adds_absolute     FOR TESTING.
    METHODS combines_both     FOR TESTING.
    METHODS clamps_at_zero    FOR TESTING.
    METHODS empty_input       FOR TESTING.
    METHODS total_of_sums     FOR TESTING.
    METHODS keeps_line_count  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_uplift IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_uplift( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_base.
  ENDMETHOD.

  METHOD make_input.
    rs_input-uplift_pct = iv_pct.
    rs_input-uplift_abs = iv_abs.
  ENDMETHOD.

  METHOD raises_by_percent.
    add( iv_id = 'R1' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_pct = 50 iv_abs = 0 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 15 ).
  ENDMETHOD.

  METHOD adds_absolute.
    add( iv_id = 'R1' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_pct = 0 iv_abs = 5 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 15 ).
  ENDMETHOD.

  METHOD combines_both.
    add( iv_id = 'R1' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_pct = 50 iv_abs = 5 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 20 ).
  ENDMETHOD.

  METHOD clamps_at_zero.
    add( iv_id = 'R1' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_pct = -100 iv_abs = -5 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 0 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA(ls_input) = make_input( iv_pct = 50 iv_abs = 5 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 0 ).
  ENDMETHOD.

  METHOD total_of_sums.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_of( mt_base ) exp = 35 ).
  ENDMETHOD.

  METHOD keeps_line_count.
    add( iv_id = 'R1' iv_qty = 1 ).
    add( iv_id = 'R2' iv_qty = 2 ).
    add( iv_id = 'R3' iv_qty = 3 ).

    DATA(ls_input) = make_input( iv_pct = 10 iv_abs = 0 ).
    DATA(lt_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 3 ]-allocated_qty exp = 3 ).
  ENDMETHOD.

ENDCLASS.
