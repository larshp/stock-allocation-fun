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
    "! @parameter rt_outcome | <p class="shorttext synchronized">One line per material, in material order</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_outcome) TYPE ty_outcome_tab.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zif_allocation_service.
    DATA mo_demand  TYPE REF TO zif_demand_reader.

ENDCLASS.


CLASS zcl_allocation_mass_run IMPLEMENTATION.

  METHOD constructor.

    mo_service = io_service.
    mo_demand  = io_demand.

  ENDMETHOD.

  METHOD run.

    DATA ls_outcome TYPE ty_outcome.

    LOOP AT mo_demand->materials_with_demand( iv_werks ) INTO DATA(lv_matnr).

      CLEAR ls_outcome.
      ls_outcome-matnr = lv_matnr.

      TRY.
          ls_outcome-run = mo_service->run(
            iv_matnr = lv_matnr
            iv_werks = iv_werks ).
        CATCH zcx_allocation INTO DATA(lx_error).
          ls_outcome-failed = abap_true.
          ls_outcome-reason = lx_error->get_text( ).
      ENDTRY.

      APPEND ls_outcome TO rt_outcome.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
