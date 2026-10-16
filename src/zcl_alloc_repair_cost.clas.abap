CLASS zcl_alloc_repair_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_part,
             part TYPE string,
             cost TYPE i,
           END OF ty_part.
    TYPES ty_part_tt TYPE STANDARD TABLE OF ty_part WITH DEFAULT KEY.

    METHODS estimate
      IMPORTING
        iv_labour_minutes TYPE i
        iv_hourly_rate    TYPE i
        it_parts          TYPE ty_part_tt
      RETURNING
        VALUE(rv_cost)    TYPE i.

    METHODS parts_cost
      IMPORTING
        it_parts       TYPE ty_part_tt
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS labour_cost
      IMPORTING
        iv_labour_minutes TYPE i
        iv_hourly_rate    TYPE i
      RETURNING
        VALUE(rv_cost)    TYPE i.

ENDCLASS.


CLASS zcl_alloc_repair_cost IMPLEMENTATION.

  METHOD labour_cost.
    " The rate is per hour, so whole minutes are converted back to an hour's share.
    IF iv_labour_minutes <= 0 OR iv_hourly_rate <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_labour_minutes * iv_hourly_rate DIV 60.
  ENDMETHOD.

  METHOD parts_cost.
    LOOP AT it_parts INTO DATA(ls_part).
      IF ls_part-cost > 0.
        rv_cost = rv_cost + ls_part-cost.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD estimate.
    rv_cost = labour_cost( iv_labour_minutes = iv_labour_minutes
                           iv_hourly_rate    = iv_hourly_rate )
              + parts_cost( it_parts ).
  ENDMETHOD.

ENDCLASS.
