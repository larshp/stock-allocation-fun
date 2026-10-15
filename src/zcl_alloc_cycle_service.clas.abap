CLASS zcl_alloc_cycle_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_period,
             target TYPE i,
             actual TYPE i,
           END OF ty_period.
    TYPES ty_period_tt TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    METHODS level
      IMPORTING
        it_periods      TYPE ty_period_tt
      RETURNING
        VALUE(rv_level) TYPE i.

    METHODS is_met
      IMPORTING
        iv_level        TYPE i
        iv_target_level TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

    METHODS breach_count
      IMPORTING
        it_periods      TYPE ty_period_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_service IMPLEMENTATION.

  METHOD level.
    DATA lv_met   TYPE i.
    DATA lv_count TYPE i.

    " The cycle service level is the share of periods that met their target.
    LOOP AT it_periods INTO DATA(ls_period).
      lv_count = lv_count + 1.
      IF ls_period-actual >= ls_period-target.
        lv_met = lv_met + 1.
      ENDIF.
    ENDLOOP.

    IF lv_count <= 0.
      RETURN.
    ENDIF.

    rv_level = lv_met * 100 DIV lv_count.
  ENDMETHOD.

  METHOD is_met.
    " The cycle service level is met once it reaches its own target.
    rv_ok = xsdbool( iv_level >= iv_target_level ).
  ENDMETHOD.

  METHOD breach_count.
    " A breach is a period that fell short of its target.
    LOOP AT it_periods INTO DATA(ls_period).
      IF ls_period-actual < ls_period-target.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
