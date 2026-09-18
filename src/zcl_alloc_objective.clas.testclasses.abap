CLASS ltcl_alloc_objective DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_objective.
    DATA mt_line TYPE zcl_alloc_objective=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_qty  TYPE menge_d
        iv_cost TYPE menge_d.

    METHODS make_weights
      IMPORTING
        iv_qty_weight     TYPE i
        iv_cost_weight    TYPE i
      RETURNING
        VALUE(rs_weights) TYPE zcl_alloc_objective=>ty_weights.

    METHODS empty_input_zero FOR TESTING.
    METHODS sums_quantities  FOR TESTING.
    METHODS sums_cost        FOR TESTING.
    METHODS weighted_gain    FOR TESTING.
    METHODS weighted_penalty FOR TESTING.
    METHODS zero_weights     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_objective IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_objective( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_objective=>ty_line.

    ls_line-line_key = iv_key.
    ls_line-quantity = iv_qty.
    ls_line-unit_cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD make_weights.
    rs_weights-quantity_weight = iv_qty_weight.
    rs_weights-cost_weight = iv_cost_weight.
  ENDMETHOD.

  METHOD empty_input_zero.
    DATA(ls_weights) = make_weights( iv_qty_weight = 1 iv_cost_weight = 1 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-total_quantity exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_score-total_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = 0 ).
  ENDMETHOD.

  METHOD sums_quantities.
    add( iv_key = 'A' iv_qty = 10 iv_cost = 2 ).
    add( iv_key = 'B' iv_qty = 5 iv_cost = 4 ).

    DATA(ls_weights) = make_weights( iv_qty_weight = 1 iv_cost_weight = 0 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-total_quantity exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = 15 ).
  ENDMETHOD.

  METHOD sums_cost.
    add( iv_key = 'A' iv_qty = 10 iv_cost = 2 ).
    add( iv_key = 'B' iv_qty = 5 iv_cost = 4 ).

    DATA(ls_weights) = make_weights( iv_qty_weight = 0 iv_cost_weight = 1 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-total_cost exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = -40 ).
  ENDMETHOD.

  METHOD weighted_gain.
    add( iv_key = 'A' iv_qty = 10 iv_cost = 1 ).

    DATA(ls_weights) = make_weights( iv_qty_weight = 3 iv_cost_weight = 1 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = 20 ).
  ENDMETHOD.

  METHOD weighted_penalty.
    add( iv_key = 'A' iv_qty = 2 iv_cost = 10 ).

    DATA(ls_weights) = make_weights( iv_qty_weight = 1 iv_cost_weight = 5 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = -98 ).
  ENDMETHOD.

  METHOD zero_weights.
    add( iv_key = 'A' iv_qty = 7 iv_cost = 3 ).

    DATA(ls_weights) = make_weights( iv_qty_weight = 0 iv_cost_weight = 0 ).
    DATA(ls_score) = mo_cut->score( it_lines   = mt_line
                                    is_weights = ls_weights ).

    cl_abap_unit_assert=>assert_equals( act = ls_score-weighted_score exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_score-total_quantity exp = 7 ).
  ENDMETHOD.

ENDCLASS.
