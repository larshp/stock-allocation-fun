CLASS zcl_alloc_tu_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             weight   TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_tu,
             tu_no        TYPE i,
             total_weight TYPE i,
           END OF ty_tu.
    TYPES ty_tu_tt TYPE STANDARD TABLE OF ty_tu WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items      TYPE ty_item_tt
        iv_max_weight TYPE i
      RETURNING
        VALUE(rt_tus) TYPE ty_tu_tt.

ENDCLASS.


CLASS zcl_alloc_tu_build IMPLEMENTATION.

  METHOD build.
    DATA lt_sorted TYPE ty_item_tt.
    DATA lt_tus    TYPE ty_tu_tt.
    DATA ls_tu     TYPE ty_tu.
    DATA lv_placed TYPE abap_bool.

    IF iv_max_weight <= 0.
      RETURN.
    ENDIF.

    lt_sorted = it_items.

    " First-fit decreasing: the heaviest item goes first and opens a unit only
    " when no existing unit can still take it, which keeps the unit count low.
    SORT lt_sorted BY weight DESCENDING
                      material ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_item).
      IF ls_item-weight <= 0 OR ls_item-weight > iv_max_weight.
        CONTINUE.
      ENDIF.

      CLEAR lv_placed.

      LOOP AT lt_tus ASSIGNING FIELD-SYMBOL(<ls_tu>).
        IF <ls_tu>-total_weight + ls_item-weight <= iv_max_weight.
          <ls_tu>-total_weight = <ls_tu>-total_weight + ls_item-weight.
          lv_placed = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_placed = abap_false.
        CLEAR ls_tu.
        ls_tu-tu_no = lines( lt_tus ) + 1.
        ls_tu-total_weight = ls_item-weight.
        APPEND ls_tu TO lt_tus.
      ENDIF.
    ENDLOOP.

    rt_tus = lt_tus.
  ENDMETHOD.

ENDCLASS.
