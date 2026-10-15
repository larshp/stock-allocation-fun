CLASS zcl_alloc_val_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_value_a    TYPE i
        iv_value_b    TYPE i
      RETURNING
        VALUE(rv_cmp) TYPE i.

    METHODS best_method
      IMPORTING
        iv_value_cost    TYPE i
        iv_value_market  TYPE i
      RETURNING
        VALUE(rv_method) TYPE string.

    METHODS delta
      IMPORTING
        iv_value_a      TYPE i
        iv_value_b      TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_compare IMPLEMENTATION.

  METHOD compare.
    " The comparison is minus one, zero or one as a is lower, equal or higher.
    IF iv_value_a < iv_value_b.
      rv_cmp = -1.
    ELSEIF iv_value_a > iv_value_b.
      rv_cmp = 1.
    ENDIF.
  ENDMETHOD.

  METHOD best_method.
    " The better method is the one that values the stock lower.
    IF iv_value_market <= iv_value_cost.
      rv_method = 'MARKET'.
    ELSE.
      rv_method = 'COST'.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    rv_delta = iv_value_a - iv_value_b.
  ENDMETHOD.

ENDCLASS.
