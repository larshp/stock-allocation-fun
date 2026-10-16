CLASS zcl_alloc_replenish_msg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_msg,
             material TYPE matnr,
             success  TYPE abap_bool,
           END OF ty_msg.
    TYPES ty_msg_tt TYPE STANDARD TABLE OF ty_msg WITH DEFAULT KEY.

    METHODS message
      IMPORTING
        iv_success     TYPE abap_bool
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS is_success
      IMPORTING
        it_msgs      TYPE ty_msg_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS error_count
      IMPORTING
        it_msgs         TYPE ty_msg_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_msg IMPLEMENTATION.

  METHOD message.
    " The confirmation message spells out the outcome.
    IF iv_success = abap_true.
      rv_text = 'REPLENISHMENT CONFIRMED'.
    ELSE.
      rv_text = 'REPLENISHMENT FAILED'.
    ENDIF.
  ENDMETHOD.

  METHOD is_success.
    " A run counts as successful only when nothing failed.
    IF lines( it_msgs ) = 0.
      RETURN.
    ENDIF.

    LOOP AT it_msgs INTO DATA(ls_msg).
      IF ls_msg-success = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD error_count.
    " The errors are the messages that failed.
    LOOP AT it_msgs INTO DATA(ls_msg).
      IF ls_msg-success = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
