CLASS zcl_alloc_gr_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             ordered   TYPE menge_d,
             delivered TYPE menge_d,
             diff      TYPE menge_d,
             status    TYPE string,
           END OF ty_result.

    METHODS check
      IMPORTING
        iv_ordered       TYPE menge_d
        iv_delivered     TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS received_percent
      IMPORTING
        iv_ordered    TYPE menge_d
        iv_delivered  TYPE menge_d
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gr_check IMPLEMENTATION.

  METHOD check.
    rs_result-ordered = iv_ordered.
    rs_result-delivered = iv_delivered.
    rs_result-diff = iv_delivered - iv_ordered.

    IF rs_result-diff = 0.
      rs_result-status = 'OK'.
    ELSEIF rs_result-diff > 0.
      rs_result-status = 'OVER'.
    ELSE.
      rs_result-status = 'UNDER'.
    ENDIF.
  ENDMETHOD.

  METHOD received_percent.
    IF iv_ordered <= 0 OR iv_delivered <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_delivered * 100 DIV iv_ordered.
  ENDMETHOD.

ENDCLASS.
