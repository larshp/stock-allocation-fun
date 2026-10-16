CLASS zcl_alloc_bin_pack DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_item,
             item_id TYPE string,
             size    TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bin,
             bin_index TYPE i,
             load      TYPE menge_d,
             item_ids  TYPE ty_ids_tt,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS pack
      IMPORTING
        it_items       TYPE ty_item_tt
        iv_capacity    TYPE menge_d
      RETURNING
        VALUE(rt_bins) TYPE ty_bin_tt.

    METHODS oversized
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_capacity     TYPE menge_d
      RETURNING
        VALUE(rt_items) TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_alloc_bin_pack IMPLEMENTATION.

  METHOD pack.
    DATA lt_sorted TYPE ty_item_tt.
    DATA ls_bin    TYPE ty_bin.
    DATA lv_found  TYPE abap_bool.
    DATA lv_next   TYPE i.

    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    lt_sorted = it_items.
    SORT lt_sorted BY size DESCENDING.

    LOOP AT lt_sorted INTO DATA(ls_item).
      IF ls_item-size <= 0 OR ls_item-size > iv_capacity.
        CONTINUE.
      ENDIF.

      lv_found = abap_false.

      LOOP AT rt_bins ASSIGNING FIELD-SYMBOL(<ls_bin>).
        IF <ls_bin>-load + ls_item-size <= iv_capacity.
          <ls_bin>-load = <ls_bin>-load + ls_item-size.
          APPEND ls_item-item_id TO <ls_bin>-item_ids.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_true.
        CONTINUE.
      ENDIF.

      lv_next = lines( rt_bins ) + 1.
      CLEAR ls_bin.
      ls_bin-bin_index = lv_next.
      ls_bin-load = ls_item-size.
      APPEND ls_item-item_id TO ls_bin-item_ids.
      APPEND ls_bin TO rt_bins.
    ENDLOOP.
  ENDMETHOD.

  METHOD oversized.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-size > iv_capacity.
        APPEND ls_item TO rt_items.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
