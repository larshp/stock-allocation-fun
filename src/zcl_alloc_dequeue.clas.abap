CLASS zcl_alloc_dequeue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
           END OF ty_input.
    TYPES ty_input_tt TYPE STANDARD TABLE OF ty_input WITH DEFAULT KEY.

    METHODS dequeue
      IMPORTING
        is_input     TYPE ty_input
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS distinct_count
      IMPORTING
        it_inputs       TYPE ty_input_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_dequeue IMPLEMENTATION.

  METHOD dequeue.
    IF is_input-object IS INITIAL.
      rv_ok = abap_false.
    ELSE.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD distinct_count.
    DATA lt_seen TYPE ty_input_tt.

    LOOP AT it_inputs INTO DATA(ls_input).
      READ TABLE lt_seen TRANSPORTING NO FIELDS
        WITH KEY object = ls_input-object.
      IF sy-subrc <> 0.
        APPEND ls_input TO lt_seen.
      ENDIF.
    ENDLOOP.

    rv_count = lines( lt_seen ).
  ENDMETHOD.

ENDCLASS.
