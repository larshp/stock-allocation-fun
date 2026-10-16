CLASS zcl_alloc_knapsack DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             item_id TYPE string,
             weight  TYPE i,
             value   TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cell,
             item_index TYPE i,
             capacity   TYPE i,
             best       TYPE i,
           END OF ty_cell.
    TYPES ty_cell_tt TYPE STANDARD TABLE OF ty_cell WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_choice,
             item_index TYPE i,
           END OF ty_choice.
    TYPES ty_choice_tt TYPE STANDARD TABLE OF ty_choice WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             chosen_ids   TYPE ty_ids_tt,
             total_weight TYPE i,
             total_value  TYPE i,
           END OF ty_result.

    METHODS solve
      IMPORTING
        it_items         TYPE ty_item_tt
        iv_capacity      TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS cell_of
      IMPORTING
        it_cells       TYPE ty_cell_tt
        iv_item        TYPE i
        iv_capacity    TYPE i
      RETURNING
        VALUE(rv_best) TYPE i.

ENDCLASS.


CLASS zcl_alloc_knapsack IMPLEMENTATION.

  METHOD cell_of.
    READ TABLE it_cells INTO DATA(ls_cell)
      WITH KEY item_index = iv_item capacity = iv_capacity.

    IF sy-subrc = 0.
      rv_best = ls_cell-best.
    ENDIF.
  ENDMETHOD.

  METHOD solve.
    DATA lt_cells  TYPE ty_cell_tt.
    DATA lt_taken  TYPE ty_choice_tt.
    DATA ls_cell   TYPE ty_cell.
    DATA ls_choice TYPE ty_choice.
    DATA lv_count  TYPE i.
    DATA lv_rows   TYPE i.
    DATA lv_index  TYPE i.
    DATA lv_cap    TYPE i.
    DATA lv_best   TYPE i.
    DATA lv_alt    TYPE i.

    lv_count = lines( it_items ).
    IF lv_count = 0 OR iv_capacity < 0.
      RETURN.
    ENDIF.

    lv_rows = iv_capacity + 1.

    lv_cap = 0.
    WHILE lv_cap < lv_rows.
      CLEAR ls_cell.
      ls_cell-item_index = 0.
      ls_cell-capacity = lv_cap.
      APPEND ls_cell TO lt_cells.
      lv_cap = lv_cap + 1.
    ENDWHILE.

    lv_index = 0.
    LOOP AT it_items INTO DATA(ls_item).
      lv_index = lv_index + 1.

      lv_cap = 0.
      WHILE lv_cap < lv_rows.
        lv_best = cell_of( it_cells    = lt_cells
                           iv_item     = lv_index - 1
                           iv_capacity = lv_cap ).

        IF ls_item-weight >= 0 AND ls_item-weight <= lv_cap.
          lv_alt = cell_of( it_cells    = lt_cells
                            iv_item     = lv_index - 1
                            iv_capacity = lv_cap - ls_item-weight ).
          lv_alt = lv_alt + ls_item-value.

          IF lv_alt > lv_best.
            lv_best = lv_alt.
          ENDIF.
        ENDIF.

        CLEAR ls_cell.
        ls_cell-item_index = lv_index.
        ls_cell-capacity = lv_cap.
        ls_cell-best = lv_best.
        APPEND ls_cell TO lt_cells.

        lv_cap = lv_cap + 1.
      ENDWHILE.
    ENDLOOP.

    lv_cap = iv_capacity.
    lv_index = lv_count.

    WHILE lv_index > 0.
      READ TABLE it_items INTO DATA(ls_current) INDEX lv_index.

      lv_best = cell_of( it_cells    = lt_cells
                         iv_item     = lv_index
                         iv_capacity = lv_cap ).
      lv_alt = cell_of( it_cells    = lt_cells
                        iv_item     = lv_index - 1
                        iv_capacity = lv_cap ).

      IF lv_best <> lv_alt.
        CLEAR ls_choice.
        ls_choice-item_index = lv_index.
        APPEND ls_choice TO lt_taken.
        lv_cap = lv_cap - ls_current-weight.
      ENDIF.

      lv_index = lv_index - 1.
    ENDWHILE.

    SORT lt_taken BY item_index ASCENDING.

    LOOP AT lt_taken INTO ls_choice.
      READ TABLE it_items INTO DATA(ls_chosen) INDEX ls_choice-item_index.
      APPEND ls_chosen-item_id TO rs_result-chosen_ids.
      rs_result-total_weight = rs_result-total_weight + ls_chosen-weight.
      rs_result-total_value = rs_result-total_value + ls_chosen-value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
