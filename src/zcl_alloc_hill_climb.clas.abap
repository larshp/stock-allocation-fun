CLASS zcl_alloc_hill_climb DEFINITION
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
             best_value TYPE i,
             best_score TYPE i,
             steps      TYPE i,
             reached    TYPE abap_bool,
           END OF ty_result.

    METHODS climb
      IMPORTING
        it_points        TYPE ty_point_tt
        iv_start         TYPE i
        iv_step          TYPE i
        iv_max_steps     TYPE i
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


CLASS zcl_alloc_hill_climb IMPLEMENTATION.

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

  METHOD climb.
    DATA lv_cur        TYPE i.
    DATA lv_cur_score  TYPE i.
    DATA lv_up         TYPE i.
    DATA lv_down       TYPE i.
    DATA lv_up_score   TYPE i.
    DATA lv_down_score TYPE i.
    DATA lv_next       TYPE i.
    DATA lv_next_score TYPE i.
    DATA lv_moved      TYPE abap_bool.

    rs_result-reached = is_known( it_points = it_points
                                  iv_value  = iv_start ).
    rs_result-best_value = iv_start.
    rs_result-best_score = score_of( it_points = it_points
                                     iv_value  = iv_start ).

    lv_cur = iv_start.
    lv_cur_score = rs_result-best_score.

    DO iv_max_steps TIMES.
      IF iv_step <= 0.
        EXIT.
      ENDIF.

      lv_up = lv_cur + iv_step.
      lv_down = lv_cur - iv_step.
      lv_up_score = score_of( it_points = it_points
                              iv_value  = lv_up ).
      lv_down_score = score_of( it_points = it_points
                                iv_value  = lv_down ).

      lv_next = lv_cur.
      lv_next_score = lv_cur_score.
      lv_moved = abap_false.

      IF is_known( it_points = it_points iv_value = lv_up ) = abap_true
         AND lv_up_score > lv_next_score.
        lv_next = lv_up.
        lv_next_score = lv_up_score.
        lv_moved = abap_true.
      ENDIF.

      IF is_known( it_points = it_points iv_value = lv_down ) = abap_true
         AND lv_down_score > lv_next_score.
        lv_next = lv_down.
        lv_next_score = lv_down_score.
        lv_moved = abap_true.
      ENDIF.

      IF lv_moved = abap_false.
        EXIT.
      ENDIF.

      lv_cur = lv_next.
      lv_cur_score = lv_next_score.
      rs_result-steps = rs_result-steps + 1.

      IF lv_cur_score > rs_result-best_score.
        rs_result-best_score = lv_cur_score.
        rs_result-best_value = lv_cur.
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
