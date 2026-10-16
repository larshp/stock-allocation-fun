CLASS zcl_alloc_layer_lifo DEFINITION
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


CLASS zcl_alloc_layer_lifo IMPLEMENTATION.

  METHOD consume.
    DATA lv_left  TYPE i.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA ls_layer TYPE ty_layer.
    DATA ls_out   TYPE ty_layer.
    DATA lt_remain TYPE ty_layer_tt.

    " The newest layers are consumed first; the older ones stay untouched.
    lv_count = lines( it_layers ).
    lv_left = iv_qty.

    DO lv_count TIMES.
      lv_idx = lv_count - sy-index + 1.
      READ TABLE it_layers INTO ls_layer INDEX lv_idx.

      IF lv_left > 0.
        IF ls_layer-quantity <= lv_left.
          lv_left = lv_left - ls_layer-quantity.
          ls_layer-quantity = 0.
        ELSE.
          ls_layer-quantity = ls_layer-quantity - lv_left.
          lv_left = 0.
        ENDIF.
      ENDIF.

      APPEND ls_layer TO lt_remain.
    ENDDO.

    " The work list runs backwards, so it is read back to restore the order.
    DO lv_count TIMES.
      lv_idx = lv_count - sy-index + 1.
      READ TABLE lt_remain INTO ls_layer INDEX lv_idx.

      IF ls_layer-quantity > 0.
        ls_out = ls_layer.
        APPEND ls_out TO rt_layers.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD remaining.
    " What is left is the sum of the layers that still carry quantity.
    LOOP AT it_layers INTO DATA(ls_layer).
      rv_total = rv_total + ls_layer-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD layers_used.
    DATA lv_left  TYPE i.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA ls_layer TYPE ty_layer.

    " The LIFO order starts at the newest layer and stops once the demand is met.
    lv_left = iv_qty.
    lv_count = lines( it_layers ).

    DO lv_count TIMES.
      IF lv_left <= 0.
        EXIT.
      ENDIF.

      lv_idx = lv_count - sy-index + 1.
      READ TABLE it_layers INTO ls_layer INDEX lv_idx.

      rv_count = rv_count + 1.
      lv_left = lv_left - ls_layer-quantity.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
