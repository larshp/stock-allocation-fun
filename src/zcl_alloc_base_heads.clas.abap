CLASS zcl_alloc_base_heads DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS heads
      IMPORTING
        it_heads        TYPE ty_values_tt
      RETURNING
        VALUE(rv_heads) TYPE i.

    METHODS per_head
      IMPORTING
        iv_cost        TYPE i
        iv_heads       TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS total
      IMPORTING
        it_costs        TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_heads IMPLEMENTATION.

  METHOD heads.
    " The headcount adds up over the base lines.
    LOOP AT it_heads INTO DATA(lv_heads).
      rv_heads = rv_heads + lv_heads.
    ENDLOOP.
  ENDMETHOD.

  METHOD per_head.
    " The cost per head spreads the cost over the headcount.
    IF iv_heads <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_cost DIV iv_heads.
  ENDMETHOD.

  METHOD total.
    " The total adds up the costs to be apportioned.
    LOOP AT it_costs INTO DATA(lv_cost).
      rv_total = rv_total + lv_cost.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
