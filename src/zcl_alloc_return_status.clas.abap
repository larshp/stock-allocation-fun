CLASS zcl_alloc_return_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS stage
      IMPORTING
        iv_index        TYPE i
      RETURNING
        VALUE(rv_stage) TYPE string.

    METHODS next_stage
      IMPORTING
        iv_stage       TYPE string
      RETURNING
        VALUE(rv_next) TYPE string.

    METHODS is_final
      IMPORTING
        iv_stage     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_status IMPLEMENTATION.

  METHOD stage.
    " The return walks a fixed pipeline; an unknown position has no stage.
    CASE iv_index.
      WHEN 1.
        rv_stage = 'CREATE'.
      WHEN 2.
        rv_stage = 'RECEIVE'.
      WHEN 3.
        rv_stage = 'INSPECT'.
      WHEN 4.
        rv_stage = 'SETTLE'.
      WHEN 5.
        rv_stage = 'CLOSE'.
      WHEN OTHERS.
        rv_stage = ''.
    ENDCASE.
  ENDMETHOD.

  METHOD next_stage.
    " The last stage has no next stage.
    CASE iv_stage.
      WHEN 'CREATE'.
        rv_next = 'RECEIVE'.
      WHEN 'RECEIVE'.
        rv_next = 'INSPECT'.
      WHEN 'INSPECT'.
        rv_next = 'SETTLE'.
      WHEN 'SETTLE'.
        rv_next = 'CLOSE'.
      WHEN OTHERS.
        rv_next = ''.
    ENDCASE.
  ENDMETHOD.

  METHOD is_final.
    rv_ok = xsdbool( iv_stage = 'CLOSE' ).
  ENDMETHOD.

ENDCLASS.
