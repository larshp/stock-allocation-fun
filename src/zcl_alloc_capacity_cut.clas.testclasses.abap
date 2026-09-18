CLASS ltcl_alloc_capacity_cut DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_capacity_cut.
    DATA mt_base TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS make_input
      IMPORTING
        iv_capacity     TYPE menge_d
        iv_max_line     TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_capacity_cut=>ty_input.

    METHODS no_cut_when_inside FOR TESTING.
    METHODS rations_to_capacity  FOR TESTING.
    METHODS caps_single_line    FOR TESTING.
    METHODS reduced_flag         FOR TESTING.
    METHODS zero_capacity_noop   FOR TESTING.
    METHODS empty_input          FOR TESTING.
    METHODS totals_reported      FOR TESTING.
    METHODS never_negative       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_capacity_cut IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_capacity_cut( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_base.
  ENDMETHOD.

  METHOD make_input.
    rs_input-capacity = iv_capacity.
    rs_input-max_line = iv_max_line.
  ENDMETHOD.

  METHOD no_cut_when_inside.
    add( iv_id = 'R1' iv_qty = 10 ).
    add( iv_id = 'R2' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_capacity = 100 iv_max_line = 0 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-reduced exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_after exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ]-allocated_qty exp = 10 ).
  ENDMETHOD.

  METHOD rations_to_capacity.
    DATA lv_fits TYPE abap_bool.

    add( iv_id = 'R1' iv_qty = 100 ).
    add( iv_id = 'R2' iv_qty = 100 ).
    add( iv_id = 'R3' iv_qty = 100 ).

    DATA(ls_input) = make_input( iv_capacity = 100 iv_max_line = 0 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    IF ls_result-total_after <= 100.
      lv_fits = abap_true.
    ELSE.
      lv_fits = abap_false.
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ]-allocated_qty exp = 33 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_after exp = 99 ).
    cl_abap_unit_assert=>assert_equals( act = lv_fits exp = abap_true ).
  ENDMETHOD.

  METHOD caps_single_line.
    add( iv_id = 'R1' iv_qty = 50 ).
    add( iv_id = 'R2' iv_qty = 5 ).

    DATA(ls_input) = make_input( iv_capacity = 0 iv_max_line = 10 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ]-allocated_qty exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 2 ]-allocated_qty exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_after exp = 15 ).
  ENDMETHOD.

  METHOD reduced_flag.
    add( iv_id = 'R1' iv_qty = 50 ).

    DATA(ls_input) = make_input( iv_capacity = 0 iv_max_line = 10 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-reduced exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_before exp = 50 ).
  ENDMETHOD.

  METHOD zero_capacity_noop.
    add( iv_id = 'R1' iv_qty = 50 ).

    DATA(ls_input) = make_input( iv_capacity = 0 iv_max_line = 0 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_after exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-reduced exp = abap_false ).
  ENDMETHOD.

  METHOD empty_input.
    DATA(ls_input) = make_input( iv_capacity = 10 iv_max_line = 1 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-reduced exp = abap_false ).
  ENDMETHOD.

  METHOD totals_reported.
    add( iv_id = 'R1' iv_qty = 40 ).
    add( iv_id = 'R2' iv_qty = 60 ).

    DATA(ls_input) = make_input( iv_capacity = 50 iv_max_line = 0 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_before exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_after exp = 50 ).
  ENDMETHOD.

  METHOD never_negative.
    add( iv_id = 'R1' iv_qty = -5 ).

    DATA(ls_input) = make_input( iv_capacity = 0 iv_max_line = 0 ).
    DATA(ls_result) = mo_cut->apply( is_input  = ls_input
                                     it_result = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-lines[ 1 ]-allocated_qty exp = 0 ).
  ENDMETHOD.

ENDCLASS.
