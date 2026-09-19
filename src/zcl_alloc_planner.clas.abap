CLASS zcl_alloc_planner DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! Who looks after a material in a plant, and how to reach them.
    "!
    "! DISPO is the MRP controller as the material master has it, NAME and
    "! PHONE what the plant's list of controllers says about that code. Any of
    "! the three can be empty: a material need not have a controller, and a
    "! controller need not have been given a name or a telephone number.
    TYPES:
      BEGIN OF ty_planner,
        dispo TYPE marc-dispo,
        name  TYPE t024d-dsnam,
        phone TYPE t024d-dstel,
      END OF ty_planner.

    "! <p class="shorttext synchronized">Who looks after a material in a plant</p>
    "!
    "! A page that says another plant has forty to spare has told a planner
    "! everything except the one thing they do next, which is ring somebody
    "! there. The material master knows who that is per plant, and the plant's
    "! own list of controllers knows their name and extension.
    "!
    "! Both reads are remembered, because a page about forty short materials
    "! across the same six plants asks about a handful of controllers over and
    "! over.
    "!
    "! Nothing here raises. A missing name is a page with a blank in it, which
    "! is the right outcome: the rest of the row is still the answer to the
    "! question that was asked.
    "!
    "! @parameter iv_matnr   | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_werks   | <p class="shorttext synchronized">Plant</p>
    "! @parameter rs_planner | <p class="shorttext synchronized">Controller, name and telephone</p>
    METHODS looking_after
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rs_planner) TYPE ty_planner.

  PRIVATE SECTION.

    "! One answer already worked out, kept under the question that produced it.
    TYPES:
      BEGIN OF ty_known,
        matnr   TYPE mard-matnr,
        werks   TYPE mard-werks,
        planner TYPE ty_planner,
      END OF ty_known.
    TYPES ty_known_tab TYPE STANDARD TABLE OF ty_known WITH EMPTY KEY.

    DATA mt_known TYPE ty_known_tab.

    METHODS read_planner
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rs_planner) TYPE ty_planner.

ENDCLASS.


CLASS zcl_alloc_planner IMPLEMENTATION.

  METHOD looking_after.

    IF line_exists( mt_known[ matnr = iv_matnr
                              werks = iv_werks ] ).
      rs_planner = mt_known[ matnr = iv_matnr
                             werks = iv_werks ]-planner.
      RETURN.
    ENDIF.

    rs_planner = read_planner(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND VALUE #(
      matnr   = iv_matnr
      werks   = iv_werks
      planner = rs_planner ) TO mt_known.

  ENDMETHOD.

  METHOD read_planner.

    SELECT SINGLE dispo
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @rs_planner-dispo.
    IF sy-subrc <> 0 OR rs_planner-dispo IS INITIAL.
      CLEAR rs_planner.
      RETURN.
    ENDIF.

    " the code on its own is worth having even where nobody filled the rest
    " in: a planner who knows the controller can find the person
    SELECT SINGLE dsnam, dstel
      FROM t024d
      WHERE werks = @iv_werks
        AND dispo = @rs_planner-dispo
      INTO ( @rs_planner-name, @rs_planner-phone ).
    IF sy-subrc <> 0.
      CLEAR rs_planner-name.
      CLEAR rs_planner-phone.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
