CLASS zcl_alloc_val_lowest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value
      IMPORTING
        iv_cost         TYPE i
        iv_market       TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS method
      IMPORTING
        iv_cost          TYPE i
        iv_market        TYPE i
      RETURNING
        VALUE(rv_method) TYPE string.

    METHODS is_written_down
      IMPORTING
        iv_cost      TYPE i
        iv_market    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_lowest IMPLEMENTATION.

  METHOD value.
    " The lowest value principle keeps the lower of cost and market.
    IF iv_cost <= iv_market.
      rv_value = iv_cost.
    ELSE.
      rv_value = iv_market.
    ENDIF.
  ENDMETHOD.

  METHOD method.
    " The method that produced the value is named back.
    IF iv_cost <= iv_market.
      rv_method = 'COST'.
    ELSE.
      rv_method = 'MARKET'.
    ENDIF.
  ENDMETHOD.

  METHOD is_written_down.
    " A market below cost forces a write-down.
    rv_ok = xsdbool( iv_market < iv_cost ).
  ENDMETHOD.

ENDCLASS.
