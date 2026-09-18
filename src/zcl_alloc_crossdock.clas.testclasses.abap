CLASS ltcl_alloc_crossdock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_crossdock.
    DATA mt_in  TYPE zcl_alloc_crossdock=>ty_inbound_tt.
    DATA mt_out TYPE zcl_alloc_crossdock=>ty_outbound_tt.

    METHODS setup.

    METHODS add_in
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d
        iv_arr TYPE i.

    METHODS add_out
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d
        iv_dep TYPE i.

    METHODS empty_inputs     FOR TESTING.
    METHODS simple_transfer  FOR TESTING.
    METHODS waits_for_arrival FOR TESTING.
    METHODS reports_shortfall FOR TESTING.
    METHODS spans_two_sources FOR TESTING.
    METHODS wait_is_reported FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_crossdock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_crossdock( ).
  ENDMETHOD.

  METHOD add_in.
    DATA ls_in TYPE zcl_alloc_crossdock=>ty_inbound.

    ls_in-source_id = iv_id.
    ls_in-quantity = iv_qty.
    ls_in-arrival = iv_arr.
    APPEND ls_in TO mt_in.
  ENDMETHOD.

  METHOD add_out.
    DATA ls_out TYPE zcl_alloc_crossdock=>ty_outbound.

    ls_out-target_id = iv_id.
    ls_out-quantity = iv_qty.
    ls_out-departure = iv_dep.
    APPEND ls_out TO mt_out.
  ENDMETHOD.

  METHOD empty_inputs.
    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_moves ) exp = 0 ).
  ENDMETHOD.

  METHOD simple_transfer.
    add_in( iv_id = 'I1' iv_qty = 10 iv_arr = 0 ).
    add_out( iv_id = 'O1' iv_qty = 6 iv_dep = 5 ).

    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_moves ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_moves[ 1 ]-source_id exp = 'I1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_moves[ 1 ]-target_id exp = 'O1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_moves[ 1 ]-quantity exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall_of( it_outbound = mt_out it_moves = lt_moves )
      exp = 0 ).
  ENDMETHOD.

  METHOD waits_for_arrival.
    add_in( iv_id = 'I1' iv_qty = 10 iv_arr = 20 ).
    add_out( iv_id = 'O1' iv_qty = 6 iv_dep = 5 ).

    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_moves ) exp = 0 ).
  ENDMETHOD.

  METHOD reports_shortfall.
    add_in( iv_id = 'I1' iv_qty = 4 iv_arr = 0 ).
    add_out( iv_id = 'O1' iv_qty = 10 iv_dep = 5 ).

    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_moves ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_moves[ 1 ]-quantity exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall_of( it_outbound = mt_out it_moves = lt_moves )
      exp = 6 ).
  ENDMETHOD.

  METHOD spans_two_sources.
    add_in( iv_id = 'I1' iv_qty = 10 iv_arr = 0 ).
    add_in( iv_id = 'I2' iv_qty = 5 iv_arr = 10 ).
    add_out( iv_id = 'O1' iv_qty = 8 iv_dep = 5 ).
    add_out( iv_id = 'O2' iv_qty = 10 iv_dep = 20 ).

    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_moves ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall_of( it_outbound = mt_out it_moves = lt_moves )
      exp = 3 ).
  ENDMETHOD.

  METHOD wait_is_reported.
    add_in( iv_id = 'I1' iv_qty = 10 iv_arr = 5 ).
    add_out( iv_id = 'O1' iv_qty = 4 iv_dep = 15 ).

    DATA(lt_moves) = mo_cut->propose( it_inbound  = mt_in
                                      it_outbound = mt_out ).

    cl_abap_unit_assert=>assert_equals( act = lt_moves[ 1 ]-wait exp = 10 ).
  ENDMETHOD.

ENDCLASS.
