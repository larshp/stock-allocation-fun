CLASS zcl_alloc_rma_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_reason_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS is_valid
      IMPORTING
        is_line      TYPE zcl_alloc_rma=>ty_line
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reasons
      IMPORTING
        is_line          TYPE zcl_alloc_rma=>ty_line
      RETURNING
        VALUE(rt_reason) TYPE ty_reason_tt.

    METHODS reject
      IMPORTING
        it_lines      TYPE zcl_alloc_rma=>ty_line_tt
      RETURNING
        VALUE(rt_bad) TYPE zcl_alloc_rma=>ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_rma_check IMPLEMENTATION.

  METHOD is_valid.
    rv_ok = xsdbool( is_line-material IS NOT INITIAL
                     AND is_line-quantity > 0
                     AND is_line-reason IS NOT INITIAL ).
  ENDMETHOD.

  METHOD reasons.
    " Every fault is reported, not just the first, so a caller can show the whole
    " line's problem in one go.
    IF is_line-material IS INITIAL.
      APPEND 'MATERIAL_MISSING' TO rt_reason.
    ENDIF.

    IF is_line-quantity <= 0.
      APPEND 'QUANTITY_NOT_POSITIVE' TO rt_reason.
    ENDIF.

    IF is_line-reason IS INITIAL.
      APPEND 'REASON_MISSING' TO rt_reason.
    ENDIF.
  ENDMETHOD.

  METHOD reject.
    LOOP AT it_lines INTO DATA(ls_line).
      IF is_valid( ls_line ) = abap_false.
        APPEND ls_line TO rt_bad.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
