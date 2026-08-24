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

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_stub_message IMPLEMENTATION.


ENDCLASS.
