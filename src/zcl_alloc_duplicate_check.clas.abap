CLASS zcl_alloc_duplicate_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_dup,
             id    TYPE zif_requirement_reader=>ty_requirement-id,
             count TYPE i,
           END OF ty_dup.
    TYPES ty_dup_tt TYPE STANDARD TABLE OF ty_dup WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_requirements TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_dups)  TYPE ty_dup_tt.

ENDCLASS.


CLASS zcl_alloc_duplicate_check IMPLEMENTATION.

  METHOD find.
    DATA lt_sorted  TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA ls_dup     TYPE ty_dup.
    DATA lv_started TYPE abap_bool.

    lt_sorted = it_requirements.
    SORT lt_sorted BY id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      IF lv_started = abap_false OR ls_requirement-id <> ls_dup-id.
        IF lv_started = abap_true AND ls_dup-count > 1.
          APPEND ls_dup TO rt_dups.
        ENDIF.
        CLEAR ls_dup.
        ls_dup-id = ls_requirement-id.
        lv_started = abap_true.
      ENDIF.

      ls_dup-count = ls_dup-count + 1.
    ENDLOOP.

    IF lv_started = abap_true AND ls_dup-count > 1.
      APPEND ls_dup TO rt_dups.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
