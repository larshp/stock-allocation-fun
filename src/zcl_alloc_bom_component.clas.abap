CLASS zcl_alloc_bom_component DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             qty       TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS qty_of
      IMPORTING
        it_lines      TYPE ty_line_tt
        iv_component  TYPE string
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS is_used
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_component TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_component IMPLEMENTATION.

  METHOD qty_of.
    " The quantity of one component across the BOM.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-component = iv_component.
        rv_qty = rv_qty + ls_line-qty.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_used.
    " A component is used once it appears in the BOM.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-component = iv_component.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    DATA lv_idx TYPE i.
    DATA lv_pos TYPE i.
    DATA lv_dup TYPE abap_bool.

    " The count is the number of distinct components.
    LOOP AT it_lines INTO DATA(ls_outer).
      lv_idx = lv_idx + 1.
      lv_dup = abap_false.
      lv_pos = 0.
      LOOP AT it_lines INTO DATA(ls_inner).
        lv_pos = lv_pos + 1.
        IF lv_pos < lv_idx AND ls_inner-component = ls_outer-component.
          lv_dup = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_dup = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
