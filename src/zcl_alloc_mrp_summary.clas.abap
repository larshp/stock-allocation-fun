CLASS zcl_alloc_mrp_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_req,
             material TYPE matnr,
             shortage TYPE i,
             code     TYPE string,
           END OF ty_req.
    TYPES ty_req_tt TYPE STANDARD TABLE OF ty_req WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             exception_count TYPE i,
             total_shortage  TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_reqs           TYPE ty_req_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS exception_count
      IMPORTING
        it_reqs         TYPE ty_req_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_shortage
      IMPORTING
        it_reqs         TYPE ty_req_tt
      RETURNING
        VALUE(rv_total) TYPE i.

  PRIVATE SECTION.
    METHODS is_exception
      IMPORTING
        is_req       TYPE ty_req
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_mrp_summary IMPLEMENTATION.

  METHOD is_exception.
    " A code other than NONE marks an exception.
    rv_ok = xsdbool( is_req-code <> 'NONE' AND is_req-code <> '' ).
  ENDMETHOD.

  METHOD exception_count.
    LOOP AT it_reqs INTO DATA(ls_req).
      IF is_exception( ls_req ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_shortage.
    " Only a positive shortage adds to the total.
    LOOP AT it_reqs INTO DATA(ls_req).
      IF ls_req-shortage > 0.
        rv_total = rv_total + ls_req-shortage.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    rs_summary-exception_count = exception_count( it_reqs ).
    rs_summary-total_shortage = total_shortage( it_reqs ).
  ENDMETHOD.

ENDCLASS.
