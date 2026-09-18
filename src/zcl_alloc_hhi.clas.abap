CLASS zcl_alloc_hhi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate
      IMPORTING
        it_items      TYPE zcl_alloc_pareto=>ty_item_tt
      RETURNING
        VALUE(rv_hhi) TYPE i.

    METHODS band_of
      IMPORTING
        iv_hhi         TYPE i
      RETURNING
        VALUE(rv_band) TYPE string.

ENDCLASS.


CLASS zcl_alloc_hhi IMPLEMENTATION.

  METHOD calculate.
    DATA lv_total TYPE menge_d.
    DATA lv_share TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      lv_total = lv_total + ls_item-quantity.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_items INTO ls_item.
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_share = ls_item-quantity * 100 DIV lv_total.
      rv_hhi = rv_hhi + lv_share * lv_share.
    ENDLOOP.
  ENDMETHOD.

  METHOD band_of.
    IF iv_hhi < 1500.
      rv_band = 'low'.
    ELSEIF iv_hhi < 2500.
      rv_band = 'moderate'.
    ELSE.
      rv_band = 'high'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
