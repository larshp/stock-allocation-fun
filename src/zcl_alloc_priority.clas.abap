CLASS zcl_alloc_priority DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_factors,
             delivery_priority TYPE i,
             days_until_due    TYPE i,
             customer_weight   TYPE i,
           END OF ty_factors.

    METHODS score
      IMPORTING
        is_factors      TYPE ty_factors
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_priority IMPLEMENTATION.

  METHOD score.
    DATA lv_urgency TYPE i.

    rv_score = is_factors-delivery_priority * 10.

    IF is_factors-days_until_due > 0
        AND is_factors-days_until_due < 30.
      lv_urgency = 30 - is_factors-days_until_due.
      rv_score = rv_score + lv_urgency.
    ENDIF.

    rv_score = rv_score + is_factors-customer_weight.
  ENDMETHOD.

ENDCLASS.
