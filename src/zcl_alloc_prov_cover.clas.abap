CLASS zcl_alloc_prov_cover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS coverage_percent
      IMPORTING
        iv_provision      TYPE i
        iv_requirement    TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_covered
      IMPORTING
        iv_provision   TYPE i
        iv_requirement TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS shortfall
      IMPORTING
        iv_provision    TYPE i
        iv_requirement  TYPE i
      RETURNING
        VALUE(rv_short) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prov_cover IMPLEMENTATION.

  METHOD coverage_percent.
    " Coverage is the provision related to what is required.
    IF iv_requirement <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_provision * 100 DIV iv_requirement.
  ENDMETHOD.

  METHOD is_covered.
    " The requirement is covered once the provision reaches it.
    rv_ok = xsdbool( iv_provision >= iv_requirement ).
  ENDMETHOD.

  METHOD shortfall.
    " The shortfall is what the provision still owes the requirement.
    IF iv_provision >= iv_requirement.
      RETURN.
    ENDIF.

    rv_short = iv_requirement - iv_provision.
  ENDMETHOD.

ENDCLASS.
