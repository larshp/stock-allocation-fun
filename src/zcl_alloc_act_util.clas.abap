CLASS zcl_alloc_act_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS utilisation_percent
      IMPORTING
        iv_used           TYPE i
        iv_capacity       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_idle
      IMPORTING
        iv_used      TYPE i
        iv_capacity  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS spare
      IMPORTING
        iv_used         TYPE i
        iv_capacity     TYPE i
      RETURNING
        VALUE(rv_spare) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_util IMPLEMENTATION.

  METHOD utilisation_percent.
    " Utilisation is the load as a share of the capacity.
    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_used * 100 DIV iv_capacity.
  ENDMETHOD.

  METHOD is_idle.
    " The activity is idle while it has capacity left over.
    rv_ok = xsdbool( iv_used < iv_capacity ).
  ENDMETHOD.

  METHOD spare.
    " The spare capacity is what is left once the load is taken off.
    IF iv_used >= iv_capacity.
      RETURN.
    ENDIF.

    rv_spare = iv_capacity - iv_used.
  ENDMETHOD.

ENDCLASS.
