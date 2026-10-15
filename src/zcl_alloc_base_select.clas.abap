CLASS zcl_alloc_base_select DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS choose
      IMPORTING
        iv_direct      TYPE i
        iv_indirect    TYPE i
      RETURNING
        VALUE(rv_base) TYPE string.

    METHODS is_direct
      IMPORTING
        iv_base      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_base          TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_base_select IMPLEMENTATION.

  METHOD choose.
    " The bigger base is the one to allocate on.
    IF iv_direct >= iv_indirect AND iv_direct > 0.
      rv_base = 'DIRECT'.
    ELSEIF iv_indirect > 0.
      rv_base = 'INDIRECT'.
    ELSE.
      rv_base = 'NONE'.
    ENDIF.
  ENDMETHOD.

  METHOD is_direct.
    " A direct base is traceable to the cost object.
    rv_ok = xsdbool( iv_base = 'DIRECT' ).
  ENDMETHOD.

  METHOD reason.
    " Each base carries the reason it was chosen.
    CASE iv_base.
      WHEN 'DIRECT'.
        rv_reason = 'traceable'.
      WHEN 'INDIRECT'.
        rv_reason = 'apportioned'.
      WHEN OTHERS.
        rv_reason = 'unassigned'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
