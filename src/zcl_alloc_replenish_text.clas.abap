CLASS zcl_alloc_replenish_text DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_run,
             name     TYPE string,
             quantity TYPE i,
           END OF ty_run.
    TYPES ty_run_tt TYPE STANDARD TABLE OF ty_run WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_runs        TYPE ty_run_tt
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS line_count
      IMPORTING
        it_runs         TYPE ty_run_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_text IMPLEMENTATION.

  METHOD build.
    DATA lv_count TYPE i.
    DATA lv_total TYPE i.

    " The summary names how many runs there were and what they add up to.
    lv_count = lines( it_runs ).
    LOOP AT it_runs INTO DATA(ls_run).
      lv_total = lv_total + ls_run-quantity.
    ENDLOOP.

    rv_text = |{ lv_count } runs, { lv_total } units|.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_runs ).
  ENDMETHOD.

ENDCLASS.
