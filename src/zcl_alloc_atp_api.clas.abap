CLASS zcl_alloc_atp_api DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What an outside caller is told: the promise, and a message if the
    "! question could not be answered. One of the two is always empty.
    TYPES:
      BEGIN OF ty_answer,
        promise TYPE zstock_alloc_promise,
        message TYPE bapiret2,
      END OF ty_answer.

    TYPES ty_ask_tab    TYPE STANDARD TABLE OF zstock_alloc_ask WITH EMPTY KEY.
    TYPES ty_answer_tab TYPE STANDARD TABLE OF zstock_alloc_ans WITH EMPTY KEY.

    "! <p class="shorttext synchronized">What a plant can promise, line by line</p>
    "!
    "! The same answer as PROMISE, for as many lines as a caller has. A basket
    "! priced over RFC one line at a time is one round trip per line and the
    "! plant's settings read again for each of them; here the settings are read
    "! once per plant and the sources wired once per plant and location.
    "!
    "! A line that cannot be answered carries the reason and the others are
    "! still answered: one material nobody has heard of must not cost the
    "! caller the whole basket.
    "!
    "! @parameter it_ask     | <p class="shorttext synchronized">The lines to ask about</p>
    "! @parameter rt_answer  | <p class="shorttext synchronized">One answer per line, in the order asked</p>
    CLASS-METHODS promises
      IMPORTING
        it_ask           TYPE ty_ask_tab
      RETURNING
        VALUE(rt_answer) TYPE ty_answer_tab.

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

    "! One plant and location the caller asked about, and the query wired up
    "! for it. Wiring reads the plant's Customizing and builds the object
    "! graph, so it is done once for every line that shares them.
    TYPES:
      BEGIN OF ty_wired,
        werks TYPE mard-werks,
        lgort TYPE mard-lgort,
        query TYPE REF TO zif_atp_query,
      END OF ty_wired.
    TYPES ty_wired_tab TYPE STANDARD TABLE OF ty_wired WITH EMPTY KEY.

    CLASS-METHODS query_for
      IMPORTING
        iv_werks TYPE mard-werks
        iv_lgort TYPE mard-lgort
      EXPORTING
        eo_query TYPE REF TO zif_atp_query
      CHANGING
        ct_wired TYPE ty_wired_tab.

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

  METHOD promises.

    DATA lt_wired   TYPE ty_wired_tab.
    DATA ls_answer  TYPE zstock_alloc_ans.
    DATA lo_query   TYPE REF TO zif_atp_query.
    DATA ls_promise TYPE zif_atp_query=>ty_promise.

    LOOP AT it_ask INTO DATA(ls_ask).

      CLEAR ls_answer.
      ls_answer-item_no = ls_ask-item_no.

      query_for(
        EXPORTING
          iv_werks = ls_ask-plant
          iv_lgort = ls_ask-stge_loc
        IMPORTING
          eo_query = lo_query
        CHANGING
          ct_wired = lt_wired ).

      TRY.
          ls_promise = lo_query->promise(
            iv_matnr    = ls_ask-material
            iv_werks    = ls_ask-plant
            iv_quantity = ls_ask-quantity
            iv_by_date  = ls_ask-by_date ).

          ls_answer-quantity   = ls_promise-quantity.
          ls_answer-avail_date = ls_promise-date.
          ls_answer-complete   = ls_promise-complete.

        CATCH zcx_allocation INTO DATA(lx_error).
          " one line nobody can answer must not cost the caller the rest of
          " the basket, so the reason goes on the line and the loop goes on
          ls_answer-message = lx_error->get_text( ).
      ENDTRY.

      APPEND ls_answer TO rt_answer.

    ENDLOOP.

  ENDMETHOD.

  METHOD query_for.

    READ TABLE ct_wired INTO DATA(ls_wired)
      WITH KEY werks = iv_werks
               lgort = iv_lgort.
    IF sy-subrc = 0.
      eo_query = ls_wired-query.
      RETURN.
    ENDIF.

    DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
    DATA(ls_config) = lo_config->for_plant( iv_werks ).

    DATA(lv_lgort) = iv_lgort.
    IF lv_lgort IS INITIAL.
      lv_lgort = ls_config-lgort.
    ENDIF.

    eo_query = zcl_atp_query=>create_default(
      iv_lgort   = lv_lgort
      iv_planned = ls_config-planned ).

    APPEND VALUE #(
      werks = iv_werks
      lgort = iv_lgort
      query = eo_query ) TO ct_wired.

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
