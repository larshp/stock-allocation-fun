INTERFACE zif_allocation_history_store PUBLIC.
  TYPES:
    BEGIN OF ty_result,
      is_success    TYPE abap_bool,
      affected_rows TYPE i,
      message       TYPE string,
    END OF ty_result.

  METHODS remove_before
    IMPORTING
      iv_cutoff_date   TYPE d
      iv_simulation    TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
