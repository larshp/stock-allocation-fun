CLASS zcl_alloc_levelling DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             periods    TYPE ty_series_tt,
             rest       TYPE menge_d,
             overloaded TYPE abap_bool,
           END OF ty_result.

    METHODS level
      IMPORTING
        it_demand        TYPE ty_series_tt
        iv_capacity      TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_levelling IMPLEMENTATION.

  METHOD level.
    DATA lv_carry TYPE menge_d.
    DATA lv_load  TYPE menge_d.

    IF iv_capacity <= 0.
      rs_result-periods = it_demand.
      RETURN.
    ENDIF.

    LOOP AT it_demand INTO DATA(lv_value).
      lv_load = lv_value + lv_carry.

      IF lv_load > iv_capacity.
        lv_carry = lv_load - iv_capacity.
        lv_load = iv_capacity.
      ELSE.
        lv_carry = 0.
      ENDIF.

      APPEND lv_load TO rs_result-periods.
    ENDLOOP.

    rs_result-rest = lv_carry.

    IF lv_carry > 0.
      rs_result-overloaded = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
