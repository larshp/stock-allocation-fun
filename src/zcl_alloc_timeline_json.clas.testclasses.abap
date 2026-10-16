CLASS ltcl_alloc_timeline_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_timeline_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_timeline_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_timeline_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_events )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.
    DATA ls_event  TYPE zcl_alloc_timeline=>ty_event.

    ls_event-sequence = 1.
    ls_event-name = 'PICK'.
    APPEND ls_event TO lt_events.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_events )
      exp = '[{"sequence":1,"name":"PICK"}]' ).
  ENDMETHOD.

ENDCLASS.
