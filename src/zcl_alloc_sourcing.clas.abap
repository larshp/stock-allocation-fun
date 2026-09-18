CLASS zcl_alloc_sourcing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             matnr       TYPE matnr,
             werks       TYPE werks_d,
             source_node TYPE string,
             priority    TYPE i,
             quota_pct   TYPE i,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             matnr       TYPE matnr,
             werks       TYPE werks_d,
             source_node TYPE string,
             priority    TYPE i,
             quota_pct   TYPE i,
             shares      TYPE i,
           END OF ty_result.
    TYPES ty_result_tt TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    METHODS evaluate
      IMPORTING
        it_rules          TYPE ty_rule_tt
      RETURNING
        VALUE(rt_results) TYPE ty_result_tt.

ENDCLASS.


CLASS zcl_alloc_sourcing IMPLEMENTATION.

  METHOD evaluate.
    DATA ls_row    TYPE ty_result.
    DATA ls_new    TYPE ty_result.
    DATA lv_better TYPE abap_bool.

    LOOP AT it_rules INTO DATA(ls_rule).
      READ TABLE rt_results INTO ls_row
        WITH KEY matnr = ls_rule-matnr werks = ls_rule-werks.

      IF sy-subrc = 0.
        ls_new = ls_row.
        ls_new-shares = ls_row-shares + 1.

        lv_better = abap_false.
        IF ls_rule-priority < ls_row-priority.
          lv_better = abap_true.
        ELSEIF ls_rule-priority = ls_row-priority
           AND ls_rule-quota_pct > ls_row-quota_pct.
          lv_better = abap_true.
        ENDIF.

        IF lv_better = abap_true.
          ls_new-source_node = ls_rule-source_node.
          ls_new-priority = ls_rule-priority.
          ls_new-quota_pct = ls_rule-quota_pct.
        ENDIF.

        DELETE rt_results WHERE matnr = ls_rule-matnr
                            AND werks = ls_rule-werks.
        APPEND ls_new TO rt_results.
        CONTINUE.
      ENDIF.

      CLEAR ls_new.
      ls_new-matnr = ls_rule-matnr.
      ls_new-werks = ls_rule-werks.
      ls_new-source_node = ls_rule-source_node.
      ls_new-priority = ls_rule-priority.
      ls_new-quota_pct = ls_rule-quota_pct.
      ls_new-shares = 1.
      APPEND ls_new TO rt_results.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
