CLASS zcx_stock_allocation DEFINITION PUBLIC
  INHERITING FROM cx_static_check FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_text     TYPE string
        io_previous TYPE REF TO cx_root OPTIONAL.
    METHODS get_text REDEFINITION.
  PRIVATE SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

CLASS zcx_stock_allocation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = io_previous ).
    mv_text = iv_text.
  ENDMETHOD.

  METHOD get_text.
    result = mv_text.
  ENDMETHOD.
ENDCLASS.
