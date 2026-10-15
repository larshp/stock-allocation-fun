CLASS zcl_alloc_return_rate_cust DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_customer,
             customer TYPE string,
             shipped  TYPE i,
             returned TYPE i,
           END OF ty_customer.
    TYPES ty_customer_tt TYPE STANDARD TABLE OF ty_customer WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_ranked,
             customer     TYPE string,
             rate_percent TYPE i,
           END OF ty_ranked.
    TYPES ty_ranked_tt TYPE STANDARD TABLE OF ty_ranked WITH DEFAULT KEY.

    METHODS rate
      IMPORTING
        is_customer   TYPE ty_customer
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS highest
      IMPORTING
        it_customers       TYPE ty_customer_tt
      RETURNING
        VALUE(rv_customer) TYPE string.

    METHODS rank
      IMPORTING
        it_customers     TYPE ty_customer_tt
      RETURNING
        VALUE(rt_ranked) TYPE ty_ranked_tt.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             customer     TYPE string,
             rate_percent TYPE i,
             seq          TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_return_rate_cust IMPLEMENTATION.

  METHOD rate.
    " A customer with no shipments has no rate, not a zero one.
    IF is_customer-shipped <= 0 OR is_customer-returned <= 0.
      RETURN.
    ENDIF.

    rv_pct = is_customer-returned * 100 DIV is_customer-shipped.
  ENDMETHOD.

  METHOD highest.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.
    DATA lv_pct   TYPE i.

    LOOP AT it_customers INTO DATA(ls_customer).
      IF ls_customer-shipped <= 0.
        CONTINUE.
      ENDIF.

      lv_pct = rate( ls_customer ).

      IF lv_found = abap_false OR lv_pct > lv_best.
        lv_found = abap_true.
        lv_best = lv_pct.
        rv_customer = ls_customer-customer.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rank.
    DATA lt_work   TYPE ty_work_tt.
    DATA ls_work   TYPE ty_work.
    DATA lv_seq    TYPE i.
    DATA ls_ranked TYPE ty_ranked.

    LOOP AT it_customers INTO DATA(ls_customer).
      IF ls_customer-shipped <= 0.
        CONTINUE.
      ENDIF.

      lv_seq = lv_seq + 1.

      CLEAR ls_work.
      ls_work-customer = ls_customer-customer.
      ls_work-rate_percent = rate( ls_customer ).
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    " The worst return rate first, with the input order breaking any tie.
    SORT lt_work BY rate_percent DESCENDING
                    seq          ASCENDING.

    LOOP AT lt_work INTO ls_work.
      CLEAR ls_ranked.
      ls_ranked-customer = ls_work-customer.
      ls_ranked-rate_percent = ls_work-rate_percent.
      APPEND ls_ranked TO rt_ranked.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
