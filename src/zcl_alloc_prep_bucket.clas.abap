CLASS zcl_alloc_prep_bucket DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS bucket_of
      IMPORTING
        iv_cost          TYPE i
        iv_width         TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE i.

    METHODS count_in
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_bucket       TYPE i
        iv_width        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_par
      IMPORTING
        iv_value     TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prep_bucket IMPLEMENTATION.

  METHOD bucket_of.
    " The bucket is the cost divided into widths.
    IF iv_width <= 0.
      RETURN.
    ENDIF.

    rv_bucket = iv_cost DIV iv_width.
  ENDMETHOD.

  METHOD count_in.
    DATA lv_bucket TYPE i.

    " The count gathers the orders that fall in the given bucket.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_bucket = bucket_of( iv_cost = ls_line-cost iv_width = iv_width ).
      IF lv_bucket = iv_bucket.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_par.
    " The value is at par once it matches the target.
    rv_ok = xsdbool( iv_value = iv_target ).
  ENDMETHOD.

ENDCLASS.
