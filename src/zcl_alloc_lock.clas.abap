"! Allocation run lock - prevents concurrent allocation runs from
"! double-allocating the same stock. Simulates an ENQUEUE-style lock.
CLASS zcl_alloc_lock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    "! Try to acquire the run lock. abap_false if already locked.
    CLASS-METHODS acquire
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    "! Release the run lock
    CLASS-METHODS release.

    "! Check whether the lock is currently held
    CLASS-METHODS is_locked
      RETURNING
        VALUE(rv_locked) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gv_locked TYPE abap_bool.

ENDCLASS.



CLASS zcl_alloc_lock IMPLEMENTATION.


  METHOD acquire.
    IF gv_locked = abap_true.
      rv_ok = abap_false.
      RETURN.
    ENDIF.
    gv_locked = abap_true.
    rv_ok = abap_true.
  ENDMETHOD.


  METHOD release.
    gv_locked = abap_false.
  ENDMETHOD.


  METHOD is_locked.
    rv_locked = gv_locked.
  ENDMETHOD.


ENDCLASS.
