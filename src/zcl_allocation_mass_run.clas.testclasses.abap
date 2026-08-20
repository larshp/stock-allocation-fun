CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    " the mass run never reads demand itself, the service does
    CLEAR rt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_service_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    METHODS constructor
      IMPORTING
        iv_fails_for TYPE mard-matnr OPTIONAL
        iv_short_for TYPE mard-matnr OPTIONAL
        iv_empty_for TYPE mard-matnr OPTIONAL.

    METHODS get_seen
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mv_fails_for TYPE mard-matnr.
    DATA mv_short_for TYPE mard-matnr.
    DATA mv_empty_for TYPE mard-matnr.
    DATA mt_seen      TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    mv_fails_for = iv_fails_for.
    mv_short_for = iv_short_for.
    mv_empty_for = iv_empty_for.
  ENDMETHOD.

  METHOD zif_allocation_service~simulate.
    rs_run = zif_allocation_service~run(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    CLEAR rs_run-run_id.
    CLEAR rs_run-reservation.
  ENDMETHOD.

  METHOD zif_allocation_service~run.

    APPEND iv_matnr TO mt_seen.

    IF iv_matnr = mv_fails_for.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.

    " a material nothing was waiting for comes back with no run at all
    IF iv_matnr = mv_empty_for.
      RETURN.
    ENDIF.

    IF iv_matnr = mv_short_for.
      rs_run = VALUE #(
        run_id     = |RUN-{ iv_matnr }|
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 )
          ( demand_id = 'D2' requested = '10' confirmed = '4' shortfall = '6' )
          ( demand_id = 'D3' requested = '10' confirmed = 0 shortfall = '10' ) ) ).
      RETURN.
    ENDIF.

    rs_run = VALUE #(
      run_id     = |RUN-{ iv_matnr }|
      allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD get_seen.
    rt_matnr = mt_seen.
  ENDMETHOD.

ENDCLASS.


"! Remembers what a run told it, so a test can read the run's diary back.
CLASS lcl_log_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log.

    TYPES:
      BEGIN OF ty_entry,
        kind  TYPE string,
        matnr TYPE mard-matnr,
        text  TYPE string,
        lines TYPE i,
      END OF ty_entry.
    TYPES ty_entry_tab TYPE STANDARD TABLE OF ty_entry WITH EMPTY KEY.

    METHODS get_entries
      RETURNING
        VALUE(rt_entry) TYPE ty_entry_tab.

  PRIVATE SECTION.
    DATA mt_entry TYPE ty_entry_tab.

ENDCLASS.


CLASS lcl_log_spy IMPLEMENTATION.

  METHOD get_entries.
    rt_entry = mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~start.
    APPEND VALUE #( kind = `start` text = CONV #( iv_werks ) ) TO mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~allocated.
    APPEND VALUE #(
      kind  = `allocated`
      matnr = iv_matnr
      text  = CONV #( iv_run_id )
      lines = iv_short_lines ) TO mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~failed.
    APPEND VALUE #(
      kind  = `failed`
      matnr = iv_matnr
      text  = iv_reason ) TO mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~save.
    APPEND VALUE #( kind = `save` ) TO mt_entry.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_mass_run DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_service TYPE REF TO lcl_service_double.
    DATA mo_log     TYPE REF TO lcl_log_spy.

    METHODS mass_run_over
      IMPORTING
        it_matnr          TYPE zif_demand_reader=>ty_matnr_tab
        iv_fails_for      TYPE mard-matnr OPTIONAL
        iv_short_for      TYPE mard-matnr OPTIONAL
        iv_empty_for      TYPE mard-matnr OPTIONAL
        iv_simulate       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_outcome) TYPE zcl_allocation_mass_run=>ty_outcome_tab.

    METHODS every_material_is_allocated FOR TESTING.
    METHODS nothing_waiting_does_nothing FOR TESTING.
    METHODS one_failure_does_not_stop_run FOR TESTING.
    METHODS failure_carries_the_reason FOR TESTING.
    METHODS simulation_changes_nothing FOR TESTING.
    METHODS a_run_is_written_down FOR TESTING.
    METHODS a_short_material_is_counted FOR TESTING.
    METHODS a_failure_is_written_down FOR TESTING.
    METHODS a_test_run_keeps_no_diary FOR TESTING.
    METHODS an_empty_material_is_not_noted FOR TESTING.

