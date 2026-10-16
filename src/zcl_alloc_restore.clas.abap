CLASS zcl_alloc_restore DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_action,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             action         TYPE string,
             target_qty     TYPE menge_d,
             current_qty    TYPE menge_d,
           END OF ty_action.
    TYPES ty_action_tt TYPE STANDARD TABLE OF ty_action WITH DEFAULT KEY.

    METHODS plan
      IMPORTING
        it_target         TYPE zcl_alloc_snap_heavy=>ty_entry_tt
        it_current        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_actions) TYPE ty_action_tt.

ENDCLASS.


CLASS zcl_alloc_restore IMPLEMENTATION.

  METHOD plan.
    DATA ls_action TYPE ty_action.
    DATA lv_found  TYPE abap_bool.

    LOOP AT it_target INTO DATA(ls_target).
      READ TABLE it_current INTO DATA(ls_current)
        WITH KEY requirement_id = ls_target-requirement_id.
      IF sy-subrc = 0.
        lv_found = abap_true.
      ELSE.
        lv_found = abap_false.
      ENDIF.

      CLEAR ls_action.
      ls_action-requirement_id = ls_target-requirement_id.
      ls_action-target_qty = ls_target-allocated_qty.

      IF lv_found = abap_false.
        ls_action-action = 'create'.
        APPEND ls_action TO rt_actions.
        CONTINUE.
      ENDIF.

      IF ls_target-allocated_qty = ls_current-allocated_qty.
        CONTINUE.
      ENDIF.

      ls_action-action = 'update'.
      ls_action-current_qty = ls_current-allocated_qty.
      APPEND ls_action TO rt_actions.
    ENDLOOP.

    LOOP AT it_current INTO DATA(ls_extra).
      READ TABLE it_target INTO DATA(ls_known)
        WITH KEY requirement_id = ls_extra-requirement_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_action.
      ls_action-requirement_id = ls_extra-requirement_id.
      ls_action-action = 'delete'.
      ls_action-current_qty = ls_extra-allocated_qty.
      APPEND ls_action TO rt_actions.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
