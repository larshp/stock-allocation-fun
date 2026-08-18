CLASS ltcl_reservation_writer DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES if_ftd_invocation_answer.

  PRIVATE SECTION.
    CONSTANTS c_bapi  TYPE sxco_fm_name VALUE 'BAPI_RESERVATION_CREATE1'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'RESERVE-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    TYPES ty_item_tab   TYPE STANDARD TABLE OF bapi2093_res_item WITH EMPTY KEY.
    TYPES ty_return_tab TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

    DATA mi_env      TYPE REF TO if_function_test_environment.
    DATA mo_cut      TYPE REF TO zif_reservation_writer.

    "! what the BAPI double was handed, and what it answers with
    DATA mt_seen      TYPE ty_item_tab.
    DATA ms_seen_head TYPE bapi2093_res_head.
    DATA mv_calls     TYPE i.
    DATA mt_answer    TYPE ty_return_tab.
    DATA mv_answer_no TYPE rkpf-rsnum.

    METHODS setup.
    METHODS teardown.

    METHODS one_item_per_confirmed_line FOR TESTING RAISING cx_static_check.
    METHODS unconfirmed_lines_are_skipped FOR TESTING RAISING cx_static_check.
    METHODS nothing_confirmed_skips_bapi FOR TESTING RAISING cx_static_check.
    METHODS header_carries_move_type FOR TESTING RAISING cx_static_check.
    METHODS error_message_raises FOR TESTING.
    METHODS success_message_is_no_error FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_reservation_writer IMPLEMENTATION.

  METHOD setup.

    DATA lt_deps TYPE if_function_test_environment=>tt_function_dependencies.

    CLEAR mt_seen.
    CLEAR ms_seen_head.
    CLEAR mv_calls.
    mt_answer = VALUE #( ( type = 'S' id = 'M7' number = '060' message = 'Reservation created' ) ).
    mv_answer_no = '0000004711'.

    mo_cut = NEW zcl_reservation_writer( ).

    INSERT c_bapi INTO TABLE lt_deps.
    mi_env = cl_function_test_environment=>create( lt_deps ).
    mi_env->get_double( c_bapi )->configure_call( )->ignore_all_parameters( )->then_answer( me ).

  ENDMETHOD.

  METHOD teardown.
    mi_env->clear_doubles( ).
  ENDMETHOD.

  METHOD if_ftd_invocation_answer~answer.

    DATA lr_items TYPE REF TO data.
    DATA lr_head  TYPE REF TO data.

    FIELD-SYMBOLS <lt_items> TYPE ty_item_tab.
    FIELD-SYMBOLS <ls_head>  TYPE bapi2093_res_head.

    mv_calls = mv_calls + 1.

    lr_items = arguments->get_table_parameter( 'RESERVATIONITEMS' ).
    ASSIGN lr_items->* TO <lt_items>.
    ASSERT sy-subrc = 0.
    mt_seen = <lt_items>.

    lr_head = arguments->get_importing_parameter( 'RESERVATIONHEADER' ).
    ASSIGN lr_head->* TO <ls_head>.
    ASSERT sy-subrc = 0.
    ms_seen_head = <ls_head>.

    result->get_output_configuration( )->set_exporting_parameter(
      name  = 'RESERVATION'
      value = mv_answer_no ).
    result->get_output_configuration( )->set_table_parameter(
      name  = 'RETURN'
      value = mt_answer ).

  ENDMETHOD.

  METHOD one_item_per_confirmed_line.

    DATA(lv_reservation) = mo_cut->reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      iv_lgort      = '0001'
      it_allocation = VALUE #(
        ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' req_date = '20260215' requested = '5'  confirmed = '5' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mt_seen
      exp = VALUE ty_item_tab(
        ( material = c_matnr plant = c_werks stge_loc = '0001'
          entry_qnt = '4' req_date = '20260210' )
        ( material = c_matnr plant = c_werks stge_loc = '0001'
          entry_qnt = '5' req_date = '20260215' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation
      exp = '0000004711'
      msg = 'the reservation number from the BAPI must be handed back' ).

  ENDMETHOD.

  METHOD unconfirmed_lines_are_skipped.

    mo_cut->reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' req_date = '20260215' requested = '5'  confirmed = 0   shortfall = '5' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mt_seen )
      exp = 1
      msg = 'a line that got nothing must not turn into a reservation item' ).

  ENDMETHOD.

  METHOD nothing_confirmed_skips_bapi.

    DATA(lv_reservation) = mo_cut->reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = 0 shortfall = '10' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mv_calls
      exp = 0
      msg = 'an empty reservation must not be sent to SAP at all' ).
    cl_abap_unit_assert=>assert_initial( lv_reservation ).

  ENDMETHOD.

  METHOD header_carries_move_type.

    DATA(lo_cut) = NEW zcl_reservation_writer( '201' ).

    lo_cut->zif_reservation_writer~reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = '4' shortfall = '6' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ms_seen_head-move_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = ms_seen_head-created_by
      exp = sy-uname ).

  ENDMETHOD.

  METHOD error_message_raises.

    mt_answer = VALUE #( ( type = 'E' id = 'M7' number = '018' message = 'No items transferred' ) ).

    TRY.
        mo_cut->reserve(
          iv_matnr      = c_matnr
          iv_werks      = c_werks
          it_allocation = VALUE #(
            ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = '4' shortfall = '6' ) ) ).
        cl_abap_unit_assert=>fail( 'a rejected reservation must not pass silently' ).
      CATCH zcx_allocation INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_equals(
          act = lx_error->mv_message
          exp = 'No items transferred' ).
    ENDTRY.

  ENDMETHOD.

  METHOD success_message_is_no_error.

    mt_answer = VALUE #(
      ( type = 'W' id = 'M7' number = '999' message = 'Something to think about' )
      ( type = 'S' id = 'M7' number = '060' message = 'Reservation created' ) ).

    DATA(lv_reservation) = mo_cut->reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' req_date = '20260210' requested = '10' confirmed = '4' shortfall = '6' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation
      exp = '0000004711'
      msg = 'a warning must not fail the reservation' ).

  ENDMETHOD.

ENDCLASS.
