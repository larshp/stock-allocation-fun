CLASS lcl_stock_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
    DATA mt_stock TYPE zcl_stock_allocator=>ty_stock_balances.
ENDCLASS.

CLASS lcl_stock_reader IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    rt_stock = mt_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_writer DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_writer.
    DATA mt_saved TYPE zcl_stock_allocator=>ty_allocations.
    DATA mv_call_count TYPE i.
    DATA mv_fail TYPE abap_bool.
ENDCLASS.

CLASS lcl_allocation_writer IMPLEMENTATION.
  METHOD zif_allocation_writer~save_allocations.
    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>).
      IF mv_fail = abap_true.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_failed.
        <ls_allocation>-posting_message = 'Posting failed'.
      ELSE.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_posted.
        <ls_allocation>-document_id = '0000000042'.
      ENDIF.
    ENDLOOP.
    mt_saved = ct_allocations.
    mv_call_count = mv_call_count + 1.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_stock_reader.
    DATA mo_writer TYPE REF TO lcl_allocation_writer.
    DATA mo_cut TYPE REF TO zcl_stock_allocation_service.

    METHODS setup.
    METHODS simulation_does_not_write FOR TESTING.
    METHODS writes_successful_allocations FOR TESTING.
    METHODS returns_posting_failure FOR TESTING.
    METHODS skips_empty_write FOR TESTING.

    METHODS requests
      IMPORTING
        iv_quantity        TYPE zcl_stock_allocator=>ty_quantity
        iv_allow_partial   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_requests) TYPE zcl_stock_allocator=>ty_requests.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_writer = NEW #( ).
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        unrestricted_qty = 10 ) ).
    mo_cut = NEW #(
      io_stock_reader      = mo_reader
      io_allocation_writer = mo_writer ).
  ENDMETHOD.

  METHOD simulation_does_not_write.
    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD writes_successful_allocations.
    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
  ENDMETHOD.

  METHOD skips_empty_write.
    DATA(lt_result) = mo_cut->execute( requests( 11 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD returns_posting_failure.
    mo_writer->mv_fail = abap_true.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Posting failed' ).
  ENDMETHOD.

  METHOD requests.
    rt_requests = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        requirement_date = '20260818'
        requested_qty    = iv_quantity
        priority         = 100
        allow_partial    = iv_allow_partial ) ).
  ENDMETHOD.
ENDCLASS.
