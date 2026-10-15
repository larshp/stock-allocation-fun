CLASS zcl_alloc_cost_basis_cmp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_cost_a     TYPE i
        iv_cost_b     TYPE i
      RETURNING
        VALUE(rv_cmp) TYPE i.

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


CLASS zcl_alloc_cost_basis_cmp IMPLEMENTATION.

  METHOD compare.
    " The comparison is minus one, zero or one as a is cheaper, equal or dearer.
    IF iv_cost_a < iv_cost_b.
      rv_cmp = -1.
    ELSEIF iv_cost_a > iv_cost_b.
      rv_cmp = 1.
    ENDIF.
  ENDMETHOD.

  METHOD cheaper.
    " The cheaper basis is the lower of the two.
    IF iv_cost_a <= iv_cost_b.
      rv_cost = iv_cost_a.
    ELSE.
      rv_cost = iv_cost_b.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    rv_delta = iv_cost_a - iv_cost_b.
  ENDMETHOD.

ENDCLASS.
