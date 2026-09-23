CLASS lcl_res_delete_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_api.
    METHODS set_delete_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_delete_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_commit_result.
    METHODS get_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_deleted_numbers
      RETURNING
        VALUE(rt_numbers) TYPE zif_so_reservation_api=>ty_reservation_numbers.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_delete_result TYPE zif_so_reservation_api=>ty_delete_result.
    DATA ms_commit_result TYPE zif_so_reservation_api=>ty_commit_result.
    DATA mt_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers.
    DATA mv_delete_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
    DATA mv_use_delete_result TYPE abap_bool.
    DATA mv_use_commit_result TYPE abap_bool.
ENDCLASS.

CLASS lcl_res_delete_api IMPLEMENTATION.
  METHOD set_delete_result.
    ms_delete_result = is_result.
    mv_use_delete_result = abap_true.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
    mv_use_commit_result = abap_true.
  ENDMETHOD.

  METHOD get_delete_count.
    rv_count = mv_delete_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD get_deleted_numbers.
    rt_numbers = mt_numbers.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_so_reservation_api~create_reservations.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_so_reservation_api~delete_reservations.
    ADD 1 TO mv_delete_count.
    mt_numbers = it_reservation_numbers.
    mv_test_run = iv_test_run.
    IF mv_use_delete_result = abap_true.
      rs_result = ms_delete_result.
    ELSE.
      rs_result-is_successful = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_so_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    IF mv_use_commit_result = abap_true.
      rs_result = ms_commit_result.
    ELSE.
      rs_result-is_successful = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_so_reservation_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_so_reservation_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_api TYPE REF TO lcl_res_delete_api.
    DATA mo_cut TYPE REF TO zcl_so_reservation_service.
    METHODS setup.
    METHODS deletes_and_commits FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_delete_error FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS rejects_invalid_numbers FOR TESTING.
ENDCLASS.

CLASS ltcl_so_reservation_service IMPLEMENTATION.
  METHOD setup.
    mo_api = NEW lcl_res_delete_api( ).
    mo_cut = NEW zcl_so_reservation_service( io_api = mo_api ).
  ENDMETHOD.

  METHOD deletes_and_commits.
    DATA(lt_numbers) = VALUE zif_so_reservation_api=>ty_reservation_numbers(
      ( '9000000001' )
      ( '9000000002' ) ).

    DATA(ls_result) = mo_cut->delete_reservations( lt_numbers ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_numbers
      act = mo_api->get_deleted_numbers( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_result) = mo_cut->delete_reservations(
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) )
      iv_test_run            = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_delete_error.
    mo_api->set_delete_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation is already issued' ) ) ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      VALUE #( ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      VALUE #( ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_numbers.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_reservations( VALUE #( ) ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    CLEAR lv_exception_raised.

    TRY.
        mo_cut->delete_reservations(
          VALUE #( ( '' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    CLEAR lv_exception_raised.

    TRY.
        mo_cut->delete_reservations(
          VALUE #( ( '9000000001' ) ( '9000000001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_delete_count( ) ).
  ENDMETHOD.
ENDCLASS.
