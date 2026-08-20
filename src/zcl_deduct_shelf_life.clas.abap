CLASS zcl_deduct_shelf_life DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_deduction.

    "! <p class="shorttext synchronized">Wire up the deduction</p>
    "!
    "! @parameter iv_today | <p class="shorttext synchronized">Day to measure from, today if empty</p>
    METHODS constructor
      IMPORTING
        iv_today TYPE d OPTIONAL.

  PRIVATE SECTION.

    "! One batch of the material in the plant, with the day it stops being
    "! worth anything. Declared explicitly rather than inferred with INTO
    "! TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_batch,
        charg TYPE mchb-charg,
        clabs TYPE mchb-clabs,
        vfdat TYPE mch1-vfdat,
      END OF ty_batch.
    TYPES ty_batch_tab TYPE STANDARD TABLE OF ty_batch WITH EMPTY KEY.

    DATA mv_today TYPE d.

    METHODS last_usable_day
      IMPORTING
        iv_matnr       TYPE mard-matnr
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS read_batches
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_batch) TYPE ty_batch_tab.

ENDCLASS.


CLASS zcl_deduct_shelf_life IMPLEMENTATION.

  METHOD constructor.

    " the day is handed in so a test can say what "today" is. A run that does
    " not care gets the real one.
    mv_today = iv_today.
    IF mv_today IS INITIAL.
      mv_today = sy-datum.
    ENDIF.

  ENDMETHOD.

  METHOD zif_stock_deduction~quantity.

    DATA(lv_last) = last_usable_day( iv_matnr ).
    IF lv_last IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT read_batches(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_batch).

      " a batch nobody has dated has no expiry to fall foul of. Guessing one
      " would hold back stock that may be perfectly good, and the material
      " master is where somebody says a date is required.
      IF ls_batch-vfdat IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_batch-vfdat > lv_last.
        CONTINUE.
      ENDIF.

      IF ls_batch-clabs > 0.
        rv_quantity = rv_quantity + ls_batch-clabs.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD last_usable_day.

    " the minimum remaining shelf life is what the customer is entitled to
    " when the goods arrive: a batch that expires inside it may be in the
    " warehouse but cannot be sent, so it is not stock to give away. A
    " material with none of it only loses what has expired already.
    SELECT SINGLE xchpf,
                  mhdrz
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @DATA(ls_material).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a material that is not batch managed has no expiry dates to read, and
    " MCHB has nothing to say about it
    IF ls_material-xchpf <> abap_true.
      RETURN.
    ENDIF.

    rv_date = mv_today + ls_material-mhdrz.

  ENDMETHOD.

  METHOD read_batches.

    " MCHB is the stock of a batch in a storage location, MCH1 the batch
    " itself, which is where the expiry date lives. A batch flagged for
    " deletion in either place is not stock anybody is going to ship.
    SELECT stock~charg,
           stock~clabs,
           batch~vfdat
      FROM mchb AS stock
      INNER JOIN mch1 AS batch ON batch~matnr = stock~matnr
                              AND batch~charg = stock~charg
      WHERE stock~matnr = @iv_matnr
        AND stock~werks = @iv_werks
        AND stock~lvorm = @space
        AND batch~lvorm = @space
      ORDER BY stock~charg
      INTO TABLE @rt_batch.
    IF sy-subrc <> 0.
      CLEAR rt_batch.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
