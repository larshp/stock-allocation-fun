CLASS zcl_alloc_delivery_win DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             status    TYPE string,
             in_window TYPE abap_bool,
             deviation TYPE i,
           END OF ty_result.

    METHODS check
      IMPORTING
        iv_arrival       TYPE i
        iv_window_from   TYPE i
        iv_window_to     TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_delivery_win IMPLEMENTATION.

  METHOD check.
    " Both ends of the window are inclusive, which is how a delivery window is
    " normally agreed. The deviation is always the positive distance to the
    " nearest edge.
    IF iv_window_from > iv_window_to.
      RETURN.
    ENDIF.

    IF iv_arrival < iv_window_from.
      rs_result-status = 'EARLY'.
      rs_result-deviation = iv_window_from - iv_arrival.
    ELSEIF iv_arrival > iv_window_to.
      rs_result-status = 'LATE'.
      rs_result-deviation = iv_arrival - iv_window_to.
    ELSE.
      rs_result-status = 'IN'.
      rs_result-in_window = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
