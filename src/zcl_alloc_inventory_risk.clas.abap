CLASS zcl_alloc_inventory_risk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS risk
      IMPORTING
        iv_age_days        TYPE i
        iv_excess_percent  TYPE i
        iv_service_percent TYPE i
      RETURNING
        VALUE(rv_risk)     TYPE i.

    METHODS is_high
      IMPORTING
        iv_risk      TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count_high
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_inventory_risk IMPLEMENTATION.

  METHOD risk.
    DATA lv_age_part     TYPE i.
    DATA lv_excess_part  TYPE i.
    DATA lv_service_part TYPE i.

    " The risk rises with age and excess and falls with the service level.
    lv_age_part = iv_age_days DIV 5.
    IF lv_age_part > 40.
      lv_age_part = 40.
    ENDIF.

    lv_excess_part = iv_excess_percent.
    IF lv_excess_part > 30.
      lv_excess_part = 30.
    ENDIF.

    lv_service_part = ( 100 - iv_service_percent ) DIV 2.
    IF lv_service_part > 30.
      lv_service_part = 30.
    ENDIF.

    rv_risk = lv_age_part + lv_excess_part + lv_service_part.
    IF rv_risk > 100.
      rv_risk = 100.
    ENDIF.
  ENDMETHOD.

  METHOD is_high.
    " The risk is high once it reaches the threshold.
    rv_ok = xsdbool( iv_risk >= iv_threshold ).
  ENDMETHOD.

  METHOD count_high.
    LOOP AT it_values INTO DATA(lv_risk).
      IF is_high( iv_risk = lv_risk iv_threshold = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
