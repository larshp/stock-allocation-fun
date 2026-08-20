CLASS zcl_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    "! <p class="shorttext synchronized">Service wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy      | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter iv_horizon_days  | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_lgort         | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_cap_percent   | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter iv_planned       | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter iv_whole_units   | <p class="shorttext synchronized">Confirm whole order units only</p>
    "! @parameter iv_recut         | <p class="shorttext synchronized">Give earlier allocations back and start again</p>
    "! @parameter iv_sto_priority  | <p class="shorttext synchronized">Where a transfer stands against an order</p>
    "! @parameter iv_ship_days     | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter ro_service       | <p class="shorttext synchronized">Ready to use service</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy       TYPE REF TO zif_allocation_strategy OPTIONAL
        iv_horizon_days   TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_lgort          TYPE mard-lgort OPTIONAL
        iv_cap_percent    TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
        iv_planned        TYPE abap_bool DEFAULT abap_false
        iv_whole_units    TYPE abap_bool DEFAULT abap_false
        iv_recut          TYPE abap_bool DEFAULT abap_false
        io_log            TYPE REF TO zif_allocation_log OPTIONAL
        iv_sto_priority   TYPE zif_allocation=>ty_priority DEFAULT zcl_sto_demand_reader=>c_default_priority
        iv_ship_days      TYPE i DEFAULT 0
      RETURNING
        VALUE(ro_service) TYPE REF TO zif_allocation_service.

    "! <p class="shorttext synchronized">Everything a plant has to give away, as one reader</p>
    "!
    "! What is on the shelf and free, what is on its way in, and what is being
    "! made. Public because a run is not the only thing that has to know: a
    "! promise asked for one line reads the same timeline the run distributes.
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Unit converter to share, its own if none</p>
    "! @parameter iv_lgort     | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_planned   | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter ro_supply    | <p class="shorttext synchronized">Reader over every source</p>
    CLASS-METHODS create_default_supply
      IMPORTING
        io_converter     TYPE REF TO zif_unit_converter OPTIONAL
        iv_lgort         TYPE mard-lgort OPTIONAL
        iv_planned       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_supply) TYPE REF TO zif_supply_reader.

    "! <p class="shorttext synchronized">Every source of demand on a plant, as one reader</p>
    "!
    "! Sales orders and stock transport orders both take stock out of the
    "! plant, so both compete in the same run. Public because a plant wide run
    "! needs the same list of sources to know which materials to cover.
    "!
    "! @parameter io_converter   | <p class="shorttext synchronized">Unit converter to share, its own if none</p>
    "! @parameter iv_sto_priority | <p class="shorttext synchronized">Where a transfer stands against an order</p>
    "! @parameter iv_ship_days   | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter ro_demand      | <p class="shorttext synchronized">Reader over every source</p>
    CLASS-METHODS create_default_demand
      IMPORTING
        io_converter     TYPE REF TO zif_unit_converter OPTIONAL
        iv_sto_priority  TYPE zif_allocation=>ty_priority DEFAULT zcl_sto_demand_reader=>c_default_priority
        iv_ship_days     TYPE i DEFAULT 0
      RETURNING
        VALUE(ro_demand) TYPE REF TO zif_demand_reader.

    "! <p class="shorttext synchronized">The rule a run distributes stock by</p>
    "!
    "! The distribution rule with everything a plant can put around it, in the
    "! order it has to go: the customer cap first, then whole units, then the
    "! complete delivery rule outside both, so that each of them sees what the
    "! one inside it did. Public because anything that shows what a run would
    "! decide has to decide it the same way.
    "!
    "! @parameter io_strategy    | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter iv_cap_percent | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter iv_whole_units | <p class="shorttext synchronized">Confirm whole order units only</p>
    "! @parameter ro_strategy    | <p class="shorttext synchronized">The rule, wrapped</p>
    CLASS-METHODS create_default_strategy
      IMPORTING
        io_strategy        TYPE REF TO zif_allocation_strategy OPTIONAL
        iv_cap_percent     TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
        iv_whole_units     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_strategy) TYPE REF TO zif_allocation_strategy.

    "! <p class="shorttext synchronized">The demand a run really works with</p>
    "!
    "! What CREATE_DEFAULT_DEMAND reads, less what earlier runs already hold
    "! and what is beyond the horizon: the reader the engine is given. Public
    "! because everything that explains, projects or compares an allocation has
    "! to read the same demand the run reads, or it is answering a different
    "! question in the same words.
    "!
    "! @parameter io_converter    | <p class="shorttext synchronized">Unit converter to share, its own if none</p>
    "! @parameter iv_horizon_days | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_sto_priority | <p class="shorttext synchronized">Where a transfer stands against an order</p>
    "! @parameter iv_ship_days    | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter ro_demand       | <p class="shorttext synchronized">Reader of what is left to serve</p>
    CLASS-METHODS create_default_open_demand
      IMPORTING
        io_converter     TYPE REF TO zif_unit_converter OPTIONAL
        iv_horizon_days  TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_sto_priority  TYPE zif_allocation=>ty_priority DEFAULT zcl_sto_demand_reader=>c_default_priority
        iv_ship_days     TYPE i DEFAULT 0
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
    "! @parameter iv_recut       | <p class="shorttext synchronized">Give earlier allocations back and start again</p>
    "! @parameter io_log         | <p class="shorttext synchronized">Where the run says what it gave back</p>
    METHODS constructor
      IMPORTING
        io_engine      TYPE REF TO zcl_allocation_engine
        io_store       TYPE REF TO zif_allocation_store
        io_run_id      TYPE REF TO zif_run_id_supplier
        io_reservation TYPE REF TO zif_reservation_writer
        io_authority   TYPE REF TO zif_allocation_authority
        io_lock        TYPE REF TO zif_allocation_lock
        io_commit      TYPE REF TO zif_unit_of_work
        iv_recut       TYPE abap_bool DEFAULT abap_false
        io_log         TYPE REF TO zif_allocation_log OPTIONAL.

  PRIVATE SECTION.
    DATA mo_engine      TYPE REF TO zcl_allocation_engine.
    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_run_id      TYPE REF TO zif_run_id_supplier.
    DATA mo_reservation TYPE REF TO zif_reservation_writer.
    DATA mo_authority   TYPE REF TO zif_allocation_authority.
    DATA mo_lock        TYPE REF TO zif_allocation_lock.
    DATA mo_commit      TYPE REF TO zif_unit_of_work.
    DATA mv_recut       TYPE abap_bool.
    DATA mo_log         TYPE REF TO zif_allocation_log.

    METHODS release_earlier
      IMPORTING
        iv_matnr TYPE mard-matnr
        iv_werks TYPE mard-werks
      RAISING
        zcx_allocation.

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

  METHOD create_default_strategy.

    DATA lo_strategy TYPE REF TO zif_allocation_strategy.

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

    " rounding goes inside the complete delivery rule as well, and for the same
    " reason as the cap: a line cut back to whole cartons may no longer reach
    " the quantity it has to ship in one go, and the rule outside has to see
    " that rather than the number before rounding
    IF iv_whole_units = abap_true.
      lo_strategy = NEW zcl_alloc_whole_units( lo_strategy ).
    ENDIF.

    " which lines may be served in part is a property of the demand, not of the
    " distribution rule, so this wraps whatever strategy is in use
    ro_strategy = NEW zcl_alloc_all_or_nothing( lo_strategy ).

  ENDMETHOD.

  METHOD create_default.

    DATA(lo_strategy) = create_default_strategy(
      io_strategy    = io_strategy
      iv_cap_percent = iv_cap_percent
      iv_whole_units = iv_whole_units ).

    " one converter serves the whole run: it buffers the material master, and
    " both the demand and the supply side ask it the same questions
    DATA(lo_converter) = NEW zcl_unit_converter( ).

    ro_service = NEW zcl_allocation_service(
      io_engine      = NEW zcl_allocation_engine(
        io_supply_reader = create_default_supply(
          io_converter = lo_converter
          iv_lgort     = iv_lgort
          iv_planned   = iv_planned )
        io_demand_reader = create_default_open_demand(
          io_converter    = lo_converter
          iv_horizon_days = iv_horizon_days
          iv_sto_priority = iv_sto_priority
          iv_ship_days    = iv_ship_days )
        io_strategy      = lo_strategy )
      io_store       = NEW zcl_allocation_store( )
      io_run_id      = NEW zcl_run_id_uuid( )
      io_reservation = NEW zcl_reservation_writer( )
      io_authority   = NEW zcl_authority_plant( )
      io_lock        = NEW zcl_lock_material( )
      io_commit      = NEW zcl_unit_of_work( )
      iv_recut       = iv_recut
      io_log         = io_log ).

  ENDMETHOD.

  METHOD create_default_supply.

    DATA lt_lgort  TYPE zcl_stock_in_locations=>ty_lgort_tab.
    DATA lt_source TYPE zcl_supply_sources=>ty_source_tab.

    " the report offers one location, the class takes as many as a caller
    " wiring it itself wants to name
    IF iv_lgort IS NOT INITIAL.
      APPEND iv_lgort TO lt_lgort.
    ENDIF.

    DATA(lo_converter) = io_converter.
    IF lo_converter IS NOT BOUND.
      lo_converter = NEW zcl_unit_converter( ).
    ENDIF.

    " what is on the shelf, what is on its way, and what is being made. A
    " planned order is not any of those until the plant says it trusts its own
    " plan, so it is added rather than always there.
    lt_source = VALUE #(
      ( NEW zcl_supply_on_hand( NEW zcl_stock_reader_net(
        io_stock     = NEW zcl_stock_in_locations(
          io_stock = NEW zcl_stock_reader( )
          it_lgort = lt_lgort )
        it_deduction = VALUE #(
          ( NEW zcl_deduct_reservations( ) )
          ( NEW zcl_deduct_deliveries( ) )
          ( NEW zcl_deduct_safety_stock( ) )
          ( NEW zcl_deduct_shelf_life( ) ) ) ) ) )
      ( NEW zcl_supply_receipts( lo_converter ) )
      ( NEW zcl_supply_production( lo_converter ) ) ).

    " a plan has two halves: what the plant will make and what it will buy.
    " MRP writes the first as a planned order and the second as a purchase
    " requisition, so a plant that trusts its plan has to be given both or it
    " gets nothing at all for everything it buys.
    IF iv_planned = abap_true.
      APPEND NEW zcl_supply_planned( lo_converter ) TO lt_source.
      APPEND NEW zcl_supply_requisitions( lo_converter ) TO lt_source.
    ENDIF.

    ro_supply = NEW zcl_supply_sources( lt_source ).

  ENDMETHOD.

  METHOD create_default_open_demand.

    " the netting and the horizon are what turn "what is on the books" into
    " "what is still to serve", and the engine is given the second of those
    ro_demand = NEW zcl_demand_reader_net(
      io_demand      = NEW zcl_demand_within_horizon(
        io_demand = create_default_demand(
          io_converter    = io_converter
          iv_sto_priority = iv_sto_priority
          iv_ship_days    = iv_ship_days )
        iv_days   = iv_horizon_days )
      io_reservation = NEW zcl_reservation_reader( ) ).

  ENDMETHOD.

  METHOD create_default_demand.

    " one converter serves both readers, and the caller may hand in the one the
    " rest of its run uses so the material master is read once for all of them
    DATA(lo_converter) = io_converter.
    IF lo_converter IS NOT BOUND.
      lo_converter = NEW zcl_unit_converter( ).
    ENDIF.

    " who is waiting is read from the documents; how much that customer
    " matters is a standing decision of the business, and how long the plant
    " needs to get the goods out of the door is a fact about the plant. Both
    " go on top of what the documents say.
    ro_demand = NEW zcl_demand_alive( NEW zcl_demand_ship_time(
      io_demand = NEW zcl_demand_customer_prio( NEW zcl_demand_sources( VALUE #(
      ( NEW zcl_so_demand_reader( lo_converter ) )
      ( NEW zcl_sto_demand_reader(
          io_converter = lo_converter
          iv_priority  = iv_sto_priority ) ) ) ) )
      iv_days   = iv_ship_days ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_engine      = io_engine.
    mo_store       = io_store.
    mo_run_id      = io_run_id.
    mo_reservation = io_reservation.
    mo_authority   = io_authority.
    mo_lock        = io_lock.
    mo_commit      = io_commit.
    mv_recut       = iv_recut.

    " a run that was given no log keeps no diary rather than checking for one
    " everywhere it might write
    mo_log = io_log.
    IF mo_log IS NOT BOUND.
      mo_log = NEW zcl_alloc_log_none( ).
    ENDIF.

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
        " what earlier runs set aside goes back into the pool first, so this
        " one sees all of it. It happens inside the lock, so nobody can take
        " the freed stock between giving it back and allocating it again.
        IF mv_recut = abap_true.
          release_earlier(
            iv_matnr = iv_matnr
            iv_werks = iv_werks ).
        ENDIF.

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

  METHOD release_earlier.

    DATA lv_released TYPE abap_bool.

    LOOP AT mo_store->runs_of_material(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_run).

      IF ls_run-reservation IS INITIAL.
        CONTINUE.
      ENDIF.

      mo_reservation->cancel( ls_run-reservation ).
      lv_released = abap_true.

      mo_log->released(
        iv_matnr       = iv_matnr
        iv_reservation = ls_run-reservation ).

    ENDLOOP.

    " a run that released nothing commits nothing. There is nothing of its own
    " to make durable, and committing anyway would make somebody else's
    " unrelated work durable for them, which is what feature 37 said about a
    " simulation and is no more welcome here.
    IF lv_released = abap_false.
      RETURN.
    ENDIF.

    " what was released has to be on the database before the readers run: the
    " stock deduction and the demand netting both ask the database what is
    " still reserved, and a cancellation nobody has committed is not there yet
    mo_commit->commit( ).

    " the recorded runs stay. They are what was decided at the time, the
    " display shows the newest one anyway, and housekeeping removes them once
    " they are old and no longer holding anything back.

  ENDMETHOD.

  METHOD allocate_and_record.

    rs_run-allocation = mo_engine->allocate_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " a material nothing is waiting for is not a run. There is no answer to
    " record, nothing to reserve, and a run id handed out for it would be a
    " number in the log that leads to an empty page. A plant wide run passes
    " over most of its materials this way, and each one it passes over is two
    " commits it does not have to wait for.
    IF rs_run-allocation IS INITIAL.
      RETURN.
    ENDIF.

    " the result is written down before the stock is reserved. If the
    " reservation is then rejected there is still a record of what was decided,
    " which can be looked up and retried. The other order would risk stock being
    " earmarked with nothing to show for it.
    rs_run-run_id = mo_run_id->next( ).

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
