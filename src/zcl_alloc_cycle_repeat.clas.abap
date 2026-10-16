CLASS zcl_alloc_cycle_repeat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS repeat
      IMPORTING
        iv_count       TYPE i
        iv_max         TYPE i
      RETURNING
        VALUE(rv_next) TYPE i.

    METHODS is_repeated
      IMPORTING
        iv_count     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS max_reached
      IMPORTING
        iv_count     TYPE i
        iv_max       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cycle_repeat IMPLEMENTATION.

  METHOD repeat.
    " The cycle repeats one more time, held at the maximum.
    rv_next = iv_count + 1.
    IF rv_next > iv_max.
      rv_next = iv_max.
    ENDIF.
  ENDMETHOD.

  METHOD is_repeated.
    " The cycle has been repeated once it has run more than once.
    rv_ok = xsdbool( iv_count > 0 ).
  ENDMETHOD.

  METHOD max_reached.
    " The maximum is reached once the count gets there.
    rv_ok = xsdbool( iv_count >= iv_max ).
  ENDMETHOD.

ENDCLASS.
