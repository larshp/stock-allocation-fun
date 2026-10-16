CLASS zcl_alloc_gov_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS entry
      IMPORTING
        iv_action       TYPE string
        iv_user         TYPE string
      RETURNING
        VALUE(rv_entry) TYPE string.

    METHODS entry_count
      IMPORTING
        it_entries      TYPE ty_entry_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_complete
      IMPORTING
        it_entries   TYPE ty_entry_tt
        iv_expected  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_gov_audit IMPLEMENTATION.

  METHOD entry.
    " An audit entry carries the user and what they did.
    rv_entry = |{ iv_user }: { iv_action }|.
  ENDMETHOD.

  METHOD entry_count.
    rv_count = lines( it_entries ).
  ENDMETHOD.

  METHOD is_complete.
    " The trail is complete once it holds as many entries as expected.
    rv_ok = xsdbool( entry_count( it_entries ) >= iv_expected ).
  ENDMETHOD.

ENDCLASS.
