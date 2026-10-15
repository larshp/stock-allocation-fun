CLASS zcl_alloc_inventory_score DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS score
      IMPORTING
        iv_availability_percent TYPE i
        iv_accuracy_percent     TYPE i
        iv_turnover_percent     TYPE i
      RETURNING
        VALUE(rv_score)         TYPE i.

    METHODS is_good
      IMPORTING
        iv_score     TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_score      TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_inventory_score IMPLEMENTATION.

  METHOD score.
    " Availability carries two fifths, accuracy and turnover a third each.
    rv_score = ( iv_availability_percent * 40
                 + iv_accuracy_percent * 30
                 + iv_turnover_percent * 30 ) DIV 100.
  ENDMETHOD.

  METHOD is_good.
    " The score is good once it reaches the threshold.
    rv_ok = xsdbool( iv_score >= iv_threshold ).
  ENDMETHOD.

  METHOD gap.
    " The gap is the shortfall against the target, never negative.
    IF iv_score >= iv_target.
      RETURN.
    ENDIF.

    rv_gap = iv_target - iv_score.
  ENDMETHOD.

ENDCLASS.
