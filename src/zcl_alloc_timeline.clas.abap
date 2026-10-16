CLASS zcl_alloc_timeline DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_event,
             sequence TYPE i,
             name     TYPE c LENGTH 20,
           END OF ty_event.
    TYPES ty_event_tt TYPE STANDARD TABLE OF ty_event WITH DEFAULT KEY.

    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS to_lines
      IMPORTING
        it_events       TYPE ty_event_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

ENDCLASS.


CLASS zcl_alloc_timeline IMPLEMENTATION.

  METHOD to_lines.
    DATA lt_sorted TYPE ty_event_tt.
    DATA lv_line   TYPE string.

    lt_sorted = it_events.
    SORT lt_sorted BY sequence ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_event).
      lv_line = |{ ls_event-sequence }: { ls_event-name }|.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
