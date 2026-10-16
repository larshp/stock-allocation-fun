CLASS zcl_alloc_wip_labour DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS labour_cost
      IMPORTING
        iv_hours       TYPE i
        iv_rate        TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS applied
      IMPORTING
        iv_budget         TYPE i
        iv_percent        TYPE i
      RETURNING
        VALUE(rv_applied) TYPE i.

    METHODS balance
      IMPORTING
        iv_budget         TYPE i
        iv_applied        TYPE i
      RETURNING
        VALUE(rv_balance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wip_labour IMPLEMENTATION.

  METHOD labour_cost.
    " The labour cost is the hours at their rate.
    rv_cost = iv_hours * iv_rate.
  ENDMETHOD.

  METHOD applied.
    " The applied labour is the budget at its percentage.
    rv_applied = iv_budget * iv_percent DIV 100.
  ENDMETHOD.

  METHOD balance.
    " The balance is what is left of the budget once applied.
    IF iv_applied >= iv_budget.
      RETURN.
    ENDIF.

    rv_balance = iv_budget - iv_applied.
  ENDMETHOD.

ENDCLASS.
