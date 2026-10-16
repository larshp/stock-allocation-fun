CLASS zcl_alloc_mrp_exception DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             code     TYPE string,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS code
      IMPORTING
        iv_net_req     TYPE i
        iv_days_late   TYPE i
      RETURNING
        VALUE(rv_code) TYPE string.

    METHODS is_exception
      IMPORTING
        iv_net_req   TYPE i
        iv_days_late TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count_of
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_code         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_mrp_exception IMPLEMENTATION.

  METHOD code.
    " A late date asks for a reschedule; a positive requirement asks for a new
    " order; everything else is no exception.
    IF iv_days_late > 0.
      rv_code = 'RESCHEDULE'.
    ELSEIF iv_net_req > 0.
      rv_code = 'NEW'.
    ELSE.
      rv_code = 'NONE'.
    ENDIF.
  ENDMETHOD.

  METHOD is_exception.
    " Either a positive requirement or a late date raises an exception.
    rv_ok = xsdbool( iv_net_req > 0 OR iv_days_late > 0 ).
  ENDMETHOD.

  METHOD count_of.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-code = iv_code.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
