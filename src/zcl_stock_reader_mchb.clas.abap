CLASS zcl_stock_reader_mchb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

  PRIVATE SECTION.
    METHODS read_batches
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.

    METHODS read_expiry
      IMPORTING
        iv_matnr        TYPE mchb-matnr
        iv_charg        TYPE mchb-charg
      RETURNING
        VALUE(rv_vfdat) TYPE mcha-vfdat.

ENDCLASS.


CLASS zcl_stock_reader_mchb IMPLEMENTATION.

  METHOD zif_stock_reader~read_stock.
    rt_stock = read_batches( iv_matnr = iv_matnr
                             iv_werks = iv_werks ).
  ENDMETHOD.

  METHOD read_batches.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.

    SELECT matnr,
           werks,
           lgort,
           charg,
           clabs,
           cinsm,
           cspem,
           ceinm
      FROM mchb
      INTO TABLE @DATA(lt_mchb)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      ORDER BY lgort, charg.

    LOOP AT lt_mchb INTO DATA(ls_mchb).
      CLEAR ls_stock.
      ls_stock-matnr            = ls_mchb-matnr.
      ls_stock-werks            = ls_mchb-werks.
      ls_stock-lgort            = ls_mchb-lgort.
      ls_stock-charg            = ls_mchb-charg.
      ls_stock-expiry_date      = read_expiry( iv_matnr = ls_mchb-matnr
                                               iv_charg = ls_mchb-charg ).
      ls_stock-unrestricted_qty = ls_mchb-clabs.
      ls_stock-quality_qty      = ls_mchb-cinsm.
      ls_stock-blocked_qty      = ls_mchb-cspem.
      ls_stock-restricted_qty   = ls_mchb-ceinm.
      APPEND ls_stock TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_expiry.
    SELECT SINGLE vfdat FROM mcha INTO @rv_vfdat
      WHERE matnr = @iv_matnr
        AND charg = @iv_charg.
  ENDMETHOD.

ENDCLASS.
