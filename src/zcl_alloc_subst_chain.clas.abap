CLASS zcl_alloc_subst_chain DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_matnr_tt TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rule,
             from_matnr TYPE matnr,
             to_matnr   TYPE matnr,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             path        TYPE ty_matnr_tt,
             final_matnr TYPE matnr,
             steps       TYPE i,
           END OF ty_result.

    TYPES: BEGIN OF ty_input,
             rules       TYPE ty_rule_tt,
             start_matnr TYPE matnr,
           END OF ty_input.

    METHODS resolve
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_subst_chain IMPLEMENTATION.

  METHOD resolve.
    DATA lv_current TYPE matnr.
    DATA lv_next    TYPE matnr.
    DATA lv_steps   TYPE i.

    lv_current = is_input-start_matnr.
    APPEND lv_current TO rs_result-path.

    WHILE lv_steps < lines( is_input-rules ).
      CLEAR lv_next.

      LOOP AT is_input-rules INTO DATA(ls_rule).
        IF ls_rule-from_matnr = lv_current.
          lv_next = ls_rule-to_matnr.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_next IS INITIAL.
        EXIT.
      ENDIF.

      lv_current = lv_next.
      APPEND lv_current TO rs_result-path.
      lv_steps = lv_steps + 1.
    ENDWHILE.

    rs_result-final_matnr = lv_current.
    rs_result-steps = lv_steps.
  ENDMETHOD.

ENDCLASS.
