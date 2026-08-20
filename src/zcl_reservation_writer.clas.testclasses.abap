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
    METHODS the_item_names_the_line FOR TESTING RAISING cx_static_check.
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
          entry_qnt = '4' req_date = '20260210' item_text = 'ALLOC D1' )
        ( material = c_matnr plant = c_werks stge_loc = '0001'
          entry_qnt = '5' req_date = '20260215' item_text = 'ALLOC D2' ) ) ).

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

  METHOD the_item_names_the_line.

    mo_cut->reserve(
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = '00000047110000100001' req_date = '20260210'
          requested = '10' confirmed = '10' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = mt_seen[ 1 ]-item_text
      exp = '*00000047110000100001*'
      msg = 'a quantity held in MB23 by nobody knows what is a quantity nobody trusts' ).

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


"! Giving an earlier reservation back, which reads RESB to find out what is
"! still on it and then tells the BAPI to delete those items.
CLASS ltcl_reservation_cancel DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES if_ftd_invocation_answer.

  PRIVATE SECTION.
    CONSTANTS c_bapi  TYPE sxco_fm_name VALUE 'BAPI_RESERVATION_CHANGE'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'CANCEL-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_rsnum TYPE rkpf-rsnum VALUE '0000008811'.

    TYPES ty_change_tab  TYPE STANDARD TABLE OF bapi2093_res_item_change WITH EMPTY KEY.
    TYPES ty_changex_tab TYPE STANDARD TABLE OF bapi2093_res_item_changex WITH EMPTY KEY.
    TYPES ty_return_tab  TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

    DATA mi_env TYPE REF TO if_function_test_environment.
    DATA mo_cut TYPE REF TO zif_reservation_writer.

    "! what the BAPI double was handed, and what it answers with
    DATA mt_seen   TYPE ty_change_tab.
    DATA mt_seenx  TYPE ty_changex_tab.
    DATA mv_calls  TYPE i.
    DATA mt_answer TYPE ty_return_tab.

    METHODS setup.
    METHODS teardown.

    METHODS given_item
      IMPORTING
        iv_rspos   TYPE resb-rspos
        iv_deleted TYPE abap_bool DEFAULT abap_false.

    METHODS live_items_are_deleted FOR TESTING RAISING cx_static_check.
    METHODS the_change_is_flagged FOR TESTING RAISING cx_static_check.
    METHODS a_gone_reservation_is_left FOR TESTING RAISING cx_static_check.
    METHODS no_reservation_is_no_call FOR TESTING RAISING cx_static_check.
    METHODS an_error_raises FOR TESTING.

ENDCLASS.


CLASS ltcl_reservation_cancel IMPLEMENTATION.

  METHOD setup.

    DATA lt_deps TYPE if_function_test_environment=>tt_function_dependencies.

    CLEAR mt_seen.
    CLEAR mt_seenx.
    CLEAR mv_calls.
    mt_answer = VALUE #( ( type = 'S' id = 'M7' number = '061' message = 'Reservation changed' ) ).

    mo_cut = NEW zcl_reservation_writer( ).

    INSERT c_bapi INTO TABLE lt_deps.
    mi_env = cl_function_test_environment=>create( lt_deps ).
    mi_env->get_double( c_bapi )->configure_call( )->ignore_all_parameters( )->then_answer( me ).

  ENDMETHOD.

  METHOD teardown.

    mi_env->clear_doubles( ).

    DELETE FROM resb WHERE rsnum = @c_rsnum.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD if_ftd_invocation_answer~answer.

    DATA lr_items  TYPE REF TO data.
    DATA lr_itemsx TYPE REF TO data.

    FIELD-SYMBOLS <lt_items>  TYPE ty_change_tab.
    FIELD-SYMBOLS <lt_itemsx> TYPE ty_changex_tab.

    mv_calls = mv_calls + 1.

    lr_items = arguments->get_table_parameter( 'RESERVATIONITEMS' ).
    ASSIGN lr_items->* TO <lt_items>.
    ASSERT sy-subrc = 0.
    mt_seen = <lt_items>.

    lr_itemsx = arguments->get_table_parameter( 'RESERVATIONITEMSX' ).
    ASSIGN lr_itemsx->* TO <lt_itemsx>.
    ASSERT sy-subrc = 0.
    mt_seenx = <lt_itemsx>.

    result->get_output_configuration( )->set_table_parameter(
      name  = 'RETURN'
      value = mt_answer ).

  ENDMETHOD.

  METHOD given_item.

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    lt_resb = VALUE #(
      ( mandt = sy-mandt
        rsnum = c_rsnum
        rspos = iv_rspos
        matnr = c_matnr
        werks = c_werks
        bdmng = '10'
        meins = 'PC'
        xloek = COND #( WHEN iv_deleted = abap_true THEN 'X' ) ) ).

    INSERT resb FROM TABLE @lt_resb.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'RESB fixture could not be inserted' ).

  ENDMETHOD.

  METHOD live_items_are_deleted.

    given_item( '0001' ).
    given_item( '0002' ).

    mo_cut->cancel( c_rsnum ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mt_seen )
      exp = 2
      msg = 'everything the reservation still holds is given back' ).
    cl_abap_unit_assert=>assert_equals(
      act = mt_seen[ 1 ]-delete_ind
      exp = abap_true ).

  ENDMETHOD.

  METHOD the_change_is_flagged.

    given_item( '0001' ).

    mo_cut->cancel( c_rsnum ).

    cl_abap_unit_assert=>assert_equals(
      act = mt_seenx[ 1 ]-delete_ind
      exp = abap_true
      msg = 'a change BAPI takes a field only when the X structure says so' ).

  ENDMETHOD.

  METHOD a_gone_reservation_is_left.

    given_item(
      iv_rspos   = '0001'
      iv_deleted = abap_true ).

    mo_cut->cancel( c_rsnum ).

    cl_abap_unit_assert=>assert_equals(
      act = mv_calls
      exp = 0
      msg = 'a reservation that holds nothing needs nothing given back' ).

  ENDMETHOD.

  METHOD no_reservation_is_no_call.

    mo_cut->cancel( '0000000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mv_calls
      exp = 0
      msg = 'a run that never reserved anything has nothing to cancel' ).

  ENDMETHOD.

  METHOD an_error_raises.

    given_item( '0001' ).

    mt_answer = VALUE #(
      ( type = 'E' id = 'M7' number = '999' message = 'Reservation is locked' ) ).

    TRY.
        mo_cut->cancel( c_rsnum ).
        cl_abap_unit_assert=>fail( 'stock that could not be given back must stop the run' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
