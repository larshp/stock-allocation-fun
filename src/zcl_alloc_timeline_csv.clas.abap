CLASS zcl_alloc_timeline_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_events       TYPE zcl_alloc_timeline=>ty_event_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_timeline_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'SEQUENCE' TO lt_fields.
    APPEND 'NAME' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_events INTO DATA(ls_event).
      CLEAR lt_fields.
      APPEND |{ ls_event-sequence }| TO lt_fields.
      APPEND |{ ls_event-name }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
