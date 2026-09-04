CLASS zcl_deduct_safety_stock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_deduction.

ENDCLASS.


CLASS zcl_deduct_safety_stock IMPLEMENTATION.

  METHOD zif_stock_deduction~quantity.

    " safety stock is what the plant keeps back to absorb variation. It sits in
    " MARD like anything else, so without this it would be handed out.
    SELECT SINGLE eisbe
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @DATA(lv_safety).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF lv_safety > 0.
      rv_quantity = lv_safety.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
