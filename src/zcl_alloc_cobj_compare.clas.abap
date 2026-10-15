CLASS zcl_alloc_cobj_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_cost_a        TYPE i
        iv_cost_b        TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS cheaper
      IMPORTING
        iv_cost_a      TYPE i
        iv_cost_b      TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS delta
      IMPORTING
        iv_cost_a       TYPE i
        iv_cost_b       TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cobj_compare IMPLEMENTATION.

  METHOD compare.
    " The cheaper cost object is named, or same when they agree.
    IF iv_cost_a < iv_cost_b.
      rv_choice = 'A'.
    ELSEIF iv_cost_b < iv_cost_a.
      rv_choice = 'B'.
    ELSE.
      rv_choice = 'SAME'.
    ENDIF.
  ENDMETHOD.

  METHOD cheaper.
    " The cheaper of the two costs.
    IF iv_cost_a < iv_cost_b.
      rv_cost = iv_cost_a.
    ELSE.
      rv_cost = iv_cost_b.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The delta is the first cost less the second.
    rv_delta = iv_cost_a - iv_cost_b.
  ENDMETHOD.

ENDCLASS.
