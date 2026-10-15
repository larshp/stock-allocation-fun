CLASS zcl_alloc_return_recon DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_pair,
             authorised TYPE menge_d,
             received   TYPE menge_d,
           END OF ty_pair.
    TYPES ty_pair_tt TYPE STANDARD TABLE OF ty_pair WITH DEFAULT KEY.

    METHODS difference
      IMPORTING
        it_pairs       TYPE ty_pair_tt
      RETURNING
        VALUE(rv_diff) TYPE menge_d.

    METHODS is_complete
      IMPORTING
        it_pairs     TYPE ty_pair_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS mismatch_count
      IMPORTING
        it_pairs        TYPE ty_pair_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_recon IMPLEMENTATION.

  METHOD difference.
    LOOP AT it_pairs INTO DATA(ls_pair).
      rv_diff = rv_diff + ls_pair-received - ls_pair-authorised.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_complete.
    " An empty list is complete. The first mismatch stops the scan.
    rv_ok = abap_true.

    LOOP AT it_pairs INTO DATA(ls_pair).
      IF ls_pair-received <> ls_pair-authorised.
        rv_ok = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD mismatch_count.
    LOOP AT it_pairs INTO DATA(ls_pair).
      IF ls_pair-received <> ls_pair-authorised.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
