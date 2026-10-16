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
    DATA lt_working TYPE HASHED TABLE OF ty_result WITH UNIQUE KEY matnr werks.
    DATA ls_new     TYPE ty_result.
    DATA lv_better  TYPE abap_bool.

    LOOP AT it_rules INTO DATA(ls_rule).
      " A hashed working table keeps the rule lookup constant time, so the
      " evaluation cost grows with the number of rules instead of scanning the
      " result table once per rule.
      READ TABLE lt_working ASSIGNING FIELD-SYMBOL(<ls_result>)
        WITH KEY matnr = ls_rule-matnr werks = ls_rule-werks.

      IF sy-subrc = 0.
        <ls_result>-shares = <ls_result>-shares + 1.

        lv_better = abap_false.
        IF ls_rule-priority < <ls_result>-priority.
          lv_better = abap_true.
        ELSEIF ls_rule-priority = <ls_result>-priority
           AND ls_rule-quota_pct > <ls_result>-quota_pct.
          lv_better = abap_true.
        ENDIF.

        IF lv_better = abap_true.
          <ls_result>-source_node = ls_rule-source_node.
          <ls_result>-priority = ls_rule-priority.
          <ls_result>-quota_pct = ls_rule-quota_pct.
        ENDIF.

        CONTINUE.
      ENDIF.

      CLEAR ls_new.
      ls_new-matnr = ls_rule-matnr.
      ls_new-werks = ls_rule-werks.
      ls_new-source_node = ls_rule-source_node.
      ls_new-priority = ls_rule-priority.
      ls_new-quota_pct = ls_rule-quota_pct.
      ls_new-shares = 1.
      INSERT ls_new INTO TABLE lt_working.
    ENDLOOP.

    rt_results = lt_working.
  ENDMETHOD.

ENDCLASS.
