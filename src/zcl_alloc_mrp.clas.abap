CLASS zcl_alloc_mrp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bom,
             parent_matnr TYPE matnr,
             child_matnr  TYPE matnr,
             qty_per      TYPE menge_d,
           END OF ty_bom.
    TYPES ty_bom_tt TYPE STANDARD TABLE OF ty_bom WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_requirement,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_requirement.
    TYPES ty_requirement_tt TYPE STANDARD TABLE OF ty_requirement
                            WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_planned,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_planned.
    TYPES ty_planned_tt TYPE STANDARD TABLE OF ty_planned WITH DEFAULT KEY.

    METHODS run
      IMPORTING
        it_demand         TYPE ty_requirement_tt
        it_bom            TYPE ty_bom_tt
        iv_levels         TYPE i
      RETURNING
        VALUE(rt_planned) TYPE ty_planned_tt.

  PRIVATE SECTION.
    METHODS bump
      IMPORTING
        it_planned      TYPE ty_planned_tt
        iv_matnr        TYPE matnr
        iv_qty          TYPE menge_d
      RETURNING
        VALUE(rt_added) TYPE ty_planned_tt.

ENDCLASS.


CLASS zcl_alloc_mrp IMPLEMENTATION.

  METHOD bump.
    DATA ls_row TYPE ty_planned.

    rt_added = it_planned.

    READ TABLE rt_added INTO ls_row WITH KEY matnr = iv_matnr.
    IF sy-subrc = 0.
      ls_row-quantity = ls_row-quantity + iv_qty.
      DELETE rt_added WHERE matnr = iv_matnr.
      APPEND ls_row TO rt_added.
      RETURN.
    ENDIF.

    ls_row-matnr = iv_matnr.
    ls_row-quantity = iv_qty.
    APPEND ls_row TO rt_added.
  ENDMETHOD.

  METHOD run.
    DATA lt_totals    TYPE ty_planned_tt.
    DATA lt_level     TYPE ty_planned_tt.
    DATA lt_next      TYPE ty_planned_tt.
    DATA lv_depth     TYPE i.
    DATA lv_child_qty TYPE menge_d.

    LOOP AT it_demand INTO DATA(ls_requirement).
      IF ls_requirement-quantity <= 0.
        CONTINUE.
      ENDIF.

      lt_totals = bump( it_planned = lt_totals
                        iv_matnr   = ls_requirement-matnr
                        iv_qty     = ls_requirement-quantity ).
    ENDLOOP.

    lt_level = lt_totals.

    lv_depth = 1.
    WHILE lv_depth <= iv_levels.
      CLEAR lt_next.

      LOOP AT lt_level INTO DATA(ls_parent).
        LOOP AT it_bom INTO DATA(ls_bom).
          IF ls_bom-parent_matnr <> ls_parent-matnr.
            CONTINUE.
          ENDIF.

          lv_child_qty = ls_parent-quantity * ls_bom-qty_per.
          IF lv_child_qty <= 0.
            CONTINUE.
          ENDIF.

          lt_next = bump( it_planned = lt_next
                          iv_matnr   = ls_bom-child_matnr
                          iv_qty     = lv_child_qty ).
          lt_totals = bump( it_planned = lt_totals
                            iv_matnr   = ls_bom-child_matnr
                            iv_qty     = lv_child_qty ).
        ENDLOOP.
      ENDLOOP.

      lt_level = lt_next.
      lv_depth = lv_depth + 1.
    ENDWHILE.

    rt_planned = lt_totals.
  ENDMETHOD.

ENDCLASS.
