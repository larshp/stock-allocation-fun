CLASS zcl_unit_converter DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_unit_converter.

  PRIVATE SECTION.

    METHODS base_unit
      IMPORTING
        iv_matnr      TYPE mard-matnr
      RETURNING
        VALUE(rv_uom) TYPE mara-meins
      RAISING
        zcx_allocation.

    METHODS refuse
      IMPORTING
        iv_matnr TYPE mard-matnr
        iv_uom   TYPE marm-meinh
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_unit_converter IMPLEMENTATION.

  METHOD zif_unit_converter~to_base.

    " typed explicitly: an inline DATA() here loses the decimal places and
    " silently rounds the quantity, see ANOMALIES.md
    DATA lv_converted TYPE zif_allocation=>ty_quantity.

    DATA(lv_base) = base_unit( iv_matnr ).
    IF lv_base = iv_uom.
      rv_quantity = iv_quantity.
      RETURN.
    ENDIF.

    SELECT SINGLE umrez, umren
      FROM marm
      WHERE matnr = @iv_matnr
        AND meinh = @iv_uom
      INTO @DATA(ls_factor).
    IF sy-subrc <> 0.
      refuse(
        iv_matnr = iv_matnr
        iv_uom   = iv_uom ).
    ENDIF.

    " a denominator of zero is broken master data, not a conversion of nothing
    IF ls_factor-umren = 0.
      refuse(
        iv_matnr = iv_matnr
        iv_uom   = iv_uom ).
    ENDIF.

    lv_converted = iv_quantity * ls_factor-umrez / ls_factor-umren.
    rv_quantity  = lv_converted.

  ENDMETHOD.

  METHOD base_unit.

    SELECT SINGLE meins
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @rv_uom.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_conversion
        mv_message = |{ iv_matnr }| ).
    ENDIF.

  ENDMETHOD.

  METHOD refuse.

    RAISE EXCEPTION NEW zcx_allocation(
      textid     = zcx_allocation=>no_conversion
      mv_message = |{ iv_uom } / { iv_matnr }| ).

  ENDMETHOD.

ENDCLASS.
