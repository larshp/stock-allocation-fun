CLASS zcl_alloc_alt_api DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_answer_tab TYPE STANDARD TABLE OF zstock_alloc_subp WITH EMPTY KEY.

    "! <p class="shorttext synchronized">What else could be promised, for a caller outside ABAP</p>
    "!
    "! The promise of feature 45 answers "how much of this can I have". The
    "! next question is the one a shop assistant asks without thinking and a
    "! webshop cannot ask at all: would you take the other size. The plant has
    "! already said which materials could stand in for which (feature 108);
    "! this asks each of them the promise question.
    "!
    "! The quantity asked of a substitute is the quantity asked of the
    "! material, converted by the factor of the arrangement: two of the
    "! substitute making one of the material means twice as many are needed.
    "!
    "! @parameter iv_matnr    | <p class="shorttext synchronized">Material that cannot be promised</p>
    "! @parameter iv_werks    | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_quantity | <p class="shorttext synchronized">Quantity of the material that is wanted</p>
    "! @parameter iv_by_date  | <p class="shorttext synchronized">Day it is wanted by, any day if empty</p>
    "! @parameter rt_answer   | <p class="shorttext synchronized">One answer per substitute the plant has named</p>
    CLASS-METHODS alternatives
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_quantity      TYPE zstock_alloc_promise-quantity
        iv_by_date       TYPE zstock_alloc_promise-avail_date OPTIONAL
      RETURNING
        VALUE(rt_answer) TYPE ty_answer_tab.

ENDCLASS.


CLASS zcl_alloc_alt_api IMPLEMENTATION.

  METHOD alternatives.

    DATA ls_answer TYPE zstock_alloc_subp.
    DATA lv_wanted TYPE zif_allocation=>ty_quantity.

    DATA(lt_substitute) = zcl_alloc_substitute=>substitutes_for(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).
    IF lt_substitute IS INITIAL.
      RETURN.
    ENDIF.

    " one query for the plant rather than one per substitute: the settings and
    " the sources are the same for all of them, which is the point feature 64
    " makes about a basket
    DATA(lo_query) = zcl_atp_query=>create_for_plant( iv_werks ).

    LOOP AT lt_substitute INTO DATA(ls_substitute).

      CLEAR ls_answer.
      ls_answer-substitute = ls_substitute-substitute.
      ls_answer-note       = ls_substitute-note.

      " two of the substitute making one of the material means twice as many
      " are wanted, and a factor nobody filled in is one for one
      DATA(lv_factor) = ls_substitute-factor.
      IF lv_factor <= 0.
        lv_factor = zcl_alloc_substitute=>c_one_for_one.
      ENDIF.

      lv_wanted = iv_quantity * lv_factor.

      TRY.
          DATA(ls_promise) = lo_query->promise(
            iv_matnr    = ls_substitute-substitute
            iv_werks    = iv_werks
            iv_quantity = lv_wanted
            iv_by_date  = iv_by_date ).

          ls_answer-quantity   = ls_promise-quantity.
          ls_answer-avail_date = ls_promise-date.
          ls_answer-complete   = ls_promise-complete.

        CATCH zcx_allocation INTO DATA(lx_error).
          " one substitute nobody can answer for must not cost the caller the
          " others, so the reason goes on the line and the loop goes on: the
          " same rule the basket of feature 64 follows
          ls_answer-message = lx_error->get_text( ).
      ENDTRY.

      APPEND ls_answer TO rt_answer.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
