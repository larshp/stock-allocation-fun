  "! <p class="shorttext synchronized">Serve what somebody promised by hand first</p>
  "!
  "! Every rule here is a rule about the ordinary night. What a business also
  "! has is the extraordinary one: a director has promised a customer a
  "! hundred pieces, and the run is going to distribute them by delivery
  "! priority to somebody else. Without somewhere to put that, it is done by
  "! reserving the stock in MB21 behind the run's back, where the allocation
  "! cannot see it and the next re-cut fights it.
  "!
  "! `ZSTOCK_ALLOC_FIX` is that somewhere: a quantity, a demand line, and who
  "! promised it. It is taken off the top before the distribution rules see
  "! the stock, so a promise is not cut back by the customer share or by a
  "! quota -- the point of a promise is that it outranks the rules.
  "!
  "! What is handed over is worked out here and handed over by
  "! ZCL_ALLOC_FLOOR, which does the same for the firm zone of feature 146:
  "! taking a quantity off the top and answering every line exactly once is
  "! the same work whoever decided the quantity.
CLASS zcl_alloc_promised DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_alloc_floor.

    "! One promise. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_promise,
        demand_id TYPE zstock_alloc_fix-demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
        valid_to  TYPE zstock_alloc_fix-valid_to,
        reason    TYPE zstock_alloc_fix-reason,
      END OF ty_promise.
    TYPES ty_promise_tab TYPE STANDARD TABLE OF ty_promise WITH EMPTY KEY.

    "! <p class="shorttext synchronized">The promises still standing for one material</p>
    "!
    "! Public because the explanation of feature 55 has to show the same rows
    "! the rule acts on: an explanation that reads the table its own way is a
    "! second implementation of the rule, and the two of them will disagree
    "! one day.
    "!
    "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_promise | <p class="shorttext synchronized">Promises that have not run out</p>
    CLASS-METHODS promised_for
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_promise) TYPE ty_promise_tab.

  PRIVATE SECTION.

    "! A promise with no last day is kept until somebody removes it.
    CONSTANTS c_no_end TYPE d VALUE '00000000'.

    "! One plant's promises, material and all.
    TYPES:
      BEGIN OF ty_row,
        matnr     TYPE zstock_alloc_fix-matnr,
        demand_id TYPE zstock_alloc_fix-demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
        valid_to  TYPE zstock_alloc_fix-valid_to,
        reason    TYPE zstock_alloc_fix-reason,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    "! The promises of the whole plant, read the first time anything is
    "! allocated in it: one round trip per material would be five thousand of
    "! them to read a page a person typed. Same reasoning as ZCL_ALLOC_QUOTA.
    DATA mt_row   TYPE ty_row_tab.
    DATA mv_werks TYPE mard-werks.
    DATA mv_read  TYPE abap_bool.

    "! The promises of the material being allocated, out of the plant's.
    DATA mt_promise TYPE ty_promise_tab.
    DATA mv_matnr   TYPE mard-matnr.

    METHODS buffered_for
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_promise) TYPE ty_promise_tab.

ENDCLASS.


CLASS zcl_alloc_promised IMPLEMENTATION.

  METHOD zif_alloc_floor~floors_for.

    DATA ls_floor TYPE zif_alloc_floor=>ty_floor.

    READ TABLE it_demand INTO DATA(ls_first) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT buffered_for(
        iv_matnr = ls_first-matnr
        iv_werks = ls_first-werks ) INTO DATA(ls_promise).
      ls_floor-demand_id = ls_promise-demand_id.
      ls_floor-quantity  = ls_promise-quantity.
      APPEND ls_floor TO rt_floor.
    ENDLOOP.

  ENDMETHOD.

  METHOD promised_for.

    " a promise with a day on it is kept until that day and then stops being
    " one: a row nobody ever removes goes on outranking the rules every night
    " for a reason that was true in March
    SELECT demand_id,
           quantity,
           valid_to,
           reason
      FROM zstock_alloc_fix
      WHERE werks = @iv_werks
        AND matnr = @iv_matnr
        AND ( valid_to = @c_no_end
           OR valid_to >= @sy-datum )
      ORDER BY demand_id
      INTO TABLE @rt_promise.
    IF sy-subrc <> 0.
      CLEAR rt_promise.
    ENDIF.

  ENDMETHOD.

  METHOD buffered_for.

    DATA ls_promise TYPE ty_promise.

    IF mv_read = abap_true AND mv_matnr = iv_matnr AND mv_werks = iv_werks.
      rt_promise = mt_promise.
      RETURN.
    ENDIF.

    IF mv_read = abap_false OR mv_werks <> iv_werks.
      SELECT matnr,
             demand_id,
             quantity,
             valid_to,
             reason
        FROM zstock_alloc_fix
        WHERE werks = @iv_werks
          AND ( valid_to = @c_no_end
             OR valid_to >= @sy-datum )
        ORDER BY matnr, demand_id
        INTO TABLE @mt_row.
      IF sy-subrc <> 0.
        CLEAR mt_row.
      ENDIF.
    ENDIF.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr.
      ls_promise-demand_id = ls_row-demand_id.
      ls_promise-quantity  = ls_row-quantity.
      ls_promise-valid_to  = ls_row-valid_to.
      ls_promise-reason    = ls_row-reason.
      APPEND ls_promise TO rt_promise.
    ENDLOOP.

    mt_promise = rt_promise.
    mv_matnr   = iv_matnr.
    mv_werks   = iv_werks.
    mv_read    = abap_true.

  ENDMETHOD.

ENDCLASS.
