CLASS zcl_alloc_consolidation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             lgort    TYPE lgort_d,
             quantity TYPE menge_d,
             capacity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             bins          TYPE ty_item_tt,
             threshold_pct TYPE i,
           END OF ty_input.

    METHODS propose
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_alloc_consolidation IMPLEMENTATION.

  METHOD propose.
    LOOP AT is_input-bins INTO DATA(ls_bin).
      IF ls_bin-quantity <= 0 OR ls_bin-capacity <= 0.
        CONTINUE.
      ENDIF.

      IF ls_bin-quantity * 100 DIV ls_bin-capacity <= is_input-threshold_pct.
        APPEND ls_bin TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
