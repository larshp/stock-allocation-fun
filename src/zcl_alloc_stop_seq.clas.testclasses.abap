CLASS ltcl_alloc_stop_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stop_seq.
    DATA mt_sto TYPE zcl_alloc_stop_seq=>ty_stop_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id TYPE string
        iv_x  TYPE i
        iv_y  TYPE i.

    METHODS nearest_first  FOR TESTING.
    METHODS walks_outwards FOR TESTING.
    METHODS keeps_all      FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stop_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stop_seq( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stop TYPE zcl_alloc_stop_seq=>ty_stop.

    ls_stop-stop_id = iv_id.
    ls_stop-x = iv_x.
    ls_stop-y = iv_y.
    APPEND ls_stop TO mt_sto.
  ENDMETHOD.

  METHOD nearest_first.
    DATA lt_stops TYPE zcl_alloc_stop_seq=>ty_stop_tt.

    add( iv_id = 'FAR' iv_x = 100 iv_y = 0 ).
    add( iv_id = 'NEAR' iv_x = 5 iv_y = 0 ).

    lt_stops = mo_cut->sequence( it_stops = mt_sto iv_x = 0 iv_y = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stops[ 1 ]-stop_id exp = 'NEAR' ).
  ENDMETHOD.

  METHOD walks_outwards.
    DATA lt_stops TYPE zcl_alloc_stop_seq=>ty_stop_tt.

    add( iv_id = 'S3' iv_x = 30 iv_y = 0 ).
    add( iv_id = 'S1' iv_x = 10 iv_y = 0 ).
    add( iv_id = 'S2' iv_x = 20 iv_y = 0 ).

    lt_stops = mo_cut->sequence( it_stops = mt_sto iv_x = 0 iv_y = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stops[ 1 ]-stop_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_stops[ 2 ]-stop_id exp = 'S2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_stops[ 3 ]-stop_id exp = 'S3' ).
  ENDMETHOD.

  METHOD keeps_all.
    DATA lt_stops TYPE zcl_alloc_stop_seq=>ty_stop_tt.

    add( iv_id = 'S1' iv_x = 10 iv_y = 0 ).
    add( iv_id = 'S2' iv_x = 20 iv_y = 0 ).

    lt_stops = mo_cut->sequence( it_stops = mt_sto iv_x = 0 iv_y = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stops ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_stops TYPE zcl_alloc_stop_seq=>ty_stop_tt.

    lt_stops = mo_cut->sequence( it_stops = mt_sto iv_x = 0 iv_y = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stops ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
