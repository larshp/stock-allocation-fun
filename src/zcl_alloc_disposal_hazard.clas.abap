CLASS zcl_alloc_disposal_hazard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS class_of
      IMPORTING
        iv_code         TYPE string
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS is_hazardous
      IMPORTING
        iv_class     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS needs_approval
      IMPORTING
        iv_class     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_disposal_hazard IMPLEMENTATION.

  METHOD class_of.
    " Known hazard codes map to their class; an empty code is not hazardous and
    " anything else falls into the miscellaneous class.
    IF iv_code IS INITIAL.
      rv_class = 'NONE'.
    ELSEIF iv_code = 'FLAMMABLE'.
      rv_class = 'HAZ_3'.
    ELSEIF iv_code = 'TOXIC'.
      rv_class = 'HAZ_6'.
    ELSEIF iv_code = 'CORROSIVE'.
      rv_class = 'HAZ_8'.
    ELSE.
      rv_class = 'HAZ_9'.
    ENDIF.
  ENDMETHOD.

  METHOD is_hazardous.
    rv_ok = xsdbool( iv_class IS NOT INITIAL AND iv_class <> 'NONE' ).
  ENDMETHOD.

  METHOD needs_approval.
    " The toxic and corrosive classes need a second signature before disposal.
    rv_ok = xsdbool( iv_class = 'HAZ_6' OR iv_class = 'HAZ_8' ).
  ENDMETHOD.

ENDCLASS.
