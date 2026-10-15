CLASS zcl_alloc_atp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_period,
             period TYPE i,
             supply TYPE i,
             demand TYPE i,
           END OF ty_period.
    TYPES ty_period_tt TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    METHODS atp
      IMPORTING
        it_periods    TYPE ty_period_tt
        iv_period     TYPE i
      RETURNING
        VALUE(rv_atp) TYPE i.

    METHODS is_positive
      IMPORTING
        iv_atp       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS first_period
      IMPORTING
        it_periods       TYPE ty_period_tt
      RETURNING
        VALUE(rv_period) TYPE i.

ENDCLASS.


CLASS zcl_alloc_atp IMPLEMENTATION.

  METHOD atp.
    DATA lv_cumulative TYPE i.

    " The available to promise accumulates supply and demand up to the period.
    LOOP AT it_periods INTO DATA(ls_period).
      IF ls_period-period > iv_period.
        EXIT.
      ENDIF.

      lv_cumulative = lv_cumulative + ls_period-supply - ls_period-demand.
    ENDLOOP.

    rv_atp = lv_cumulative.
  ENDMETHOD.

  METHOD is_positive.
    rv_ok = xsdbool( iv_atp > 0 ).
  ENDMETHOD.

  METHOD first_period.
    DATA lv_cumulative TYPE i.

    " The first period is the one whose cumulative promise turns positive.
    LOOP AT it_periods INTO DATA(ls_period).
      lv_cumulative = lv_cumulative + ls_period-supply - ls_period-demand.

      IF lv_cumulative > 0.
        rv_period = ls_period-period.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
