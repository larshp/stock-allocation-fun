CLASS zcl_alloc_bom_level DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS level_of
      IMPORTING
        iv_depth        TYPE i
      RETURNING
        VALUE(rv_level) TYPE i.

    METHODS is_top
      IMPORTING
        iv_level     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS depth
      IMPORTING
        iv_level        TYPE i
      RETURNING
        VALUE(rv_depth) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_level IMPLEMENTATION.

  METHOD level_of.
    " A level is one more than its depth.
    rv_level = iv_depth + 1.
    IF rv_level < 1.
      rv_level = 1.
    ENDIF.
  ENDMETHOD.

  METHOD is_top.
    " The top level is the first one.
    rv_ok = xsdbool( iv_level = 1 ).
  ENDMETHOD.

  METHOD depth.
    " The depth is the level less one, with the top at zero.
    rv_depth = iv_level - 1.
    IF rv_depth < 0.
      rv_depth = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
