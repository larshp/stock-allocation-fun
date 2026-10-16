CLASS ltcl_alloc_change_request DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_change_request.
    DATA mt_req TYPE zcl_alloc_change_request=>ty_request_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id    TYPE string
        iv_state TYPE string
        iv_prio  TYPE i
        iv_owner TYPE string.

    METHODS empty_requests FOR TESTING.
    METHODS closed_is_not_open FOR TESTING.
    METHODS unknown_is_open  FOR TESTING.
    METHODS sorts_by_priority FOR TESTING.
    METHODS ranks_are_sequential FOR TESTING.
    METHODS counts_open     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_change_request IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_change_request( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_request TYPE zcl_alloc_change_request=>ty_request.

    ls_request-request_id = iv_id.
    ls_request-status = iv_state.
    ls_request-priority = iv_prio.
    ls_request-owner = iv_owner.
    APPEND ls_request TO mt_req.
  ENDMETHOD.

  METHOD empty_requests.
    DATA(lt_rows) = mo_cut->build( mt_req ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->open_count( lt_rows ) exp = 0 ).
  ENDMETHOD.

  METHOD closed_is_not_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open_status( 'closed' ) exp = abap_false ).
  ENDMETHOD.

  METHOD unknown_is_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open_status( 'new' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open_status( 'approved' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open_status( '' ) exp = abap_true ).
  ENDMETHOD.

  METHOD sorts_by_priority.
    add( iv_id = 'A' iv_state = 'new' iv_prio = 2 iv_owner = 'LARS' ).
    add( iv_id = 'B' iv_state = 'closed' iv_prio = 1 iv_owner = 'ANNA' ).
    add( iv_id = 'C' iv_state = 'approved' iv_prio = 1 iv_owner = 'LARS' ).

    DATA(lt_rows) = mo_cut->build( mt_req ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-request_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-request_id exp = 'C' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-request_id exp = 'A' ).
  ENDMETHOD.

  METHOD ranks_are_sequential.
    add( iv_id = 'A' iv_state = 'new' iv_prio = 2 iv_owner = 'LARS' ).
    add( iv_id = 'B' iv_state = 'closed' iv_prio = 1 iv_owner = 'ANNA' ).

    DATA(lt_rows) = mo_cut->build( mt_req ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-rank exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-owner exp = 'LARS' ).
  ENDMETHOD.

  METHOD counts_open.
    add( iv_id = 'A' iv_state = 'new' iv_prio = 2 iv_owner = 'LARS' ).
    add( iv_id = 'B' iv_state = 'closed' iv_prio = 1 iv_owner = 'ANNA' ).
    add( iv_id = 'C' iv_state = 'approved' iv_prio = 1 iv_owner = 'LARS' ).

    DATA(lt_rows) = mo_cut->build( mt_req ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-is_open exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-is_open exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->open_count( lt_rows ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
