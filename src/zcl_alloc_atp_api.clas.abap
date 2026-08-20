CLASS zcl_alloc_atp_api DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What an outside caller is told: the promise, and a message if the
    "! question could not be answered. One of the two is always empty.
    TYPES:
      BEGIN OF ty_answer,
        promise TYPE zstock_alloc_promise,
        message TYPE bapiret2,
      END OF ty_answer.

    "! <p class="shorttext synchronized">What a plant can promise, for a caller outside ABAP</p>
    "!
    "! The same answer as ZIF_ATP_QUERY, in the shape a remote caller can
    "! read: flat fields and a BAPIRET2 instead of an exception, and the
    "! plant's own settings looked up rather than asked for.
    "!
    "! @parameter iv_matnr    | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks    | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_quantity | <p class="shorttext synchronized">Quantity asked for, in the base unit</p>
    "! @parameter iv_by_date  | <p class="shorttext synchronized">Day it is wanted by, any day if empty</p>
    "! @parameter iv_lgort    | <p class="shorttext synchronized">Location to promise from, the plant's if empty</p>
    "! @parameter rs_answer   | <p class="shorttext synchronized">The promise, or why there is none</p>
    CLASS-METHODS promise
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_quantity      TYPE zstock_alloc_promise-quantity
        iv_by_date       TYPE zstock_alloc_promise-avail_date OPTIONAL
        iv_lgort         TYPE mard-lgort OPTIONAL
      RETURNING
        VALUE(rs_answer) TYPE ty_answer.

  PRIVATE SECTION.

    CLASS-METHODS failed
      IMPORTING
        ix_error          TYPE REF TO zcx_allocation
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rs_message) TYPE bapiret2.

ENDCLASS.


CLASS zcl_alloc_atp_api IMPLEMENTATION.

  METHOD promise.

    " whether the plan counts as supply is the plant's decision and is read
    " here, the same way the reports read it. A caller may narrow the storage
    " location further, because that is a question about the goods it asks for.
    DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
    DATA(ls_config) = lo_config->for_plant( iv_werks ).

    DATA(lv_lgort) = iv_lgort.
    IF lv_lgort IS INITIAL.
      lv_lgort = ls_config-lgort.
    ENDIF.

    TRY.
        DATA(ls_promise) = zcl_atp_query=>create_default(
          iv_lgort   = lv_lgort
          iv_planned = ls_config-planned )->promise(
            iv_matnr    = iv_matnr
            iv_werks    = iv_werks
            iv_quantity = iv_quantity
            iv_by_date  = iv_by_date ).
      CATCH zcx_allocation INTO DATA(lx_error).
        rs_answer-message = failed(
          ix_error = lx_error
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
        RETURN.
    ENDTRY.

    rs_answer-promise-quantity   = ls_promise-quantity.
    rs_answer-promise-avail_date = ls_promise-date.
    rs_answer-promise-complete   = ls_promise-complete.

  ENDMETHOD.

  METHOD failed.

    " a caller on the other end of an RFC destination cannot catch an ABAP
    " exception, so what went wrong is said in the structure every SAP caller
    " already knows how to read
    rs_message-type       = 'E'.
    rs_message-id         = ix_error->if_t100_message~t100key-msgid.
    rs_message-number     = ix_error->if_t100_message~t100key-msgno.
    rs_message-message    = ix_error->get_text( ).
    rs_message-message_v1 = iv_matnr.
    rs_message-message_v2 = iv_werks.

  ENDMETHOD.

ENDCLASS.
