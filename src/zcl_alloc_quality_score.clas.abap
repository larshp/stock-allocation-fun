CLASS zcl_alloc_quality_score DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_criterion,
             weight TYPE i,
             score  TYPE i,
           END OF ty_criterion.
    TYPES ty_criterion_tt TYPE STANDARD TABLE OF ty_criterion WITH DEFAULT KEY.

    METHODS score
      IMPORTING
        it_criteria     TYPE ty_criterion_tt
      RETURNING
        VALUE(rv_score) TYPE i.

    METHODS grade
      IMPORTING
        iv_score        TYPE i
      RETURNING
        VALUE(rv_grade) TYPE string.

ENDCLASS.


CLASS zcl_alloc_quality_score IMPLEMENTATION.

  METHOD score.
    DATA lv_weight_sum     TYPE i.
    DATA lv_weighted_total TYPE i.

    " A weighted average over the criteria that carry weight. A criterion with a
    " non-positive weight or a score outside 0-100 is ignored, so a malformed row
    " cannot pull the score out of range.
    LOOP AT it_criteria INTO DATA(ls_criterion).
      IF ls_criterion-weight <= 0.
        CONTINUE.
      ENDIF.
      IF ls_criterion-score < 0 OR ls_criterion-score > 100.
        CONTINUE.
      ENDIF.

      lv_weight_sum = lv_weight_sum + ls_criterion-weight.
      lv_weighted_total = lv_weighted_total
                        + ls_criterion-weight * ls_criterion-score.
    ENDLOOP.

    IF lv_weight_sum = 0.
      RETURN.
    ENDIF.

    rv_score = lv_weighted_total DIV lv_weight_sum.
  ENDMETHOD.

  METHOD grade.
    IF iv_score >= 90.
      rv_grade = 'A'.
    ELSEIF iv_score >= 75.
      rv_grade = 'B'.
    ELSEIF iv_score >= 60.
      rv_grade = 'C'.
    ELSE.
      rv_grade = 'D'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
