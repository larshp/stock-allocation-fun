CLASS zcl_alloc_valm_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             line_count   TYPE i,
             breach_count TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
        iv_threshold      TYPE i
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS evaluate
      IMPORTING
        iv_breach_count   TYPE i
        iv_line_count     TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS status
      IMPORTING
        iv_breach_percent TYPE i
        iv_limit_percent  TYPE i
      RETURNING
        VALUE(rv_status)  TYPE string.

ENDCLASS.


CLASS zcl_alloc_valm_summary IMPLEMENTATION.

  METHOD build.
    " The summary counts the lines and how many of them breached.
    rs_summary-line_count = lines( it_lines ).

    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-value <= iv_threshold.
        CONTINUE.
      ENDIF.

      rs_summary-breach_count = rs_summary-breach_count + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate.
    " The breach rate is the breached lines as a share of all of them.
    IF iv_line_count <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_breach_count * 100 DIV iv_line_count.
  ENDMETHOD.

  METHOD status.
    " A rate past the limit is an alert, any breach at all is a watch.
    IF iv_breach_percent > iv_limit_percent.
      rv_status = 'ALERT'.
    ELSEIF iv_breach_percent > 0.
      rv_status = 'WATCH'.
    ELSE.
      rv_status = 'OK'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
