CLASS zcl_alloc_replenish_alert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             rate     TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_alert,
             material TYPE matnr,
             level    TYPE string,
           END OF ty_alert.
    TYPES ty_alert_tt TYPE STANDARD TABLE OF ty_alert WITH DEFAULT KEY.

    METHODS is_alert
      IMPORTING
        iv_rate      TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS alert_count
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_target       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS build
      IMPORTING
        it_items         TYPE ty_item_tt
        iv_target        TYPE i
      RETURNING
        VALUE(rt_alerts) TYPE ty_alert_tt.

ENDCLASS.


CLASS zcl_alloc_replenish_alert IMPLEMENTATION.

  METHOD is_alert.
    " A rate below the target raises an alert.
    rv_ok = xsdbool( iv_rate < iv_target ).
  ENDMETHOD.

  METHOD alert_count.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_alert( iv_rate = ls_item-rate iv_target = iv_target ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA ls_alert TYPE ty_alert.

    " Every item below the target becomes a low-level alert.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_alert( iv_rate = ls_item-rate iv_target = iv_target ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_alert-material = ls_item-material.
      ls_alert-level = 'LOW'.
      APPEND ls_alert TO rt_alerts.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
