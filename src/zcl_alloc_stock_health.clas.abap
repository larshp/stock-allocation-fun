CLASS zcl_alloc_stock_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS health
      IMPORTING
        iv_turns           TYPE i
        iv_service_percent TYPE i
        iv_excess_percent  TYPE i
      RETURNING
        VALUE(rv_health)   TYPE i.

    METHODS grade
      IMPORTING
        iv_health       TYPE i
      RETURNING
        VALUE(rv_grade) TYPE string.

    METHODS is_healthy
      IMPORTING
        iv_health    TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_stock_health IMPLEMENTATION.

  METHOD health.
    DATA lv_turns_part   TYPE i.
    DATA lv_service_part TYPE i.
    DATA lv_excess_part  TYPE i.

    " The health score weights turnover, service and the absence of excess.
    lv_turns_part = iv_turns * 5.
    IF lv_turns_part > 50.
      lv_turns_part = 50.
    ENDIF.

    lv_service_part = iv_service_percent * 30 DIV 100.

    lv_excess_part = ( 100 - iv_excess_percent ) * 20 DIV 100.

    rv_health = lv_turns_part + lv_service_part + lv_excess_part.
  ENDMETHOD.

  METHOD grade.
    IF iv_health >= 85.
      rv_grade = 'A'.
    ELSEIF iv_health >= 70.
      rv_grade = 'B'.
    ELSEIF iv_health >= 50.
      rv_grade = 'C'.
    ELSE.
      rv_grade = 'D'.
    ENDIF.
  ENDMETHOD.

  METHOD is_healthy.
    " The health is fine once it reaches the threshold.
    rv_ok = xsdbool( iv_health >= iv_threshold ).
  ENDMETHOD.

ENDCLASS.
