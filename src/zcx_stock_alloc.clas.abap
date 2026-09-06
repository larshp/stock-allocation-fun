CLASS zcx_stock_alloc DEFINITION PUBLIC INHERITING FROM cx_static_check
  FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_messages TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA reason TYPE string READ-ONLY.
    DATA messages TYPE ty_messages READ-ONLY.
    METHODS constructor
      IMPORTING reason   TYPE string
                messages TYPE ty_messages OPTIONAL.
ENDCLASS.

CLASS zcx_stock_alloc IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->reason = reason.
    me->messages = messages.
  ENDMETHOD.
ENDCLASS.
