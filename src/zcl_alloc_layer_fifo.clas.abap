CLASS zcl_alloc_layer_fifo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    METHODS consume
      IMPORTING
        it_layers        TYPE ty_layer_tt
        iv_qty           TYPE i
      RETURNING
        VALUE(rt_layers) TYPE ty_layer_tt.

    METHODS remaining
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS layers_used
      IMPORTING
        it_layers       TYPE ty_layer_tt
        iv_qty          TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_fifo IMPLEMENTATION.

  METHOD consume.
    DATA lv_left TYPE i.
    DATA ls_out  TYPE ty_layer.

    " The oldest layers are consumed first; the newer ones stay untouched.
    lv_left = iv_qty.

    LOOP AT it_layers INTO DATA(ls_layer).
      IF lv_left <= 0.
        APPEND ls_layer TO rt_layers.
        CONTINUE.
      ENDIF.

      IF ls_layer-quantity <= lv_left.
        lv_left = lv_left - ls_layer-quantity.
      ELSE.
        ls_out = ls_layer.
        ls_out-quantity = ls_layer-quantity - lv_left.
        lv_left = 0.
        APPEND ls_out TO rt_layers.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD remaining.
    " What is left is the sum of the layers that still carry quantity.
    LOOP AT it_layers INTO DATA(ls_layer).
      rv_total = rv_total + ls_layer-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD layers_used.
    DATA lv_left TYPE i.

    " The half-open order starts at the oldest layer and stops when the demand is met.
    lv_left = iv_qty.

    LOOP AT it_layers INTO DATA(ls_layer).
      IF lv_left <= 0.
        RETURN.
      ENDIF.

      rv_count = rv_count + 1.
      lv_left = lv_left - ls_layer-quantity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
