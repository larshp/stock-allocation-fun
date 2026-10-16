CLASS ltcl_alloc_serial_history DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_serial_history.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_serial TYPE i
        iv_type   TYPE string
        iv_day    TYPE i.

    METHODS filters_serial FOR TESTING.
    METHODS counts_serial  FOR TESTING.
    METHODS latest_day     FOR TESTING.
    METHODS unknown_serial FOR TESTING.
    METHODS clear_resets   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_serial_history IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_serial_history( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_event TYPE zcl_alloc_serial_history=>ty_event.

    ls_event-serial = iv_serial.
    ls_event-event_type = iv_type.
    ls_event-day = iv_day.
    mo_cut->add( ls_event ).
  ENDMETHOD.

  METHOD filters_serial.
    DATA lt_events TYPE zcl_alloc_serial_history=>ty_event_tt.

    add( iv_serial = 1 iv_type = 'GOODS_RECEIPT' iv_day = 10 ).
    add( iv_serial = 2 iv_type = 'GOODS_RECEIPT' iv_day = 11 ).

    lt_events = mo_cut->history( iv_serial = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_events ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_events[ 1 ]-event_type exp = 'GOODS_RECEIPT' ).
  ENDMETHOD.

  METHOD counts_serial.
    add( iv_serial = 1 iv_type = 'A' iv_day = 10 ).
    add( iv_serial = 1 iv_type = 'B' iv_day = 11 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( iv_serial = 1 ) exp = 2 ).
  ENDMETHOD.

  METHOD latest_day.
    add( iv_serial = 1 iv_type = 'A' iv_day = 10 ).
    add( iv_serial = 1 iv_type = 'SHIPPED' iv_day = 20 ).
    add( iv_serial = 1 iv_type = 'B' iv_day = 15 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->last_event( iv_serial = 1 ) exp = 'SHIPPED' ).
  ENDMETHOD.

  METHOD unknown_serial.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->last_event( iv_serial = 99 ) exp = '' ).
  ENDMETHOD.

  METHOD clear_resets.
    add( iv_serial = 1 iv_type = 'A' iv_day = 10 ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( iv_serial = 1 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
