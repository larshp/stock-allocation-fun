CLASS zcl_deduct_deliveries DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_deduction.

  PRIVATE SECTION.

    "! LIKP-VBTYP of an outbound delivery. Stock leaves the plant on one of
    "! those; an inbound delivery ('7') and a returns delivery ('T') bring
    "! stock the other way and hold nothing back.
    CONSTANTS c_outbound_delivery TYPE likp-vbtyp VALUE 'J'.

    "! LIPS-WBSTA: the goods issue of the item has been posted in full, so the
    "! stock has already left MARD and must not be held back a second time.
    CONSTANTS c_goods_issue_posted TYPE lips-wbsta VALUE 'C'.

    "! One delivery item that is still waiting for its goods issue.
    TYPES:
      BEGIN OF ty_open,
        vbeln    TYPE lips-vbeln,
        posnr    TYPE lips-posnr,
        quantity TYPE lips-lgmng,
      END OF ty_open.
    TYPES ty_open_tab TYPE STANDARD TABLE OF ty_open WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_deduct_deliveries IMPLEMENTATION.

  METHOD zif_stock_deduction~quantity.

    DATA lt_open TYPE ty_open_tab.

    " a delivery that exists but has not been goods issued still has its stock
    " in MARD, while the order it came from no longer counts it as open demand.
    " Without this the same stock would be given to somebody else.
    "
    " LGMNG is the delivery quantity in the base unit of measure, the unit
    " everything here works in. The quantities are added up in ABAP rather than
    " with SUM( ) and a GROUP BY, see ANOMALIES.md.
    SELECT item~vbeln,
           item~posnr,
           item~lgmng AS quantity
      FROM lips AS item
      INNER JOIN likp AS header ON header~vbeln = item~vbeln
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~wbsta <> @c_goods_issue_posted
        AND header~vbtyp = @c_outbound_delivery
      ORDER BY item~vbeln, item~posnr
      INTO TABLE @lt_open.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a cancelled delivery item is gone from LIPS rather than negative, and a
    " quantity that is not positive holds nothing back
    LOOP AT lt_open INTO DATA(ls_open).
      IF ls_open-quantity > 0.
        rv_quantity = rv_quantity + ls_open-quantity.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