ENDCLASS.


CLASS ltcl_mass_run IMPLEMENTATION.

  METHOD mass_run_over.

    DATA lo_demand TYPE REF TO zif_demand_reader.

    mo_service = NEW #(
      iv_fails_for = iv_fails_for
      iv_short_for = iv_short_for
      iv_empty_for = iv_empty_for ).
    mo_log     = NEW lcl_log_spy( ).
    lo_demand  = NEW lcl_demand_double( it_matnr ).

    rt_outcome = NEW zcl_allocation_mass_run(
      io_service = mo_service
      io_demand  = lo_demand
      io_log     = mo_log )->run(
        iv_werks    = c_werks
        iv_simulate = iv_simulate ).

  ENDMETHOD.

  METHOD every_material_is_allocated.

    DATA(lt_outcome) = mass_run_over( VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_service->get_seen( )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 2 ]-run-run_id
      exp = 'RUN-MAT-2' ).

  ENDMETHOD.

  METHOD nothing_waiting_does_nothing.

    cl_abap_unit_assert=>assert_initial( mass_run_over( VALUE #( ) ) ).

  ENDMETHOD.

  METHOD one_failure_does_not_stop_run.

    DATA(lt_outcome) = mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 3
      msg = 'a blocked material must not cost the rest of the run' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 3 ]-run-run_id
      exp = 'RUN-MAT-3'
      msg = 'the materials after the failure must still be allocated' ).

  ENDMETHOD.

  METHOD simulation_changes_nothing.

    DATA(lt_outcome) = mass_run_over(
      it_matnr    = VALUE #( ( 'MAT-1' ) )
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 1 ).
    cl_abap_unit_assert=>assert_not_initial(
      act = lt_outcome[ 1 ]-run-allocation
      msg = 'a simulation must still say who would get what' ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_outcome[ 1 ]-run-run_id
      msg = 'a simulation has no run to look up, because nothing was recorded' ).

  ENDMETHOD.

  METHOD failure_carries_the_reason.

    DATA(lt_outcome) = mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 1 ]-failed
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 2 ]-failed
      exp = abap_true ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_outcome[ 2 ]-reason
      exp = '*stock is blocked*'
      msg = 'the log must say why a material was skipped' ).
    cl_abap_unit_assert=>assert_initial( lt_outcome[ 2 ]-run ).

  ENDMETHOD.

  METHOD a_run_is_written_down.

    mass_run_over( VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ) ).

    DATA(lt_entry) = mo_log->get_entries( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_entry )
      exp = 4
      msg = 'a run says it started, what it did to each material, and saves' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 1 ]-kind
      exp = `start` ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 1 ]-text
      exp = c_werks ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 2 ]-kind
      exp = `allocated` ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 2 ]-text
      exp = `RUN-MAT-1`
      msg = 'the diary points at the run the result was recorded under' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 4 ]-kind
      exp = `save`
      msg = 'a log that is never saved is gone when the job ends' ).

  ENDMETHOD.

  METHOD a_short_material_is_counted.

    mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) )
      iv_short_for = 'MAT-1' ).

    DATA(lt_entry) = mo_log->get_entries( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 2 ]-lines
      exp = 2
      msg = 'two of the three lines did not get everything, and the log says so' ).

  ENDMETHOD.

  METHOD a_failure_is_written_down.

    mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) )
      iv_fails_for = 'MAT-1' ).

    DATA(lt_entry) = mo_log->get_entries( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 2 ]-kind
      exp = `failed` ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 2 ]-matnr
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_entry[ 2 ]-text
      exp = '*stock is blocked*'
      msg = 'the reason a material was skipped is the point of keeping a log' ).

  ENDMETHOD.

  METHOD an_empty_material_is_not_noted.

    mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) )
      iv_empty_for = 'MAT-1' ).

    DATA(lt_entry) = mo_log->get_entries( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_entry )
      exp = 2
      msg = 'the run started and saved, and had nothing to say about the material' ).

  ENDMETHOD.

  METHOD a_test_run_keeps_no_diary.

    mass_run_over(
      it_matnr    = VALUE #( ( 'MAT-1' ) )
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_log->get_entries( )
      msg = 'a run that changes nothing has nothing to account for afterwards' ).

  ENDMETHOD.

ENDCLASS.
