"! Answers with a fixed set of recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_written  TYPE abap_bool.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_written.
  ENDMETHOD.

ENDCLASS.


"! Allows the plants it was told to allow, and refuses the rest.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_allowed TYPE ty_werks_tab.

  PRIVATE SECTION.
    DATA mt_allowed TYPE ty_werks_tab.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mt_allowed = it_allowed.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF NOT line_exists( mt_allowed[ table_line = iv_werks ] ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>not_authorised
        mv_message = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


"! Hands out what it was told, per plant.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    TYPES:
      BEGIN OF ty_row,
        matnr    TYPE mard-matnr,
        werks    TYPE mard-werks,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_row TYPE ty_row_tab.

  PRIVATE SECTION.
    DATA mt_row TYPE ty_row_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_row = it_row.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr
          AND werks = iv_werks.
      APPEND VALUE #( quantity = ls_row-quantity ) TO rt_supply.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


"! Hands out the demand it was told, per plant.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_row TYPE lcl_supply_double=>ty_row_tab.

  PRIVATE SECTION.
    DATA mt_row TYPE lcl_supply_double=>ty_row_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_row = it_row.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr
          AND werks = iv_werks.
      APPEND VALUE #(
        demand_id = |{ ls_row-werks }|
        matnr     = ls_row-matnr
        werks     = ls_row-werks
        quantity  = ls_row-quantity ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


"! Counts the commits.
CLASS lcl_commit_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_unit_of_work.

    METHODS commits
      RETURNING
        VALUE(rv_commits) TYPE i.

  PRIVATE SECTION.
    DATA mv_commits TYPE i.
    DATA mv_rolled  TYPE abap_bool.

ENDCLASS.


CLASS lcl_commit_double IMPLEMENTATION.

  METHOD commits.
    rv_commits = mv_commits.
  ENDMETHOD.

  METHOD zif_unit_of_work~commit.
    mv_commits = mv_commits + 1.
  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.
    " nothing here rolls back: a proposal is written down or it is not
    CLEAR mv_rolled.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_propose DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PROPOSE-01'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_far   TYPE mard-werks VALUE '3000'.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.
    DATA mo_commit   TYPE REF TO lcl_commit_double.

    METHODS setup.
    METHODS teardown.

    METHODS run_of
      IMPORTING
        it_supply      TYPE lcl_supply_double=>ty_row_tab
        it_demand      TYPE lcl_supply_double=>ty_row_tab OPTIONAL
        it_allowed     TYPE lcl_authority_double=>ty_werks_tab OPTIONAL
        iv_short       TYPE zif_allocation=>ty_quantity DEFAULT '40'
        iv_test        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_propose=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS found
      IMPORTING
        it_line         TYPE zcl_alloc_propose=>ty_line_tab
        iv_pattern      TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS a_spare_plant_is_proposed FOR TESTING RAISING cx_static_check.
    METHODS the_proposal_is_written_down FOR TESTING RAISING cx_static_check.
    METHODS a_test_run_writes_nothing FOR TESTING RAISING cx_static_check.
    METHODS an_open_one_is_not_repeated FOR TESTING RAISING cx_static_check.
    METHODS a_plant_with_no_spare FOR TESTING RAISING cx_static_check.
    METHODS the_shortfall_caps_it FOR TESTING RAISING cx_static_check.
    METHODS nothing_new_says_so FOR TESTING RAISING cx_static_check.
    METHODS one_commit_for_the_run FOR TESTING RAISING cx_static_check.
    METHODS nothing_written_is_no_commit FOR TESTING RAISING cx_static_check.
    METHODS a_plant_nobody_may_see FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_propose IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    lt_marc = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_here )
      ( mandt = sy-mandt matnr = c_matnr werks = c_there )
      ( mandt = sy-mandt matnr = c_matnr werks = c_far ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_subrc( ).

    mo_transfer = NEW zcl_alloc_transfer( ).
    mo_commit   = NEW lcl_commit_double( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM zstock_alloc_trf WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD run_of.

    DATA(lt_allowed) = it_allowed.
    IF lt_allowed IS INITIAL.
      lt_allowed = VALUE #( ( c_here ) ( c_there ) ( c_far ) ).
    ENDIF.

    DATA(lo_cut) = NEW zcl_alloc_propose(
      io_supply    = NEW lcl_supply_double( it_supply )
      io_demand    = NEW lcl_demand_double( it_demand )
      io_store     = NEW lcl_store_double( VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = iv_short
          confirmed = 0 shortfall = iv_short reason = 'S' ) ) )
      io_authority = NEW lcl_authority_double( lt_allowed )
      io_transfer  = mo_transfer
      io_commit    = mo_commit ).

    rt_line = lo_cut->run(
      iv_werks = c_here
      iv_test  = iv_test ).

  ENDMETHOD.

  METHOD found.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CP iv_pattern.
        rv_found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_spare_plant_is_proposed.

    DATA(lt_line) = run_of(
      VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*2000*40.000*proposed*' )
      msg = 'a plant with stock to spare is a transfer worth raising' ).

  ENDMETHOD.

  METHOD the_proposal_is_written_down.

    run_of( VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) ) ).

    DATA(lt_open) = mo_transfer->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_open )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-from_werks
      exp = c_there ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-quantity
      exp = '40'
      msg = 'the page and the note have to say the same number' ).

  ENDMETHOD.

  METHOD a_test_run_writes_nothing.

    DATA(lt_line) = run_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) )
      iv_test   = abap_true ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*would be proposed*' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'a test run of a program that changes something changes nothing' ).

  ENDMETHOD.

  METHOD an_open_one_is_not_repeated.

    " what makes this schedulable: a nightly job that made the same note
    " every night would be a worklist nobody could work through
    run_of( VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) ) ).

    DATA(lt_line) = run_of(
      VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_transfer->open_for( c_here ) )
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*already proposed*' )
      msg = 'and it says so rather than going quiet about it' ).

  ENDMETHOD.

  METHOD a_plant_with_no_spare.

    run_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) )
      it_demand = VALUE #( ( matnr = c_matnr werks = c_there quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'a plant with everything promised already is not asked for it' ).

  ENDMETHOD.

  METHOD the_shortfall_caps_it.

    " sixty spare there and forty missing here: the note asks for forty,
    " because a transfer of sixty would move a shortage rather than fix one
    run_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_there quantity = '60' ) )
      iv_short  = '40' ).

    DATA(lt_open) = mo_transfer->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-quantity
      exp = '40' ).

  ENDMETHOD.

  METHOD nothing_new_says_so.

    DATA(lt_line) = run_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*Nothing new to propose*' ) ).

  ENDMETHOD.

  METHOD one_commit_for_the_run.

    run_of( VALUE #(
      ( matnr = c_matnr werks = c_there quantity = '100' )
      ( matnr = c_matnr werks = c_far quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_transfer->open_for( c_here ) )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->commits( )
      exp = 1
      msg = 'a proposal is a note, and the run is what has to survive' ).

  ENDMETHOD.

  METHOD nothing_written_is_no_commit.

    " the rule feature 37 settled for a simulation: a run with nothing of its
    " own to make durable must not make somebody else's work durable for them
    run_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->commits( )
      exp = 0 ).

  ENDMETHOD.

  METHOD a_plant_nobody_may_see.

    run_of(
      it_supply  = VALUE #( ( matnr = c_matnr werks = c_far quantity = '100' ) )
      it_allowed = VALUE #( ( c_here ) ( c_there ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'nobody makes a note about a plant they may not know about' ).

  ENDMETHOD.

ENDCLASS.
