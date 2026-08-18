CLASS ltcl_allocation_store DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'STORE-TEST-RUN-000001'.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'STORE-TEST-01'.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.

    " a host variable rather than an inline @( CONV ... ), see ANOMALIES.md
    CONSTANTS c_demand_id TYPE zstock_alloc_res-demand_id VALUE 'D1'.

    DATA mo_cut TYPE REF TO zif_allocation_store.

    METHODS setup.
    METHODS teardown.
    METHODS saved_result_reads_back FOR TESTING RAISING cx_static_check.
    METHODS saving_twice_replaces FOR TESTING RAISING cx_static_check.
    METHODS unknown_run_reads_empty FOR TESTING.
    METHODS empty_result_saves_nothing FOR TESTING RAISING cx_static_check.
    METHODS header_fields_are_stamped FOR TESTING RAISING cx_static_check.
    METHODS reservation_is_recorded FOR TESTING RAISING cx_static_check.
    METHODS unknown_run_cannot_be_linked FOR TESTING.

ENDCLASS.


CLASS ltcl_allocation_store IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_allocation_store( ).
  ENDMETHOD.

  METHOD teardown.
    DELETE FROM zstock_alloc_res WHERE run_id = @c_run_id.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD saved_result_reads_back.

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->read( c_run_id )
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD saving_twice_replaces.

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ).

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->read( c_run_id )
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 ) )
      msg = 'rerunning an allocation must not leave the earlier lines behind' ).

  ENDMETHOD.

  METHOD unknown_run_reads_empty.

    cl_abap_unit_assert=>assert_initial( mo_cut->read( 'NO-SUCH-RUN' ) ).

  ENDMETHOD.

  METHOD empty_result_saves_nothing.

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( mo_cut->read( c_run_id ) ).

  ENDMETHOD.

  METHOD header_fields_are_stamped.

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' ) ) ).

    SELECT SINGLE matnr, werks, created_by, created_at
      FROM zstock_alloc_res
      WHERE run_id = @c_run_id
        AND demand_id = @c_demand_id
      INTO @DATA(ls_row).
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_row-matnr
      exp = c_matnr ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_row-werks
      exp = c_werks ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_row-created_by
      exp = sy-uname ).
    cl_abap_unit_assert=>assert_not_initial( ls_row-created_at ).

  ENDMETHOD.

  METHOD reservation_is_recorded.

    mo_cut->save(
      iv_run_id     = c_run_id
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ).

    mo_cut->record_reservation(
      iv_run_id      = c_run_id
      iv_reservation = '0000004711' ).

    SELECT reservation
      FROM zstock_alloc_res
      WHERE run_id = @c_run_id
      ORDER BY demand_id
      INTO TABLE @DATA(lt_row).
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_row )
      exp = 2 ).
    LOOP AT lt_row INTO DATA(ls_row).
      cl_abap_unit_assert=>assert_equals(
        act = ls_row-reservation
        exp = '0000004711'
        msg = 'every line of the run belongs to the same reservation' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD unknown_run_cannot_be_linked.

    TRY.
        mo_cut->record_reservation(
          iv_run_id      = 'NO-SUCH-RUN'
          iv_reservation = '0000004711' ).
        cl_abap_unit_assert=>fail( 'linking a run that was never saved must not pass silently' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
