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
        iv_empty_for TYPE mard-matnr OPTIONAL
        iv_fails_all TYPE abap_bool DEFAULT abap_false.

    METHODS get_seen
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mv_fails_for TYPE mard-matnr.
    DATA mv_fails_all TYPE abap_bool.
    DATA mv_short_for TYPE mard-matnr.
    DATA mv_empty_for TYPE mard-matnr.
    DATA mt_seen      TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    mv_fails_for = iv_fails_for.
    mv_fails_all = iv_fails_all.
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

    IF iv_matnr = mv_fails_for OR mv_fails_all = abap_true.
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

  METHOD zif_allocation_log~released.
    APPEND VALUE #(
      kind  = `released`
      matnr = iv_matnr
      text  = |{ iv_reservation }| ) TO mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~removed.
    APPEND VALUE #(
      kind = `removed`
      text = CONV #( iv_run_id ) ) TO mt_entry.
  ENDMETHOD.

  METHOD zif_allocation_log~finished.
    APPEND VALUE #(
      kind  = `finished`
      lines = iv_materials
      text  = |{ iv_short } short, { iv_failed } failed| ) TO mt_entry.
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
        iv_fails_all      TYPE abap_bool DEFAULT abap_false
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
    METHODS the_night_is_summed_up FOR TESTING.
    METHODS everything_failing_stops FOR TESTING.
    METHODS a_run_can_carry_on FOR TESTING.
    METHODS the_stop_is_written_down FOR TESTING.

    METHODS many_materials
      IMPORTING
        iv_count        TYPE i
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS ltcl_mass_run IMPLEMENTATION.

  METHOD mass_run_over.

    DATA lo_demand TYPE REF TO zif_demand_reader.

    mo_service = NEW #(
      iv_fails_for = iv_fails_for
      iv_short_for = iv_short_for
      iv_empty_for = iv_empty_for
      iv_fails_all = iv_fails_all ).
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
      exp = 5
      msg = 'it started, said what it did to each material, summed up and saved' ).
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
      exp = `finished`
      msg = 'the last thing anybody reads is how the night went as a whole' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entry[ 5 ]-kind
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
      exp = 3
      msg = 'started, summed up and saved, with nothing to say about the material' ).

  ENDMETHOD.

  METHOD the_night_is_summed_up.

    mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) )
      iv_short_for = 'MAT-2'
      iv_fails_for = 'MAT-3' ).

    DATA(lt_entry) = mo_log->get_entries( ).
    DATA(ls_last)  = lt_entry[ lines( lt_entry ) - 1 ].

    cl_abap_unit_assert=>assert_equals(
      act = ls_last-kind
      exp = `finished` ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_last-lines
      exp = 3
      msg = 'three materials were covered' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_last-text
      exp = `1 short, 1 failed`
      msg = 'and four hundred lines do not say which night this was' ).

  ENDMETHOD.

  METHOD a_test_run_keeps_no_diary.

    mass_run_over(
      it_matnr    = VALUE #( ( 'MAT-1' ) )
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_log->get_entries( )
      msg = 'a run that changes nothing has nothing to account for afterwards' ).

  ENDMETHOD.

  METHOD many_materials.

    DO iv_count TIMES.
      APPEND |MAT-{ sy-index }| TO rt_matnr.
    ENDDO.

  ENDMETHOD.

  METHOD everything_failing_stops.

    DATA(lt_outcome) = mass_run_over(
      it_matnr     = many_materials( 40 )
      iv_fails_all = abap_true ).

    " twenty tried, and one more line saying it stopped: the twenty-first
    " material would have failed for the same reason as the first twenty, and
    " a run that grinds through five thousand of those is an hour of a work
    " process and five thousand log entries nobody reads
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_service->get_seen( ) )
      exp = zcl_allocation_mass_run=>c_max_in_a_row ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = zcl_allocation_mass_run=>c_max_in_a_row + 1 ).

  ENDMETHOD.

  METHOD the_stop_is_written_down.

    mass_run_over(
      it_matnr     = many_materials( 40 )
      iv_fails_all = abap_true ).

    DATA(lv_said) = abap_false.

    LOOP AT mo_log->get_entries( ) INTO DATA(ls_entry).
      IF ls_entry-text CS 'not attempted'.
        lv_said = abap_true.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lv_said
      exp = abap_true
      msg = 'a night that stopped half way has to say so where the night is read' ).

  ENDMETHOD.

  METHOD a_run_can_carry_on.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_now TYPE zstock_alloc_res-created_at.

    CONVERT DATE sy-datum TIME '120000'
      INTO TIME STAMP lv_now TIME ZONE 'UTC'.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = 'CARRY-ON-1'
        demand_id  = 'CARRY-D1'
        matnr      = 'MAT-1'
        werks      = c_werks
        requested  = 10
        confirmed  = 10
        created_at = lv_now ) ).
    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    mo_service = NEW #( ).
    mo_log     = NEW lcl_log_spy( ).

    DATA(lt_outcome) = NEW zcl_allocation_mass_run(
      io_service = mo_service
      io_demand  = NEW lcl_demand_double( VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ) )
      io_log     = mo_log )->run(
        iv_werks    = c_werks
        iv_carry_on = abap_true ).

    DELETE FROM zstock_alloc_res WHERE run_id = 'CARRY-ON-1'.
    cl_abap_unit_assert=>assert_subrc( ).

    " a night that died at four in the morning has done most of the plant,
    " and doing it again from the beginning is an hour of a work process for
    " answers that were already right
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 1 ]-matnr
      exp = CONV mard-matnr( 'MAT-2' ) ).

  ENDMETHOD.
