CLASS zcl_alloc_queue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             arrival_rate TYPE i,
             service_rate TYPE i,
             servers      TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             utilisation_x100  TYPE i,
             queue_length_x100 TYPE i,
             wait_x100         TYPE i,
             saturated         TYPE abap_bool,
           END OF ty_result.

    METHODS estimate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_queue IMPLEMENTATION.

  METHOD estimate.
    DATA lv_capacity TYPE i.
    DATA lv_util     TYPE i.

    IF is_input-arrival_rate <= 0 OR is_input-service_rate <= 0.
      RETURN.
    ENDIF.

    lv_capacity = is_input-service_rate * is_input-servers.
    IF lv_capacity <= 0.
      rs_result-saturated = abap_true.
      RETURN.
    ENDIF.

    IF is_input-arrival_rate >= lv_capacity.
      rs_result-saturated = abap_true.
      rs_result-utilisation_x100 = 100.
      RETURN.
    ENDIF.

    lv_util = is_input-arrival_rate * 100 DIV lv_capacity.
    rs_result-utilisation_x100 = lv_util.

    " Queuing estimate (M/M/1): Lq = rho^2 / (1 - rho), kept in hundredths, and
    " Little's law turns the queue length into the waiting time.
    rs_result-queue_length_x100 =
      lv_util * lv_util * 100 DIV ( 100 * ( 100 - lv_util ) ).
    rs_result-wait_x100 =
      rs_result-queue_length_x100 * 100 DIV is_input-arrival_rate.
  ENDMETHOD.

ENDCLASS.
