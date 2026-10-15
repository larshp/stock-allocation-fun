CLASS zcl_alloc_return_escalate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_case,
             case_id TYPE string,
             level   TYPE i,
           END OF ty_case.

    METHODS escalate
      IMPORTING
        is_case        TYPE ty_case
      RETURNING
        VALUE(rs_case) TYPE ty_case.

    METHODS level_of
      IMPORTING
        is_case         TYPE ty_case
      RETURNING
        VALUE(rv_level) TYPE i.

    METHODS is_escalated
      IMPORTING
        is_case      TYPE ty_case
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_escalate IMPLEMENTATION.

  METHOD escalate.
    " Each escalation moves the case one level up, up to the top level of three.
    rs_case = is_case.

    IF is_case-level < 0 OR is_case-level >= 3.
      RETURN.
    ENDIF.

    rs_case-level = is_case-level + 1.
  ENDMETHOD.

  METHOD level_of.
    rv_level = is_case-level.
  ENDMETHOD.

  METHOD is_escalated.
    rv_ok = xsdbool( is_case-level > 0 ).
  ENDMETHOD.

ENDCLASS.
