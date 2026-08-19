CLASS cl_stub_enqueue DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Take the lock for a material in a plant</p>
    "!
    "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
    "! @parameter rv_granted | <p class="shorttext synchronized">False if somebody else holds it</p>
    CLASS-METHODS acquire
      IMPORTING
        iv_matnr          TYPE marc-matnr
        iv_werks          TYPE marc-werks
      RETURNING
        VALUE(rv_granted) TYPE abap_bool.

    "! <p class="shorttext synchronized">Give the lock back</p>
    "!
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    CLASS-METHODS release
      IMPORTING
        iv_matnr TYPE marc-matnr
        iv_werks TYPE marc-werks.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_lock,
        matnr TYPE marc-matnr,
        werks TYPE marc-werks,
      END OF ty_lock.

    CLASS-DATA gt_lock TYPE SORTED TABLE OF ty_lock WITH UNIQUE KEY matnr werks.

ENDCLASS.


CLASS cl_stub_enqueue IMPLEMENTATION.

  METHOD acquire.

    DATA ls_lock TYPE ty_lock.

    ls_lock = VALUE #(
      matnr = iv_matnr
      werks = iv_werks ).

    IF line_exists( gt_lock[ matnr = iv_matnr werks = iv_werks ] ).
      rv_granted = abap_false.
      RETURN.
    ENDIF.

    INSERT ls_lock INTO TABLE gt_lock.
    rv_granted = abap_true.

  ENDMETHOD.

  METHOD release.

    DELETE gt_lock WHERE matnr = iv_matnr
                     AND werks = iv_werks.

  ENDMETHOD.

ENDCLASS.
