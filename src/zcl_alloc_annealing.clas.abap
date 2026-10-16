CLASS zcl_alloc_annealing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_point,
             point_value TYPE i,
             score       TYPE i,
           END OF ty_point.
    TYPES ty_point_tt TYPE STANDARD TABLE OF ty_point WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             best_value     TYPE i,
             best_score     TYPE i,
             final_value    TYPE i,
             steps          TYPE i,
             accepted_worse TYPE i,
           END OF ty_result.

    METHODS anneal
      IMPORTING
        it_points        TYPE ty_point_tt
        iv_start         TYPE i
        iv_step          TYPE i
        iv_max_steps     TYPE i
        iv_start_temp    TYPE i
        iv_cool_pct      TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS score_of
      IMPORTING
        it_points       TYPE ty_point_tt
        iv_value        TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

    METHODS is_known
      IMPORTING
        it_points       TYPE ty_point_tt
        iv_value        TYPE i
      RETURNING
        VALUE(rv_known) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_annealing IMPLEMENTATION.

  METHOD score_of.
    READ TABLE it_points INTO DATA(ls_point) WITH KEY point_value = iv_value.

    IF sy-subrc = 0.
      rv_score = ls_point-score.
    ENDIF.
  ENDMETHOD.

  METHOD is_known.
    READ TABLE it_points INTO DATA(ls_point) WITH KEY point_value = iv_value.

    IF sy-subrc = 0.
      rv_known = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD anneal.
    DATA lv_cur        TYPE i.
    DATA lv_cur_score  TYPE i.
    DATA lv_up         TYPE i.
    DATA lv_down       TYPE i.
    DATA lv_up_score   TYPE i.
    DATA lv_down_score TYPE i.
    DATA lv_up_known   TYPE abap_bool.
    DATA lv_down_known TYPE abap_bool.
    DATA lv_next       TYPE i.
    DATA lv_next_score TYPE i.
    DATA lv_temp       TYPE i.
    DATA lv_moved      TYPE abap_bool.
    DATA lv_gap        TYPE i.

    lv_cur = iv_start.
    lv_cur_score = score_of( it_points = it_points
                             iv_value  = iv_start ).

    rs_result-best_value = iv_start.
    rs_result-best_score = lv_cur_score.
    rs_result-final_value = iv_start.

    lv_temp = iv_start_temp.

    DO iv_max_steps TIMES.
      IF iv_step <= 0.
        EXIT.
      ENDIF.

      lv_up = lv_cur + iv_step.
      lv_down = lv_cur - iv_step.

      lv_up_known = is_known( it_points = it_points
                              iv_value  = lv_up ).
      lv_down_known = is_known( it_points = it_points
                                iv_value  = lv_down ).
      lv_up_score = score_of( it_points = it_points
                              iv_value  = lv_up ).
      lv_down_score = score_of( it_points = it_points
                                iv_value  = lv_down ).

      lv_moved = abap_false.
      lv_next = lv_cur.
      lv_next_score = lv_cur_score.

      IF lv_up_known = abap_true.
        IF lv_down_known = abap_false OR lv_up_score >= lv_down_score.
          lv_next = lv_up.
          lv_next_score = lv_up_score.
          lv_moved = abap_true.
        ENDIF.
      ENDIF.

      IF lv_moved = abap_false AND lv_down_known = abap_true.
        lv_next = lv_down.
        lv_next_score = lv_down_score.
        lv_moved = abap_true.
      ENDIF.

      IF lv_moved = abap_false.
        EXIT.
      ENDIF.

      lv_gap = lv_cur_score - lv_next_score.

      IF lv_gap <= 0.
        lv_cur = lv_next.
        lv_cur_score = lv_next_score.
      ELSEIF lv_gap <= lv_temp.
        lv_cur = lv_next.
        lv_cur_score = lv_next_score.
        rs_result-accepted_worse = rs_result-accepted_worse + 1.
      ELSE.
        EXIT.
      ENDIF.

      rs_result-steps = rs_result-steps + 1.
      rs_result-final_value = lv_cur.

      IF lv_cur_score > rs_result-best_score.
        rs_result-best_score = lv_cur_score.
        rs_result-best_value = lv_cur.
      ENDIF.

      IF iv_cool_pct >= 100.
        lv_temp = 0.
      ELSEIF iv_cool_pct > 0.
        lv_temp = lv_temp * ( 100 - iv_cool_pct ) DIV 100.
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
