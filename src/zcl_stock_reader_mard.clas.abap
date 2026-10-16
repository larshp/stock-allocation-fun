CLASS zcl_stock_reader_mard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

  PRIVATE SECTION.
    METHODS read_mard_stock
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.

ENDCLASS.

CLASS zcl_stock_reader_mard IMPLEMENTATION.

  METHOD zif_stock_reader~read_stock.
    rt_stock = read_mard_stock( iv_matnr = iv_matnr
                                iv_werks = iv_werks ).
  ENDMETHOD.

  METHOD read_mard_stock.
    SELECT matnr,
           werks,
           lgort,
           labst,
           insme,
           speme,
           einme,
           umlme
      FROM mard
      INTO TABLE @DATA(lt_mard)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      ORDER BY lgort.

    LOOP AT lt_mard INTO DATA(ls_mard).
      APPEND VALUE #( matnr            = ls_mard-matnr
                      werks            = ls_mard-werks
                      lgort            = ls_mard-lgort
                      unrestricted_qty = ls_mard-labst
                      quality_qty      = ls_mard-insme
                      blocked_qty      = ls_mard-speme
                      restricted_qty   = ls_mard-einme
                      in_transit_qty   = ls_mard-umlme ) TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
