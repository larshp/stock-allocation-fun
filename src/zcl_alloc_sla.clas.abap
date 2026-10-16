CLASS zcl_alloc_sla DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             lead_days      TYPE i,
             target_days    TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             lead_days      TYPE i,
             target_days    TYPE i,
             on_time        TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             lines          TYPE ty_line_tt,
             total          TYPE i,
             on_time        TYPE i,
             breached       TYPE i,
             compliance_pct TYPE i,
           END OF ty_result.

    METHODS assess
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_sla IMPLEMENTATION.

  METHOD assess.
    DATA ls_line TYPE ty_line.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_line.
      ls_line-requirement_id = ls_item-requirement_id.
      ls_line-lead_days = ls_item-lead_days.
      ls_line-target_days = ls_item-target_days.
      IF ls_item-lead_days <= ls_item-target_days.
        ls_line-on_time = abap_true.
      ENDIF.
      APPEND ls_line TO rs_result-lines.

      rs_result-total = rs_result-total + 1.
      IF ls_line-on_time = abap_true.
        rs_result-on_time = rs_result-on_time + 1.
      ELSE.
        rs_result-breached = rs_result-breached + 1.
      ENDIF.
    ENDLOOP.

    IF rs_result-total > 0.
      rs_result-compliance_pct = rs_result-on_time * 100 DIV rs_result-total.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
