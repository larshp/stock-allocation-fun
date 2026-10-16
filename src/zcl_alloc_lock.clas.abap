CLASS zcl_alloc_lock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lock,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
             owner  TYPE c LENGTH 20,
           END OF ty_lock.
    TYPES ty_lock_tt TYPE STANDARD TABLE OF ty_lock WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_acquire,
             locks  TYPE ty_lock_tt,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
             owner  TYPE c LENGTH 20,
           END OF ty_acquire.

    TYPES: BEGIN OF ty_release,
             locks  TYPE ty_lock_tt,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
           END OF ty_release.

    TYPES: BEGIN OF ty_query,
             locks  TYPE ty_lock_tt,
             object TYPE c LENGTH 30,
             key    TYPE c LENGTH 20,
           END OF ty_query.

    METHODS acquire
      IMPORTING
        is_input        TYPE ty_acquire
      RETURNING
        VALUE(rt_locks) TYPE ty_lock_tt.

    METHODS release
      IMPORTING
        is_input        TYPE ty_release
      RETURNING
        VALUE(rt_locks) TYPE ty_lock_tt.

    METHODS is_locked
      IMPORTING
        is_input         TYPE ty_query
      RETURNING
        VALUE(rv_locked) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_lock IMPLEMENTATION.

  METHOD acquire.
    rt_locks = is_input-locks.

    READ TABLE rt_locks TRANSPORTING NO FIELDS
      WITH KEY object = is_input-object
               key = is_input-key.
    IF sy-subrc <> 0.
      APPEND VALUE #( object = is_input-object
                      key    = is_input-key
                      owner  = is_input-owner ) TO rt_locks.
    ENDIF.
  ENDMETHOD.

  METHOD release.
    DATA lt_kept TYPE ty_lock_tt.

    LOOP AT is_input-locks INTO DATA(ls_lock).
      IF ls_lock-object = is_input-object
          AND ls_lock-key = is_input-key.
        CONTINUE.
      ENDIF.

      APPEND ls_lock TO lt_kept.
    ENDLOOP.

    rt_locks = lt_kept.
  ENDMETHOD.

  METHOD is_locked.
    READ TABLE is_input-locks TRANSPORTING NO FIELDS
      WITH KEY object = is_input-object
               key = is_input-key.
    IF sy-subrc = 0.
      rv_locked = abap_true.
    ELSE.
      rv_locked = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
