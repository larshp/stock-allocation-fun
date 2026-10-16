CLASS zcl_alloc_gross_req DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_req,
             material TYPE matnr,
             period   TYPE i,
             quantity TYPE i,
           END OF ty_req.
    TYPES ty_req_tt TYPE STANDARD TABLE OF ty_req WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_reqs         TYPE ty_req_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS period
      IMPORTING
        it_reqs         TYPE ty_req_tt
        iv_period       TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS line_count
      IMPORTING
        it_reqs         TYPE ty_req_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gross_req IMPLEMENTATION.

  METHOD total.
    " The gross requirement sums the requirement over every period.
    LOOP AT it_reqs INTO DATA(ls_req).
      rv_total = rv_total + ls_req-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD period.
    " The period requirement sums the requirements of one period only.
    LOOP AT it_reqs INTO DATA(ls_req).
      IF ls_req-period = iv_period.
        rv_total = rv_total + ls_req-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_reqs ).
  ENDMETHOD.

ENDCLASS.
