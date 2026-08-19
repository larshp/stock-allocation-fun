CLASS zcl_unit_converter DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_unit_converter.

  PRIVATE SECTION.

    "! The base unit of a material, once it has been read.
    TYPES:
      BEGIN OF ty_base,
        matnr TYPE mard-matnr,
        meins TYPE mara-meins,
      END OF ty_base.
    TYPES ty_base_tab TYPE SORTED TABLE OF ty_base WITH UNIQUE KEY matnr.

    "! One conversion of a material, once it has been read.
    TYPES:
      BEGIN OF ty_factor,
        matnr TYPE mard-matnr,
        meinh TYPE marm-meinh,
        umrez TYPE marm-umrez,
        umren TYPE marm-umren,
      END OF ty_factor.
    TYPES ty_factor_tab TYPE SORTED TABLE OF ty_factor WITH UNIQUE KEY matnr meinh.

    DATA mt_base   TYPE ty_base_tab.
    DATA mt_factor TYPE ty_factor_tab.

    METHODS base_unit
      IMPORTING
        iv_matnr      TYPE mard-matnr
      RETURNING
        VALUE(rv_uom) TYPE mara-meins
      RAISING
        zcx_allocation.

    METHODS factor
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_uom           TYPE marm-meinh
      RETURNING
        VALUE(rs_factor) TYPE ty_factor
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

    DATA(ls_factor) = factor(
      iv_matnr = iv_matnr
      iv_uom   = iv_uom ).

    lv_converted = iv_quantity * ls_factor-umrez / ls_factor-umren.
    rv_quantity  = lv_converted.

  ENDMETHOD.

  METHOD base_unit.

    " a demand reader converts every schedule line it reads, and one material
    " has many of them, so the master data is read once per instance rather
    " than once per quantity. It cannot change during a run, and a run that
    " worked from two versions of it would be worse than one that did not.
    IF line_exists( mt_base[ matnr = iv_matnr ] ).
      rv_uom = mt_base[ matnr = iv_matnr ]-meins.
      RETURN.
    ENDIF.

    SELECT SINGLE meins
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @rv_uom.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_conversion
        mv_message = |{ iv_matnr }| ).
    ENDIF.

    INSERT VALUE #(
      matnr = iv_matnr
      meins = rv_uom ) INTO TABLE mt_base.

  ENDMETHOD.

  METHOD factor.

    IF line_exists( mt_factor[ matnr = iv_matnr
                               meinh = iv_uom ] ).
      rs_factor = mt_factor[ matnr = iv_matnr
                             meinh = iv_uom ].
      RETURN.
    ENDIF.

    SELECT SINGLE umrez, umren
      FROM marm
      WHERE matnr = @iv_matnr
        AND meinh = @iv_uom
      INTO CORRESPONDING FIELDS OF @rs_factor.
    IF sy-subrc <> 0.
      refuse(
        iv_matnr = iv_matnr
        iv_uom   = iv_uom ).
    ENDIF.

    " a denominator of zero is broken master data, not a conversion of nothing.
    " It is refused rather than buffered: nothing may convert with it.
    IF rs_factor-umren = 0.
      refuse(
        iv_matnr = iv_matnr
        iv_uom   = iv_uom ).
    ENDIF.

    rs_factor-matnr = iv_matnr.
    rs_factor-meinh = iv_uom.
    INSERT rs_factor INTO TABLE mt_factor.

  ENDMETHOD.

  METHOD refuse.

    RAISE EXCEPTION NEW zcx_allocation(
      textid     = zcx_allocation=>no_conversion
      mv_message = |{ iv_uom } / { iv_matnr }| ).

  ENDMETHOD.

ENDCLASS.
