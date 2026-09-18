CLASS zcl_alloc_update_task DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_string_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             tasks TYPE ty_string_tt,
             task  TYPE c LENGTH 30,
           END OF ty_input.

    METHODS queue
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_tasks) TYPE ty_string_tt.

    METHODS flush
      IMPORTING
        it_tasks        TYPE ty_string_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_update_task IMPLEMENTATION.

  METHOD queue.
    rt_tasks = is_input-tasks.

    IF is_input-task IS INITIAL.
      RETURN.
    ENDIF.

    APPEND is_input-task TO rt_tasks.
  ENDMETHOD.

  METHOD flush.
    rv_count = lines( it_tasks ).
  ENDMETHOD.

ENDCLASS.
