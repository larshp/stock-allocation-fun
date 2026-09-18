CLASS zcl_alloc_req_group DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr       TYPE matnr,
             requirement TYPE zif_requirement_reader=>ty_requirement,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             matnr         TYPE matnr,
             count         TYPE i,
             requested_qty TYPE menge_d,
           END OF ty_group.
    TYPES ty_group_tt TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY.

    METHODS group
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_groups) TYPE ty_group_tt.

ENDCLASS.


CLASS zcl_alloc_req_group IMPLEMENTATION.

  METHOD group.
    DATA lt_work    TYPE ty_item_tt.
    DATA ls_group   TYPE ty_group.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY matnr ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false OR ls_item-matnr <> ls_group-matnr.
        IF lv_started = abap_true.
          APPEND ls_group TO rt_groups.
        ENDIF.
        CLEAR ls_group.
        ls_group-matnr = ls_item-matnr.
        lv_started = abap_true.
      ENDIF.

      ls_group-count = ls_group-count + 1.
      ls_group-requested_qty = ls_group-requested_qty
        + ls_item-requirement-requested_qty.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_group TO rt_groups.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
