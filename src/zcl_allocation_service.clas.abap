CLASS zcl_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    "! <p class="shorttext synchronized">Service wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy      | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter iv_horizon_days  | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_lgort         | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_cap_percent   | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter ro_service       | <p class="shorttext synchronized">Ready to use service</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy       TYPE REF TO zif_allocation_strategy OPTIONAL
        iv_horizon_days   TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_lgort          TYPE mard-lgort OPTIONAL
        iv_cap_percent    TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
      RETURNING
        VALUE(ro_service) TYPE REF TO zif_allocation_service.

    "! <p class="shorttext synchronized">Every source of demand on a plant, as one reader</p>
    "!
    "! Sales orders and stock transport orders both take stock out of the
    "! plant, so both compete in the same run. Public because a plant wide run
    "! needs the same list of sources to know which materials to cover.
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Unit converter to share, its own if none</p>
    "! @parameter ro_demand    | <p class="shorttext synchronized">Reader over every source</p>
    CLASS-METHODS create_default_demand
      IMPORTING
        io_converter     TYPE REF TO zif_unit_converter OPTIONAL
      RETURNING
        VALUE(ro_demand) TYPE REF TO zif_demand_reader.

    "! <p class="shorttext synchronized">Wire up the service</p>
    "!
    "! @parameter io_engine      | <p class="shorttext synchronized">Calculates the allocation</p>
    "! @parameter io_store       | <p class="shorttext synchronized">Records the result</p>
    "! @parameter io_run_id      | <p class="shorttext synchronized">Identifies the run</p>
    "! @parameter io_reservation | <p class="shorttext synchronized">Earmarks the confirmed stock</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may allocate where</p>
    "! @parameter io_lock        | <p class="shorttext synchronized">Keeps two runs off the same material</p>
    "! @parameter io_commit      | <p class="shorttext synchronized">Makes what the run wrote durable</p>
    METHODS constructor
      IMPORTING
        io_engine      TYPE REF TO zcl_allocation_engine
        io_store       TYPE REF TO zif_allocation_store
        io_run_id      TYPE REF TO zif_run_id_supplier
        io_reservation TYPE REF TO zif_reservation_writer
        io_authority   TYPE REF TO zif_allocation_authority
        io_lock        TYPE REF TO zif_allocation_lock
        io_commit      TYPE REF TO zif_unit_of_work.

  PRIVATE SECTION.
    DATA mo_engine      TYPE REF TO zcl_allocation_engine.
    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_run_id      TYPE REF TO zif_run_id_supplier.
    DATA mo_reservation TYPE REF TO zif_reservation_writer.
    DATA mo_authority   TYPE REF TO zif_allocation_authority.
    DATA mo_lock        TYPE REF TO zif_allocation_lock.
    DATA mo_commit      TYPE REF TO zif_unit_of_work.

    METHODS allocate_and_record
      IMPORTING
        iv_matnr      TYPE mard-matnr
        iv_werks      TYPE mard-werks
      RETURNING
        VALUE(rs_run) TYPE zif_allocation_service=>ty_run
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_allocation_service IMPLEMENTATION.

  METHOD create_default.

    DATA lo_strategy TYPE REF TO zif_allocation_strategy.
    DATA lt_lgort    TYPE zcl_stock_in_locations=>ty_lgort_tab.

    " the report offers one location, the class takes as many as a caller
    " wiring it itself wants to name
    IF iv_lgort IS NOT INITIAL.
      APPEND iv_lgort TO lt_lgort.
    ENDIF.

    lo_strategy = io_strategy.
    IF lo_strategy IS NOT BOUND.
      lo_strategy = NEW zcl_alloc_strategy_priority( ).
    ENDIF.

    " the cap goes inside the complete delivery rule on purpose: a line that may
    " only ship in full and is held back by its customer's share can never ship,
    " so the rule outside sees it fall short of the whole quantity and drops it
    lo_strategy = NEW zcl_alloc_customer_cap(
      io_strategy = lo_strategy
      iv_percent  = iv_cap_percent ).

    " which lines may be served in part is a property of the demand, not of the
    " distribution rule, so this wraps whatever strategy is in use
    lo_strategy = NEW zcl_alloc_all_or_nothing( lo_strategy ).

    " one converter serves the whole run: it buffers the material master, and
    " both the demand and the supply side ask it the same questions
    DATA(lo_converter) = NEW zcl_unit_converter( ).

    ro_service = NEW zcl_allocation_service(
      io_engine      = NEW zcl_allocation_engine(
        io_supply_reader = NEW zcl_supply_sources( VALUE #(
          ( NEW zcl_supply_on_hand( NEW zcl_stock_reader_net(
            io_stock     = NEW zcl_stock_in_locations(
              io_stock = NEW zcl_stock_reader( )
              it_lgort = lt_lgort )
            it_deduction = VALUE #(
              ( NEW zcl_deduct_reservations( ) )
              ( NEW zcl_deduct_deliveries( ) )
              ( NEW zcl_deduct_safety_stock( ) ) ) ) ) )
          ( NEW zcl_supply_receipts( lo_converter ) )
          ( NEW zcl_supply_production( lo_converter ) ) ) )
        io_demand_reader = NEW zcl_demand_reader_net(
          io_demand      = NEW zcl_demand_within_horizon(
            io_demand = create_default_demand( lo_converter )
            iv_days   = iv_horizon_days )
          io_reservation = NEW zcl_reservation_reader( ) )
        io_strategy      = lo_strategy )
      io_store       = NEW zcl_allocation_store( )
      io_run_id      = NEW zcl_run_id_uuid( )
      io_reservation = NEW zcl_reservation_writer( )
      io_authority   = NEW zcl_authority_plant( )
      io_lock        = NEW zcl_lock_material( )
      io_commit      = NEW zcl_unit_of_work( ) ).

  ENDMETHOD.

  METHOD create_default_demand.

    " one converter serves both readers, and the caller may hand in the one the
    " rest of its run uses so the material master is read once for all of them
    DATA(lo_converter) = io_converter.
    IF lo_converter IS NOT BOUND.
      lo_converter = NEW zcl_unit_converter( ).
    ENDIF.

    ro_demand = NEW zcl_demand_sources( VALUE #(
      ( NEW zcl_so_demand_reader( lo_converter ) )
      ( NEW zcl_sto_demand_reader( lo_converter ) ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_engine      = io_engine.
    mo_store       = io_store.
    mo_run_id      = io_run_id.
    mo_reservation = io_reservation.
    mo_authority   = io_authority.
    mo_lock        = io_lock.
    mo_commit      = io_commit.

  ENDMETHOD.

  METHOD zif_allocation_service~run.

    " nothing is read, written or reserved before the user has been checked
    mo_authority->check_plant( iv_werks ).

    " and nothing is read before this run owns the material, otherwise a
    " second run would work from the same available stock and give it away too
    mo_lock->acquire(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " CATCH and re-raise rather than CLEANUP: the transpiler drops the body of
    " a CLEANUP block, so the lock would never come back. See ANOMALIES.md.
    TRY.
        rs_run = allocate_and_record(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
      CATCH zcx_allocation INTO DATA(lx_error).
        " whatever this run had written is half an answer, and the next run
        " would read it as a whole one
        mo_commit->rollback( ).
        mo_lock->release(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
        RAISE EXCEPTION lx_error.
    ENDTRY.

    mo_lock->release(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD zif_allocation_service~simulate.

    " a simulation still asks whether the user may allocate here: it answers
    " the same question as a real run and should not answer it for a plant the
    " user cannot see
    mo_authority->check_plant( iv_werks ).

    rs_run-allocation = mo_engine->allocate_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD allocate_and_record.

    " the result is written down before the stock is reserved. If the
    " reservation is then rejected there is still a record of what was decided,
    " which can be looked up and retried. The other order would risk stock being
    " earmarked with nothing to show for it.
    rs_run-run_id     = mo_run_id->next( ).
    rs_run-allocation = mo_engine->allocate_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    mo_store->save(
      iv_run_id     = rs_run-run_id
      iv_matnr      = iv_matnr
      iv_werks      = iv_werks
      it_allocation = rs_run-allocation ).

    " ... and the record is committed before the stock is reserved, for the same
    " reason. A reservation that is then rejected leaves a run somebody can look
    " up and retry, rather than nothing at all. The record on its own holds no
    " stock back: the netting only counts a run whose reservation is live.
    mo_commit->commit( ).

    rs_run-reservation = mo_reservation->reserve(
      iv_matnr      = iv_matnr
      iv_werks      = iv_werks
      it_allocation = rs_run-allocation ).

    IF rs_run-reservation IS NOT INITIAL.
      mo_store->record_reservation(
        iv_run_id      = rs_run-run_id
        iv_reservation = rs_run-reservation ).
    ENDIF.

    " the reservation and the link to it are one unit: a reservation nothing
    " points at is stock held back that no run admits to holding
    mo_commit->commit( ).

  ENDMETHOD.

ENDCLASS.
