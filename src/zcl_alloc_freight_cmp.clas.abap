CLASS zcl_alloc_freight_cmp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_quote,
             carrier    TYPE string,
             cost_cents TYPE i,
           END OF ty_quote.
    TYPES ty_quote_tt TYPE STANDARD TABLE OF ty_quote WITH DEFAULT KEY.

    METHODS cheapest
      IMPORTING
        it_quotes         TYPE ty_quote_tt
      RETURNING
        VALUE(rv_carrier) TYPE string.

    METHODS cheapest_cost
      IMPORTING
        it_quotes      TYPE ty_quote_tt
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS savings
      IMPORTING
        it_quotes       TYPE ty_quote_tt
      RETURNING
        VALUE(rv_cents) TYPE i.

ENDCLASS.


CLASS zcl_alloc_freight_cmp IMPLEMENTATION.

  METHOD cheapest_cost.
    DATA lv_seen TYPE abap_bool.

    LOOP AT it_quotes INTO DATA(ls_quote).
      IF ls_quote-cost_cents < 0.
        CONTINUE.
      ENDIF.

      IF lv_seen = abap_false OR ls_quote-cost_cents < rv_cost.
        rv_cost = ls_quote-cost_cents.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cheapest.
    DATA lv_cost TYPE i.

    lv_cost = cheapest_cost( it_quotes ).

    " The first carrier at the cheapest price wins, so a result is never
    " ambiguous when two quotes are equal.
    LOOP AT it_quotes INTO DATA(ls_quote).
      IF ls_quote-cost_cents = lv_cost.
        rv_carrier = ls_quote-carrier.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD savings.
    DATA lv_seen   TYPE abap_bool.
    DATA lv_lowest TYPE i.
    DATA lv_highest TYPE i.

    LOOP AT it_quotes INTO DATA(ls_quote).
      IF ls_quote-cost_cents < 0.
        CONTINUE.
      ENDIF.

      IF lv_seen = abap_false.
        lv_lowest = ls_quote-cost_cents.
        lv_highest = ls_quote-cost_cents.
        lv_seen = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_quote-cost_cents < lv_lowest.
        lv_lowest = ls_quote-cost_cents.
      ELSEIF ls_quote-cost_cents > lv_highest.
        lv_highest = ls_quote-cost_cents.
      ENDIF.
    ENDLOOP.

    rv_cents = lv_highest - lv_lowest.
  ENDMETHOD.

ENDCLASS.
