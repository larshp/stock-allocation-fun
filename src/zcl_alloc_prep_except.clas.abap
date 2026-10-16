CLASS zcl_alloc_prep_except DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
             limit    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS is_exception
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_cost          TYPE i
        iv_limit         TYPE i
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS count_of
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prep_except IMPLEMENTATION.

  METHOD is_exception.
    " The order is an exception once its cost passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD reason.
    " The reason explains whether the cost broke the limit.
    IF iv_cost > iv_limit.
      rv_reason = 'cost over limit'.
    ELSE.
      rv_reason = 'within limit'.
    ENDIF.
  ENDMETHOD.

  METHOD count_of.
    " The count gathers the orders in exception.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-cost > ls_line-limit.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
