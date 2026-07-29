CLASS zcl_salloc_stock_stub DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_stock.
    METHODS constructor
      IMPORTING iv_available TYPE zif_salloc_types=>ty_quantity.
    METHODS get_reserved
      RETURNING VALUE(rv_quantity) TYPE zif_salloc_types=>ty_quantity.
  PRIVATE SECTION.
    DATA mv_available TYPE zif_salloc_types=>ty_quantity.
    DATA mv_reserved TYPE zif_salloc_types=>ty_quantity.
ENDCLASS.

CLASS zcl_salloc_stock_stub IMPLEMENTATION.
  METHOD constructor.
    mv_available = iv_available.
  ENDMETHOD.

  METHOD zif_salloc_stock~get_available.
    rv_quantity = mv_available - mv_reserved.
  ENDMETHOD.

  METHOD zif_salloc_stock~reserve.
    mv_reserved = mv_reserved + iv_quantity.
  ENDMETHOD.

  METHOD get_reserved.
    rv_quantity = mv_reserved.
  ENDMETHOD.
ENDCLASS.
