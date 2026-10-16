CLASS zcl_alloc_replenish_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS status
      IMPORTING
        iv_done          TYPE i
        iv_total         TYPE i
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS is_done
      IMPORTING
        iv_done      TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_count
      IMPORTING
        iv_done         TYPE i
        iv_total        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_status IMPLEMENTATION.

  METHOD status.
    " The run reads EMPTY, OPEN, PARTIAL or DONE as the lines get confirmed.
    IF iv_total <= 0.
      rv_status = 'EMPTY'.
    ELSEIF iv_done >= iv_total.
      rv_status = 'DONE'.
    ELSEIF iv_done > 0.
      rv_status = 'PARTIAL'.
    ELSE.
      rv_status = 'OPEN'.
    ENDIF.
  ENDMETHOD.

  METHOD is_done.
    " A run is done once every line has been confirmed and there is a line.
    IF iv_total <= 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_done >= iv_total ).
  ENDMETHOD.

  METHOD pending_count.
    " The pending lines are the part still short of the total, never negative.
    IF iv_done >= iv_total.
      RETURN.
    ENDIF.

    rv_count = iv_total - iv_done.
  ENDMETHOD.

ENDCLASS.