ENDCLASS.


"! The whole thing as it ships: real readers, the real engine, the real store,
"! against a plant put together in the database. Only the function modules are
"! doubled, because they are the edge of the system.
"!
"! What this catches that the tests above cannot is wiring: a source that was
"! written and never added to CREATE_DEFAULT reads the same in a unit test and
"! is missing here.
CLASS ltcl_end_to_end DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES if_ftd_invocation_answer.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'E2E-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9601'.
    CONSTANTS c_ebeln TYPE ekko-ebeln VALUE 'E2E-PO-001'.
    CONSTANTS c_soon  TYPE vbak-vbeln VALUE 'E2E-SO-001'.
    CONSTANTS c_late  TYPE vbak-vbeln VALUE 'E2E-SO-002'.

    CONSTANTS c_create   TYPE sxco_fm_name VALUE 'BAPI_RESERVATION_CREATE1'.
    CONSTANTS c_commit   TYPE sxco_fm_name VALUE 'BAPI_TRANSACTION_COMMIT'.
    CONSTANTS c_rollback TYPE sxco_fm_name VALUE 'BAPI_TRANSACTION_ROLLBACK'.
    CONSTANTS c_log      TYPE sxco_fm_name VALUE 'BAL_LOG_CREATE'.
    CONSTANTS c_msg      TYPE sxco_fm_name VALUE 'BAL_LOG_MSG_ADD'.
    CONSTANTS c_save     TYPE sxco_fm_name VALUE 'BAL_DB_SAVE'.

    DATA mi_env   TYPE REF TO if_function_test_environment.
    DATA mv_calls TYPE i.

    METHODS setup.
    METHODS teardown.

    METHODS allocation
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS outcome_of
      RETURNING
        VALUE(rt_outcome) TYPE zcl_allocation_mass_run=>ty_outcome_tab.

    METHODS the_plant_is_covered FOR TESTING.
    METHODS priority_takes_the_shelf FOR TESTING.
    METHODS the_receipt_dates_the_line FOR TESTING.
    METHODS the_line_left_out_says_why FOR TESTING.
    METHODS the_answer_is_written_down FOR TESTING.
    METHODS a_test_run_writes_nothing FOR TESTING.

ENDCLASS.


