CLASS zcl_alloc_aisle_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             aisle    TYPE i,
             used     TYPE i,
             capacity TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_aisle,
             aisle       TYPE i,
             used        TYPE i,
             capacity    TYPE i,
             utilisation TYPE i,
           END OF ty_aisle.
    TYPES ty_aisle_tt TYPE STANDARD TABLE OF ty_aisle WITH DEFAULT KEY.

    METHODS analyse
      IMPORTING
        it_bins          TYPE ty_bin_tt
      RETURNING
        VALUE(rt_aisles) TYPE ty_aisle_tt.

ENDCLASS.


CLASS zcl_alloc_aisle_util IMPLEMENTATION.

  METHOD analyse.
    DATA ls_aisle TYPE ty_aisle.
    DATA lt_work  TYPE HASHED TABLE OF ty_aisle WITH UNIQUE KEY aisle.

    " A hashed working table keeps the per-aisle aggregation one lookup per bin
    " instead of a rescan of the aisle list.
    LOOP AT it_bins INTO DATA(ls_bin).
      READ TABLE lt_work ASSIGNING FIELD-SYMBOL(<ls_work>)
        WITH KEY aisle = ls_bin-aisle.

      IF sy-subrc = 0.
        <ls_work>-used = <ls_work>-used + ls_bin-used.
        <ls_work>-capacity = <ls_work>-capacity + ls_bin-capacity.
      ELSE.
        INSERT VALUE #( aisle    = ls_bin-aisle
                        used     = ls_bin-used
                        capacity = ls_bin-capacity ) INTO TABLE lt_work.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_work INTO DATA(ls_work).
      CLEAR ls_aisle.
      ls_aisle = ls_work.
      IF ls_aisle-capacity > 0 AND ls_aisle-used > 0.
        ls_aisle-utilisation = ls_aisle-used * 100 DIV ls_aisle-capacity.
      ENDIF.

      APPEND ls_aisle TO rt_aisles.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
