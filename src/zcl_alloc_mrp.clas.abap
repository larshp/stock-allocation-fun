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
    METHODS planned_of
      IMPORTING
        io_map            TYPE REF TO zcl_alloc_key_map
      RETURNING
        VALUE(rt_planned) TYPE ty_planned_tt.

ENDCLASS.


CLASS zcl_alloc_mrp IMPLEMENTATION.

  METHOD planned_of.
    DATA ls_planned TYPE ty_planned.
    DATA lt_entries TYPE zcl_alloc_key_map=>ty_entry_tt.

    lt_entries = io_map->entries( ).

    LOOP AT lt_entries INTO DATA(ls_entry).
      CLEAR ls_planned.
      ls_planned-matnr = ls_entry-entry_key.
      ls_planned-quantity = ls_entry-value.
      APPEND ls_planned TO rt_planned.
    ENDLOOP.
  ENDMETHOD.

  METHOD run.
    DATA lo_totals    TYPE REF TO zcl_alloc_key_map.
    DATA lo_next      TYPE REF TO zcl_alloc_key_map.
    DATA lt_level     TYPE ty_planned_tt.
    DATA ls_level     TYPE ty_planned.
    DATA lv_depth     TYPE i.
    DATA lv_child_qty TYPE menge_d.
    DATA lv_key       TYPE string.

    lo_totals = NEW zcl_alloc_key_map( ).

    LOOP AT it_demand INTO DATA(ls_requirement).
      IF ls_requirement-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_key = ls_requirement-matnr.
      lo_totals->add( iv_key   = lv_key
                      iv_delta = ls_requirement-quantity ).
    ENDLOOP.

    lt_level = planned_of( io_map = lo_totals ).

    lv_depth = 1.
    WHILE lv_depth <= iv_levels.
      lo_next = NEW zcl_alloc_key_map( ).

      LOOP AT lt_level INTO ls_level.
        LOOP AT it_bom INTO DATA(ls_bom).
          IF ls_bom-parent_matnr <> ls_level-matnr.
            CONTINUE.
          ENDIF.

          lv_child_qty = ls_level-quantity * ls_bom-qty_per.
          IF lv_child_qty <= 0.
            CONTINUE.
          ENDIF.

          " The map aggregates per material with one key lookup per contribution,
          " so a level costs the number of BOM lines instead of scanning the
          " planning table once per line.
          lv_key = ls_bom-child_matnr.
          lo_next->add( iv_key   = lv_key
                        iv_delta = lv_child_qty ).
          lo_totals->add( iv_key   = lv_key
                          iv_delta = lv_child_qty ).
        ENDLOOP.
      ENDLOOP.

      lt_level = planned_of( io_map = lo_next ).
      lv_depth = lv_depth + 1.
    ENDWHILE.

    rt_planned = planned_of( io_map = lo_totals ).
  ENDMETHOD.

ENDCLASS.
