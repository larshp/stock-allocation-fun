CLASS zcl_alloc_hold DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Materials a plant has put on hold</p>
    "!
    "! Asked by the run, which leaves them alone, and by the explanation, which
    "! has to say so rather than going quiet. One place decides what "on hold"
    "! means, including when a hold has lifted.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_today | <p class="shorttext synchronized">Day to measure a hold against</p>
    "! @parameter rt_matnr | <p class="shorttext synchronized">Materials on hold, in material order</p>
    CLASS-METHODS materials
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_today        TYPE d
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

    "! <p class="shorttext synchronized">Why one material is on hold</p>
    "!
    "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_today  | <p class="shorttext synchronized">Day to measure a hold against</p>
    "! @parameter rv_reason | <p class="shorttext synchronized">The reason, empty if it is not on hold</p>
    CLASS-METHODS reason_for
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_today         TYPE d
      RETURNING
        VALUE(rv_reason) TYPE string.

  PRIVATE SECTION.

    "! An empty date field, which SQL will not compare against SPACE.
    CONSTANTS c_no_date TYPE d VALUE '00000000'.

ENDCLASS.


CLASS zcl_alloc_hold IMPLEMENTATION.

  METHOD materials.

    " a hold with a date on it lifts by itself on that day, which is what
    " somebody putting one on for a stock count wants; a hold without one
    " stays until somebody takes it off, which is what a quality problem
    " wants. The row is left in the table either way, so there is a record of
    " what was held and why.
    SELECT matnr
      FROM zstock_alloc_hld
      WHERE werks = @iv_werks
        AND ( until_date = @c_no_date
           OR until_date >= @iv_today )
      ORDER BY matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
    ENDIF.

  ENDMETHOD.

  METHOD reason_for.

    SELECT SINGLE reason
      FROM zstock_alloc_hld
      WHERE werks = @iv_werks
        AND matnr = @iv_matnr
        AND ( until_date = @c_no_date
           OR until_date >= @iv_today )
      INTO @DATA(lv_reason).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a hold with nothing written in the reason is still a hold, and saying so
    " is better than saying nothing
    rv_reason = lv_reason.
    IF rv_reason IS INITIAL.
      rv_reason = `no reason given`.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
