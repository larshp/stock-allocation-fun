CLASS zcl_alloc_abc_xyz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             abc      TYPE string,
             xyz      TYPE string,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cell,
             cell  TYPE string,
             count TYPE i,
           END OF ty_cell.
    TYPES ty_cell_tt TYPE STANDARD TABLE OF ty_cell WITH DEFAULT KEY.

    METHODS matrix
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_cells) TYPE ty_cell_tt.

    METHODS cell_of
      IMPORTING
        it_items       TYPE ty_item_tt
        iv_material    TYPE matnr
      RETURNING
        VALUE(rv_cell) TYPE string.

    METHODS count_in_cell
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_cell         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_xyz IMPLEMENTATION.

  METHOD matrix.
    DATA lt_cells TYPE SORTED TABLE OF ty_cell WITH UNIQUE KEY cell.
    DATA ls_cell  TYPE ty_cell.
    DATA lv_cell  TYPE string.

    " The items are counted per ABC-XYZ cell in a sorted table.
    LOOP AT it_items INTO DATA(ls_item).
      lv_cell = ls_item-abc && ls_item-xyz.

      READ TABLE lt_cells ASSIGNING FIELD-SYMBOL(<ls_cell>)
        WITH KEY cell = lv_cell.

      IF sy-subrc <> 0.
        CLEAR ls_cell.
        ls_cell-cell = lv_cell.
        INSERT ls_cell INTO TABLE lt_cells ASSIGNING <ls_cell>.
      ENDIF.

      <ls_cell>-count = <ls_cell>-count + 1.
    ENDLOOP.

    rt_cells = lt_cells.
  ENDMETHOD.

  METHOD cell_of.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material = iv_material.
        rv_cell = ls_item-abc && ls_item-xyz.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_in_cell.
    DATA lv_cell TYPE string.

    LOOP AT it_items INTO DATA(ls_item).
      lv_cell = ls_item-abc && ls_item-xyz.
      IF lv_cell = iv_cell.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
