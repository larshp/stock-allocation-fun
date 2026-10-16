CLASS zcl_alloc_stop_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stop,
             stop_id TYPE string,
             x       TYPE i,
             y       TYPE i,
           END OF ty_stop.
    TYPES ty_stop_tt TYPE STANDARD TABLE OF ty_stop WITH DEFAULT KEY.

    METHODS sequence
      IMPORTING
        it_stops        TYPE ty_stop_tt
        iv_x            TYPE i
        iv_y            TYPE i
      RETURNING
        VALUE(rt_stops) TYPE ty_stop_tt.

  PRIVATE SECTION.
    METHODS distance
      IMPORTING
        iv_x1          TYPE i
        iv_y1          TYPE i
        iv_x2          TYPE i
        iv_y2          TYPE i
      RETURNING
        VALUE(rv_dist) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stop_seq IMPLEMENTATION.

  METHOD distance.
    DATA lv_dx TYPE i.
    DATA lv_dy TYPE i.

    " Manhattan distance, written without the ABS built-in so the arithmetic is
    " the same on every runtime.
    lv_dx = iv_x2 - iv_x1.
    IF lv_dx < 0.
      lv_dx = 0 - lv_dx.
    ENDIF.

    lv_dy = iv_y2 - iv_y1.
    IF lv_dy < 0.
      lv_dy = 0 - lv_dy.
    ENDIF.

    rv_dist = lv_dx + lv_dy.
  ENDMETHOD.

  METHOD sequence.
    DATA lt_remaining TYPE ty_stop_tt.
    DATA lv_cur_x     TYPE i.
    DATA lv_cur_y     TYPE i.
    DATA lv_best      TYPE i.
    DATA lv_best_dist TYPE i.
    DATA lv_dist      TYPE i.

    lt_remaining = it_stops.
    lv_cur_x = iv_x.
    lv_cur_y = iv_y.

    " Nearest neighbour from the depot: always drive to the closest stop left.
    WHILE lines( lt_remaining ) > 0.
      CLEAR lv_best.
      CLEAR lv_best_dist.

      LOOP AT lt_remaining INTO DATA(ls_stop).
        lv_dist = distance( iv_x1 = lv_cur_x
                            iv_y1 = lv_cur_y
                            iv_x2 = ls_stop-x
                            iv_y2 = ls_stop-y ).

        IF lv_best = 0 OR lv_dist < lv_best_dist.
          lv_best = sy-tabix.
          lv_best_dist = lv_dist.
        ENDIF.
      ENDLOOP.

      READ TABLE lt_remaining INTO DATA(ls_chosen) INDEX lv_best.
      APPEND ls_chosen TO rt_stops.

      lv_cur_x = ls_chosen-x.
      lv_cur_y = ls_chosen-y.
      DELETE lt_remaining INDEX lv_best.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
