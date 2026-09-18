CLASS zcl_alloc_highlight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             rule_id   TYPE string,
             threshold TYPE menge_d,
             severity  TYPE string,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_hit,
             rule_id  TYPE string,
             severity TYPE string,
           END OF ty_hit.
    TYPES ty_hit_tt TYPE STANDARD TABLE OF ty_hit WITH DEFAULT KEY.

    METHODS apply
      IMPORTING
        it_rules       TYPE ty_rule_tt
        iv_value       TYPE menge_d
      RETURNING
        VALUE(rt_hits) TYPE ty_hit_tt.

    METHODS worst_severity
      IMPORTING
        it_hits            TYPE ty_hit_tt
      RETURNING
        VALUE(rv_severity) TYPE string.

  PRIVATE SECTION.
    METHODS rank_of
      IMPORTING
        iv_severity    TYPE string
      RETURNING
        VALUE(rv_rank) TYPE i.

ENDCLASS.


CLASS zcl_alloc_highlight IMPLEMENTATION.

  METHOD rank_of.
    IF iv_severity = 'error'.
      rv_rank = 3.
    ELSEIF iv_severity = 'warning'.
      rv_rank = 2.
    ELSEIF iv_severity = 'info'.
      rv_rank = 1.
    ENDIF.
  ENDMETHOD.

  METHOD apply.
    DATA ls_hit TYPE ty_hit.

    LOOP AT it_rules INTO DATA(ls_rule).
      " A rule fires when the value reaches its threshold.
      IF iv_value < ls_rule-threshold.
        CONTINUE.
      ENDIF.

      CLEAR ls_hit.
      ls_hit-rule_id = ls_rule-rule_id.
      ls_hit-severity = ls_rule-severity.
      APPEND ls_hit TO rt_hits.
    ENDLOOP.
  ENDMETHOD.

  METHOD worst_severity.
    DATA lv_rank TYPE i.
    DATA lv_best TYPE i.

    LOOP AT it_hits INTO DATA(ls_hit).
      lv_rank = rank_of( iv_severity = ls_hit-severity ).

      IF lv_rank > lv_best.
        lv_best = lv_rank.
        rv_severity = ls_hit-severity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
