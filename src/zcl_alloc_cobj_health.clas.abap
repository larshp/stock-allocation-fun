CLASS zcl_alloc_cobj_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_healthy
      IMPORTING
        iv_margin    TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS issue_count
      IMPORTING
        it_margins      TYPE ty_values_tt
        iv_target       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS score
      IMPORTING
        iv_margin       TYPE i
        iv_target       TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cobj_health IMPLEMENTATION.

  METHOD is_healthy.
    " The object is healthy once its margin reaches the target.
    rv_ok = xsdbool( iv_margin >= iv_target ).
  ENDMETHOD.

  METHOD issue_count.
    " An issue is a margin that falls short of the target.
    LOOP AT it_margins INTO DATA(lv_margin).
      IF lv_margin < iv_target.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD score.
    " The score is the margin against the target, held between zero and a hundred.
    IF iv_target <= 0.
      RETURN.
    ENDIF.

    rv_score = iv_margin * 100 DIV iv_target.
    IF rv_score > 100.
      rv_score = 100.
    ENDIF.
    IF rv_score < 0.
      rv_score = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
