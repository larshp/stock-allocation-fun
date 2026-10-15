CLASS zcl_alloc_return_reason_dist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             reason TYPE string,
             count  TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_share,
             reason        TYPE string,
             count         TYPE i,
             share_percent TYPE i,
           END OF ty_share.
    TYPES ty_share_tt TYPE STANDARD TABLE OF ty_share WITH DEFAULT KEY.

    METHODS share
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rt_shares) TYPE ty_share_tt.

    METHODS share_percent
      IMPORTING
        iv_count      TYPE i
        iv_total      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS top_reason
      IMPORTING
        it_shares        TYPE ty_share_tt
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_reason_dist IMPLEMENTATION.

  METHOD share_percent.
    IF iv_total <= 0 OR iv_count <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_count * 100 DIV iv_total.
  ENDMETHOD.

  METHOD share.
    DATA lt_count TYPE SORTED TABLE OF ty_share WITH UNIQUE KEY reason.
    DATA ls_count TYPE ty_share.
    DATA lv_total TYPE i.
    DATA lv_count TYPE i.

    " Counts are grouped once in a sorted table, then turned into shares in a
    " second pass, so the total is known before any percentage is taken.
    LOOP AT it_items INTO DATA(ls_item).
      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY reason = ls_item-reason.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-reason = ls_item-reason.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-count = <ls_count>-count + ls_item-count.
      lv_total = lv_total + ls_item-count.
    ENDLOOP.

    LOOP AT lt_count ASSIGNING <ls_count>.
      lv_count = <ls_count>-count.
      <ls_count>-share_percent = share_percent( iv_count  = lv_count
                                                 iv_total = lv_total ).
    ENDLOOP.

    rt_shares = lt_count.
  ENDMETHOD.

  METHOD top_reason.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_shares INTO DATA(ls_share).
      IF lv_found = abap_false OR ls_share-count > lv_best.
        lv_found = abap_true.
        lv_best = ls_share-count.
        rv_reason = ls_share-reason.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
