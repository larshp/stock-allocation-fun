"! SAP standard stub: message class simulation for allocation messages
"! In a real SAP system this would be message class ZSTOCK_ALLOC in SE91.
CLASS zcl_stub_message DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZSTOCK_ALLOC'.

    CONSTANTS:
      BEGIN OF gc_msgno,
        no_stock          TYPE symsgno VALUE '001',
        partial_alloc     TYPE symsgno VALUE '002',
        full_alloc        TYPE symsgno VALUE '003',
        order_not_found   TYPE symsgno VALUE '004',
        posting_failed    TYPE symsgno VALUE '005',
      END OF gc_msgno.

    TYPES: BEGIN OF ty_message,
             msgty TYPE symsgty,       " message type S/E/W/I
             msgid TYPE symsgid,
             msgno TYPE symsgno,
             msgv1 TYPE symsgv,        " message variables
             msgv2 TYPE symsgv,
             msgv3 TYPE symsgv,
             msgv4 TYPE symsgv,
           END OF ty_message.
    TYPES tt_message TYPE STANDARD TABLE OF ty_message WITH DEFAULT KEY.

    "! Build a message row (simulates MESSAGE ... INTO structure)
    CLASS-METHODS build
      IMPORTING
        iv_msgty         TYPE symsgty
        iv_msgno         TYPE symsgno
        iv_msgv1         TYPE symsgv OPTIONAL
        iv_msgv2         TYPE symsgv OPTIONAL
      RETURNING
        VALUE(rs_message) TYPE ty_message.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_stub_message IMPLEMENTATION.


  METHOD build.
    rs_message-msgty  = iv_msgty.
    rs_message-msgid  = gc_msgid.
    rs_message-msgno  = iv_msgno.
    rs_message-msgv1  = iv_msgv1.
    rs_message-msgv2  = iv_msgv2.
  ENDMETHOD.


ENDCLASS.
