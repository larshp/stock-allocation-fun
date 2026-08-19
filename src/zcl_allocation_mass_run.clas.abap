CLASS zcl_allocation_mass_run DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What became of one material in a plant wide run. FAILED lines carry the
    "! reason instead of a result, so a run can be read as a whole.
    TYPES:
      BEGIN OF ty_outcome,
        matnr  TYPE mard-matnr,
        failed TYPE abap_bool,
        reason TYPE string,
        run    TYPE zif_allocation_service=>ty_run,
      END OF ty_outcome.
    TYPES ty_outcome_tab TYPE STANDARD TABLE OF ty_outcome WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Plant wide run wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy     | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter iv_horizon_days | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_lgort        | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_cap_percent  | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter ro_mass_run     | <p class="shorttext synchronized">Ready to use plant wide run</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy        TYPE REF TO zif_allocation_strategy OPTIONAL
        iv_horizon_days    TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_lgort           TYPE mard-lgort OPTIONAL
        iv_cap_percent     TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
      RETURNING
        VALUE(ro_mass_run) TYPE REF TO zcl_allocation_mass_run.

    "! <p class="shorttext synchronized">Wire up the plant wide run</p>
    "!
    "! @parameter io_service | <p class="shorttext synchronized">Allocates one material</p>
    "! @parameter io_demand  | <p class="shorttext synchronized">Says which materials need one</p>
    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zif_allocation_service
        io_demand  TYPE REF TO zif_demand_reader.

    "! <p class="shorttext synchronized">Allocate every material in a plant that is waiting for stock</p>
    "!
    "! One material failing does not stop the rest. This runs unattended, and a
    "! single blocked material must not cost a night's worth of allocations.
    "!
    "! @parameter iv_werks   | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_matnr    | <p class="shorttext synchronized">Materials to cover, everything waiting if empty</p>
    "! @parameter iv_simulate | <p class="shorttext synchronized">Work it out but change nothing</p>
    "! @parameter rt_outcome  | <p class="shorttext synchronized">One line per material, in material order</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
        it_matnr          TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL
        iv_simulate       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_outcome) TYPE ty_outcome_tab.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zif_allocation_service.
    DATA mo_demand  TYPE REF TO zif_demand_reader.

ENDCLASS.


CLASS zcl_allocation_mass_run IMPLEMENTATION.

  METHOD create_default.

    " the material list wants the sources themselves, not the netted view of
    " them: which materials are worth looking at is a wider question than what
    " is left to serve, and the service works that out per material anyway
    ro_mass_run = NEW zcl_allocation_mass_run(
      io_service = zcl_allocation_service=>create_default(
        io_strategy     = io_strategy
        iv_horizon_days = iv_horizon_days
        iv_lgort        = iv_lgort
        iv_cap_percent  = iv_cap_percent )
      io_demand  = zcl_allocation_service=>create_default_demand( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_service = io_service.
    mo_demand  = io_demand.

  ENDMETHOD.

  METHOD run.

    DATA ls_outcome TYPE ty_outcome.
    DATA lt_matnr   TYPE zif_demand_reader=>ty_matnr_tab.

    lt_matnr = it_matnr.
    IF lt_matnr IS INITIAL.
      lt_matnr = mo_demand->materials_with_demand( iv_werks ).
    ENDIF.

    LOOP AT lt_matnr INTO DATA(lv_matnr).

      CLEAR ls_outcome.
      ls_outcome-matnr = lv_matnr.

      TRY.
          IF iv_simulate = abap_true.
            ls_outcome-run = mo_service->simulate(
              iv_matnr = lv_matnr
              iv_werks = iv_werks ).
          ELSE.
            ls_outcome-run = mo_service->run(
              iv_matnr = lv_matnr
              iv_werks = iv_werks ).
          ENDIF.
        CATCH zcx_allocation INTO DATA(lx_error).
          ls_outcome-failed = abap_true.
          ls_outcome-reason = lx_error->get_text( ).
      ENDTRY.

      APPEND ls_outcome TO rt_outcome.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
