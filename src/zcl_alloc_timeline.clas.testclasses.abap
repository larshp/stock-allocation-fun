CLASS ltcl_alloc_timeline DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_timeline.

    METHODS setup.

    METHODS event
      IMPORTING
        iv_sequence   TYPE i
        iv_name       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_timeline=>ty_event.

    METHODS empty_list   FOR TESTING.
    METHODS renders_line FOR TESTING.
    METHODS sorts_events FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_timeline IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_timeline( ).
  ENDMETHOD.

  METHOD event.
    rs_row-sequence = iv_sequence.
    rs_row-name = iv_name.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->to_lines( lt_events ) ).
  ENDMETHOD.

  METHOD renders_line.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.

    APPEND event( iv_sequence = 1 iv_name = 'PICK' ) TO lt_events.

    DATA(lt_lines) = mo_cut->to_lines( lt_events ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = '1: PICK' ).
  ENDMETHOD.

  METHOD sorts_events.
    DATA lt_events TYPE zcl_alloc_timeline=>ty_event_tt.

    APPEND event( iv_sequence = 2 iv_name = 'POST' ) TO lt_events.
    APPEND event( iv_sequence = 1 iv_name = 'PICK' ) TO lt_events.

    DATA(lt_lines) = mo_cut->to_lines( lt_events ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = '1: PICK' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = '2: POST' ).
  ENDMETHOD.

ENDCLASS.
