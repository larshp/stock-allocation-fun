CLASS zcl_alloc_messages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_message,
             msgty TYPE c LENGTH 1,
             msgid TYPE c LENGTH 20,
             msgno TYPE c LENGTH 3,
             text  TYPE c LENGTH 80,
           END OF ty_message.
    TYPES ty_message_tt TYPE STANDARD TABLE OF ty_message WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             messages TYPE ty_message_tt,
             message  TYPE ty_message,
           END OF ty_input.

    METHODS collect
      IMPORTING
        is_input           TYPE ty_input
      RETURNING
        VALUE(rt_messages) TYPE ty_message_tt.

    METHODS count
      IMPORTING
        it_messages     TYPE ty_message_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_messages IMPLEMENTATION.

  METHOD collect.
    rt_messages = is_input-messages.

    IF is_input-message-text IS INITIAL.
      RETURN.
    ENDIF.

    APPEND is_input-message TO rt_messages.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_messages ).
  ENDMETHOD.

ENDCLASS.