CLASS ltcl_end_to_end IMPLEMENTATION.

  METHOD setup.

    DATA lt_deps TYPE if_function_test_environment=>tt_function_dependencies.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.
    DATA lt_vbak TYPE STANDARD TABLE OF vbak WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    " every function module the run reaches, doubled to answer with nothing:
    " what they do is covered where they are called, and here they only have
    " to exist
    INSERT c_create INTO TABLE lt_deps.
    INSERT c_commit INTO TABLE lt_deps.
    INSERT c_rollback INTO TABLE lt_deps.
    INSERT c_log INTO TABLE lt_deps.
    INSERT c_msg INTO TABLE lt_deps.
    INSERT c_save INTO TABLE lt_deps.

    mi_env = cl_function_test_environment=>create( lt_deps ).
    mi_env->get_double( c_create )->configure_call( )->ignore_all_parameters( )->then_answer( me ).
    mi_env->get_double( c_commit )->configure_call( )->ignore_all_parameters( )->then_answer( me ).
    mi_env->get_double( c_rollback )->configure_call( )->ignore_all_parameters( )->then_answer( me ).
    mi_env->get_double( c_log )->configure_call( )->ignore_all_parameters( )->then_answer( me ).
    mi_env->get_double( c_msg )->configure_call( )->ignore_all_parameters( )->then_answer( me ).
    mi_env->get_double( c_save )->configure_call( )->ignore_all_parameters( )->then_answer( me ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    " twenty on the shelf
    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks lgort = '0001' labst = '20' ) ).
    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_subrc( ).

    " and ten more landing on the tenth of March
    lt_ekko = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln bsart = 'NB' ) ).
    INSERT ekko FROM TABLE @lt_ekko.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_ekpo = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' matnr = c_matnr
        werks = c_werks menge = '10' meins = 'PC' ) ).
    INSERT ekpo FROM TABLE @lt_ekpo.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_eket = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' etenr = '0001'
        eindt = '20260310' menge = '10' wemng = 0 ) ).
    INSERT eket FROM TABLE @lt_eket.
    cl_abap_unit_assert=>assert_subrc( ).

    " one order wanted on the fifth of March at ordinary priority, one wanted
    " on the first of April by a customer that comes first
    lt_vbak = VALUE #(
      ( mandt = sy-mandt vbeln = c_soon auart = 'TA' vkorg = '1000'
        kunnr = '0000030001' vdatu = '20260305' )
      ( mandt = sy-mandt vbeln = c_late auart = 'TA' vkorg = '1000'
        kunnr = '0000030002' vdatu = '20260401' ) ).
    INSERT vbak FROM TABLE @lt_vbak.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_vbap = VALUE #(
      ( mandt = sy-mandt vbeln = c_soon posnr = '000010' matnr = c_matnr
        werks = c_werks vrkme = 'PC' kwmeng = '15' lprio = '02' )
      ( mandt = sy-mandt vbeln = c_late posnr = '000010' matnr = c_matnr
        werks = c_werks vrkme = 'PC' kwmeng = '25' lprio = '01' ) ).
    INSERT vbap FROM TABLE @lt_vbap.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    mi_env->clear_doubles( ).

    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM vbap WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM vbak WHERE vbeln IN ( @c_soon, @c_late ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM eket WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekpo WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekko WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD if_ftd_invocation_answer~answer.
    " the doubles answer with nothing at all, which every caller here reads as
    " "it worked": no BAPIRET2 rows, no reservation number, no log handle
    mv_calls = mv_calls + 1.
  ENDMETHOD.

  METHOD outcome_of.

    rt_outcome = zcl_allocation_mass_run=>create_default( )->run(
      iv_werks    = c_werks
      iv_simulate = abap_true ).

  ENDMETHOD.

  METHOD allocation.

    DATA(lt_outcome) = outcome_of( ).

    rt_allocation = lt_outcome[ 1 ]-run-allocation.

  ENDMETHOD.

  METHOD the_plant_is_covered.

    DATA(lt_outcome) = outcome_of( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 1
      msg = 'the material two orders are waiting for is found without being named' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 1 ]-matnr
      exp = c_matnr ).

  ENDMETHOD.

  METHOD priority_takes_the_shelf.

    DATA(lt_line) = allocation( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ demand_id = 'E2E-SO-002000010' && '0000' ]-confirmed
      exp = '25'
      msg = 'the urgent line takes the shelf and then the receipt' ).

  ENDMETHOD.

  METHOD the_receipt_dates_the_line.

    DATA(lt_line) = allocation( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ demand_id = 'E2E-SO-002000010' && '0000' ]-avail_date
      exp = '20260310'
      msg = 'twenty off the shelf and five off the receipt is there on the tenth' ).

  ENDMETHOD.

  METHOD the_line_left_out_says_why.

    DATA(lt_line) = allocation( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ demand_id = 'E2E-SO-001000010' && '0000' ]-confirmed
      exp = 0
      msg = 'the shelf went to the urgent line and the receipt lands too late' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ demand_id = 'E2E-SO-001000010' && '0000' ]-reason
      exp = zif_allocation=>c_reason-no_stock ).

  ENDMETHOD.

  METHOD the_answer_is_written_down.

    zcl_allocation_mass_run=>create_default( )->run( c_werks ).

    SELECT COUNT( * ) FROM zstock_alloc_res
      WHERE werks = @c_werks
      INTO @DATA(lv_rows).

    cl_abap_unit_assert=>assert_equals(
      act = lv_rows
      exp = 2
      msg = 'a real run records one row per demand line it answered' ).

  ENDMETHOD.

  METHOD a_test_run_writes_nothing.

    outcome_of( ).

    SELECT COUNT( * ) FROM zstock_alloc_res
      WHERE werks = @c_werks
      INTO @DATA(lv_rows).

    cl_abap_unit_assert=>assert_equals(
      act = lv_rows
      exp = 0
      msg = 'a test run does the whole calculation and leaves nothing behind' ).

  ENDMETHOD.

