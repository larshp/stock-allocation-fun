CLASS zcl_alloc_act_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS cost
      IMPORTING
        iv_rate        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS total
      IMPORTING
        it_costs        TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_cost IMPLEMENTATION.

  METHOD cost.
    " An activity cost is its rate taken over its quantity.
    rv_cost = iv_rate * iv_quantity.
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost is the activity cost spread over its quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_quantity.
  ENDMETHOD.

  METHOD total.
    " The total adds the activity cost of every line.
    LOOP AT it_costs INTO DATA(lv_cost).
      rv_total = rv_total + lv_cost.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
