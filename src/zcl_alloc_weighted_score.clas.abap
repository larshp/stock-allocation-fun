CLASS zcl_alloc_weighted_score DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             total_weight TYPE i,
             earned       TYPE i,
             score_x10000 TYPE i,
             grade        TYPE string,
           END OF ty_result.

    METHODS score
      IMPORTING
        it_rows          TYPE zcl_alloc_scorecard=>ty_row_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS grade_of
      IMPORTING
        iv_score_x10000 TYPE i
      RETURNING
        VALUE(rv_grade) TYPE string.

ENDCLASS.


CLASS zcl_alloc_weighted_score IMPLEMENTATION.

  METHOD score.
    LOOP AT it_rows INTO DATA(ls_row).
      " A metric without a positive weight cannot influence the result.
      IF ls_row-weight <= 0.
        CONTINUE.
      ENDIF.

      rs_result-total_weight = rs_result-total_weight + ls_row-weight.

      IF ls_row-met = abap_true.
        rs_result-earned = rs_result-earned + ls_row-weight.
      ENDIF.
    ENDLOOP.

    IF rs_result-total_weight = 0.
      rs_result-grade = grade_of( iv_score_x10000 = 0 ).
      RETURN.
    ENDIF.

    " The score is the earned share of the total weight, in ten-thousandths.
    rs_result-score_x10000 =
      rs_result-earned * 10000 DIV rs_result-total_weight.
    rs_result-grade = grade_of( iv_score_x10000 = rs_result-score_x10000 ).
  ENDMETHOD.

  METHOD grade_of.
    IF iv_score_x10000 >= 9000.
      rv_grade = 'A'.
    ELSEIF iv_score_x10000 >= 7500.
      rv_grade = 'B'.
    ELSEIF iv_score_x10000 >= 6000.
      rv_grade = 'C'.
    ELSE.
      rv_grade = 'D'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
