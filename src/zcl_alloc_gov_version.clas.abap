CLASS zcl_alloc_gov_version DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS version
      IMPORTING
        iv_major          TYPE i
        iv_minor          TYPE i
      RETURNING
        VALUE(rv_version) TYPE i.

    METHODS is_newer
      IMPORTING
        iv_version_a TYPE i
        iv_version_b TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_version_a    TYPE i
        iv_version_b    TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_version IMPLEMENTATION.

  METHOD version.
    " A version number is the major part in the hundreds plus the minor part.
    rv_version = iv_major * 100 + iv_minor.
  ENDMETHOD.

  METHOD is_newer.
    " The first version is newer once it carries the higher number.
    rv_ok = xsdbool( iv_version_a > iv_version_b ).
  ENDMETHOD.

  METHOD delta.
    " The move from one version to the next.
    rv_delta = iv_version_a - iv_version_b.
  ENDMETHOD.

ENDCLASS.
