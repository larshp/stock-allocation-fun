CLASS ltcl_alloc_timeline_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_timeline_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_timeline_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_timeline_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.

    DATA(lt_lines) = mo_cut->build( lt_events ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'SEQUENCE;NAME' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.
    DATA ls_event  TYPE zcl_alloc_timeline=>ty_event.

    ls_event-sequence = 1.
    ls_event-name = 'PICK'.
    APPEND ls_event TO lt_events.

    DATA(lt_lines) = mo_cut->build( lt_events ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;PICK' ).
  ENDMETHOD.

ENDCLASS.
