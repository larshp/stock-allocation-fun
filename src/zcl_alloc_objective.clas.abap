CLASS zcl_alloc_objective DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             line_key  TYPE string,
             quantity  TYPE menge_d,
             unit_cost TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_weights,
             quantity_weight TYPE i,
             cost_weight     TYPE i,
           END OF ty_weights.

    TYPES: BEGIN OF ty_score,
             total_quantity TYPE menge_d,
             total_cost     TYPE menge_d,
             weighted_score TYPE menge_d,
           END OF ty_score.

    METHODS score
      IMPORTING
        it_lines        TYPE ty_line_tt
        is_weights      TYPE ty_weights
      RETURNING
        VALUE(rs_score) TYPE ty_score.

ENDCLASS.


CLASS zcl_alloc_objective IMPLEMENTATION.

  METHOD score.
    DATA lv_gain TYPE menge_d.
    DATA lv_cost TYPE menge_d.

    LOOP AT it_lines INTO DATA(ls_line).
      rs_score-total_quantity = rs_score-total_quantity + ls_line-quantity.
      rs_score-total_cost =
        rs_score-total_cost + ls_line-quantity * ls_line-unit_cost.
    ENDLOOP.

    lv_gain = is_weights-quantity_weight * rs_score-total_quantity.
    lv_cost = is_weights-cost_weight * rs_score-total_cost.
    rs_score-weighted_score = lv_gain - lv_cost.
  ENDMETHOD.

ENDCLASS.