ENDCLASS.

"! The line the log and the report head their pages with.
CLASS ltcl_settings_line DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS settings_of
      IMPORTING
        iv_quota           TYPE abap_bool DEFAULT abap_false
        iv_ship_days       TYPE i DEFAULT 0
        iv_work_days       TYPE abap_bool DEFAULT abap_false
        iv_age_days        TYPE i DEFAULT 0
      RETURNING
        VALUE(rv_settings) TYPE string.

    METHODS a_default_run_says_its_rule FOR TESTING.
    METHODS the_newest_rules_are_named FOR TESTING.
    METHODS what_is_off_is_not_mentioned FOR TESTING.

ENDCLASS.


CLASS ltcl_settings_line IMPLEMENTATION.

  METHOD settings_of.

    rv_settings = zcl_allocation_mass_run=>create_default(
      iv_quota     = iv_quota
      iv_ship_days = iv_ship_days
      iv_work_days = iv_work_days
      iv_age_days  = iv_age_days )->settings( ).

  ENDMETHOD.

  METHOD a_default_run_says_its_rule.

    " it was worked out from the beginning and never passed on, so every
    " scheduled job headed its log with an empty settings line
    cl_abap_unit_assert=>assert_char_cp(
      act = settings_of( )
      exp = '*priority*'
      msg = 'a log nobody can read the settings of is a log of what, exactly' ).

  ENDMETHOD.

  METHOD the_newest_rules_are_named.

    DATA(lv_settings) = settings_of(
      iv_quota     = abap_true
      iv_ship_days = 2
      iv_work_days = abap_true
      iv_age_days  = 7 ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lv_settings
      exp = '*quotas*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lv_settings
      exp = '*2 day(s) to ship in working days*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lv_settings
      exp = '*a place per 7 day(s) waited*' ).

  ENDMETHOD.

  METHOD what_is_off_is_not_mentioned.

    " a header that lists every setting a run could have had, on or off, is a
    " header nobody reads twice
    cl_abap_unit_assert=>assert_char_np(
      act = settings_of( )
      exp = '*quotas*' ).

  ENDMETHOD.

ENDCLASS.
