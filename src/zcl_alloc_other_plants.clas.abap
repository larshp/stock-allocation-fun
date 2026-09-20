CLASS zcl_alloc_other_plants DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.
    TYPES ty_matnr_tab TYPE STANDARD TABLE OF mard-matnr WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Read where a batch of materials is kept, in one go</p>
    "!
    "! Both callers work from a list of what is short and then ask about each
    "! of them in turn, so the list is known before the first question. Told
    "! it, this reads the lot in one statement; not told it, `OTHERS` still
    "! answers, one read at a time. Feature 172 is what made the difference
    "! worth having: a company of twenty plants with forty short materials
    "! each was eight hundred reads of `MARC`.
    "!
    "! Materials already known are not read again, so calling this twice with
    "! overlapping lists costs one read of the difference.
    "!
    "! @parameter it_matnr | <p class="shorttext synchronized">Materials about to be asked about</p>
    METHODS preload
      IMPORTING
        it_matnr TYPE ty_matnr_tab.

    "! <p class="shorttext synchronized">Which other plants could hold a material</p>
    "!
    "! A plant the material is extended to is a plant that could hold it. One
    "! flagged for deletion there is on its way out and is not somewhere to
    "! move goods to or from.
    "!
    "! The asking plant is left out at the answer rather than at the read, so
    "! one object can serve a run that walks every plant in turn -- which is
    "! what `ZCL_ALLOC_PROPOSE` does since feature 172, and the whole point of
    "! reading `MARC` once.
    "!
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant doing the asking, left out</p>
    "! @parameter rt_werks | <p class="shorttext synchronized">The other plants, in plant order</p>
    METHODS others
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_werks) TYPE ty_werks_tab.

  PRIVATE SECTION.

    "! Where one material is kept, as MARC has it and before any plant of the
    "! company is left out of the answer.
    TYPES:
      BEGIN OF ty_kept,
        matnr TYPE mard-matnr,
        werks TYPE mard-werks,
      END OF ty_kept.
    TYPES ty_kept_tab TYPE STANDARD TABLE OF ty_kept WITH EMPTY KEY.

    DATA mt_kept  TYPE ty_kept_tab.
    DATA mt_known TYPE ty_matnr_tab.

    METHODS read
      IMPORTING
        it_matnr TYPE ty_matnr_tab.

ENDCLASS.


CLASS zcl_alloc_other_plants IMPLEMENTATION.

  METHOD preload.

    DATA lt_wanted TYPE ty_matnr_tab.

    LOOP AT it_matnr INTO DATA(lv_matnr).
      IF lv_matnr IS INITIAL
          OR line_exists( mt_known[ table_line = lv_matnr ] )
          OR line_exists( lt_wanted[ table_line = lv_matnr ] ).
        CONTINUE.
      ENDIF.
      APPEND lv_matnr TO lt_wanted.
    ENDLOOP.

    IF lt_wanted IS INITIAL.
      RETURN.
    ENDIF.

    read( lt_wanted ).

  ENDMETHOD.

  METHOD others.

    IF NOT line_exists( mt_known[ table_line = iv_matnr ] ).
      read( VALUE #( ( iv_matnr ) ) ).
    ENDIF.

    LOOP AT mt_kept INTO DATA(ls_kept)
        WHERE matnr = iv_matnr.
      IF ls_kept-werks = iv_werks.
        CONTINUE.
      ENDIF.
      APPEND ls_kept-werks TO rt_werks.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA lt_matnr TYPE RANGE OF marc-matnr.

    LOOP AT it_matnr INTO DATA(lv_matnr).
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = lv_matnr ) TO lt_matnr.
    ENDLOOP.

    " a material nobody has anywhere is still an answered question, so it
    " goes on the known list whatever the read comes back with
    APPEND LINES OF it_matnr TO mt_known.

    SELECT matnr, werks
      FROM marc
      WHERE matnr IN @lt_matnr
        AND lvorm = @space
      ORDER BY matnr, werks
      INTO TABLE @DATA(lt_kept).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_kept INTO DATA(ls_kept).
      APPEND VALUE #(
        matnr = ls_kept-matnr
        werks = ls_kept-werks ) TO mt_kept.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
