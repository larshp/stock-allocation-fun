"! Stock transfer suggestions - when an order cannot be fully served from
"! its preferred storage location but another location has surplus stock,
"! suggest a transfer (UB-like) instead of splitting the delivery.
CLASS zcl_stock_transfer_sugg DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_transfer,
             matnr      TYPE matnr,     " material to move
             werks      TYPE werks_d,   " plant
             lgort_from TYPE lgort_d,   " source storage location
             lgort_to   TYPE lgort_d,   " destination storage location
             qty        TYPE labst,     " suggested transfer quantity
           END OF ty_transfer.
    TYPES tt_transfers TYPE STANDARD TABLE OF ty_transfer WITH DEFAULT KEY.

    "! Suggest transfers for a material/plant: if iv_lgort_pref cannot cover
    "! iv_qty but other locations together can, propose moving the shortfall.
    CLASS-METHODS suggest
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks            TYPE werks_d
        iv_lgort_pref       TYPE lgort_d
        iv_qty              TYPE labst
      RETURNING
        VALUE(rt_transfers) TYPE tt_transfers.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_stock_transfer_sugg IMPLEMENTATION.


  METHOD suggest.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    DATA lv_pref_available TYPE labst.
    DATA lv_shortfall TYPE labst.
    DATA lv_free TYPE labst.
    DATA lv_move TYPE labst.
    DATA lt_others LIKE lt_mard.

    lt_mard = zcl_stub_mard=>read_by_material_plant(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " available stock at the preferred location
    lv_pref_available = zcl_stub_mard=>get_available(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        iv_lgort = iv_lgort_pref ).

    " enough at the preferred location: no transfer needed
    IF lv_pref_available >= iv_qty.
      RETURN.
    ENDIF.

    " shortfall must come from other locations; prefer locations with the
    " largest free stock first so fewer transfers are needed
    lv_shortfall = iv_qty - lv_pref_available.
    LOOP AT lt_mard INTO DATA(ls_mard).
      IF ls_mard-lgort <> iv_lgort_pref.
        APPEND ls_mard TO lt_others.
      ENDIF.
    ENDLOOP.
    SORT lt_others BY labst DESCENDING.

    LOOP AT lt_others INTO ls_mard.
      IF lv_shortfall <= 0.
        EXIT.
      ENDIF.
      lv_free = zcl_stub_mard=>get_available(
          iv_matnr = iv_matnr
          iv_werks = iv_werks
          iv_lgort = ls_mard-lgort ).
      IF lv_free <= 0.
        CONTINUE.
      ENDIF.
      lv_move = lv_shortfall.
      IF lv_free < lv_move.
        lv_move = lv_free.
      ENDIF.
      APPEND VALUE ty_transfer(
          matnr      = iv_matnr
          werks      = iv_werks
          lgort_from = ls_mard-lgort
          lgort_to   = iv_lgort_pref
          qty        = lv_move ) TO rt_transfers.
      lv_shortfall = lv_shortfall - lv_move.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
