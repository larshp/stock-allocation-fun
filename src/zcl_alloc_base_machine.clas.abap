CLASS zcl_alloc_base_machine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS hours
      IMPORTING
        it_hours        TYPE ty_values_tt
      RETURNING
        VALUE(rv_hours) TYPE i.

    METHODS per_hour
      IMPORTING
        iv_cost        TYPE i
        iv_hours       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_machine IMPLEMENTATION.

  METHOD hours.
    " The machine hours add up over the base lines.
    LOOP AT it_hours INTO DATA(lv_hours).
      rv_hours = rv_hours + lv_hours.
    ENDLOOP.
  ENDMETHOD.

  METHOD per_hour.
    " The machine hour rate spreads the cost over the hours.
    IF iv_hours <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_hours.
  ENDMETHOD.

  METHOD total.
    " The total adds up the base quantities.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
