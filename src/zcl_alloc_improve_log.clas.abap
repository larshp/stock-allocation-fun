CLASS zcl_alloc_improve_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             step        TYPE i,
             description TYPE string,
             score       TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        iv_description TYPE string
        iv_score       TYPE i
      RETURNING
        VALUE(rv_step) TYPE i.

    METHODS best
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS first
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS gain
      RETURNING
        VALUE(rv_gain) TYPE i.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS reset.

  PRIVATE SECTION.
    DATA mt_entry TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_improve_log IMPLEMENTATION.

  METHOD add.
    DATA ls_entry TYPE ty_entry.

    ls_entry-step = lines( mt_entry ) + 1.
    ls_entry-description = iv_description.
    ls_entry-score = iv_score.
    APPEND ls_entry TO mt_entry.

    rv_step = ls_entry-step.
  ENDMETHOD.

  METHOD best.
    LOOP AT mt_entry INTO DATA(ls_entry).
      IF sy-tabix = 1 OR ls_entry-score > rs_entry-score.
        rs_entry = ls_entry.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD first.
    READ TABLE mt_entry INTO rs_entry INDEX 1.
  ENDMETHOD.

  METHOD gain.
    DATA ls_best TYPE ty_entry.

    ls_best = best( ).
    READ TABLE mt_entry INTO DATA(ls_first) INDEX 1.

    rv_gain = ls_best-score - ls_first-score.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entry ).
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entry.
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entry.
  ENDMETHOD.

ENDCLASS.
