CLASS zcl_alloc_result_api DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF zstock_alloc_lin WITH EMPTY KEY.

    "! What an outside caller is told: the lines, and a message if the question
    "! could not be answered.
    TYPES:
      BEGIN OF ty_answer,
        line    TYPE ty_line_tab,
        message TYPE bapiret2,
      END OF ty_answer.

    "! <p class="shorttext synchronized">What the last run gave one order, for a caller outside ABAP</p>
    "!
    "! The promise of feature 45 answers "what could I have". This answers the
    "! question afterwards: "what did I get". A webshop that took an order at
    "! nine and a customer service screen looking at it at eleven both need
    "! the same answer, and neither of them can read `ZSTOCK_ALLOC_RES` or
    "! catch an ABAP exception.
    "!
    "! The newest run per schedule line, because that is the one that stands:
    "! a re-cut replaces what the run before it decided.
    "!
    "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_vbeln  | <p class="shorttext synchronized">Sales document</p>
    "! @parameter iv_posnr  | <p class="shorttext synchronized">Item, every one if empty</p>
    "! @parameter rs_answer | <p class="shorttext synchronized">The lines, or why there are none</p>
    CLASS-METHODS result
      IMPORTING
        iv_werks         TYPE mard-werks
        iv_vbeln         TYPE vbap-vbeln
        iv_posnr         TYPE vbap-posnr OPTIONAL
      RETURNING
        VALUE(rs_answer) TYPE ty_answer.

  PRIVATE SECTION.

    "! Reading what was decided, not deciding anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! One recorded line. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_row,
        demand_id  TYPE zstock_alloc_res-demand_id,
        created_at TYPE zstock_alloc_res-created_at,
        run_id     TYPE zstock_alloc_res-run_id,
        matnr      TYPE zstock_alloc_res-matnr,
        req_date   TYPE zstock_alloc_res-req_date,
        avail_date TYPE zstock_alloc_res-avail_date,
        requested  TYPE zstock_alloc_res-requested,
        confirmed  TYPE zstock_alloc_res-confirmed,
        shortfall  TYPE zstock_alloc_res-shortfall,
        reason     TYPE zstock_alloc_res-reason,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    CLASS-METHODS rows_of
      IMPORTING
        iv_werks      TYPE mard-werks
        iv_vbeln      TYPE vbap-vbeln
        iv_posnr      TYPE vbap-posnr
      RETURNING
        VALUE(rt_row) TYPE ty_row_tab.

    CLASS-METHODS failed
      IMPORTING
        ix_error          TYPE REF TO zcx_allocation
        iv_vbeln          TYPE vbap-vbeln
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rs_message) TYPE bapiret2.

ENDCLASS.


CLASS zcl_alloc_result_api IMPLEMENTATION.

  METHOD result.

    DATA lv_demand_id TYPE zstock_alloc_res-demand_id.
    DATA ls_line      TYPE zstock_alloc_lin.

    " a caller outside the system is a user like any other, and what a plant
    " decided is the plant's business
    TRY.
        CAST zif_allocation_authority( NEW zcl_authority_alloc( c_activity_display )
          )->check_plant( iv_werks ).
      CATCH zcx_allocation INTO DATA(lx_error).
        rs_answer-message = failed(
          ix_error = lx_error
          iv_vbeln = iv_vbeln
          iv_werks = iv_werks ).
        RETURN.
    ENDTRY.

    " newest first per line, so the first row of each schedule line is the run
    " that stands
    LOOP AT rows_of(
        iv_werks = iv_werks
        iv_vbeln = iv_vbeln
        iv_posnr = iv_posnr ) INTO DATA(ls_row).

      IF ls_row-demand_id = lv_demand_id.
        CONTINUE.
      ENDIF.
      lv_demand_id = ls_row-demand_id.

      CLEAR ls_line.
      ls_line-demand_id   = ls_row-demand_id.
      ls_line-matnr       = ls_row-matnr.
      ls_line-req_date    = ls_row-req_date.
      ls_line-avail_date  = ls_row-avail_date.
      ls_line-requested   = ls_row-requested.
      ls_line-confirmed   = ls_row-confirmed.
      ls_line-shortfall   = ls_row-shortfall.
      ls_line-reason      = ls_row-reason.
      ls_line-run_id      = ls_row-run_id.
      ls_line-reason_text = zcl_alloc_reason_text=>text( ls_row-reason ).

      APPEND ls_line TO rs_answer-line.

    ENDLOOP.

  ENDMETHOD.

  METHOD rows_of.

    DATA lv_pattern TYPE string.

    " the demand id of a sales order line is the document, then the item, then
    " the schedule line, as ZCL_SO_DEMAND_READER builds it
    IF iv_posnr IS INITIAL.
      lv_pattern = |{ iv_vbeln }%|.
    ELSE.
      lv_pattern = |{ iv_vbeln }{ iv_posnr }%|.
    ENDIF.

    SELECT demand_id,
           created_at,
           run_id,
           matnr,
           req_date,
           avail_date,
           requested,
           confirmed,
           shortfall,
           reason
      FROM zstock_alloc_res
      WHERE werks = @iv_werks
        AND demand_id LIKE @lv_pattern
      ORDER BY demand_id ASCENDING, created_at DESCENDING
      INTO TABLE @rt_row.
    IF sy-subrc <> 0.
      CLEAR rt_row.
    ENDIF.

  ENDMETHOD.

  METHOD failed.

    " a caller on the other end of an RFC destination cannot catch an ABAP
    " exception, so what went wrong is said in the structure every SAP caller
    " already knows how to read
    rs_message-type       = 'E'.
    rs_message-id         = ix_error->if_t100_message~t100key-msgid.
    rs_message-number     = ix_error->if_t100_message~t100key-msgno.
    rs_message-message    = ix_error->get_text( ).
    rs_message-message_v1 = iv_vbeln.
    rs_message-message_v2 = iv_werks.

  ENDMETHOD.

ENDCLASS.
