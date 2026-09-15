CLASS zcl_alloc_over_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_over,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             requested_qty  TYPE menge_d,
             allocated_qty  TYPE menge_d,
           END OF ty_over.
    TYPES ty_over_tt TYPE STANDARD TABLE OF ty_over WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_overs) TYPE ty_over_tt.

ENDCLASS.


CLASS zcl_alloc_over_check IMPLEMENTATION.

  METHOD find.
    DATA ls_over TYPE ty_over.

    LOOP AT it_result INTO DATA(ls_result).
      IF ls_result-allocated_qty <= ls_result-requested_qty.
        CONTINUE.
      ENDIF.

      CLEAR ls_over.
      ls_over-requirement_id = ls_result-requirement_id.
      ls_over-requested_qty = ls_result-requested_qty.
      ls_over-allocated_qty = ls_result-allocated_qty.
      APPEND ls_over TO rt_overs.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
