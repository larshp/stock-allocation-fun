CLASS zcl_lock_material DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.

  PRIVATE SECTION.

    "! Exclusive, and not cumulative.
    CONSTANTS c_mode TYPE enqmode VALUE 'E'.

    "! The lock lives in the current work process only, and the run gives it
    "! back itself. Handing it to the update task instead would release it at
    "! the run's own commit, which comes before the run is over: the reservation
    "! is created, committed, and only then is the material free again. The
    "! commit waits for the update, so nothing of the run outlives the lock.
    CONSTANTS c_scope_dialog TYPE ddenqscope VALUE '1'.

    "! Wait for the lock instead of being refused the moment somebody else has
    "! it. A material is locked for as long as one run of it takes, which is a
    "! second or two, and a nightly job that gave up on every material a person
    "! happened to be looking at would report failures nobody can act on. How
    "! long the enqueue server keeps trying is a system setting, which is where
    "! that decision belongs.
    CONSTANTS c_wait TYPE ddenqwait VALUE 'X'.

ENDCLASS.


CLASS zcl_lock_material IMPLEMENTATION.

  METHOD zif_allocation_lock~acquire.

    CALL FUNCTION 'ENQUEUE_EZSTOCK_ALLOC'
      EXPORTING
        mode_marc      = c_mode
        matnr          = iv_matnr
        werks          = iv_werks
        _scope         = c_scope_dialog
        _wait          = c_wait
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>locked
        mv_message = |{ iv_matnr }|
        mv_werks   = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_allocation_lock~release.

    CALL FUNCTION 'DEQUEUE_EZSTOCK_ALLOC'
      EXPORTING
        mode_marc = c_mode
        matnr     = iv_matnr
        werks     = iv_werks
        _scope    = c_scope_dialog.

  ENDMETHOD.

ENDCLASS.
