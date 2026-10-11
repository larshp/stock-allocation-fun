CLASS lcl_reservation_reader_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    TYPES ty_results TYPE STANDARD TABLE OF
      zif_so_reservation_reader=>ty_result WITH EMPTY KEY.
    TYPES ty_reservation_numbers TYPE STANDARD TABLE OF
      bapi2093_res_key-reserv_no WITH EMPTY KEY.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_so_reservation_reader=>ty_result.
    METHODS set_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_reservation_number
      RETURNING
        VALUE(rv_number) TYPE bapi2093_res_key-reserv_no.
    METHODS get_read_numbers
      RETURNING
        VALUE(rt_numbers) TYPE ty_reservation_numbers.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mt_results TYPE ty_results.
    DATA mt_read_numbers TYPE ty_reservation_numbers.
    DATA mv_read_count TYPE i.
    DATA mv_reservation_number TYPE bapi2093_res_key-reserv_no.
ENDCLASS.

CLASS lcl_reservation_reader_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
    CLEAR mt_results.
  ENDMETHOD.

  METHOD set_results.
    mt_results = it_results.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_reservation_number.
    rv_number = mv_reservation_number.
  ENDMETHOD.

  METHOD get_read_numbers.
    rt_numbers = mt_read_numbers.
  ENDMETHOD.

  METHOD zif_so_reservation_reader~read_reservation.
    ADD 1 TO mv_read_count.
    mv_reservation_number = iv_reservation_number.
    APPEND iv_reservation_number TO mt_read_numbers.
    IF mt_results IS INITIAL.
      rs_result = ms_result.
    ELSE.
      READ TABLE mt_results INTO rs_result INDEX mv_read_count.
      IF sy-subrc <> 0.
        rs_result = ms_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_reservation_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_reservation_reader_double.
    DATA mo_cut TYPE REF TO zcl_so_res_read_service.
    METHODS setup.
    METHODS reads_reservation_items FOR TESTING.
    METHODS rejects_missing_number FOR TESTING.
    METHODS clears_failed_read FOR TESTING.
    METHODS rejects_wrong_res_number FOR TESTING.
    METHODS rejects_duplicate_items FOR TESTING.
    METHODS rejects_empty_read FOR TESTING.
    METHODS reads_multiple_reservations FOR TESTING.
    METHODS continues_after_bulk_error FOR TESTING.
    METHODS rejects_bad_reservation_list FOR TESTING.
    METHODS empty_reservation_list_skips FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation_read IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW lcl_reservation_reader_double( ).
    mo_cut = NEW zcl_so_res_read_service( io_reader = mo_reader ).
  ENDMETHOD.

  METHOD reads_reservation_items.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            record_type        = ' '
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            movement_allowed   = abap_true ) ) ) ).

    DATA(ls_result) = mo_cut->read_reservation( '9000000001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapi2093_res_item_detail-req_quan( '5.000' )
      act = ls_result-items[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapi2093_res_item_detail-withd_quan( '2.000' )
      act = ls_result-items[ 1 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = mo_reader->get_reservation_number( ) ).
  ENDMETHOD.

  METHOD rejects_missing_number.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->read_reservation( space ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD clears_failed_read.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_false
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001' ) )
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation not found' ) ) ) ).

    DATA(ls_result) = mo_cut->read_reservation( '9000000001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-items ) ).
  ENDMETHOD.

  METHOD rejects_empty_read.
    mo_reader->set_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->read_reservation( '9000000001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
  ENDMETHOD.

  METHOD rejects_wrong_res_number.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000002'
            item_number        = '0001' ) ) ) ).

    DATA(ls_result) = mo_cut->read_reservation( '9000000001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-items ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_items.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001' )
          ( reservation_number = '9000000001'
            item_number        = '0001' ) ) ) ).

    DATA(ls_result) = mo_cut->read_reservation( '9000000001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation API returned duplicate item details'
      act = ls_result-messages[ type = 'E' ]-message ).
  ENDMETHOD.

  METHOD reads_multiple_reservations.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002' ) ) )
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001' ) ) ) ) ).

    DATA(lt_results) = mo_cut->read_reservations(
      it_reservation_numbers = VALUE #(
        ( '9000000002' )
        ( '9000000001' ) ) ).
    DATA(lt_read_numbers) = mo_reader->get_read_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = lt_results[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-read_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_results[ 1 ]-read_result-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_results[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 2 ]-read_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = VALUE lcl_reservation_reader_double=>ty_reservation_numbers(
        ( '9000000002' )
        ( '9000000001' ) )
      act = lt_read_numbers ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD continues_after_bulk_error.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002' ) ) )
        ( is_successful = abap_false
          messages      = VALUE #(
            ( type = 'E' message = 'Reservation not found' ) ) ) ) ).

    DATA(lt_results) = mo_cut->read_reservations(
      it_reservation_numbers = VALUE #(
        ( '9000000002' )
        ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-read_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_results[ 2 ]-read_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results[ 2 ]-read_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = lt_results[ 2 ]-read_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_list.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->read_reservations(
          it_reservation_numbers = VALUE #(
            ( '9000000001' )
            ( space ) ) ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->read_reservations(
          it_reservation_numbers = VALUE #(
            ( '9000000001' )
            ( '9000000001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_reservation_list_skips.
    DATA(lt_results) = mo_cut->read_reservations(
      it_reservation_numbers = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_results ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
