CLASS zcl_alloc_log_none DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">A run that keeps no diary</p>
    "!
    "! What a test run uses, and what a system without the SLG0 object can be
    "! wired with. Having one of these means nothing else has to ask whether
    "! there is a log before writing to it.
    INTERFACES zif_allocation_log.

ENDCLASS.


CLASS zcl_alloc_log_none IMPLEMENTATION.

  METHOD zif_allocation_log~start.
  ENDMETHOD.

  METHOD zif_allocation_log~allocated.
  ENDMETHOD.

  METHOD zif_allocation_log~failed.
  ENDMETHOD.

  METHOD zif_allocation_log~save.
  ENDMETHOD.

ENDCLASS.
